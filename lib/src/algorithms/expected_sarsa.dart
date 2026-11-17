import '../contracts/td_update_rule.dart';
import '../values/q_table.dart';
import '../policies/probability_validation.dart';

/// Expected TD bootstrap under an explicit next-state action distribution.
/// The enum agent constructor binds this to its current behavior policy and
/// epsilon. Direct consumers must supply probabilities matching their policy.
final class ExpectedSarsa<S, A> implements TdUpdateRule<S, A> {
  const ExpectedSarsa({required this.probabilities});

  final List<double> Function(S state, List<A> actions) probabilities;

  @override
  bool get requiresNextAction => false;

  @override
  double bootstrap(
      {required QTable<S, A> table,
      required S nextState,
      required List<A> nextActions,
      A? nextAction}) {
    final weights = probabilities(nextState, nextActions);
    validateProbabilities(weights, nextActions.length);
    var value = 0.0;
    for (var i = 0; i < nextActions.length; i++) {
      value += weights[i] * table.value(nextState, nextActions[i]);
    }
    return value;
  }
}
