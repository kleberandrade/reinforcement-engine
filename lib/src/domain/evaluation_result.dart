import 'episode_result.dart';

/// Immutable episode summaries and aggregate policy evaluation metrics.
final class EvaluationResult {
  EvaluationResult(
      {required List<EpisodeResult> episodes, required this.successes})
      : episodes = List.unmodifiable(episodes) {
    if (episodes.isEmpty) {
      throw ArgumentError('At least one episode is required');
    }
    if (successes < 0 || successes > episodes.length) {
      throw ArgumentError.value(successes, 'successes');
    }
  }

  final List<EpisodeResult> episodes;

  /// Count classified as successful by the caller, independently of termination.
  final int successes;

  int get episodeCount => episodes.length;
  double get successRate => successes / episodeCount;
  double get terminationRate =>
      episodes.where((episode) => episode.terminated).length / episodeCount;
  double get truncationRate =>
      episodes.where((episode) => episode.truncated).length / episodeCount;

  /// Average per-episode return. Divide before summation to avoid total overflow.
  double get meanReward =>
      episodes.fold(0.0, (sum, episode) => sum + episode.reward / episodeCount);
  double get meanSteps =>
      episodes.fold(0.0, (sum, episode) => sum + episode.steps / episodeCount);
}
