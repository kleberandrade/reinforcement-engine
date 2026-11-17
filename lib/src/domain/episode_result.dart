/// Immutable summary of a completed or truncated episode.
class EpisodeResult {
  const EpisodeResult(
      {required this.reward,
      required this.steps,
      required this.terminated,
      required this.truncated});
  final double reward;
  final int steps;
  final bool terminated;
  final bool truncated;
}
