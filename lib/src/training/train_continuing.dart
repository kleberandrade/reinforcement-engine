import '../contracts/continuing_agent.dart';
import '../contracts/environment.dart';
import '../domain/continuing_result.dart';

/// Runs a bounded observation window without resetting state or exploration.
/// Pass environment.reset() as initialState for the first window, then pass
/// the previous result.finalState for subsequent windows. Terminal or truncated
/// transitions are rejected before any agent update: use episodic control there.
ContinuingResult<S> trainContinuing<S, A>({
  required Environment<S, A> environment,
  required ContinuingAgent<S, A> agent,
  required S initialState,
  int steps = 1000,
}) {
  if (steps <= 0) throw ArgumentError.value(steps, 'steps');
  var state = initialState;
  var reward = 0.0;
  for (var step = 0; step < steps; step++) {
    final actions = List<A>.unmodifiable(environment.actions(state));
    if (actions.isEmpty) throw ArgumentError('No available actions');
    final action = agent.selectAction(state, actions);
    if (!actions.contains(action)) {
      throw ArgumentError('Illegal continuing action');
    }
    final result = environment.step(action);
    if (result.terminated || result.truncated) {
      throw StateError('Continuing tasks must not terminate or truncate');
    }
    if (!result.reward.isFinite || !(reward + result.reward).isFinite) {
      throw ArgumentError.value(result.reward, 'reward', 'Nonfinite return');
    }
    final nextActions = List<A>.unmodifiable(environment.actions(result.state));
    agent.update(
        state: state,
        action: action,
        actions: actions,
        reward: result.reward,
        nextState: result.state,
        nextActions: nextActions);
    reward += result.reward;
    state = result.state;
  }
  return ContinuingResult(finalState: state, reward: reward, steps: steps);
}
