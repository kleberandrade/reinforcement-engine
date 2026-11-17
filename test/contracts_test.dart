import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

void main() {
  test('nonfinite custom bootstrap is rejected without mutating the table', () {
    final agent = TabularAgent<int, int>(updateRule: const InvalidValue());
    expect(
        () => agent.update(
            state: 0,
            action: 0,
            reward: 1,
            nextState: 1,
            terminated: false,
            nextActions: [0]),
        throwsArgumentError);
    expect(agent.table.stateCount, 0);
  });

  test('explicit SARSA strategy overrides convenience selector in runner', () {
    final environment = RecordedEpisode();
    final agent = TabularAgent<int, int>(
      updateRule: const Sarsa(),
      learningRate: 1,
      discountFactor: 1,
      seed: 18,
    );
    agent.table.set(1, 0, 3);
    agent.table.set(1, 1, 9);
    trainEpisode(environment: environment, agent: agent);
    expect(agent.table.value(0, 0), environment.lastAction == 0 ? 3 : 9);
  });

  test('custom rule controls bootstrap and is bypassed at termination', () {
    final agent = TabularAgent<int, int>(
      updateRule: const MeanValue(),
      learningRate: 1,
      discountFactor: 0.5,
    );
    agent.table.set(1, 0, 2);
    agent.table.set(1, 1, 6);
    agent.table.set(1, 2, 100);
    expect(
        agent.update(
            state: 0,
            action: 0,
            reward: 1,
            nextState: 1,
            terminated: false,
            nextActions: [0, 1]),
        3);
    expect(
        agent.update(
            state: 0, action: 0, reward: 7, nextState: 1, terminated: true),
        7);
  });

  test('strategies agree with convenience API during seeded training', () {
    for (final algorithm in LearningAlgorithm.values) {
      final a = TabularAgent<int, GridAction>(algorithm: algorithm, seed: 42);
      final b = TabularAgent<int, GridAction>(
          seed: 42,
          updateRule: algorithm == LearningAlgorithm.sarsa
              ? const Sarsa()
              : const QLearning());
      final first = GridWorld();
      final second = GridWorld();
      for (var episode = 0; episode < 50; episode++) {
        final x = trainEpisode(environment: first, agent: a, maxSteps: 100);
        final y = trainEpisode(environment: second, agent: b, maxSteps: 100);
        expect((x.reward, x.steps, x.terminated, x.truncated),
            (y.reward, y.steps, y.terminated, y.truncated));
      }
      expect(a.table.toJson(encodeState: (s) => s, encodeAction: (a) => a.name),
          b.table.toJson(encodeState: (s) => s, encodeAction: (a) => a.name));
    }
  });
}

final class MeanValue implements TdUpdateRule<int, int> {
  const MeanValue();
  @override
  bool get requiresNextAction => false;
  @override
  double bootstrap(
          {required QTable<int, int> table,
          required int nextState,
          required List<int> nextActions,
          int? nextAction}) =>
      nextActions
          .map((a) => table.value(nextState, a))
          .reduce((a, b) => a + b) /
      nextActions.length;
}

final class RecordedEpisode implements Environment<int, int> {
  int state = 0;
  int? lastAction;
  @override
  int reset() => state = 0;
  @override
  List<int> actions(int state) => state == 0 ? [0] : [0, 1];
  @override
  StepResult<int> step(int action) {
    if (state == 1) lastAction = action;
    state++;
    return StepResult(state: state, reward: 0, terminated: state == 2);
  }
}

final class InvalidValue implements TdUpdateRule<int, int> {
  const InvalidValue();
  @override
  bool get requiresNextAction => false;
  @override
  double bootstrap(
          {required QTable<int, int> table,
          required int nextState,
          required List<int> nextActions,
          int? nextAction}) =>
      double.nan;
}
