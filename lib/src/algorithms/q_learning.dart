import 'dart:math';

import '../contracts/td_update_rule.dart';
import '../values/q_table.dart';

/// Off-policy TD control using the maximum legal next action value.
final class QLearning<S, A> implements TdUpdateRule<S, A> {
  const QLearning();

  @override
  bool get requiresNextAction => false;

  @override
  double bootstrap(
          {required QTable<S, A> table,
          required S nextState,
          required List<A> nextActions,
          A? nextAction}) =>
      nextActions.map((action) => table.value(nextState, action)).reduce(max);
}
