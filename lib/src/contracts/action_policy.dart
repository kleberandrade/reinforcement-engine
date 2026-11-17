import 'dart:math';

/// Chooses one action from a nonempty legal list during evaluation.
/// Implementations must not mutate the list or any learned values. The runner
/// supplies an independent random source for reproducible evaluation.
abstract interface class ActionPolicy<S, A> {
  A selectAction(S state, List<A> actions, Random random);
}
