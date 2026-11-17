# Tabular control and exploration strategies

Implemented in `0.2.0-dev.2`, not yet published. Version `0.1.0` retains its
Q-Learning/SARSA API; existing constructors and TD extension contracts remain available.

## Choosing an agent

| Algorithm | Construction | Nonterminal bootstrap |
| --- | --- | --- |
| Q-Learning | `TabularAgent(algorithm: LearningAlgorithm.qLearning)` | Maximum legal next Q-value |
| SARSA | `TabularAgent(algorithm: LearningAlgorithm.sarsa)` | Value of sampled and reused next action |
| Expected SARSA | `TabularAgent(algorithm: LearningAlgorithm.expectedSarsa)` | Sum of `probability(a) * Q(nextState, a)` |
| Double Q-Learning | `DoubleQAgent()` | Select with one table, evaluate with the other |

`LearningAgent<S, A>` lets all four agents use `trainEpisode`. It exposes read-only
values, action selection, updating and per-episode decay. `ActionValues<S, A>` is
the minimal value-reading interface. `QTable` implements it; `SumActionValues`
combines two estimators without copying or mutating either table.

## Expected SARSA

```dart
final agent = TabularAgent<int, GridAction>(
  algorithm: LearningAlgorithm.expectedSarsa,
  epsilon: 0.2,
  epsilonDecay: 0.995,
  minEpsilon: 0.01,
  seed: 42,
);
```

The constructor binds bootstrap to the current behavior-policy probabilities,
including epsilon after each decay. For epsilon-greedy, every action receives
`epsilon / actionCount`; the remaining `1 - epsilon` is shared by all maximum-valued
actions. Tie handling and negative values match actual behavior selection.

Bootstrap samples no action. Terminal targets use reward alone; truncation retains
bootstrap. Probabilities must be finite, nonnegative, match the legal-action count
and sum to one within `1e-10`. When constructing `ExpectedSarsa(probabilities: ...)`
directly, callers must supply a distribution matching their policy. The enum
constructor binds it automatically. The earlier uniform-mean extension example
remains an illustrative contract, not an epsilon-greedy algorithm implementation.

## Double Q-Learning

```dart
final agent = DoubleQAgent<int, GridAction>(seed: 42);
final result = trainEpisode(environment: GridWorld(), agent: agent, maxSteps: 200);
final policy = GreedyPolicy(agent.values);
```

The agent owns independent `tableA` and `tableB`; aliasing the same table is
rejected. Behavior consults their sum. Each update chooses one estimator with
probability 0.5. To update A, it selects a greedy next-state action using A and
reads B to evaluate that action; updating B is symmetric. Only the chosen table
is written. `update()` returns that estimator's new value, not the sum.
Combined values form a live read-only view. The same seed and call order reproduce
both tables within one runtime. Save and restore each table separately; this
preserves neither epsilon, RNG nor environment state and is not an exact checkpoint.

## Composable exploration

```dart
final agent = TabularAgent<int, GridAction>(
  algorithm: LearningAlgorithm.expectedSarsa,
  explorationPolicy: SoftmaxExploration(temperature: 0.5),
  seed: 42,
);
```

`ExplorationPolicy<S, A>` supplies coherent action selection and probabilities.
`EpsilonGreedy` is the default and preserves the `0.1.0` RNG call order.
`SoftmaxExploration` uses a fixed positive temperature and subtracts the maximum
before exponentiation to avoid positive overflow. It ignores epsilon; agent decay
does not cool temperature. For evaluation, `explore: false` and `GreedyPolicy`
choose greedily regardless of training exploration. The lab retains epsilon-greedy
as its default, so its exploration display describes epsilon.

The engine does not inspect concrete policy types. Custom strategies must keep
selection and probability distributions equivalent and must not mutate received
values or action lists. Returned actions outside the legal list are rejected.

## Examples and limits

```sh
dart run example/evaluation.dart
dart run example/exploration.dart
```

With 2,000 Cliff Walking training episodes, alpha 0.5, discount 1, fixed epsilon
0.1, seed 42 and greedy evaluation seed 7, the local runtime produced 13 steps for
Q-Learning, 17 for SARSA, 15 for Expected SARSA and 17 for Double Q. All 100 evaluation
episodes reached the goal. These educational results establish no general
superiority. The lab supports all four algorithms and GridWorld evaluation.

Adding `expectedSarsa` to the enum may require another branch in consumer
exhaustive switches. The published `0.1.0` `TdUpdateRule` contract is unchanged.

## References

- [Sutton and Barto, Reinforcement Learning: An Introduction, chapter 6](https://www.andrew.cmu.edu/course/10-703/textbook/BartoSutton.pdf).
- [Hado van Hasselt, Double Q-learning, NeurIPS 2010](https://proceedings.neurips.cc/paper/2010/file/091d584fced301b442654dd8c23b3fc9-Paper.pdf).
