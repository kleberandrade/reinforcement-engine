import '../contracts/td_update_rule.dart';
import '../values/q_table.dart';

/// On-policy TD control using the next sampled behavior action.
final class Sarsa<S, A> implements TdUpdateRule<S, A> {
  const Sarsa();

  @override
  bool get requiresNextAction => true;

  @override
  double bootstrap(
          {required QTable<S, A> table,
          required S nextState,
          required List<A> nextActions,
          A? nextAction}) =>
      table.value(nextState, nextAction as A);
}
