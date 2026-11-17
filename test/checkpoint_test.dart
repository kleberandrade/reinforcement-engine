import 'dart:convert';
import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

Object? encode(int key) => key;
int decode(Object? key) => key as int;
TrainingCheckpoint wire(TrainingCheckpoint c) => TrainingCheckpoint.fromJson(
    jsonDecode(jsonEncode(c.toJson())) as Map<String, dynamic>);

void main() {
  for (final algorithm in LearningAlgorithm.values) {
    test('round trip $algorithm and resume numerical update', () {
      final a = TabularAgent<int, int>(
          algorithm: algorithm,
          learningRate: .25,
          discountFactor: .8,
          epsilon: .4,
          epsilonDecay: .5,
          minEpsilon: .02,
          explorationPolicy: SoftmaxExploration(temperature: .3));
      a.table.set(1, 0, 2);
      a.table.set(2, 0, 4);
      a.decayExploration();
      final c = TrainingCheckpoint.tabular(a,
          encodeState: encode, encodeAction: encode);
      a.table.set(1, 0, 99);
      final b = wire(c).restoreTabular<int, int>(
          decodeState: decode, decodeAction: decode, seed: 9);
      expect(b.algorithm, algorithm);
      expect(b.learningRate, .25);
      expect(b.discountFactor, .8);
      expect(b.epsilon, .2);
      expect(b.epsilonDecay, .5);
      expect(b.minEpsilon, .02);
      expect((b.explorationPolicy as SoftmaxExploration).temperature, .3);
      expect(b.table.value(1, 0), 2);
      b.update(
          state: 1,
          action: 0,
          reward: 1,
          nextState: 2,
          terminated: false,
          nextActions: [0],
          nextAction: 0);
      expect(b.table.value(1, 0), closeTo(2.55, 1e-12));
      expect(a.table.value(1, 0), 99);
      b.decayExploration();
      expect(b.epsilon, .1);
    });
  }
  test(
      'double Q keeps unequal tables independent and starts repeatable new RNG',
      () {
    final a = DoubleQAgent<int, int>(learningRate: 1, discountFactor: 1);
    a.tableA.set(1, 0, 2);
    a.tableB.set(1, 0, 7);
    a.tableA.set(2, 0, 4);
    a.tableB.set(2, 0, 9);
    final c = wire(TrainingCheckpoint.doubleQ(a,
        encodeState: encode, encodeAction: encode));
    final b = c.restoreDoubleQ<int, int>(
        decodeState: decode, decodeAction: decode, seed: 77);
    final twin = c.restoreDoubleQ<int, int>(
        decodeState: decode, decodeAction: decode, seed: 77);
    expect(b.values.value(1, 0), 9);
    for (var i = 0; i < 10; i++) {
      final x = b.update(
          state: 1,
          action: 0,
          reward: 1,
          nextState: 2,
          terminated: false,
          nextActions: [0]);
      final y = twin.update(
          state: 1,
          action: 0,
          reward: 1,
          nextState: 2,
          terminated: false,
          nextActions: [0]);
      expect(x, y);
      expect([5.0, 10.0], contains(x));
    }
    b.tableA.set(1, 0, -1);
    expect(b.tableB.value(1, 0), isNot(-1));
    expect(a.tableA.value(1, 0), 2);
  });
  test('R learning restores rho and continues with correct arithmetic', () {
    final a = RLearningAgent<int, int>(
        initialAverageReward: 1.5,
        learningRate: .2,
        averageRewardRate: .05,
        epsilon: .3);
    a.table.set(0, 0, 2);
    final b = wire(TrainingCheckpoint.rLearning(a,
            encodeState: encode, encodeAction: encode))
        .restoreRLearning<int, int>(decodeState: decode, decodeAction: decode);
    expect(b.averageReward, 1.5);
    expect(b.epsilon, .3);
    b.update(
        state: 0,
        action: 0,
        actions: [0],
        reward: 3,
        nextState: 0,
        nextActions: [0]);
    expect(b.table.value(0, 0), closeTo(2.3, 1e-12));
    expect(b.averageReward, closeTo(1.575, 1e-12));
    expect(a.averageReward, 1.5);
  });
  test(
      'traces must end before checkpoint; restored learner has no stale traces',
      () {
    final a = SarsaLambdaAgent<int, int>(
        lambda: .6, learningRate: .5, discountFactor: 1);
    a.beginEpisode();
    a.update(
        state: 0,
        action: 0,
        reward: 1,
        nextState: 1,
        terminated: false,
        nextActions: [0],
        nextAction: 0);
    expect(
        () => TrainingCheckpoint.sarsaLambda(a,
            encodeState: encode, encodeAction: encode),
        throwsStateError);
    a.endEpisode();
    final b = wire(TrainingCheckpoint.sarsaLambda(a,
            encodeState: encode, encodeAction: encode))
        .restoreSarsaLambda<int, int>(
            decodeState: decode, decodeAction: decode);
    expect(b.lambda, .6);
    expect(b.traceCount, 0);
    b.update(state: 1, action: 0, reward: 4, nextState: 2, terminated: true);
    expect(b.table.value(0, 0), .5);
    expect(b.table.value(1, 0), 2);
  });
  test('detached snapshots and repeated restores do not share mutable data',
      () {
    final a = TabularAgent<int, int>();
    a.table.set(1, 0, 4);
    final c = TrainingCheckpoint.tabular(a,
        encodeState: encode, encodeAction: encode);
    final data = c.toJson();
    (data['config'] as Map)['epsilon'] = 9;
    expect(c.toJson()['config']['epsilon'], 1);
    final parsed = TrainingCheckpoint.fromJson(c.toJson());
    data.clear();
    expect(parsed.toJson(), c.toJson());
    expect(() => c.restoreDoubleQ(decodeState: decode, decodeAction: decode),
        throwsStateError);
  });
  test('malformed formats and numeric/configuration errors are rejected', () {
    final a = TabularAgent<int, int>();
    a.table.set(1, 0, 4);
    final c = TrainingCheckpoint.tabular(a,
        encodeState: encode, encodeAction: encode);
    final mutations = <void Function(Map<String, dynamic>)>[
      (d) => d['version'] = 2,
      (d) => d['kind'] = 'other',
      (d) => d['resume'] = 'exact',
      (d) => d['tables'] = <Object?>[],
      (d) => d['tables'] = [null],
      (d) => d['config'] = null,
      (d) => d['config']['learningRate'] = 0,
      (d) => d['config']['epsilon'] = 2,
      (d) => d['config']['epsilonDecay'] = 0,
      (d) => d['config']['minEpsilon'] = 2,
      (d) => d['config']['discountFactor'] = -1,
      (d) => d['config']['algorithm'] = 'other',
      (d) => d['exploration'] = {'kind': 'custom'},
      (d) => d['exploration'] = {'kind': 'softmax', 'temperature': 0},
      (d) => d['tables'][0]['entries'][0]['value'] = 'invalid',
    ];
    for (final mutate in mutations) {
      final data = c.toJson();
      mutate(data);
      expect(() => TrainingCheckpoint.fromJson(data), throwsFormatException);
    }
  });
  test('decoded key collisions are rejected without changing the source', () {
    final a = TabularAgent<int, int>();
    a.table.set(1, 0, 2);
    a.table.set(2, 0, 3);
    final c = TrainingCheckpoint.tabular(a,
        encodeState: encode, encodeAction: encode);
    expect(
        () => c.restoreTabular<int, int>(
            decodeState: (_) => 0, decodeAction: decode),
        throwsFormatException);
    expect(a.table.value(1, 0), 2);
  });
  test('custom TD callback is never silently replaced by enum strategy', () {
    final a = TabularAgent<int, int>(
        updateRule: ExpectedSarsa(
            probabilities: (_, actions) =>
                [for (final _ in actions) 1 / actions.length]));
    expect(
        () => TrainingCheckpoint.tabular(a,
            encodeState: encode, encodeAction: encode),
        throwsUnsupportedError);
  });
}
