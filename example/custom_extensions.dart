import 'package:reinforcement_engine/reinforcement_engine.dart';

/// A deterministic two-action corridor with caller-owned state.
final class Corridor implements Environment<int, int> {
  int _state = 0;

  @override
  int reset() => _state = 0;

  @override
  List<int> actions(int state) => state == 3 ? [] : [-1, 1];

  @override
  StepResult<int> step(int action) {
    if (_state == 3) throw StateError('Reset before stepping again');
    if (action != -1 && action != 1) {
      throw ArgumentError.value(action, 'action');
    }
    _state = (_state + action).clamp(0, 3);
    return StepResult(
        state: _state, reward: _state == 3 ? 5 : -1, terminated: _state == 3);
  }
}

/// Illustrative uniform-policy bootstrap, not epsilon-greedy Expected SARSA.
final class UniformBootstrap<S, A> implements TdUpdateRule<S, A> {
  const UniformBootstrap();

  @override
  bool get requiresNextAction => false;

  @override
  double bootstrap(
          {required QTable<S, A> table,
          required S nextState,
          required List<A> nextActions,
          A? nextAction}) =>
      nextActions
          .map((action) => table.value(nextState, action))
          .reduce((a, b) => a + b) /
      nextActions.length;
}

void main() {
  final environment = Corridor();
  final agent =
      TabularAgent<int, int>(updateRule: const UniformBootstrap(), seed: 42);
  for (var episode = 0; episode < 300; episode++) {
    trainEpisode(environment: environment, agent: agent, maxSteps: 50);
  }
  var state = environment.reset();
  var steps = 0;
  while (state != 3 && steps < 10) {
    state = environment
        .step(agent.selectAction(state, environment.actions(state),
            explore: false))
        .state;
    steps++;
  }
  if (state != 3 || steps != 3) throw StateError('Corridor policy failed');
  print('Custom environment and strategy: goal in $steps steps');
}
