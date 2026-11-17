import '../domain/step_result.dart';

/// Reset must return a nonterminal state with at least one legal action.
abstract interface class Environment<S, A> {
  S reset();
  List<A> actions(S state);
  StepResult<S> step(A action);
}
