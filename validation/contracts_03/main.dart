import 'package:reinforcement_engine/reinforcement_engine.dart';

// This independent package uses only public exports and implements the contracts.
void main() {
  final continuing = ConsumerContinuingAgent();
  final run = trainContinuing(
      environment: ConsumerEnvironment(continuing: true),
      agent: continuing,
      initialState: 0,
      steps: 5);
  if (run.reward != 5 || run.steps != 5) {
    throw StateError('Continuing contract failed');
  }
  final episodic = ConsumerEpisodicAgent();
  final episode =
      trainEpisodic(environment: ConsumerEnvironment(), agent: episodic);
  if (!episode.terminated || episodic.starts != 1 || episodic.ends != 1) {
    throw StateError('Episode lifecycle contract failed');
  }
  final traces = SarsaLambdaAgent<int, int>(lambda: 0.5, seed: 42);
  trainEpisodic(environment: ConsumerEnvironment(), agent: traces);
  if (traces.traceCount != 0) throw StateError('Public trace cleanup failed');
  final average = RLearningAgent<int, int>(seed: 42);
  trainContinuing(
      environment: ConsumerEnvironment(continuing: true),
      agent: average,
      initialState: 0,
      steps: 100);
  if (!average.averageReward.isFinite) {
    throw StateError('Public R-learning failed');
  }
  final checkpoint = TrainingCheckpoint.rLearning(average,
      encodeState: (state) => state, encodeAction: (action) => action);
  final resumed = TrainingCheckpoint.fromJson(checkpoint.toJson())
      .restoreRLearning<int, int>(
          decodeState: (key) => key as int,
          decodeAction: (key) => key as int,
          seed: 99);
  if (resumed.averageReward != average.averageReward ||
      resumed.table.value(0, 0) != average.table.value(0, 0)) {
    throw StateError('Public checkpoint consumer failed');
  }
  print('Independent contracts and 0.4 checkpoint consumer passed');
}

final class ConsumerEnvironment implements Environment<int, int> {
  ConsumerEnvironment({this.continuing = false});
  final bool continuing;
  @override
  int reset() => 0;
  @override
  List<int> actions(int state) => [0];
  @override
  StepResult<int> step(int action) =>
      StepResult(state: 0, reward: 1, terminated: !continuing);
}

final class ConsumerContinuingAgent implements ContinuingAgent<int, int> {
  @override
  final QTable<int, int> values = QTable();
  @override
  double get epsilon => 0;
  @override
  int selectAction(int state, List<int> actions, {bool explore = true}) =>
      actions.first;
  @override
  double update(
      {required int state,
      required int action,
      required List<int> actions,
      required double reward,
      required int nextState,
      required List<int> nextActions}) {
    values.set(state, action, reward);
    return reward;
  }
}

final class ConsumerEpisodicAgent implements EpisodicAgent<int, int> {
  final TabularAgent<int, int> delegate = TabularAgent(seed: 42);
  int starts = 0;
  int ends = 0;
  @override
  ActionValues<int, int> get values => delegate.values;
  @override
  double get epsilon => delegate.epsilon;
  @override
  bool get requiresNextAction => delegate.requiresNextAction;
  @override
  void beginEpisode() => starts++;
  @override
  void endEpisode() => ends++;
  @override
  void decayExploration() => delegate.decayExploration();
  @override
  int selectAction(int state, List<int> actions, {bool explore = true}) =>
      delegate.selectAction(state, actions, explore: explore);
  @override
  double update(
          {required int state,
          required int action,
          required double reward,
          required int nextState,
          required bool terminated,
          List<int> nextActions = const [],
          int? nextAction}) =>
      delegate.update(
          state: state,
          action: action,
          reward: reward,
          nextState: nextState,
          terminated: terminated,
          nextActions: nextActions,
          nextAction: nextAction);
}
