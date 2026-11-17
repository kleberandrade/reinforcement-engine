import 'action_values.dart';

/// Control for non-episodic tasks. No terminal or discounted-target semantics.
abstract interface class ContinuingAgent<S, A> {
  ActionValues<S, A> get values;
  double get epsilon;
  A selectAction(S state, List<A> actions, {bool explore = true});
  double update(
      {required S state,
      required A action,
      required List<A> actions,
      required double reward,
      required S nextState,
      required List<A> nextActions});
}
