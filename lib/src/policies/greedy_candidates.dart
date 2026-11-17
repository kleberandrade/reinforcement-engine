import '../contracts/action_values.dart';

/// Shared maximum selection with finite-value validation and unbiased ties.
List<A> greedyCandidates<S, A>(
    S state, List<A> actions, ActionValues<S, A> values) {
  if (actions.isEmpty) throw ArgumentError('No available actions');
  var best = double.negativeInfinity;
  final candidates = <A>[];
  for (final action in actions) {
    final value = values.value(state, action);
    if (!value.isFinite) throw ArgumentError.value(value, 'action value');
    if (value > best) {
      best = value;
      candidates.clear();
    }
    if (value == best) candidates.add(action);
  }
  return candidates;
}
