import '../contracts/episodic_agent.dart';
import '../contracts/exploration_policy.dart';
import '../policies/epsilon_greedy.dart';
import '../policies/greedy_candidates.dart';
import '../values/q_table.dart';
import 'agent_behavior.dart';
import 'agent_validation.dart';

/// Off-policy Watkins Q(lambda) with accumulating eligibility traces.
/// Trace retention uses the next behavior action and pre-update greedy set.
/// All tied maxima count as greedy; a nongreedy action clears all traces.
/// Use trainEpisodic to clear traces on reset, truncation and exceptions.
/// Manual loops must call beginEpisode/endEpisode at their own boundaries.
final class WatkinsQLambdaAgent<S, A> implements EpisodicAgent<S, A> {
  WatkinsQLambdaAgent(
      {this.learningRate = 0.1,
      this.discountFactor = 0.99,
      this.lambda = 0.8,
      double epsilon = 1,
      this.epsilonDecay = 0.995,
      this.minEpsilon = 0.01,
      int? seed,
      QTable<S, A>? table,
      ExplorationPolicy<S, A>? explorationPolicy})
      : table = table ?? QTable<S, A>(),
        explorationPolicy = explorationPolicy ?? EpsilonGreedy<S, A>() {
    validateUnit(learningRate, 'learningRate', allowZero: false);
    validateUnit(discountFactor, 'discountFactor');
    validateUnit(lambda, 'lambda');
    _behavior = AgentBehavior(
        values: this.table,
        policy: this.explorationPolicy,
        epsilon: epsilon,
        epsilonDecay: epsilonDecay,
        minEpsilon: minEpsilon,
        seed: seed);
  }
  final double learningRate;
  final double discountFactor;
  final double lambda;
  final double epsilonDecay;
  final double minEpsilon;
  final QTable<S, A> table;
  final ExplorationPolicy<S, A> explorationPolicy;
  late final AgentBehavior<S, A> _behavior;
  final Map<(S, A), double> _traces = {};
  int get traceCount => _traces.length;

  @override
  QTable<S, A> get values => table;
  @override
  double get epsilon => _behavior.epsilon;
  @override
  bool get requiresNextAction => true;
  @override
  A selectAction(S state, List<A> actions, {bool explore = true}) =>
      _behavior.selectAction(state, actions, explore: explore);

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
    if (!terminated &&
        (nextActions.isEmpty || !nextActions.contains(nextAction))) {
      throw ArgumentError('Watkins Q(lambda) requires a legal nextAction');
    }
    // Snapshot greediness BEFORE any Q writes, including self-loop updates.
    final greedy =
        terminated ? <A>[] : greedyCandidates(nextState, nextActions, table);
    final retainTraces = !terminated && greedy.contains(nextAction);
    final bootstrap = terminated ? 0.0 : table.value(nextState, greedy.first);
    final delta =
        reward + discountFactor * bootstrap - table.value(state, action);
    if (!delta.isFinite) throw ArgumentError.value(delta, 'TD error');
    final key = (state, action);
    final eligibility = (_traces[key] ?? 0) + 1;
    final traces = Map<(S, A), double>.of(_traces)..[key] = eligibility;
    final updates = <(S, A), double>{};
    for (final entry in traces.entries) {
      final (s, a) = entry.key;
      final value = table.value(s, a) + learningRate * delta * entry.value;
      if (!value.isFinite) throw ArgumentError.value(value, 'trace update');
      updates[entry.key] = value;
    }
    for (final entry in updates.entries) {
      table.set(entry.key.$1, entry.key.$2, entry.value);
    }
    _traces.clear();
    if (retainTraces) {
      for (final entry in traces.entries) {
        final decayed = entry.value * discountFactor * lambda;
        if (decayed != 0) _traces[entry.key] = decayed;
      }
    }
    return table.value(state, action);
  }

  @override
  void beginEpisode() => _traces.clear();
  @override
  void endEpisode() => _traces.clear();
  @override
  void decayExploration() => _behavior.decayExploration();
}
