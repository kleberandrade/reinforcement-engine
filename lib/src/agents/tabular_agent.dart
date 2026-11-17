import '../contracts/td_update_rule.dart';
import '../domain/learning_algorithm.dart';
import '../algorithms/q_learning.dart';
import '../algorithms/sarsa.dart';
import '../values/q_table.dart';
import '../contracts/learning_agent.dart';
import '../contracts/exploration_policy.dart';
import '../policies/epsilon_greedy.dart';
import '../algorithms/expected_sarsa.dart';
import 'agent_behavior.dart';
import 'agent_validation.dart';

/// Tabular learner with composable update and exploration strategies.
/// Supply the same seed and call order to
/// reproduce a run within the same Dart runtime and environment.
class TabularAgent<S, A> implements LearningAgent<S, A> {
  TabularAgent(
      {this.algorithm = LearningAlgorithm.qLearning,
      TdUpdateRule<S, A>? updateRule,
      ExplorationPolicy<S, A>? explorationPolicy,
      this.learningRate = 0.1,
      this.discountFactor = 0.99,
      double epsilon = 1,
      this.epsilonDecay = 0.995,
      this.minEpsilon = 0.01,
      int? seed,
      QTable<S, A>? table})
      : explorationPolicy = explorationPolicy ?? EpsilonGreedy<S, A>(),
        table = table ?? QTable<S, A>() {
    validateUnit(learningRate, 'learningRate', allowZero: false);
    validateUnit(discountFactor, 'discountFactor');
    _behavior = AgentBehavior(
        values: this.table,
        policy: this.explorationPolicy,
        epsilon: epsilon,
        epsilonDecay: epsilonDecay,
        minEpsilon: minEpsilon,
        seed: seed);
    _updateRule = updateRule ??
        switch (algorithm) {
          LearningAlgorithm.qLearning => QLearning<S, A>(),
          LearningAlgorithm.sarsa => Sarsa<S, A>(),
          LearningAlgorithm.expectedSarsa =>
            ExpectedSarsa<S, A>(probabilities: _behavior.probabilities),
        };
  }

  /// Convenience selector used when no explicit update rule is supplied.
  final LearningAlgorithm algorithm;

  /// Effective strategy. An explicit rule takes precedence over [algorithm].
  TdUpdateRule<S, A> get updateRule => _updateRule;
  late final TdUpdateRule<S, A> _updateRule;

  final ExplorationPolicy<S, A> explorationPolicy;

  /// Step size in (0, 1].
  final double learningRate;

  /// Weight of future value in [0, 1].
  final double discountFactor;

  /// Per-episode multiplier in (0, 1].
  final double epsilonDecay;

  /// Lower exploration bound in [0, epsilon].
  final double minEpsilon;
  final QTable<S, A> table;
  late final AgentBehavior<S, A> _behavior;

  @override
  QTable<S, A> get values => table;

  @override
  bool get requiresNextAction => updateRule.requiresNextAction;

  /// Current exploration schedule value. Softmax uses its own temperature.
  @override
  double get epsilon => _behavior.epsilon;

  /// Selects with the configured behavior policy, or greedy when not exploring.
  @override
  A selectAction(S state, List<A> actions, {bool explore = true}) =>
      _behavior.selectAction(state, actions, explore: explore);

  /// Terminal transitions never bootstrap. For SARSA, pass the actual next
  /// behavior action; for Q-learning, pass all legal next actions.
  @override
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
  @override
  void decayExploration() => _behavior.decayExploration();
}
