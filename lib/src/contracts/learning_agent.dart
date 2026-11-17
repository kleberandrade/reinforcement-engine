import 'action_values.dart';

/// Small control interface used by the bounded episode runner.
abstract interface class LearningAgent<S, A> {
  ActionValues<S, A> get values;
  double get epsilon;
  bool get requiresNextAction;
  A selectAction(S state, List<A> actions, {bool explore = true});
  double update(
      {required S state,
      required A action,
      required double reward,
      required S nextState,
      required bool terminated,
      List<A> nextActions = const [],
      A? nextAction});
  void decayExploration();
}
