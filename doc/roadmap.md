# Roadmap

## 0.1.0 — initial implementation

- [x] Tabular Q-Learning and SARSA.
- [x] Generic state/action types and legal-action constraints.
- [x] Epsilon-greedy exploration with decay and seeded random tie-breaking.
- [x] Versioned JSON Q-table serialization with custom codecs.
- [x] Termination/truncation handling and episode metrics.
- [x] Deterministic GridWorld and Flutter lab.
- [x] Behavioral tests and CI configuration.
- [ ] Run Flutter widget tests in an environment allowing loopback sockets.
- [ ] Create remote repository and verify hosted CI.
- [ ] Verify package name availability and publish to pub.dev.

## Candidate 0.2.0 — evaluate after first release

- Expected SARSA and Double Q-Learning.
- Evaluation runner with aggregate success/reward/step metrics.
- Cliff Walking environment and algorithm comparisons.
- Exploration strategy composition.

## Later candidates

- R-Learning for average-reward tasks (with its own update semantics).
- Eligibility traces: SARSA(lambda) and Watkins Q(lambda).
- Bandit algorithms under distinct interfaces.
- DQN with optional neural_engine integration in a separate package.
- Explicit checkpoint contract, including a serializable RNG if exact resume is needed.

Continuous-control policy-gradient algorithms require separate design and benchmarks.
