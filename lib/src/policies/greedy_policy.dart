import 'dart:math';

import '../contracts/action_policy.dart';
import '../contracts/action_values.dart';
import 'greedy_candidates.dart';

/// Read-only greedy policy over a Q-table, with uniform random tie-breaking.
/// The caller owns the table; evaluation does not copy or modify it.
final class GreedyPolicy<S, A> implements ActionPolicy<S, A> {
  const GreedyPolicy(this.table);

  final ActionValues<S, A> table;

  @override
  A selectAction(S state, List<A> actions, Random random) {
    final candidates = greedyCandidates(state, actions, table);
    return candidates[random.nextInt(candidates.length)];
  }
}
