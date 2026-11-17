import '../contracts/action_values.dart';

/// Read-only candidate update for validating dependent arithmetic before commit.
final class ProjectedActionValues<S, A> implements ActionValues<S, A> {
  const ProjectedActionValues(
      this.source, this.state, this.action, this.updated);
  final ActionValues<S, A> source;
  final S state;
  final A action;
  final double updated;
  @override
  double value(S state, A action) =>
      state == this.state && action == this.action
          ? updated
          : source.value(state, action);
}
