/// Immutable summary of a fixed continuing-task observation window.
/// Window boundaries neither reset the environment nor create terminal targets.
final class ContinuingResult<S> {
  const ContinuingResult(
      {required this.finalState, required this.reward, required this.steps});
  final S finalState;
  final double reward;
  final int steps;
  double get meanReward => reward / steps;
}
