import 'learning_agent.dart';

/// A learner with episode-local state, such as eligibility traces.
/// Use trainEpisodic to enforce these boundaries automatically, including errors.
abstract interface class EpisodicAgent<S, A> implements LearningAgent<S, A> {
  void beginEpisode();
  void endEpisode();
}
