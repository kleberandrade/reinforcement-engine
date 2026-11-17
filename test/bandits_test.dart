import 'dart:math';
import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

void main() {
  test('sample means and counts change only on valid observations', () {
    final a = BanditAgent<String>(arms: ['A', 'B'], seed: 42);
    for (var i = 0; i < 10; i++) {
      a.selectArm();
    }
    expect(a.values.observations, 0);
    expect(a.values.mean('A'), 0);
    a.observe('A', 1);
    a.observe('A', 0);
    a.observe('A', .5);
    expect(a.values.mean('A'), .5);
    expect(a.values.count('A'), 3);
    expect(a.values.count('B'), 0);
    for (final reward in [-.1, 1.1, double.nan, double.infinity]) {
      expect(() => a.observe('A', reward), throwsArgumentError);
    }
    expect(() => a.observe('unknown', 1), throwsArgumentError);
    expect(a.values.count('A'), 3);
    expect(a.values.mean('A'), .5);
    expect(a.values.observations, 3);
  });
  test('arms are unique, fixed and detached from input', () {
    final arms = ['A', 'B'];
    final a = BanditAgent(arms: arms);
    arms.add('C');
    expect(a.arms, ['A', 'B']);
    expect(() => a.arms.add('D'), throwsUnsupportedError);
    expect(() => BanditAgent<int>(arms: []), throwsArgumentError);
    expect(() => BanditAgent<String>(arms: ['A', 'A']), throwsArgumentError);
  });
  test('UCB1 samples every unseen arm before revisiting', () {
    final a = BanditAgent<String>(
        arms: ['A', 'B', 'C'], policy: const Ucb1(), seed: 42);
    final selected = <String>{};
    for (var i = 0; i < 3; i++) {
      final arm = a.selectArm();
      expect(selected.add(arm), isTrue);
      a.observe(arm, 1);
    }
    expect(selected, {'A', 'B', 'C'});
  });
  test('UCB1 score can favor uncertainty over the highest sample mean', () {
    final a =
        BanditAgent<String>(arms: ['A', 'B'], policy: const Ucb1(), seed: 7);
    for (var i = 0; i < 100; i++) {
      a.observe('A', .8);
    }
    a.observe('B', .2);
    // A: .8 + sqrt(2 ln101/100) = 1.104; B: .2 + sqrt(2 ln101) = 3.238.
    expect(a.selectArm(), 'B');
  });
  test('epsilon zero exploits means, epsilon one explores uniformly', () {
    final greedy = BanditAgent<int>(
        arms: [0, 1], policy: EpsilonGreedyBandit(epsilon: 0), seed: 42);
    greedy.observe(0, .2);
    greedy.observe(1, .8);
    for (var i = 0; i < 100; i++) {
      expect(greedy.selectArm(), 1);
    }
    final exploring = BanditAgent<int>(
        arms: [0, 1], policy: EpsilonGreedyBandit(epsilon: 1), seed: 42);
    exploring.observe(0, 0);
    exploring.observe(1, 1);
    var first = 0;
    for (var i = 0; i < 10000; i++) {
      if (exploring.selectArm() == 0) first++;
    }
    expect(first, inInclusiveRange(4700, 5300));
  });
  test('tied greedy means allow every tied arm with seeded repeatability', () {
    final a = BanditAgent<int>(
        arms: [0, 1, 2], policy: EpsilonGreedyBandit(epsilon: 0), seed: 9);
    final b = BanditAgent<int>(
        arms: [0, 1, 2], policy: EpsilonGreedyBandit(epsilon: 0), seed: 9);
    final selected = <int>{};
    for (var i = 0; i < 100; i++) {
      final x = a.selectArm();
      selected.add(x);
      expect(x, b.selectArm());
    }
    expect(selected, {0, 1, 2});
  });
  test('bandit runner reports window counts and preserves prior observations',
      () {
    final a = BanditAgent<String>(arms: ['A'], policy: const Ucb1());
    a.observe('A', 0);
    final report = trainBandit(agent: a, pulls: 4, reward: (_) => .5);
    expect(report.pulls, 4);
    expect(report.reward, 2);
    expect(report.meanReward, .5);
    expect(report.counts, {'A': 4});
    expect(a.values.count('A'), 5);
    expect(a.values.mean('A'), closeTo(.4, 1e-12));
    expect(() => report.counts['A'] = 0, throwsUnsupportedError);
    expect(() => trainBandit(agent: a, pulls: 0, reward: (_) => 1),
        throwsArgumentError);
  });
  test('runner propagates callback errors and preserves earlier valid pulls',
      () {
    final a = BanditAgent<int>(arms: [0]);
    var calls = 0;
    expect(
        () => trainBandit(
            agent: a,
            pulls: 4,
            reward: (_) {
              if (++calls == 3) throw StateError('feedback failed');
              return 1;
            }),
        throwsStateError);
    expect(a.values.observations, 2);
    expect(() => trainBandit(agent: a, pulls: 1, reward: (_) => 9),
        throwsArgumentError);
    expect(a.values.observations, 2);
  });
  test('custom policy uses public read-only contracts; illegal arm rejected',
      () {
    final a = BanditAgent<int>(arms: [0, 1], policy: const LastArm());
    expect(a.selectArm(), 1);
    final invalid = BanditAgent<int>(arms: [0], policy: const LastArm());
    expect(() => invalid.selectArm(), throwsArgumentError);
    expect(invalid.values.observations, 0);
  });
  for (final policy in <BanditPolicy<int>>[
    EpsilonGreedyBandit(epsilon: .1),
    const Ucb1(),
  ]) {
    test(
        '${policy.runtimeType} prioritizes best deterministic arm across seeds',
        () {
      for (var seed = 0; seed < 10; seed++) {
        final a = BanditAgent<int>(arms: [0, 1, 2], policy: policy, seed: seed);
        trainBandit(agent: a, pulls: 3000, reward: (arm) => [.1, .4, .9][arm]);
        expect(a.values.count(2), greaterThan(2400));
        expect(a.values.mean(2), .9);
        expect(a.values.observations, 3000);
      }
    });
  }
  test('invalid epsilon is rejected', () {
    for (final value in [-1.0, 1.1, double.nan, double.infinity]) {
      expect(
          () => EpsilonGreedyBandit<int>(epsilon: value), throwsArgumentError);
    }
  });
}

final class LastArm implements BanditPolicy<int> {
  const LastArm();
  @override
  int selectArm(
          {required List<int> arms,
          required BanditValues<int> values,
          required Random random}) =>
      1;
}
