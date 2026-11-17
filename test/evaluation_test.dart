import 'dart:math';
import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

void main() {
  test('evaluation reports success separately from task termination', () {
    final report = evaluatePolicy<int, int>(
      environmentFactory: () => SingleStep(),
      policy: const FirstAction(),
      isSuccess: (state, episode) => false,
      episodes: 3,
    );
    expect(report.episodeCount, 3);
    expect(report.meanReward, 4);
    expect(report.meanSteps, 1);
    expect(report.terminationRate, 1);
    expect(report.truncationRate, 0);
    expect(report.successRate, 0);
    expect(() => report.episodes.clear(), throwsUnsupportedError);
  });

  test('evaluation truncates loops and preserves table and agent exploration',
      () {
    final agent = TabularAgent<int, GridAction>(seed: 42);
    for (var i = 0; i < 500; i++) {
      trainEpisode(environment: GridWorld(), agent: agent, maxSteps: 200);
    }
    final before =
        agent.table.toJson(encodeState: (s) => s, encodeAction: (a) => a.name);
    final epsilon = agent.epsilon;
    final report = evaluatePolicy<int, GridAction>(
      environmentFactory: GridWorld.new,
      policy: GreedyPolicy(agent.table),
      isSuccess: (state, episode) => state == 24 && episode.terminated,
      episodes: 10,
      seed: 42,
      maxSteps: 50,
    );
    expect(report.successRate, 1);
    expect(report.meanSteps, closeTo(8, 1e-12));
    expect(report.meanReward, closeTo(3, 1e-12));
    expect(agent.epsilon, epsilon);
    expect(
        agent.table.toJson(encodeState: (s) => s, encodeAction: (a) => a.name),
        before);
    final loop = evaluatePolicy<int, int>(
        environmentFactory: () => SingleStep(loop: true),
        policy: const FirstAction(),
        isSuccess: (s, e) => false,
        episodes: 2,
        maxSteps: 3);
    expect(loop.truncationRate, 1);
    expect(loop.meanSteps, 3);
    expect(loop.meanReward, 12);
  });

  test('evaluation leaves subsequent seeded training action sequence unchanged',
      () {
    final first = TabularAgent<int, GridAction>(seed: 84);
    final second = TabularAgent<int, GridAction>(seed: 84);
    for (var episode = 0; episode < 50; episode++) {
      trainEpisode(environment: GridWorld(), agent: first, maxSteps: 100);
      trainEpisode(environment: GridWorld(), agent: second, maxSteps: 100);
    }
    evaluatePolicy<int, GridAction>(
        environmentFactory: GridWorld.new,
        policy: GreedyPolicy(first.table),
        episodes: 10,
        maxSteps: 100,
        isSuccess: (state, episode) => episode.terminated && state == 24,
        seed: 42);
    expect(List.generate(100, (_) => first.selectAction(0, GridAction.values)),
        List.generate(100, (_) => second.selectAction(0, GridAction.values)));
  });

  test('greedy ties reproduce with seed and ignore illegal high values', () {
    final table = QTable<int, int>();
    table.set(0, 2, 999);
    final policy = GreedyPolicy(table);
    final a = Random(1);
    final b = Random(1);
    final first = List.generate(100, (_) => policy.selectAction(0, [0, 1], a));
    final second = List.generate(100, (_) => policy.selectAction(0, [0, 1], b));
    expect(first, second);
    expect(first.toSet(), {0, 1});
    table.set(0, 0, -5);
    table.set(0, 1, -2);
    expect(policy.selectAction(0, [0, 1], a), 1);
  });

  test('runner validates policy actions, finite rewards and episode limits',
      () {
    EvaluationResult run(
            {int episodes = 1,
            int maxSteps = 2,
            ActionPolicy<int, int> policy = const FirstAction(),
            double reward = 4,
            bool empty = false}) =>
        evaluatePolicy(
            environmentFactory: () => SingleStep(reward: reward, empty: empty),
            policy: policy,
            isSuccess: (s, e) => false,
            episodes: episodes,
            maxSteps: maxSteps);
    expect(() => run(episodes: 0), throwsArgumentError);
    expect(() => run(maxSteps: 0), throwsArgumentError);
    expect(() => run(policy: const IllegalAction()), throwsArgumentError);
    expect(() => run(reward: double.nan), throwsArgumentError);
    expect(() => run(empty: true), throwsArgumentError);
  });

  test('environment truncation is retained independently of termination', () {
    final report = evaluatePolicy<int, int>(
        environmentFactory: () => SingleStep(truncated: true),
        policy: const FirstAction(),
        isSuccess: (s, e) => false,
        episodes: 1,
        maxSteps: 10);
    expect(report.episodes.single.truncated, isTrue);
    expect(report.episodes.single.terminated, isFalse);
    expect(report.meanSteps, 1);
  });
}

final class FirstAction implements ActionPolicy<int, int> {
  const FirstAction();
  @override
  int selectAction(int state, List<int> actions, Random random) =>
      actions.first;
}

final class IllegalAction implements ActionPolicy<int, int> {
  const IllegalAction();
  @override
  int selectAction(int state, List<int> actions, Random random) => 999;
}

final class SingleStep implements Environment<int, int> {
  SingleStep(
      {this.loop = false,
      this.reward = 4,
      this.empty = false,
      this.truncated = false});
  final bool loop;
  final double reward;
  final bool empty;
  final bool truncated;
  @override
  int reset() => 0;
  @override
  List<int> actions(int state) => empty ? [] : [0];
  @override
  StepResult<int> step(int action) => StepResult(
      state: 1,
      reward: reward,
      terminated: !loop && !truncated,
      truncated: truncated);
}
