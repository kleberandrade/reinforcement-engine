import '../contracts/bandit_learner.dart';
import '../domain/bandit_result.dart';

/// Synchronous bounded immediate-reward training. Callback owns reward RNG/IO.
/// Invalid feedback does not change that observation; earlier pulls remain.
/// A callback exception propagates. UI scheduling belongs to the application.
BanditResult<A> trainBandit<A>(
    {required BanditLearner<A> agent,
    required double Function(A) reward,
    int pulls = 1000}) {
  if (pulls <= 0) throw ArgumentError.value(pulls, 'pulls');
  var total = 0.0;
  final counts = <A, int>{};
  for (var i = 0; i < pulls; i++) {
    final arm = agent.selectArm();
    final observed = reward(arm);
    if (!observed.isFinite || observed < 0 || observed > 1) {
      throw ArgumentError.value(
          observed, 'reward', 'Expected reward in [0, 1]');
    }
    agent.observe(arm, observed);
    total += observed;
    counts[arm] = (counts[arm] ?? 0) + 1;
  }
  return BanditResult(pulls: pulls, reward: total, counts: counts);
}
