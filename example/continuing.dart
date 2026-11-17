import 'dart:math';
import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final environment = MaintenanceTask();
  final agent = RLearningAgent<MachineState, MachineAction>(
      learningRate: 0.1,
      averageRewardRate: 0.005,
      epsilon: 0.1,
      minEpsilon: 0.1,
      seed: 42);
  var state = environment.reset();
  for (var window = 0; window < 100; window++) {
    final result = trainContinuing(
        environment: environment,
        agent: agent,
        initialState: state,
        steps: 200);
    state = result.finalState;
  }
  // Evaluate in a fresh environment with a separate random source.
  final evaluation = MaintenanceTask();
  final policy = GreedyPolicy(agent.values);
  final random = Random(7);
  state = evaluation.reset();
  var reward = 0.0;
  for (var i = 0; i < 1000; i++) {
    final result = evaluation
        .step(policy.selectAction(state, evaluation.actions(state), random));
    state = result.state;
    reward += result.reward;
  }
  final mean = reward / 1000;
  if ((mean - 1.5).abs() > 1e-12) throw StateError('Maintenance policy failed');
  print(
      'R-learning: rho=${agent.averageReward.toStringAsFixed(3)}, greedy mean=$mean');
}
