import 'dart:math';
import '../contracts/action_values.dart';
import '../contracts/exploration_policy.dart';
import 'greedy_candidates.dart';
import 'greedy_policy.dart';

/// Uniform epsilon exploration and uniformly randomized greedy ties.
final class EpsilonGreedy<S, A> implements ExplorationPolicy<S, A> {
  const EpsilonGreedy();

  void _validate(double epsilon, List<A> actions) {
    if (actions.isEmpty || !epsilon.isFinite || epsilon < 0 || epsilon > 1) {
      throw ArgumentError('Expected legal actions and epsilon in [0, 1]');
    }
  }

  @override
  A selectAction(
      {required S state,
      required List<A> actions,
      required ActionValues<S, A> values,
      required double epsilon,
      required Random random}) {
    _validate(epsilon, actions);
    // Preserve the original agent's seeded call order, including epsilon zero.
    if (epsilon > 0 && random.nextDouble() < epsilon) {
      return actions[random.nextInt(actions.length)];
    }
    return GreedyPolicy(values).selectAction(state, actions, random);
  }

  @override
  List<double> probabilities(
      {required S state,
      required List<A> actions,
      required ActionValues<S, A> values,
      required double epsilon}) {
    _validate(epsilon, actions);
    final candidates = greedyCandidates(state, actions, values);
    return List.unmodifiable([
      for (final action in actions)
        epsilon / actions.length +
            (candidates.contains(action)
                ? (1 - epsilon) / candidates.length
                : 0),
    ]);
  }
}
