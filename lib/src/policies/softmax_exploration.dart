import 'dart:math';
import '../contracts/action_values.dart';
import '../contracts/exploration_policy.dart';
import 'probability_validation.dart';

/// Boltzmann exploration with a fixed positive temperature. Epsilon is ignored.
/// Subtracting the maximum before exponentiation prevents positive overflow.
final class SoftmaxExploration<S, A> implements ExplorationPolicy<S, A> {
  SoftmaxExploration({this.temperature = 1}) {
    if (!temperature.isFinite || temperature <= 0) {
      throw ArgumentError.value(temperature, 'temperature');
    }
  }
  final double temperature;

  @override
  List<double> probabilities(
      {required S state,
      required List<A> actions,
      required ActionValues<S, A> values,
      required double epsilon}) {
    if (actions.isEmpty) throw ArgumentError('No available actions');
    final scores =
        actions.map((action) => values.value(state, action)).toList();
    if (scores.any((value) => !value.isFinite)) {
      throw ArgumentError('Action values must be finite');
    }
    final maximum = scores.reduce(max);
    final weights =
        scores.map((value) => exp((value - maximum) / temperature)).toList();
    final total = weights.reduce((a, b) => a + b);
    return List.unmodifiable(weights.map((weight) => weight / total));
  }

  @override
  A selectAction(
          {required S state,
          required List<A> actions,
          required ActionValues<S, A> values,
          required double epsilon,
          required Random random}) =>
      actions[sampleProbability(
          probabilities(
              state: state, actions: actions, values: values, epsilon: epsilon),
          random)];
}
