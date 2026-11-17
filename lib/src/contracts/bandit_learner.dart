import 'bandit_values.dart';

/// Immediate-reward feedback contract independent of episodic state transitions.
/// Arms are fixed, unique and nonempty; selection returns a listed arm.
/// Observe records one finite reward in [0, 1]; invalid input must not mutate values.
abstract interface class BanditLearner<A> {
  List<A> get arms;
  BanditValues<A> get values;
  A selectArm();
  void observe(A arm, double reward);
}
