import 'dart:math';
import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

void main() {
  test('Expected SARSA weights tied greedy actions and exploration exactly',
      () {
    final agent = TabularAgent<int, int>(
        algorithm: LearningAlgorithm.expectedSarsa,
        learningRate: 1,
        discountFactor: 0.5,
        epsilon: 0.2,
        minEpsilon: 0.1);
    agent.table.set(1, 0, 10);
    agent.table.set(1, 1, 10);
    agent.table.set(1, 2, -2);
    agent.table.set(1, 3, 1000); // illegal
    // Probabilities: 7/15, 7/15, 1/15; expected value 9.2.
    expect(
        agent.update(
            state: 0,
            action: 0,
            reward: 1,
            nextState: 1,
            terminated: false,
            nextActions: [0, 1, 2]),
        closeTo(5.6, 1e-12));
    expect(
        agent.update(
            state: 0, action: 0, reward: 7, nextState: 1, terminated: true),
        7);
  });
  test('Expected SARSA uses current decayed exploration probability', () {
    final agent = TabularAgent<int, int>(
        algorithm: LearningAlgorithm.expectedSarsa,
        learningRate: 1,
        discountFactor: 1,
        epsilon: 1,
        epsilonDecay: 0.5,
        minEpsilon: 0);
    agent.table.set(1, 0, 10);
    agent.table.set(1, 1, 0);
    agent.decayExploration();
    expect(
        agent.update(
            state: 0,
            action: 0,
            reward: 0,
            nextState: 1,
            terminated: false,
            nextActions: [0, 1]),
        7.5);
  });
  test('Expected SARSA rejects invalid distributions before table mutation',
      () {
    for (final probabilities in <List<double>>[
      [1],
      [-1, 2],
      [0.2, 0.2],
      [double.nan, 1]
    ]) {
      final agent = TabularAgent<int, int>(
          updateRule:
              ExpectedSarsa(probabilities: (s, actions) => probabilities));
      expect(
          () => agent.update(
              state: 0,
              action: 0,
              reward: 1,
              nextState: 1,
              terminated: false,
              nextActions: [0, 1]),
          throwsArgumentError);
      expect(agent.table.stateCount, 0);
    }
  });
  test('Expected SARSA follows a custom softmax behavior distribution', () {
    final agent = TabularAgent<int, int>(
        algorithm: LearningAlgorithm.expectedSarsa,
        explorationPolicy: SoftmaxExploration(temperature: 2),
        learningRate: 1,
        discountFactor: 1,
        epsilon: 0,
        minEpsilon: 0);
    agent.table.set(1, 0, 2);
    agent.table.set(1, 1, 0);
    expect(
        agent.update(
            state: 0,
            action: 0,
            reward: 0,
            nextState: 1,
            terminated: false,
            nextActions: [0, 1]),
        closeTo(2 / (1 + exp(-1)), 1e-12));
  });

  test('Double Q seeds reproduce both tables and episode outcomes', () {
    final a = DoubleQAgent<int, GridAction>(seed: 42);
    final b = DoubleQAgent<int, GridAction>(seed: 42);
    for (var episode = 0; episode < 100; episode++) {
      final x = trainEpisode(environment: GridWorld(), agent: a, maxSteps: 100);
      final y = trainEpisode(environment: GridWorld(), agent: b, maxSteps: 100);
      expect((x.reward, x.steps), (y.reward, y.steps));
    }
    Map<String, Object?> json(QTable<int, GridAction> table) =>
        table.toJson(encodeState: (s) => s, encodeAction: (a) => a.name);
    expect(json(a.tableA), json(b.tableA));
    expect(json(a.tableB), json(b.tableB));
    expect(a.epsilon, b.epsilon);
  });

  test('Double Q selects with one estimator and evaluates with the other', () {
    final agent =
        DoubleQAgent<int, int>(learningRate: 1, discountFactor: 0.5, seed: 42);
    agent.tableA.set(1, 0, 10);
    agent.tableA.set(1, 1, 2);
    agent.tableB.set(1, 0, 1);
    agent.tableB.set(1, 1, 20);
    // If A is updated: target = 3 + .5*B(1,0) = 3.5.
    // If B is updated: target = 3 + .5*A(1,1) = 4.
    final updated = agent.update(
        state: 0,
        action: 0,
        reward: 3,
        nextState: 1,
        terminated: false,
        nextActions: [0, 1]);
    final updatedA = agent.tableA.stateCount == 2;
    expect(updated, updatedA ? 3.5 : 4);
    expect(agent.tableA.value(0, 0), updatedA ? 3.5 : 0);
    expect(agent.tableB.value(0, 0), updatedA ? 0 : 4);
  });
  test('Double Q terminal updates ignore next values and tables cannot alias',
      () {
    final table = QTable<int, int>();
    expect(() => DoubleQAgent<int, int>(tableA: table, tableB: table),
        throwsArgumentError);
    final agent = DoubleQAgent<int, int>(learningRate: 1, seed: 7);
    expect(
        agent.update(
            state: 0, action: 0, reward: -7, nextState: 1, terminated: true),
        -7);
    expect(agent.values.value(0, 0), -7);
    expect(
        () => agent.update(
            state: 0,
            action: 0,
            reward: double.nan,
            nextState: 1,
            terminated: true),
        throwsArgumentError);
  });
  test(
      'Double Q covers both estimator update branches and excludes illegal actions',
      () {
    final seen = <bool>{};
    for (var seed = 0; seed < 20; seed++) {
      final agent = DoubleQAgent<int, int>(
          learningRate: 1, discountFactor: 1, seed: seed);
      agent.tableA.set(1, 0, -2);
      agent.tableA.set(1, 1, -4);
      agent.tableB.set(1, 0, -9);
      agent.tableB.set(1, 1, -3);
      agent.tableA.set(1, 2, 999);
      agent.tableB.set(1, 2, 999);
      agent.update(
          state: 0,
          action: 0,
          reward: 1,
          nextState: 1,
          terminated: false,
          nextActions: [0, 1]);
      final updateA = agent.tableA.stateCount == 2;
      seen.add(updateA);
      expect(agent.values.value(0, 0), updateA ? -8 : -3);
    }
    expect(seen, {true, false});
  });

  test('default exploration retains v0.1 seeded action selection semantics',
      () {
    final agent = TabularAgent<int, int>(epsilon: 0.4, seed: 17);
    agent.table.set(0, 0, 3);
    agent.table.set(0, 1, 3);
    agent.table.set(0, 2, -1);
    final random = Random(17);
    final reference = List.generate(100, (_) {
      if (random.nextDouble() < 0.4) return [0, 1, 2][random.nextInt(3)];
      return [0, 1][random.nextInt(2)];
    });
    expect(
        List.generate(100, (_) => agent.selectAction(0, [0, 1, 2])), reference);
  });

  test('softmax sampled actions match probabilities and reproduce with seed',
      () {
    final table = QTable<int, int>();
    table.set(0, 0, 1);
    final policy = SoftmaxExploration<int, int>(temperature: 1);
    final a = Random(77);
    final b = Random(77);
    final first = List.generate(
        10000,
        (_) => policy.selectAction(
            state: 0, actions: [0, 1], values: table, epsilon: 0, random: a));
    final second = List.generate(
        10000,
        (_) => policy.selectAction(
            state: 0, actions: [0, 1], values: table, epsilon: 1, random: b));
    expect(first, second); // Fixed-temperature softmax ignores epsilon.
    expect(first.where((action) => action == 0).length / first.length,
        closeTo(1 / (1 + exp(-1)), 0.02));
  });

  test(
      'Double Q tables restore independently and the combined values stay live',
      () {
    final first = QTable<int, int>()..set(0, 0, 3);
    final second = QTable<int, int>()..set(0, 0, 7);
    QTable<int, int> restore(QTable<int, int> table) =>
        QTable.fromJson<int, int>(
            table.toJson(encodeState: (s) => s, encodeAction: (a) => a),
            decodeState: (v) => v as int,
            decodeAction: (v) => v as int);
    final agent =
        DoubleQAgent<int, int>(tableA: restore(first), tableB: restore(second));
    expect(agent.values.value(0, 0), 10);
    agent.tableA.set(0, 0, 4);
    expect(agent.values.value(0, 0), 11);
    expect(first.value(0, 0), 3);
    expect(agent.tableB.value(0, 0), 7);
  });

  test('epsilon greedy probabilities agree with tie semantics', () {
    final table = QTable<int, int>();
    table.set(0, 0, 4);
    table.set(0, 1, 4);
    table.set(0, 2, 1);
    final probabilities = const EpsilonGreedy<int, int>().probabilities(
        state: 0, actions: [0, 1, 2], values: table, epsilon: 0.3);
    expect(probabilities[0], closeTo(0.45, 1e-12));
    expect(probabilities[1], closeTo(0.45, 1e-12));
    expect(probabilities[2], closeTo(0.1, 1e-12));
  });
  test('softmax is stable for large values and exposes matching probabilities',
      () {
    final table = QTable<int, int>();
    table.set(0, 0, 10000);
    table.set(0, 1, 9999);
    final policy = SoftmaxExploration<int, int>(temperature: 1);
    final p = policy.probabilities(
        state: 0, actions: [0, 1], values: table, epsilon: 1);
    expect(p[0], closeTo(1 / (1 + exp(-1)), 1e-12));
    expect(p.reduce((a, b) => a + b), closeTo(1, 1e-12));
    expect(() => SoftmaxExploration<int, int>(temperature: 0),
        throwsArgumentError);
    final agent = TabularAgent<int, int>(
        explorationPolicy: policy, table: table, seed: 1);
    expect(
        List.generate(30, (_) => agent.selectAction(0, [0, 1], explore: false)),
        everyElement(0));
  });
  test('new algorithms train through the common bounded runner', () {
    final agents = <LearningAgent<int, GridAction>>[
      TabularAgent(
          algorithm: LearningAlgorithm.expectedSarsa,
          seed: 42,
          learningRate: 0.2),
      DoubleQAgent(seed: 42, learningRate: 0.2),
    ];
    for (final agent in agents) {
      for (var i = 0; i < 500; i++) {
        trainEpisode(environment: GridWorld(), agent: agent, maxSteps: 200);
      }
      final report = evaluatePolicy<int, GridAction>(
          environmentFactory: GridWorld.new,
          policy: GreedyPolicy(agent.values),
          episodes: 10,
          maxSteps: 50,
          seed: 7,
          isSuccess: (state, result) => result.terminated && state == 24);
      expect(report.successRate, 1);
      expect(report.meanSteps, closeTo(8, 1e-12));
    }
  });
}
