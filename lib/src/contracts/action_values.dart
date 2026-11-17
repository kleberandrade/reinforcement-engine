/// Read-only action values. Unseen state/action pairs should evaluate to zero.
/// Values must be finite and keys must have stable equality and hash codes.
abstract interface class ActionValues<S, A> {
  double value(S state, A action);
}
