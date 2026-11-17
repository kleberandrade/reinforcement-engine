import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:reinforcement_lab/paired_training.dart';

void main() {
  test(
      'paired runs match independently trained algorithms with shared settings',
      () {
    const settings = LabParameters(seed: 7, epsilon: .6);
    final pair = PairedTraining(settings);
    for (final algorithm in [
      LearningAlgorithm.qLearning,
      LearningAlgorithm.sarsa
    ]) {
      final agent = settings.createAgent(algorithm);
      final world = GridWorld();
      final expected = [
        for (var i = 0; i < 40; i++)
          trainEpisode(
                  environment: world, agent: agent, maxSteps: settings.maxSteps)
              .reward
      ];
      if (algorithm == LearningAlgorithm.qLearning) {
        final observed = [for (var i = 0; i < 40; i++) pair.trainPair().reward];
        expect(observed, expected);
      } else {
        expect(pair.sarsaRewards, expected);
      }
    }
    expect(pair.qAgent.epsilon, pair.sarsaAgent.epsilon);
    expect(pair.qAgent.learningRate, pair.sarsaAgent.learningRate);
    expect(pair.qAgent.discountFactor, pair.sarsaAgent.discountFactor);
    expect(() => pair.sarsaRewards.add(0), throwsUnsupportedError);
  });
}
