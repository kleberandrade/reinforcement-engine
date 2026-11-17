# Tabular control algorithms

The single-table strategies update `Q(s,a) += alpha * (reward + gamma * bootstrap - Q(s,a))`.

| Rule | Bootstrap for a nonterminal transition | Next action |
| --- | --- | --- |
| `QLearning<S, A>` | Maximum over legal next action values | Sampled after the update |
| `Sarsa<S, A>` | Value of the sampled next behavior action | Sampled before the update and reused |
| `ExpectedSarsa<S, A>` | Expected value under the behavior policy | No bootstrap sampling |

Unseen pairs are zero. For Q-Learning, illegal actions never participate and
negative maxima remain negative. Terminal transitions set bootstrap to zero.
Truncation ends an episode but retains bootstrap; even its last state needs legal
actions. `maxSteps` imposes the same truncation behavior.

Epsilon-greedy selection explores with probability epsilon; otherwise it chooses
a maximum-valued legal action and randomizes ties. Decay happens once per returned
episode, using `max(minEpsilon, epsilon * epsilonDecay)`. Manual loops call
`decayExploration()` themselves. Use `explore: false` for evaluation, which still
randomizes ties. If configuring `epsilon: 0`, also set `minEpsilon: 0`.

A fixed seed reproduces runs only with the same runtime, action order, initial
table and environment behavior. Stochastic environments need their own seed.
There is no cross-runtime bitwise guarantee or general convergence guarantee.

Run `dart run example/reinforcement_engine_example.dart` to train Q-Learning
on the default maze. Its goal is eight moves away. This is an educational
finite-state example, not a benchmark for real applications.

See [control and exploration](control.md) for Expected SARSA, Double Q-Learning and softmax.

## Beyond one-step rules

| Learner | Target/feedback | Lifecycle |
| --- | --- | --- |
| DoubleQAgent | Cross-table discounted bootstrap | trainEpisode |
| SarsaLambdaAgent | Sampled next Q; accumulating traces | trainEpisodic |
| WatkinsQLambdaAgent | Maximum next Q; traces cut after nongreedy next action | trainEpisodic |
| RLearningAgent | Reward minus average reward plus relative next value | trainContinuing |
| BanditAgent | Immediate normalized reward updates a sample mean | trainBandit or selectArm/observe |

For Q=2, alpha=.25, reward=1, gamma=.8 and next bootstrap=4, the new value is
`2 + .25 * (1 + .8*4 - 2) = 2.55`. A terminal transition gives 1.75 instead.
This calculation also illustrates why truncation must not be treated as termination.

Start with the [learning guide](learning_guide.md), then [Watkins](watkins.md),
[traces](traces.md), [continuing tasks](continuing.md) or [bandits](bandits.md).
