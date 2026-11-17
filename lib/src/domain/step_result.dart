/// An environment transition. Truncation ends an episode while preserving the
/// bootstrap value (for example, a time limit); termination does not bootstrap.
class StepResult<S> {
  const StepResult(
      {required this.state,
      required this.reward,
      this.terminated = false,
      this.truncated = false});
  final S state;
  final double reward;

  /// Whether the task ended, disabling bootstrapping.
  final bool terminated;

  /// Whether an external boundary ended the episode, retaining bootstrapping.
  final bool truncated;
}
