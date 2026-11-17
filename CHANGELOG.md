## 0.1.0

- Align source organization with the engine family: contracts, domain values,
  algorithms, agents, values, training and reference environments.
- Add composable `TdUpdateRule`, `QLearning` and `Sarsa` strategies while retaining
  the existing enum constructor and public exports.
- Add bilingual architecture, algorithm, extension, persistence and integration
  guides, class diagrams, runnable consumer examples and strategy parity tests.

- Generic tabular Q-Learning and SARSA agents.
- Epsilon-greedy exploration, random tie-breaking and seeded runs.
- Sparse JSON Q-tables with user-defined state/action codecs.
- Bounded episode runner with separate termination and truncation.
- GridWorld and interactive Flutter learning lab.
