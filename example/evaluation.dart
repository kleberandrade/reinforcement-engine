import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final agents = <String, LearningAgent<int, GridAction>>{
    for (final algorithm in LearningAlgorithm.values)
      algorithm.name: TabularAgent<int, GridAction>(
          algorithm: algorithm,
          learningRate: 0.5,
          discountFactor: 1,
          epsilon: 0.1,
          epsilonDecay: 1,
          minEpsilon: 0.1,
          seed: 42),
    'doubleQ': DoubleQAgent<int, GridAction>(
        learningRate: 0.5,
        discountFactor: 1,
        epsilon: 0.1,
        epsilonDecay: 1,
        minEpsilon: 0.1,
        seed: 42),
  };
  for (final entry in agents.entries) {
    final environment = CliffWalking();
    final agent = entry.value;
    for (var episode = 0; episode < 2000; episode++) {
      trainEpisode(environment: environment, agent: agent, maxSteps: 1000);
    }
    final report = evaluatePolicy<int, GridAction>(
      environmentFactory: CliffWalking.new,
      policy: GreedyPolicy(agent.values),
      isSuccess: (state, episode) =>
          episode.terminated && state == environment.goal,
      episodes: 100,
      maxSteps: 100,
      seed: 7,
    );
    if (report.successRate != 1) throw StateError('Cliff policy failed');
    print('${entry.key}: success=${report.successRate}, '
        'return=${report.meanReward.toStringAsFixed(1)}, '
        'steps=${report.meanSteps.toStringAsFixed(1)}');
  }
}
