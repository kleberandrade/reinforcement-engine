import 'dart:math';

import '../contracts/action_policy.dart';
import '../values/q_table.dart';

/// Read-only greedy policy over a Q-table, with uniform random tie-breaking.
/// The caller owns the table; evaluation does not copy or modify it.
final class GreedyPolicy<S, A> implements ActionPolicy<S, A> {
  const GreedyPolicy(this.table);

  final QTable<S, A> table;

  @override
  A selectAction(S state, List<A> actions, Random random) {
    if (actions.isEmpty) throw ArgumentError('No available actions');
    var best = double.negativeInfinity;
    final candidates = <A>[];
    for (final action in actions) {
      final value = table.value(state, action);
      if (value > best) {
        best = value;
        candidates.clear();
      }
      if (value == best) candidates.add(action);
    }
    return candidates[random.nextInt(candidates.length)];
  }
}
