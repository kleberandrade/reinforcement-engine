import '../contracts/action_values.dart';
import '../contracts/exploration_policy.dart';
import '../contracts/learning_agent.dart';
import '../policies/epsilon_greedy.dart';
import '../policies/greedy_policy.dart';
import '../values/q_table.dart';
import '../values/sum_action_values.dart';
import 'agent_behavior.dart';
import 'agent_validation.dart';

/// Double Q-Learning with independent estimators and behavior based on their sum.
/// Each transition randomly updates one estimator, selecting the bootstrap action
/// with that estimator and evaluating it with the other. Evaluation uses [values].
final class DoubleQAgent<S, A> implements LearningAgent<S, A> {
  DoubleQAgent(
      {this.learningRate = 0.1,
      this.discountFactor = 0.99,
      double epsilon = 1,
      this.epsilonDecay = 0.995,
      this.minEpsilon = 0.01,
      int? seed,
      QTable<S, A>? tableA,
      QTable<S, A>? tableB,
      ExplorationPolicy<S, A>? explorationPolicy})
      : tableA = tableA ?? QTable<S, A>(),
        tableB = tableB ?? QTable<S, A>(),
        explorationPolicy = explorationPolicy ?? EpsilonGreedy<S, A>() {
    if (identical(this.tableA, this.tableB)) {
      throw ArgumentError('Double Q requires independent tables');
    }
    validateUnit(learningRate, 'learningRate', allowZero: false);
    validateUnit(discountFactor, 'discountFactor');
    _values = SumActionValues(this.tableA, this.tableB);
    _behavior = AgentBehavior(
        values: values,
        policy: this.explorationPolicy,
        epsilon: epsilon,
        epsilonDecay: epsilonDecay,
        minEpsilon: minEpsilon,
        seed: seed);
  }

  final double learningRate;
  final double discountFactor;
  final double epsilonDecay;
  final double minEpsilon;
  final QTable<S, A> tableA;
  final QTable<S, A> tableB;
  final ExplorationPolicy<S, A> explorationPolicy;
  late final AgentBehavior<S, A> _behavior;

  @override
  ActionValues<S, A> get values => _values;
  late final ActionValues<S, A> _values;
  @override
  double get epsilon => _behavior.epsilon;
  @override
  bool get requiresNextAction => false;

  @override
  A selectAction(S state, List<A> actions, {bool explore = true}) =>
      _behavior.selectAction(state, actions, explore: explore);

  /// Returns the newly written value in the single estimator chosen this step.
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
    if (!terminated && nextActions.isEmpty) {
      throw ArgumentError('No next actions');
    }
    final updateA = _behavior.random.nextBool();
    final primary = updateA ? tableA : tableB;
    final other = updateA ? tableB : tableA;
    var bootstrap = 0.0;
    if (!terminated) {
      final selected = GreedyPolicy(primary)
          .selectAction(nextState, nextActions, _behavior.random);
      bootstrap = other.value(nextState, selected);
    }
    final old = primary.value(state, action);
    final updated =
        old + learningRate * (reward + discountFactor * bootstrap - old);
    primary.set(state, action, updated);
    return updated;
  }

  @override
  void decayExploration() => _behavior.decayExploration();
}
