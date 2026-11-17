import '../agents/tabular_agent.dart';
import '../contracts/environment.dart';
import '../domain/episode_result.dart';

/// Runs one bounded episode. Call between UI frames or from an isolate for
/// long-running training. This runner is synchronous.
EpisodeResult trainEpisode<S, A>(
    {required Environment<S, A> environment,
    required TabularAgent<S, A> agent,
    int maxSteps = 1000}) {
  if (maxSteps <= 0) throw ArgumentError.value(maxSteps, 'maxSteps');
  var state = environment.reset();
  var action = agent.selectAction(state, environment.actions(state));
  var total = 0.0;
  for (var step = 1; step <= maxSteps; step++) {
    final result = environment.step(action);
    final nextActions =
        result.terminated ? <A>[] : environment.actions(result.state);
    // SARSA must reuse this sampled action at the next transition.
    final nextAction = !result.terminated && agent.updateRule.requiresNextAction
        ? agent.selectAction(result.state, nextActions)
        : null;
    agent.update(
        state: state,
        action: action,
        reward: result.reward,
        nextState: result.state,
        terminated: result.terminated,
        nextActions: nextActions,
        nextAction: nextAction);
    total += result.reward;
    final truncated =
        result.truncated || (!result.terminated && step == maxSteps);
    if (result.terminated || truncated) {
      agent.decayExploration();
      return EpisodeResult(
          reward: total,
          steps: step,
          terminated: result.terminated,
          truncated: truncated);
    }
    state = result.state;
    action = agent.updateRule.requiresNextAction
        ? nextAction as A
        : agent.selectAction(state, nextActions);
  }
  throw StateError('Unreachable');
}
