## Unreleased

- Add read-only policy evaluation with independent RNG, caller-defined success,
  immutable episode summaries and aggregate reward/step/termination metrics.
- Add the `ActionPolicy` contract and `GreedyPolicy`, shared by evaluation and
  the agent's exploitation path while preserving seeded behavior.
- Add deterministic Cliff Walking with nonterminal cliff resets and a runnable
  Q-Learning/SARSA comparison.
- Add Flutter evaluation controls and bilingual guides for the next 0.2 release.

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
- Retain Flutter compatibility across the Material library split.
