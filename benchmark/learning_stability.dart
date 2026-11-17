import 'dart:convert';
import 'dart:math';
import 'package:reinforcement_engine/reinforcement_engine.dart';

/// Finite learning-quality experiment, not a throughput benchmark.
/// Full: 10 seeds, 2 episodic tasks, 3 alphas, 4 trace settings, plus
/// 2 continuing tasks, 3 alphas and 3 betas. --smoke reduces training only.
void main(List<String> args) {
  final smoke = args.contains('--smoke');
  final seeds = List.generate(smoke ? 1 : 10, (i) => i);
  final episodes = smoke ? 20 : 400;
  final continuingSteps = smoke ? 200 : 10000;
  final rows = <Map<String, Object?>>[];
  for (final task in ['grid', 'cliff']) {
    for (final alpha in [0.05, 0.1, 0.2]) {
      for (final lambda in [0.0, 0.5, 0.8, 0.95]) {
        for (final seed in seeds) {
          final row = <String, Object?>{
            'family': 'episodic',
            'task': task,
            'alpha': alpha,
            'lambda': lambda,
            'seed': seed,
            'trainingEpisodes': episodes,
          };
          Environment<int, GridAction> environment() =>
              task == 'grid' ? GridWorld() : CliffWalking();
          final base = lambda == 0
              ? TabularAgent<int, GridAction>(
                  algorithm: LearningAlgorithm.sarsa,
                  learningRate: alpha,
                  epsilon: 0.1,
                  epsilonDecay: 1,
                  minEpsilon: 0.1,
                  seed: seed)
              : null;
          final trace = lambda == 0
              ? null
              : SarsaLambdaAgent<int, GridAction>(
                  lambda: lambda,
                  learningRate: alpha,
                  epsilon: 0.1,
                  epsilonDecay: 1,
                  minEpsilon: 0.1,
                  seed: seed);
          final agent = base ?? trace!;
          final training = environment();
          var trainingReward = 0.0;
          var trainingSteps = 0;
          try {
            for (var i = 0; i < episodes; i++) {
              final result = trace == null
                  ? trainEpisode(
                      environment: training, agent: agent, maxSteps: 300)
                  : trainEpisodic(
                      environment: training, agent: trace, maxSteps: 300);
              trainingReward += result.reward;
              trainingSteps += result.steps;
              if (trace != null && trace.traceCount != 0) {
                throw StateError('Eligibility leaked across episode boundary');
              }
            }
            final report = evaluatePolicy<int, GridAction>(
                environmentFactory: environment,
                policy: GreedyPolicy(agent.values),
                isSuccess: (state, result) => result.terminated,
                episodes: 20,
                maxSteps: 200,
                seed: seed + 100000);
            row.addAll({
              'status': 'ok',
              'trainingMeanReward': trainingReward / episodes,
              'trainingSteps': trainingSteps,
              'successRate': report.successRate,
              'meanSteps': report.meanSteps,
              'meanReward': report.meanReward,
              'truncationRate': report.truncationRate
            });
          } on ArgumentError catch (error) {
            row.addAll({
              'status': 'numeric_error',
              'error': error.toString(),
              'completedTrainingSteps': trainingSteps
            });
          }
          rows.add(row);
        }
      }
    }
  }
  for (final noisy in [false, true]) {
    for (final alpha in [0.05, 0.1, 0.2]) {
      for (final beta in [0.001, 0.005, 0.01]) {
        for (final seed in seeds) {
          final row = <String, Object?>{
            'family': 'continuing',
            'task': noisy ? 'noisy_maintenance' : 'maintenance',
            'alpha': alpha,
            'beta': beta,
            'seed': seed,
            'trainingSteps': continuingSteps
          };
          Environment<MachineState, MachineAction> environment(int value) =>
              noisy ? NoisyMaintenance(value) : MaintenanceTask();
          final training = environment(seed + 200000);
          final agent = RLearningAgent<MachineState, MachineAction>(
              learningRate: alpha,
              averageRewardRate: beta,
              epsilon: 0.1,
              minEpsilon: 0.1,
              seed: seed);
          try {
            trainContinuing(
                environment: training,
                agent: agent,
                initialState: training.reset(),
                steps: continuingSteps);
            final evaluation = environment(seed + 300000);
            final random = Random(seed + 400000);
            final policy = GreedyPolicy(agent.values);
            var state = evaluation.reset();
            var reward = 0.0;
            for (var i = 0; i < 2000; i++) {
              final result = evaluation.step(policy.selectAction(
                  state, evaluation.actions(state), random));
              reward += result.reward;
              state = result.state;
            }
            final readyAction = policy.selectAction(
                MachineState.ready, MachineAction.values, random);
            final wornAction = policy.selectAction(
                MachineState.worn, MachineAction.values, random);
            row.addAll({
              'status': 'ok',
              'meanReward': reward / 2000,
              'rho': agent.averageReward,
              'rhoError': (agent.averageReward - 1.5).abs(),
              'optimalPolicy': readyAction == MachineAction.work &&
                  wornAction == MachineAction.service
            });
          } on ArgumentError catch (error) {
            row.addAll({'status': 'numeric_error', 'error': error.toString()});
          }
          rows.add(row);
        }
      }
    }
  }
  print(jsonEncode({
    'protocol': 'learning-stability-v1',
    'smoke': smoke,
    'discount': 0.99,
    'epsilon': 0.1,
    'episodicStepLimit': 300,
    'evaluationEpisodes': 20,
    'evaluationStepLimit': 200,
    'continuingEvaluationSteps': 2000,
    'records': rows
  }));
}

/// Deterministic transitions plus independently seeded, zero-mean reward noise.
final class NoisyMaintenance
    implements Environment<MachineState, MachineAction> {
  NoisyMaintenance(int seed) : random = Random(seed);
  final Random random;
  final MaintenanceTask task = MaintenanceTask();
  @override
  MachineState reset() => task.reset();
  @override
  List<MachineAction> actions(MachineState state) => task.actions(state);
  @override
  StepResult<MachineState> step(MachineAction action) {
    final result = task.step(action);
    return StepResult(
        state: result.state,
        reward: result.reward + (random.nextDouble() - 0.5) * 0.4);
  }
}
