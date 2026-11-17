import 'dart:math';
import '../contracts/bandit_policy.dart';
import '../contracts/bandit_values.dart';

/// Fixed epsilon exploration; exploitation maximizes observed sample means.
/// Unseen arms have zero mean; greedy ties are broken uniformly.
final class EpsilonGreedyBandit<A> implements BanditPolicy<A> {
  EpsilonGreedyBandit({this.epsilon = 0.1}) {
    if (!epsilon.isFinite || epsilon < 0 || epsilon > 1) {
      throw ArgumentError.value(epsilon, 'epsilon');
    }
  }
  final double epsilon;

  @override
  A selectArm(
      {required List<A> arms,
      required BanditValues<A> values,
      required Random random}) {
    if (arms.isEmpty) throw ArgumentError('No available arms');
    if (epsilon > 0 && random.nextDouble() < epsilon) {
      return arms[random.nextInt(arms.length)];
    }
    var best = double.negativeInfinity;
    final candidates = <A>[];
    for (final arm in arms) {
      final mean = values.mean(arm);
      if (!mean.isFinite) throw ArgumentError('Non-finite arm mean');
      if (mean > best) {
        best = mean;
        candidates.clear();
      }
      if (mean == best) candidates.add(arm);
    }
    return candidates[random.nextInt(candidates.length)];
  }
}
