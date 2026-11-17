import 'dart:math';
import '../contracts/bandit_policy.dart';
import '../contracts/bandit_values.dart';

/// UCB1: mean(a) + sqrt(2 * ln(total observations) / count(a)).
/// Samples every unseen arm first; ties are uniform. The finite-time analysis
/// assumes stationary independent rewards in [0, 1]; no universal guarantee.
final class Ucb1<A> implements BanditPolicy<A> {
  const Ucb1();

  @override
  A selectArm(
      {required List<A> arms,
      required BanditValues<A> values,
      required Random random}) {
    if (arms.isEmpty) throw ArgumentError('No available arms');
    final unseen = <A>[];
    for (final arm in arms) {
      final n = values.count(arm);
      final mean = values.mean(arm);
      if (n < 0 ||
          n > values.observations ||
          !mean.isFinite ||
          mean < 0 ||
          mean > 1) {
        throw ArgumentError('Invalid bandit statistics');
      }
      if (n == 0) unseen.add(arm);
    }
    if (unseen.isNotEmpty) return unseen[random.nextInt(unseen.length)];
    var best = double.negativeInfinity;
    final candidates = <A>[];
    for (final arm in arms) {
      final score = values.mean(arm) +
          sqrt(2 * log(values.observations) / values.count(arm));
      if (score > best) {
        best = score;
        candidates.clear();
      }
      if (score == best) candidates.add(arm);
    }
    return candidates[random.nextInt(candidates.length)];
  }
}
