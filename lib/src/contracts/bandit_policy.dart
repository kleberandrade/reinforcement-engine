import 'dart:math';
import 'bandit_values.dart';

/// Chooses among a fixed, nonempty set of unique arms using immediate rewards.
/// Implementations must not mutate the arm list and must return a listed arm.
abstract interface class BanditPolicy<A> {
  A selectArm(
      {required List<A> arms,
      required BanditValues<A> values,
      required Random random});
}
