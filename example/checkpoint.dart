import 'dart:convert';
import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final agent = TabularAgent<int, GridAction>(seed: 42);
  for (var i = 0; i < 100; i++) {
    trainEpisode(environment: GridWorld(), agent: agent, maxSteps: 200);
  }
  final saved = jsonEncode(TrainingCheckpoint.tabular(agent,
      encodeState: (state) => state,
      encodeAction: (action) => action.name).toJson());
  final checkpoint =
      TrainingCheckpoint.fromJson(jsonDecode(saved) as Map<String, dynamic>);
  final restored = checkpoint.restoreTabular<int, GridAction>(
      decodeState: (value) => value as int,
      decodeAction: (value) => GridAction.values.byName(value as String),
      seed: 99);
  if (restored.epsilon != agent.epsilon) throw StateError('Lost schedule');
  for (var i = 0; i < 400; i++) {
    trainEpisode(environment: GridWorld(), agent: restored, maxSteps: 200);
  }
  final result = evaluatePolicy<int, GridAction>(
      environmentFactory: GridWorld.new,
      policy: GreedyPolicy(restored.values),
      isSuccess: (state, episode) => episode.terminated && state == 24,
      episodes: 20,
      maxSteps: 100,
      seed: 7);
  if (result.successRate != 1) throw StateError('Resume did not learn maze');
  print('Checkpoint restored; new RNG stream; '
      'success ${result.successRate}, mean steps ${result.meanSteps}.');
}
