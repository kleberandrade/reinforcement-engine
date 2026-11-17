# Tabular control algorithms

Both strategies update `Q(s,a) += alpha * (reward + gamma * bootstrap - Q(s,a))`.

| Rule | Bootstrap for a nonterminal transition | Next action |
| --- | --- | --- |
| `QLearning<S, A>` | Maximum over legal next action values | Sampled after the update |
| `Sarsa<S, A>` | Value of the sampled next behavior action | Sampled before the update and reused |

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
