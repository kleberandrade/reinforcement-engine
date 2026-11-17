import 'dart:math';

import '../contracts/td_update_rule.dart';
import '../domain/learning_algorithm.dart';
import '../algorithms/q_learning.dart';
import '../algorithms/sarsa.dart';
import '../values/q_table.dart';
import '../policies/greedy_policy.dart';

/// Epsilon-greedy tabular learner. Supply the same seed and call order to
/// reproduce a run within the same Dart runtime and environment.
class TabularAgent<S, A> {
  TabularAgent(
      {this.algorithm = LearningAlgorithm.qLearning,
      TdUpdateRule<S, A>? updateRule,
      this.learningRate = 0.1,
      this.discountFactor = 0.99,
      double epsilon = 1,
      this.epsilonDecay = 0.995,
      this.minEpsilon = 0.01,
      int? seed,
      QTable<S, A>? table})
      : updateRule = updateRule ??
            (algorithm == LearningAlgorithm.sarsa
                ? Sarsa<S, A>()
                : QLearning<S, A>()),
        _epsilon = epsilon,
        _random = Random(seed),
        table = table ?? QTable<S, A>() {
    _unit(learningRate, 'learningRate', allowZero: false);
    _unit(discountFactor, 'discountFactor');
    _unit(epsilon, 'epsilon');
    _unit(epsilonDecay, 'epsilonDecay', allowZero: false);
    _unit(minEpsilon, 'minEpsilon');
    if (minEpsilon > epsilon) throw ArgumentError('minEpsilon exceeds epsilon');
  }

  /// Convenience selector used when no explicit update rule is supplied.
  final LearningAlgorithm algorithm;

  /// Effective strategy. An explicit rule takes precedence over [algorithm].
  final TdUpdateRule<S, A> updateRule;

  /// Step size in (0, 1].
  final double learningRate;

  /// Weight of future value in [0, 1].
  final double discountFactor;

  /// Per-episode multiplier in (0, 1].
  final double epsilonDecay;

  /// Lower exploration bound in [0, epsilon].
  final double minEpsilon;
  final QTable<S, A> table;
  final Random _random;
  late final _greedyPolicy = GreedyPolicy<S, A>(table);
  double _epsilon;

  /// Current exploration probability.
  double get epsilon => _epsilon;
  static void _unit(double value, String name, {bool allowZero = true}) {
    if (!value.isFinite ||
        value > 1 ||
        value < 0 ||
        (!allowZero && value == 0)) {
      throw ArgumentError.value(value, name, 'Expected a probability in range');
    }
  }

  /// Randomizes ties to avoid bias toward the first available action.
  A selectAction(S state, List<A> actions, {bool explore = true}) {
    if (actions.isEmpty) throw ArgumentError('No available actions');
    if (explore && _epsilon > 0 && _random.nextDouble() < _epsilon) {
      return actions[_random.nextInt(actions.length)];
    }
    return _greedyPolicy.selectAction(state, actions, _random);
  }

  /// Terminal transitions never bootstrap. For SARSA, pass the actual next
  /// behavior action; for Q-learning, pass all legal next actions.
  double update(
      {required S state,
      required A action,
      required double reward,
      required S nextState,
      required bool terminated,
      List<A> nextActions = const [],
      A? nextAction}) {
    if (!reward.isFinite) throw ArgumentError.value(reward, 'reward');
    var bootstrap = 0.0;
    if (!terminated) {
      if (nextActions.isEmpty) throw ArgumentError('No next actions');
      if (updateRule.requiresNextAction && !nextActions.contains(nextAction)) {
        throw ArgumentError('The update rule requires a legal nextAction');
      }
      bootstrap = updateRule.bootstrap(
        table: table,
        nextState: nextState,
        nextActions: nextActions,
        nextAction: nextAction,
      );
      if (!bootstrap.isFinite) {
        throw ArgumentError.value(
            bootstrap, 'bootstrap', 'Expected finite value');
      }
    }
    final old = table.value(state, action);
    final updated =
        old + learningRate * (reward + discountFactor * bootstrap - old);
    table.set(state, action, updated);
    return updated;
  }

  /// Applies one episode of multiplicative decay with the configured floor.
  void decayExploration() =>
      _epsilon = max(minEpsilon, _epsilon * epsilonDecay);
}
