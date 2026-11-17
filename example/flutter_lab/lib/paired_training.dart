import 'package:reinforcement_engine/reinforcement_engine.dart';

/// Application settings shared by both independently seeded learners.
class LabParameters {
  const LabParameters({required this.seed, required this.epsilon});
  final int seed;
  final double epsilon;
  double get learningRate => .2;
  double get discountFactor => .99;
  double get epsilonDecay => .995;
  double get minEpsilon => .01;
  int get maxSteps => 200;

  TabularAgent<int, GridAction> createAgent(LearningAlgorithm algorithm) =>
      TabularAgent<int, GridAction>(
          algorithm: algorithm,
          seed: seed,
          epsilon: epsilon,
          learningRate: learningRate,
          discountFactor: discountFactor,
          epsilonDecay: epsilonDecay,
          minEpsilon: minEpsilon);
}

/// Interleaves complete episodes; each learner owns its environment and RNG.
/// Flutter owns scheduling, pause/cancel and the primary reward history.
class PairedTraining {
  PairedTraining(this.parameters)
      : qAgent = parameters.createAgent(LearningAlgorithm.qLearning),
        sarsaAgent = parameters.createAgent(LearningAlgorithm.sarsa);
  final LabParameters parameters;
  final TabularAgent<int, GridAction> qAgent, sarsaAgent;
  final _qWorld = GridWorld(), _sarsaWorld = GridWorld();
  final _sarsaRewards = <double>[];
  List<double> get sarsaRewards => List.unmodifiable(_sarsaRewards);

  EpisodeResult trainPair() {
    final q = trainEpisode(
        environment: _qWorld, agent: qAgent, maxSteps: parameters.maxSteps);
    final sarsa = trainEpisode(
        environment: _sarsaWorld,
        agent: sarsaAgent,
        maxSteps: parameters.maxSteps);
    _sarsaRewards.add(sarsa.reward);
    return q;
  }
}
