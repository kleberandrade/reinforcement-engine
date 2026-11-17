import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

void main() {
  test('uses max bootstrap but cuts traces after nongreedy behavior action',
      () {
    final a = WatkinsQLambdaAgent<int, String>(
        learningRate: .5, discountFactor: 1, lambda: .8);
    a.table.set(1, 'best', 4);
    a.table.set(1, 'other', 1);
    final value = a.update(
        state: 0,
        action: 'go',
        reward: 2,
        nextState: 1,
        terminated: false,
        nextActions: ['best', 'other'],
        nextAction: 'other');
    expect(value, 3);
    expect(a.traceCount, 0);
    a.update(
        state: 1, action: 'other', reward: 10, nextState: 2, terminated: true);
    expect(a.table.value(0, 'go'), 3);
  });
  test('greedy continuation propagates terminal reward to earlier pairs', () {
    final a = WatkinsQLambdaAgent<int, String>(
        learningRate: .5, discountFactor: 1, lambda: .8);
    a.update(
        state: 0,
        action: 'go',
        reward: 0,
        nextState: 1,
        terminated: false,
        nextActions: ['go'],
        nextAction: 'go');
    expect(a.traceCount, 1);
    a.update(
        state: 1, action: 'go', reward: 10, nextState: 2, terminated: true);
    expect(a.table.value(0, 'go'), 4);
    expect(a.table.value(1, 'go'), 5);
    expect(a.traceCount, 0);
  });
  test('ties are greedy and greediness is captured before self-loop writes',
      () {
    final a = WatkinsQLambdaAgent<int, String>(
        learningRate: 1, discountFactor: 1, lambda: .5);
    a.table.set(0, 'a', 2);
    a.table.set(0, 'b', 2);
    a.update(
        state: 0,
        action: 'a',
        reward: 10,
        nextState: 0,
        terminated: false,
        nextActions: ['a', 'b'],
        nextAction: 'b');
    expect(a.table.value(0, 'a'), 12);
    expect(a.traceCount, 1); // b was tied before a increased to 12.
    a.update(state: 1, action: 'x', reward: 2, nextState: 2, terminated: true);
    expect(a.table.value(0, 'a'), 13);
  });
  test('repeated visits accumulate eligibility', () {
    final a = WatkinsQLambdaAgent<int, int>(
        learningRate: 1, discountFactor: 1, lambda: .5);
    for (var i = 0; i < 2; i++) {
      a.update(
          state: 0,
          action: 0,
          reward: 0,
          nextState: 0,
          terminated: false,
          nextActions: [0],
          nextAction: 0);
    }
    a.update(state: 0, action: 0, reward: 4, nextState: 1, terminated: true);
    expect(a.table.value(0, 0), 7); // e = 1 + .5 * (1 + .5).
  });
  test('lambda zero equals Q-learning on the same explicit transitions', () {
    final a = WatkinsQLambdaAgent<int, int>(lambda: 0);
    final b = TabularAgent<int, int>();
    for (var i = 0; i < 30; i++) {
      final done = i % 3 == 2;
      final expected = b.update(
          state: i % 3,
          action: 0,
          reward: 1,
          nextState: (i + 1) % 3,
          terminated: done,
          nextActions: [0]);
      expect(
          a.update(
              state: i % 3,
              action: 0,
              reward: 1,
              nextState: (i + 1) % 3,
              terminated: done,
              nextActions: [0],
              nextAction: 0),
          expected);
      expect(a.traceCount, 0);
    }
  });
  test('truncation bootstraps before lifecycle clears traces', () {
    final a =
        WatkinsQLambdaAgent<int, int>(learningRate: 1, discountFactor: .5);
    a.table.set(0, 0, 4);
    final result = trainEpisodic(environment: Loop(), agent: a, maxSteps: 1);
    expect(result.truncated, isTrue);
    expect(a.table.value(0, 0), 3);
    expect(a.traceCount, 0);
  });
  test('invalid update and multi-cell overflow do not partially commit', () {
    final a = WatkinsQLambdaAgent<int, int>(
        learningRate: 1, discountFactor: 1, lambda: 1);
    a.update(
        state: 0,
        action: 0,
        reward: 0,
        nextState: 1,
        terminated: false,
        nextActions: [0],
        nextAction: 0);
    expect(
        () => a.update(
            state: 1,
            action: 0,
            reward: 1,
            nextState: 2,
            terminated: false,
            nextActions: [0],
            nextAction: 9),
        throwsArgumentError);
    expect(a.traceCount, 1);
    a.table.set(0, 0, 1e308);
    expect(
        () => a.update(
            state: 1, action: 0, reward: 1e308, nextState: 2, terminated: true),
        throwsArgumentError);
    expect(a.table.value(0, 0), 1e308);
    expect(a.table.value(1, 0), 0);
    expect(a.traceCount, 1);
  });
  test(
      'boundary checkpoint restores Watkins configuration and rejects active traces',
      () {
    final a = WatkinsQLambdaAgent<int, int>(
        lambda: .7, epsilon: .3, epsilonDecay: .9, learningRate: .2);
    a.table.set(1, 0, 4);
    a.decayExploration();
    final c = TrainingCheckpoint.watkinsQLambda(a,
        encodeState: (s) => s, encodeAction: (a) => a);
    final b = TrainingCheckpoint.fromJson(c.toJson())
        .restoreWatkinsQLambda<int, int>(
            decodeState: (s) => s as int,
            decodeAction: (a) => a as int,
            seed: 99);
    expect(b.lambda, .7);
    expect(b.epsilon, a.epsilon);
    expect(b.table.value(1, 0), 4);
    expect(b.traceCount, 0);
    a.update(
        state: 0,
        action: 0,
        reward: 0,
        nextState: 1,
        terminated: false,
        nextActions: [0],
        nextAction: 0);
    expect(
        () => TrainingCheckpoint.watkinsQLambda(a,
            encodeState: (s) => s, encodeAction: (a) => a),
        throwsStateError);
  });
  test('episode exception clears traces while retaining learned values', () {
    final a = WatkinsQLambdaAgent<int, int>();
    expect(() => trainEpisodic(environment: Loop(fail: true), agent: a),
        throwsStateError);
    expect(a.traceCount, 0);
    expect(a.table.stateCount, 1);
  });
  test('invalid constructor configuration is rejected', () {
    for (final value in [-1.0, 1.1, double.nan, double.infinity]) {
      expect(() => WatkinsQLambdaAgent<int, int>(lambda: value),
          throwsArgumentError);
    }
  });
}

final class Loop implements Environment<int, int> {
  Loop({this.fail = false});
  final bool fail;
  int steps = 0;
  @override
  int reset() {
    steps = 0;
    return 0;
  }

  @override
  List<int> actions(int state) => [0];
  @override
  StepResult<int> step(int action) {
    if (fail && steps++ == 1) throw StateError('environment failed');
    return const StepResult(state: 0, reward: 1);
  }
}
