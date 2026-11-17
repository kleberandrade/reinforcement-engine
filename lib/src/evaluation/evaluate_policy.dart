import 'dart:math';

import '../contracts/action_policy.dart';
import '../contracts/environment.dart';
import '../domain/episode_result.dart';
import '../domain/evaluation_result.dart';

/// Evaluates a fixed policy using an independent RNG and fresh environments.
/// No learning, exploration decay or training RNG use occurs here. The factory
/// must return a fresh instance per episode. Stochastic environments need their
/// own seeds. The caller defines success; termination alone need not mean success.
EvaluationResult evaluatePolicy<S, A>({
  required Environment<S, A> Function() environmentFactory,
  required ActionPolicy<S, A> policy,
  required bool Function(S finalState, EpisodeResult episode) isSuccess,
  int episodes = 100,
  int maxSteps = 1000,
  int? seed,
}) {
  if (episodes <= 0) throw ArgumentError.value(episodes, 'episodes');
  if (maxSteps <= 0) throw ArgumentError.value(maxSteps, 'maxSteps');
  final random = Random(seed);
  final results = <EpisodeResult>[];
  var successes = 0;
  for (var episode = 0; episode < episodes; episode++) {
    final environment = environmentFactory();
    var state = environment.reset();
    var reward = 0.0;
    for (var step = 1; step <= maxSteps; step++) {
      final actions = List<A>.unmodifiable(environment.actions(state));
      if (actions.isEmpty) throw ArgumentError('No available actions');
      final action = policy.selectAction(state, actions, random);
      if (!actions.contains(action)) {
        throw ArgumentError.value(
            action, 'action', 'Policy returned illegal action');
      }
      final transition = environment.step(action);
      if (!transition.reward.isFinite) {
        throw ArgumentError.value(transition.reward, 'reward');
      }
      reward += transition.reward;
      if (!reward.isFinite) {
        throw ArgumentError.value(reward, 'episode reward', 'Return overflow');
      }
      state = transition.state;
      final truncated =
          transition.truncated || (!transition.terminated && step == maxSteps);
      if (transition.terminated || truncated) {
        final result = EpisodeResult(
            reward: reward,
            steps: step,
            terminated: transition.terminated,
            truncated: truncated);
        results.add(result);
        if (isSuccess(state, result)) successes++;
        break;
      }
    }
  }
  return EvaluationResult(episodes: results, successes: successes);
}
