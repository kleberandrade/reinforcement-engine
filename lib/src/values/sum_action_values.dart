import '../contracts/action_values.dart';

/// Live read-only sum of two independent action-value sources.
final class SumActionValues<S, A> implements ActionValues<S, A> {
  const SumActionValues(this.first, this.second);
  final ActionValues<S, A> first;
  final ActionValues<S, A> second;

  @override
  double value(S state, A action) {
    final result = first.value(state, action) + second.value(state, action);
    if (!result.isFinite) throw ArgumentError.value(result, 'summed value');
    return result;
  }
}
