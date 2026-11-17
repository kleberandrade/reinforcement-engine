import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
      'R-learning updates relative values then post-update greedy reward estimate',
      () {
    final agent = RLearningAgent<int, int>(
        learningRate: 0.5, averageRewardRate: 0.1, initialAverageReward: 1);
    agent.table.set(0, 0, 3);
    agent.table.set(0, 1, 1);
    agent.table.set(1, 0, 8);
    agent.table.set(1, 1, 2);
    expect(
        agent.update(
            state: 0,
            action: 0,
            actions: [0, 1],
            reward: 2,
            nextState: 1,
            nextActions: [0, 1]),
        6);
    expect(agent.averageReward, closeTo(1.3, 1e-12));
  });
  test('R-learning excludes nongreedy transitions from average estimate', () {
    final agent =
        RLearningAgent<int, int>(learningRate: 0.1, averageRewardRate: 0.1);
    agent.table.set(0, 1, 10);
    agent.update(
        state: 0,
        action: 0,
        actions: [0, 1],
        reward: 1,
        nextState: 1,
        nextActions: [0]);
    expect(agent.table.value(0, 0), 0.1);
    expect(agent.averageReward, 0);
  });
  test('R-learning self-loop uses updated maxima for reward estimate', () {
    final agent =
        RLearningAgent<int, int>(learningRate: 0.5, averageRewardRate: 0.1);
    agent.update(
        state: 0,
        action: 0,
        actions: [0],
        reward: 4,
        nextState: 0,
        nextActions: [0]);
    expect(agent.table.value(0, 0), 2);
    expect(agent.averageReward, 0.4);
  });
  test('R-learning greedy gate is evaluated after the value update', () {
    final agent =
        RLearningAgent<int, int>(learningRate: 0.5, averageRewardRate: 0.1);
    agent.table.set(0, 1, 1);
    agent.update(
        state: 0,
        action: 0,
        actions: [0, 1],
        reward: 10,
        nextState: 1,
        nextActions: [0]);
    expect(agent.table.value(0, 0), 5);
    expect(agent.averageReward, 0.5);
  });
  test('maintenance task learns a continuing cycle with mean 1.5', () {
    final environment = MaintenanceTask();
    final agent = RLearningAgent<MachineState, MachineAction>(
        seed: 42, averageRewardRate: 0.005, epsilon: 0.1, minEpsilon: 0.1);
    trainContinuing(
        environment: environment,
        agent: agent,
        initialState: environment.reset(),
        steps: 10000);
    expect(
        agent.selectAction(MachineState.ready, MachineAction.values,
            explore: false),
        MachineAction.work);
    expect(
        agent.selectAction(MachineState.worn, MachineAction.values,
            explore: false),
        MachineAction.service);
    expect(agent.averageReward, closeTo(1.5, 0.01));
    expect(environment.step(MachineAction.service).state, MachineState.ready);
    expect(environment.step(MachineAction.work).reward, 3);
    expect(environment.step(MachineAction.work).reward, -1);
  });
  test('continuing windows preserve state and reward estimate across blocks',
      () {
    final environment = RewardCycle();
    final agent = RLearningAgent<int, int>(seed: 42);
    final first = trainContinuing(
        environment: environment,
        agent: agent,
        initialState: environment.reset(),
        steps: 5);
    expect(first.finalState, 1);
    expect(first.reward, 9);
    expect(first.meanReward, 1.8);
    final before = agent.averageReward;
    final second = trainContinuing(
        environment: environment,
        agent: agent,
        initialState: first.finalState,
        steps: 5);
    expect(second.finalState, 0);
    expect(second.reward, 11);
    expect(agent.averageReward, isNot(before));
    expect(agent.epsilon, 1); // No implicit per-window exploration decay.
    final loop = RLearningAgent<int, int>(epsilon: 0, minEpsilon: 0);
    for (var i = 0; i < 1000; i++) {
      loop.update(
          state: 0,
          action: 0,
          actions: [0],
          reward: 2,
          nextState: 0,
          nextActions: [0]);
    }
    expect(loop.averageReward, closeTo(2, 0.001));
  });
  test('continuing runner rejects terminal boundaries and illegal inputs', () {
    final agent = RLearningAgent<int, int>();
    expect(
        () => trainContinuing(
            environment: Ending(), agent: agent, initialState: 0, steps: 2),
        throwsStateError);
    expect(
        () => trainContinuing(
            environment: Ending(), agent: agent, initialState: 0, steps: 0),
        throwsArgumentError);
    expect(
        () => agent.update(
            state: 0,
            action: 9,
            actions: [0],
            reward: 1,
            nextState: 0,
            nextActions: [0]),
        throwsArgumentError);
    expect(
        () => agent.update(
            state: 0,
            action: 0,
            actions: [0],
            reward: double.nan,
            nextState: 0,
            nextActions: [0]),
        throwsArgumentError);
    expect(() => RLearningAgent<int, int>(averageRewardRate: 0),
        throwsArgumentError);
  });
  test('SARSA lambda propagates terminal reward through accumulating traces',
      () {
    final agent = SarsaLambdaAgent<int, int>(
        learningRate: 0.5, discountFactor: 1, lambda: 0.5);
    agent.beginEpisode();
    agent.update(
        state: 0,
        action: 0,
        reward: 0,
        nextState: 1,
        terminated: false,
        nextActions: [0],
        nextAction: 0);
    agent.update(
        state: 1, action: 0, reward: 2, nextState: 2, terminated: true);
    expect(agent.table.value(0, 0), 0.5);
    expect(agent.table.value(1, 0), 1);
    expect(agent.traceCount, 0);
    agent.update(
        state: 9, action: 0, reward: 3, nextState: 10, terminated: true);
    expect(agent.table.value(0, 0), 0.5);
  });
  test('repeated visits accumulate traces and lifecycle clears only traces',
      () {
    final agent = SarsaLambdaAgent<int, int>(
        learningRate: 0.5, discountFactor: 1, lambda: 1);
    for (var i = 0; i < 2; i++) {
      agent.update(
          state: 0,
          action: 0,
          reward: 1,
          nextState: 0,
          terminated: false,
          nextActions: [0],
          nextAction: 0);
    }
    expect(agent.table.value(0, 0), 1.5);
    expect(agent.traceCount, 1);
    agent.endEpisode();
    expect(agent.traceCount, 0);
    expect(agent.table.value(0, 0), 1.5);
  });
  test('eligibility decay includes discount and lambda', () {
    final agent = SarsaLambdaAgent<int, int>(
        learningRate: 0.5, discountFactor: 0.8, lambda: 0.5);
    agent.update(
        state: 0,
        action: 0,
        reward: 0,
        nextState: 1,
        terminated: false,
        nextActions: [0],
        nextAction: 0);
    agent.update(
        state: 1, action: 0, reward: 2, nextState: 2, terminated: true);
    expect(agent.table.value(0, 0), 0.4);
  });
  test('trace overflow rejects the whole multi-cell update', () {
    final agent = SarsaLambdaAgent<int, int>(
        learningRate: 1, discountFactor: 1, lambda: 1);
    for (final state in [0, 1, 1]) {
      agent.update(
          state: state,
          action: 0,
          reward: 0,
          nextState: state,
          terminated: false,
          nextActions: [0],
          nextAction: 0);
    }
    agent.table.set(1, 0, 1e308);
    expect(
        () => agent.update(
            state: 1,
            action: 0,
            reward: 1.7e308,
            nextState: 2,
            terminated: true),
        throwsArgumentError);
    expect(agent.table.value(0, 0), 0);
    expect(agent.table.value(1, 0), 1e308);
    expect(agent.traceCount, 2);
  });
  test('lambda zero matches SARSA values and seeded episode outcomes', () {
    final trace = SarsaLambdaAgent<int, GridAction>(lambda: 0, seed: 42);
    final base = TabularAgent<int, GridAction>(
        algorithm: LearningAlgorithm.sarsa, seed: 42);
    for (var i = 0; i < 100; i++) {
      final a =
          trainEpisodic(environment: GridWorld(), agent: trace, maxSteps: 100);
      final b =
          trainEpisode(environment: GridWorld(), agent: base, maxSteps: 100);
      expect((a.reward, a.steps), (b.reward, b.steps));
    }
    Map<String, Object?> json(QTable<int, GridAction> table) =>
        table.toJson(encodeState: (s) => s, encodeAction: (a) => a.name);
    expect(json(trace.table), json(base.table));
  });
  test('trace runner bootstraps truncation then clears eligibility', () {
    final agent = SarsaLambdaAgent<int, int>(
        learningRate: 1, discountFactor: 0.5, lambda: 0.8);
    agent.table.set(1, 0, 4);
    final result =
        trainEpisodic(environment: Ending(truncated: true), agent: agent);
    expect(result.truncated, isTrue);
    expect(agent.table.value(0, 0), 3);
    expect(agent.traceCount, 0);
    expect(() => SarsaLambdaAgent<int, int>(lambda: 1.1), throwsArgumentError);
  });
  test('trace runner clears traces after an environment exception', () {
    final agent = SarsaLambdaAgent<int, int>();
    expect(() => trainEpisodic(environment: Broken(), agent: agent),
        throwsStateError);
    expect(agent.traceCount, 0);
  });
}

final class RewardCycle implements Environment<int, int> {
  int _state = 0;
  @override
  int reset() => _state = 0;
  @override
  List<int> actions(int state) => [0];
  @override
  StepResult<int> step(int action) {
    final reward = _state == 0 ? 1.0 : 3.0;
    _state = 1 - _state;
    return StepResult(state: _state, reward: reward);
  }
}

final class Ending implements Environment<int, int> {
  Ending({this.truncated = false});
  final bool truncated;
  @override
  int reset() => 0;
  @override
  List<int> actions(int state) => [0];
  @override
  StepResult<int> step(int action) => StepResult(
      state: 1, reward: 1, terminated: !truncated, truncated: truncated);
}

final class Broken implements Environment<int, int> {
  int _steps = 0;
  @override
  int reset() => _steps = 0;
  @override
  List<int> actions(int state) => [0];
  @override
  StepResult<int> step(int action) {
    if (_steps++ > 0) throw StateError('broken environment');
    return const StepResult(state: 1, reward: 0);
  }
}
