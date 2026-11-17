# Policy evaluation and Cliff Walking

Available in development `0.2.0-dev.1`; not part of the initial `0.1.0` release.

Training modifies the table and exploration. Evaluation measures a fixed policy
through `ActionPolicy<S, A>`. `GreedyPolicy` reads Q-values and randomizes ties
using the evaluation RNG. The evaluator never uses the agent, its epsilon or its
training RNG. The factory must create an independent environment per episode;
stochastic environments need their own seeds. Do not mutate the table through
callbacks during evaluation.

```dart
final report = evaluatePolicy<int, GridAction>(
  environmentFactory: GridWorld.new,
  policy: GreedyPolicy(agent.table),
  isSuccess: (state, episode) => episode.terminated && state == 24,
  episodes: 50,
  maxSteps: 100,
  seed: 7,
);
print(report.successRate);
print(report.meanReward);
print(report.meanSteps);
```

`isSuccess` is required: task termination may represent failure.
The report holds an immutable episode list, success count and success,
termination and truncation rates. Rewards are validated; return overflow, illegal
actions and empty action lists are rejected. `maxSteps` truncates unfinished
episodes. An environment may signal both termination and truncation, in which
case both rates count that episode. Means use floating-point arithmetic.

## Cliff Walking

The default environment has 12 columns and 4 rows. States are row-major cell
indices. Start is 36, goal is 47, and cells 37–46 form the cliff.

| Event | Reward | Outcome |
| --- | --- | --- |
| Ordinary step or boundary collision | -1 | Continue |
| Cliff fall | -100 | Return to start without termination |
| Goal | -1 | Terminate |

The shortest safe route takes 13 steps. Run:

```sh
dart run example/evaluation.dart
```

The example trains 2,000 episodes with fixed epsilon 0.1, alpha 0.5 and discount 1,
then evaluates 100 episodes without exploration. On the local runtime with training
seed 42 and evaluation seed 7, Q-Learning took 13 moves and SARSA took 17, both
with 100% success. This illustrates learned policies in one specific environment;
it establishes neither general superiority nor real-world performance.
The Flutter lab provides **Avaliar ×50** for GridWorld without altering training.
