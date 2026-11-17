import 'dart:math';
import 'package:reinforcement_engine/reinforcement_engine.dart';

/// Synthetic three-arm experiment. A success returns 1, a failure returns 0.
/// The learner sees only observed rewards, never the true arm probabilities.
void main() {
  const probabilities = {'A': 0.2, 'B': 0.5, 'C': 0.8};
  for (final policy in <BanditPolicy<String>>[
    EpsilonGreedyBandit(epsilon: 0.1),
    const Ucb1(),
  ]) {
    final agent = BanditAgent(
        arms: probabilities.keys.toList(), policy: policy, seed: 42);
    // Independent per-arm reward streams avoid coupling one arm to another's
    // selection count; the policy RNG is separate from the reward generators.
    final randoms = {
      for (var i = 0; i < 3; i++)
        probabilities.keys.elementAt(i): Random(100 + i)
    };
    final result = trainBandit(
        agent: agent,
        pulls: 5000,
        reward: (arm) =>
            randoms[arm]!.nextDouble() < probabilities[arm]! ? 1 : 0);
    print('${policy.runtimeType}: observed reward '
        '${result.meanReward.toStringAsFixed(3)}');
    for (final arm in agent.arms) {
      print('$arm: pulls ${agent.values.count(arm)}, '
          'estimated mean ${agent.values.mean(arm).toStringAsFixed(3)}');
    }
    if (agent.values.count('C') <= 2500) {
      throw StateError('Synthetic run did not prioritize the best arm');
    }
  }
}
