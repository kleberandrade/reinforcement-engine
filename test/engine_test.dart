import 'dart:convert';
import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

void main() {
  test('Q-learning uses maximum legal next value, including negatives', () {
    final agent =
        TabularAgent<String, int>(learningRate: 0.5, discountFactor: 0.9);
    agent.table.set('s', 0, 2);
    agent.table.set('next', 0, -4);
    agent.table.set('next', 1, -2);
    agent.table.set('next', 2, 100); // Illegal action must not participate.
    expect(
        agent.update(
            state: 's',
            action: 0,
            reward: 1,
            nextState: 'next',
            terminated: false,
            nextActions: [0, 1]),
        closeTo(0.6, 1e-12));
  });
  test('SARSA uses sampled behavior action instead of maximum', () {
    final agent = TabularAgent<int, int>(
        algorithm: LearningAlgorithm.sarsa,
        learningRate: 0.5,
        discountFactor: 0.9);
    agent.table.set(1, 0, 10);
    agent.table.set(1, 1, 2);
    expect(
        agent.update(
            state: 0,
            action: 0,
            reward: 1,
            nextState: 1,
            terminated: false,
            nextActions: [0, 1],
            nextAction: 1),
        closeTo(1.4, 1e-12));
    expect(
        () => agent.update(
            state: 0,
            action: 0,
            reward: 1,
            nextState: 1,
            terminated: false,
            nextActions: [0, 1]),
        throwsArgumentError);
  });
  for (final algorithm in LearningAlgorithm.values) {
    test('$algorithm terminal transition ignores next values', () {
      final agent =
          TabularAgent<int, int>(algorithm: algorithm, learningRate: 1);
      agent.table.set(1, 0, 999);
      expect(
          agent.update(
              state: 0, action: 0, reward: 7, nextState: 1, terminated: true),
          7);
    });
    test('$algorithm learns shortest default maze path', () {
      final env = GridWorld();
      final agent = TabularAgent<int, GridAction>(
          algorithm: algorithm, seed: 42, learningRate: 0.2);
      for (var i = 0; i < 500; i++) {
        trainEpisode(environment: env, agent: agent, maxSteps: 200);
      }
      var state = env.reset();
      var steps = 0;
      while (state != env.goal && steps < 40) {
        state = env
            .step(agent.selectAction(state, env.actions(state), explore: false))
            .state;
        steps++;
      }
      expect(state, env.goal);
      expect(steps, 8);
    });
    test('$algorithm truncation bootstraps and stops', () {
      final agent = TabularAgent<int, int>(
          algorithm: algorithm, learningRate: 1, discountFactor: 0.5);
      agent.table.set(1, 0, 4);
      final result =
          trainEpisode(environment: OneStep(truncated: true), agent: agent);
      expect(agent.table.value(0, 0), 3);
      expect(result.truncated, isTrue);
      expect(result.terminated, isFalse);
      expect(result.steps, 1);
    });
  }
  test('runner time limit stops nonterminating environment', () {
    final result = trainEpisode(
        environment: Loop(), agent: TabularAgent<int, int>(), maxSteps: 3);
    expect(result.steps, 3);
    expect(result.reward, -3);
    expect(result.truncated, isTrue);
    expect(
        () => trainEpisode(
            environment: Loop(), agent: TabularAgent<int, int>(), maxSteps: 0),
        throwsArgumentError);
  });
  test('SARSA carries the exact sampled action into the next step', () {
    final env = TwoSteps();
    final agent = TabularAgent<int, int>(
        algorithm: LearningAlgorithm.sarsa,
        learningRate: 1,
        discountFactor: 1,
        epsilon: 1,
        seed: 18);
    agent.table.set(1, 0, 3);
    agent.table.set(1, 1, 9);
    trainEpisode(environment: env, agent: agent);
    expect(agent.table.value(0, 0), env.secondAction == 0 ? 3 : 9);
  });
  test('same seeds reproduce actions and training', () {
    final a = TabularAgent<int, int>(seed: 123);
    final b = TabularAgent<int, int>(seed: 123);
    expect(List.generate(100, (_) => a.selectAction(0, [0, 1, 2])),
        List.generate(100, (_) => b.selectAction(0, [0, 1, 2])));
  });
  test('greedy mode ignores epsilon and supports negative values', () {
    final a = TabularAgent<int, int>(epsilon: 1, seed: 12);
    a.table.set(0, 0, -2);
    a.table.set(0, 1, -1);
    expect(List.generate(30, (_) => a.selectAction(0, [0, 1], explore: false)),
        everyElement(1));
    expect(() => a.selectAction(0, []), throwsArgumentError);
  });
  test('epsilon decay respects floor', () {
    final a = TabularAgent<int, int>(
        epsilon: 0.4, epsilonDecay: 0.5, minEpsilon: 0.1);
    for (var i = 0; i < 10; i++) {
      a.decayExploration();
    }
    expect(a.epsilon, 0.1);
  });
  test('invalid configuration and numeric boundaries are rejected', () {
    expect(() => TabularAgent<int, int>(learningRate: 0), throwsArgumentError);
    expect(() => TabularAgent<int, int>(discountFactor: double.nan),
        throwsArgumentError);
    expect(() => TabularAgent<int, int>(epsilon: 0.1, minEpsilon: 0.2),
        throwsArgumentError);
    expect(
        () => TabularAgent<int, int>(epsilonDecay: 1.1), throwsArgumentError);
    final a = TabularAgent<int, int>();
    expect(
        () => a.update(
            state: 0,
            action: 0,
            reward: double.infinity,
            nextState: 1,
            terminated: true),
        throwsArgumentError);
    expect(
        () => a.update(
            state: 0, action: 0, reward: 1, nextState: 1, terminated: false),
        throwsArgumentError);
  });
  test('JSON round trip preserves typed values and rejects invalid data', () {
    final t = QTable<int, GridAction>();
    expect(t.value(0, GridAction.up), 0);
    expect(t.stateCount, 0);
    t.set(3, GridAction.right, -2.5);
    final json = jsonDecode(jsonEncode(
            t.toJson(encodeState: (s) => s, encodeAction: (a) => a.name)))
        as Map<String, dynamic>;
    final restored = QTable.fromJson<int, GridAction>(json,
        decodeState: (v) => v as int,
        decodeAction: (v) => GridAction.values.byName(v as String));
    expect(restored.value(3, GridAction.right), -2.5);
    expect(
        () => QTable.fromJson<int, int>({'version': 2, 'entries': <Object?>[]},
            decodeState: (v) => v as int, decodeAction: (v) => v as int),
        throwsFormatException);
    expect(
        () => QTable.fromJson<int, int>({
              'version': 1,
              'entries': [
                {'state': 0, 'action': 0, 'value': double.nan}
              ]
            }, decodeState: (v) => v as int, decodeAction: (v) => v as int),
        throwsFormatException);
    expect(() => t.set(0, GridAction.up, double.infinity), throwsArgumentError);
    restored.clear();
    expect(restored.stateCount, 0);
  });
  test('grid respects walls, boundaries, terminal and reset', () {
    final env = GridWorld(width: 3, height: 2, walls: {1});
    expect(env.step(GridAction.up).state, 0);
    expect(env.step(GridAction.right).state, 0);
    expect(env.step(GridAction.down).state, 3);
    expect(env.step(GridAction.right).state, 4);
    final result = env.step(GridAction.right);
    expect(result.terminated, isTrue);
    expect(result.reward, 10);
    expect(env.actions(5), isEmpty);
    expect(() => env.step(GridAction.left), throwsStateError);
    expect(env.reset(), 0);
    expect(() => GridWorld(width: 0), throwsArgumentError);
    expect(() => GridWorld(walls: {0}), throwsArgumentError);
  });
}

class OneStep implements Environment<int, int> {
  OneStep({required this.truncated});
  final bool truncated;
  @override
  int reset() => 0;
  @override
  List<int> actions(int state) => [0];
  @override
  StepResult<int> step(int action) => StepResult(
      state: 1, reward: 1, terminated: !truncated, truncated: truncated);
}

class Loop implements Environment<int, int> {
  @override
  int reset() => 0;
  @override
  List<int> actions(int state) => [0];
  @override
  StepResult<int> step(int action) => const StepResult(state: 0, reward: -1);
}

class TwoSteps implements Environment<int, int> {
  int current = 0;
  int? secondAction;
  @override
  int reset() => current = 0;
  @override
  List<int> actions(int state) => state == 0 ? [0] : [0, 1];
  @override
  StepResult<int> step(int action) {
    if (current == 1) secondAction = action;
    current++;
    return StepResult(state: current, reward: 0, terminated: current == 2);
  }
}
