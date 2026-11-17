/// Immutable summary of one bounded bandit training window.
final class BanditResult<A> {
  BanditResult(
      {required this.pulls, required this.reward, required Map<A, int> counts})
      : counts = Map.unmodifiable(counts);
  final int pulls;
  final double reward;
  final Map<A, int> counts;
  double get meanReward => reward / pulls;
}
