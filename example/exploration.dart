import 'dart:math';
import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final table = QTable<int, int>()
    ..set(0, 0, 10000)
    ..set(0, 1, 9999)
    ..set(0, 2, 9998);
  final policies = <String, ExplorationPolicy<int, int>>{
    'epsilon-greedy': const EpsilonGreedy(),
    'softmax': SoftmaxExploration(temperature: 1),
  };
  for (final entry in policies.entries) {
    final probabilities = entry.value.probabilities(
        state: 0, actions: [0, 1, 2], values: table, epsilon: 0.3);
    if ((probabilities.reduce((a, b) => a + b) - 1).abs() > 1e-10) {
      throw StateError('Invalid exploration distribution');
    }
    final random = Random(42);
    final counts = [0, 0, 0];
    for (var i = 0; i < 1000; i++) {
      counts[entry.value.selectAction(
          state: 0,
          actions: [0, 1, 2],
          values: table,
          epsilon: 0.3,
          random: random)]++;
    }
    print('${entry.key}: probabilities=$probabilities, counts=$counts');
  }
}
