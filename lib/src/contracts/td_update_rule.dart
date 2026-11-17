import '../values/q_table.dart';

/// Computes the bootstrap value for a nonterminal TD control transition.
/// Implementations must not mutate the table or action list, and must return a
/// finite value. The agent handles reward, discount and learning rate.
abstract interface class TdUpdateRule<S, A> {
  /// Whether the runner must sample and reuse the next behavior action.
  bool get requiresNextAction;

  /// [nextActions] is nonempty. If [requiresNextAction] is true, [nextAction]
  /// is a member of that list. Terminal transitions never call this method.
  double bootstrap({
    required QTable<S, A> table,
    required S nextState,
    required List<A> nextActions,
    A? nextAction,
  });
}
