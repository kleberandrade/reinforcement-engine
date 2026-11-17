import '../contracts/continuing_agent.dart';
import '../contracts/exploration_policy.dart';
import '../policies/epsilon_greedy.dart';
import '../policies/greedy_candidates.dart';
import '../values/q_table.dart';
import '../values/projected_action_values.dart';
import 'agent_behavior.dart';
import 'agent_validation.dart';

/// Undiscounted R-learning for continuing tasks, with a relative value table
/// and average-reward estimate. Greedy gating and reward-estimate maxima are
/// evaluated after the relative-value update, including self-loop transitions.
final class RLearningAgent<S, A> implements ContinuingAgent<S, A> {
  RLearningAgent(
      {this.learningRate = 0.1,
      this.averageRewardRate = 0.01,
      double initialAverageReward = 0,
      double epsilon = 1,
      this.epsilonDecay = 0.995,
      this.minEpsilon = 0.01,
      int? seed,
      QTable<S, A>? table,
      ExplorationPolicy<S, A>? explorationPolicy})
      : table = table ?? QTable<S, A>(),
        _averageReward = initialAverageReward,
        explorationPolicy = explorationPolicy ?? EpsilonGreedy<S, A>() {
    validateUnit(learningRate, 'learningRate', allowZero: false);
    validateUnit(averageRewardRate, 'averageRewardRate', allowZero: false);
    if (!initialAverageReward.isFinite) {
      throw ArgumentError.value(initialAverageReward, 'initialAverageReward');
    }
    _behavior = AgentBehavior(
        values: this.table,
        policy: this.explorationPolicy,
        epsilon: epsilon,
        epsilonDecay: epsilonDecay,
        minEpsilon: minEpsilon,
        seed: seed);
  }
  final double learningRate;
  final double averageRewardRate;
  final double epsilonDecay;
  final double minEpsilon;
  final QTable<S, A> table;
  final ExplorationPolicy<S, A> explorationPolicy;
  late final AgentBehavior<S, A> _behavior;
  double _averageReward;
  double get averageReward => _averageReward;

  @override
  QTable<S, A> get values => table;
  @override
  double get epsilon => _behavior.epsilon;
  @override
  A selectAction(S state, List<A> actions, {bool explore = true}) =>
      _behavior.selectAction(state, actions, explore: explore);

  @override
  double update(
      {required S state,
      required A action,
      required List<A> actions,
      required double reward,
      required S nextState,
      required List<A> nextActions}) {
    if (!reward.isFinite) throw ArgumentError.value(reward, 'reward');
    if (actions.isEmpty || nextActions.isEmpty || !actions.contains(action)) {
      throw ArgumentError('Expected a legal action and nonempty action lists');
    }
    final nextGreedy = greedyCandidates(nextState, nextActions, table).first;
    final old = table.value(state, action);
    final updated = old +
        learningRate *
            (reward -
                _averageReward +
                table.value(nextState, nextGreedy) -
                old);
    if (!updated.isFinite) throw ArgumentError.value(updated, 'updated value');
    // Compute the post-update maxima through a temporary read-only projection,
    // so invalid arithmetic cannot partially commit the table or reward estimate.
    final projected = ProjectedActionValues(table, state, action, updated);
    final currentGreedy = greedyCandidates(state, actions, projected);
    var average = _averageReward;
    if (currentGreedy.contains(action)) {
      final projectedNext =
          greedyCandidates(nextState, nextActions, projected).first;
      average += averageRewardRate *
          (reward -
              average +
              projected.value(nextState, projectedNext) -
              projected.value(state, currentGreedy.first));
      if (!average.isFinite) {
        throw ArgumentError.value(average, 'averageReward');
      }
    }
    table.set(state, action, updated);
    _averageReward = average;
    return updated;
  }

  /// Optional caller-controlled decay. Continuing windows never decay implicitly.
  void decayExploration() => _behavior.decayExploration();
}
