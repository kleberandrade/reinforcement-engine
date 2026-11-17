import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final agent = SarsaLambdaAgent<int, GridAction>(
      lambda: 0.8, learningRate: 0.2, seed: 42);
  final environment = GridWorld();
  for (var episode = 0; episode < 500; episode++) {
    trainEpisodic(environment: environment, agent: agent, maxSteps: 200);
  }
  final report = evaluatePolicy<int, GridAction>(
      environmentFactory: GridWorld.new,
      policy: GreedyPolicy(agent.values),
      episodes: 20,
      maxSteps: 100,
      seed: 7,
      isSuccess: (state, result) => result.terminated && state == 24);
  if (report.successRate != 1 ||
      (report.meanSteps - 8).abs() > 1e-10 ||
      agent.traceCount != 0) {
    throw StateError('Trace policy or episode lifecycle failed');
  }
  print(
      'SARSA(lambda): success=${report.successRate}, steps=${report.meanSteps.toStringAsFixed(1)}, active traces=${agent.traceCount}');
}
