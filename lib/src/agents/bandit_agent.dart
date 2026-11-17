import 'dart:math';
import '../contracts/bandit_policy.dart';
import '../contracts/bandit_learner.dart';
import '../contracts/bandit_values.dart';
import '../policies/epsilon_greedy_bandit.dart';
import '../values/bandit_statistics.dart';

/// Stateless-decision learner with a fixed set of arms and rewards in [0, 1].
/// Each observe records ONE outcome. Selection alone never changes statistics.
/// Not a LearningAgent: no next state, gamma, terminal flag or delayed return.
final class BanditAgent<A> implements BanditLearner<A> {
  BanditAgent({required List<A> arms, BanditPolicy<A>? policy, int? seed})
      : arms = List.unmodifiable(arms),
        policy = policy ?? EpsilonGreedyBandit<A>(),
        _random = Random(seed) {
    if (this.arms.isEmpty || this.arms.toSet().length != this.arms.length) {
      throw ArgumentError('Expected a nonempty list of unique arms');
    }
  }
  @override
  final List<A> arms;
  final BanditPolicy<A> policy;
  final Random _random;
  final BanditStatistics<A> _statistics = BanditStatistics();
  @override
  BanditValues<A> get values => _statistics;

  @override
  A selectArm() {
    final arm = policy.selectArm(arms: arms, values: values, random: _random);
    if (!arms.contains(arm)) {
      throw ArgumentError('Policy returned an unknown arm');
    }
    return arm;
  }

  /// Records externally supplied feedback for a legal arm, without sampling.
  /// Delayed/repeated feedback must be deduplicated by the application.
  @override
  void observe(A arm, double reward) {
    if (!arms.contains(arm)) throw ArgumentError.value(arm, 'arm');
    _statistics.observe(arm, reward);
  }
}
