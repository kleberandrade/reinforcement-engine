import '../contracts/environment.dart';
import '../contracts/episodic_agent.dart';
import '../domain/episode_result.dart';
import 'train_episode.dart';

/// Bounded training with explicit episode-local lifecycle, without type checks.
/// Truncation bootstraps inside trainEpisode before endEpisode clears traces.
EpisodeResult trainEpisodic<S, A>(
    {required Environment<S, A> environment,
    required EpisodicAgent<S, A> agent,
    int maxSteps = 1000}) {
  if (maxSteps <= 0) throw ArgumentError.value(maxSteps, 'maxSteps');
  agent.beginEpisode();
  try {
    return trainEpisode(
        environment: environment, agent: agent, maxSteps: maxSteps);
  } finally {
    agent.endEpisode();
  }
}
