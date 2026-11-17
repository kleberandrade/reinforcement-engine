# Migration from 0.1 to 0.2

The existing public import, QTable JSON format, Q-Learning/SARSA constructors
and TdUpdateRule implementations remain supported. The default epsilon-greedy
seeded call order is preserved within the same runtime.

- LearningAlgorithm adds expectedSarsa. Add it to exhaustive consumer switches.
- trainEpisode now accepts LearningAgent, including TabularAgent and DoubleQAgent.
- Use agent.values for evaluation across both agent families. Single-table agents
  retain agent.table. Double Q owns tableA and tableB; serialize both separately.
- Expected SARSA via the enum constructor follows the actual behavior probabilities
  and current epsilon. A custom ExpectedSarsa probability callback is caller-owned.
- SoftmaxExploration uses a fixed temperature, ignores epsilon, and does not cool
  when decayExploration is called. explore: false always selects greedily.

See [control](control.md), [evaluation](evaluation.md) and [persistence](persistence.md).
