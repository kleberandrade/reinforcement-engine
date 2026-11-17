import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final agent = WatkinsQLambdaAgent<int, GridAction>(
      lambda: 0.8, learningRate: 0.1, seed: 42);
  final maze = GridWorld();
  for (var episode = 0; episode < 500; episode++) {
    trainEpisodic(environment: maze, agent: agent, maxSteps: 200);
    if (agent.traceCount != 0) throw StateError('Episode traces leaked');
  }
  final result = evaluatePolicy<int, GridAction>(
      environmentFactory: GridWorld.new,
      policy: GreedyPolicy(agent.values),
      isSuccess: (state, result) => result.terminated && state == maze.goal,
      episodes: 20,
      maxSteps: 100,
      seed: 7);
  if (result.successRate != 1 || (result.meanSteps - 8).abs() > 1e-9) {
    throw StateError('Watkins did not learn the shortest maze route');
  }
  print('Watkins Q(lambda): ${(result.successRate * 100).round()}% success, '
      '${result.meanSteps.toStringAsFixed(1)} steps; no retained episode traces.');
}
