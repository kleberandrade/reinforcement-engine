import 'dart:math';
import '../contracts/action_values.dart';
import '../contracts/exploration_policy.dart';
import '../policies/greedy_policy.dart';
import 'agent_validation.dart';

/// Per-agent RNG, exploration schedule and shared action selection lifecycle.
final class AgentBehavior<S, A> {
  AgentBehavior(
      {required this.values,
      required this.policy,
      required double epsilon,
      required this.epsilonDecay,
      required this.minEpsilon,
      int? seed})
      : _epsilon = epsilon,
        random = Random(seed) {
    validateUnit(epsilon, 'epsilon');
    validateUnit(epsilonDecay, 'epsilonDecay', allowZero: false);
    validateUnit(minEpsilon, 'minEpsilon');
    if (minEpsilon > epsilon) throw ArgumentError('minEpsilon exceeds epsilon');
  }
  final ActionValues<S, A> values;
  final ExplorationPolicy<S, A> policy;
  final double epsilonDecay;
  final double minEpsilon;
  final Random random;
  double _epsilon;
  double get epsilon => _epsilon;

  A selectAction(S state, List<A> actions, {bool explore = true}) {
    if (actions.isEmpty) throw ArgumentError('No available actions');
    final action = explore
        ? policy.selectAction(
            state: state,
            actions: actions,
            values: values,
            epsilon: _epsilon,
            random: random)
        : GreedyPolicy(values).selectAction(state, actions, random);
    if (!actions.contains(action)) {
      throw ArgumentError('Policy returned illegal action');
    }
    return action;
  }

  List<double> probabilities(S state, List<A> actions) => policy.probabilities(
      state: state, actions: actions, values: values, epsilon: _epsilon);

  void decayExploration() =>
      _epsilon = max(minEpsilon, _epsilon * epsilonDecay);
}
