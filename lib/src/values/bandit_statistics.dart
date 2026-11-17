import '../contracts/bandit_values.dart';

/// Incremental sample means for rewards normalized to [0, 1].
/// The read-only BanditValues view is exposed by BanditAgent.
final class BanditStatistics<A> implements BanditValues<A> {
  final Map<A, int> _counts = {};
  final Map<A, double> _means = {};
  int _observations = 0;
  @override
  int get observations => _observations;
  @override
  int count(A arm) => _counts[arm] ?? 0;
  @override
  double mean(A arm) => _means[arm] ?? 0;

  void observe(A arm, double reward) {
    if (!reward.isFinite || reward < 0 || reward > 1) {
      throw ArgumentError.value(
          reward, 'reward', 'Expected a reward in [0, 1]');
    }
    // Keep integer counts exact on both Dart VM and JavaScript.
    if (_observations >= 9007199254740991) {
      throw StateError('Bandit observation count exceeds the supported range');
    }
    final n = count(arm) + 1;
    final updated = mean(arm) + (reward - mean(arm)) / n;
    _counts[arm] = n;
    _means[arm] = updated;
    _observations++;
  }
}
