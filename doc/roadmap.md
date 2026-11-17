# Roadmap

## 0.1.0 — initial implementation

- [x] Tabular Q-Learning and SARSA.
- [x] Generic state/action types and legal-action constraints.
- [x] Epsilon-greedy exploration with decay and seeded random tie-breaking.
- [x] Versioned JSON Q-table serialization with custom codecs.
- [x] Termination/truncation handling and episode metrics.
- [x] Deterministic GridWorld and Flutter lab.
- [x] Behavioral tests and CI configuration.
- [x] Run Flutter widget tests on GitHub Actions.
- [x] Create public GitHub repository.
- [x] Complete first-release hosted CI on Dart 3.3/stable and Flutter stable.
- [x] Validate first-release publication with hosted dry-run.
- [x] Publish 0.1.0 to pub.dev.
- [x] Transfer to verified publisher kleberandrade.dev (160 pub points).

## 0.2.0 — release prepared

- [x] Expected SARSA and Double Q-Learning.
- [x] Evaluation runner with aggregate success/reward/step metrics.
- [x] Cliff Walking environment and algorithm comparisons.
- [x] Exploration strategy composition: epsilon-greedy and fixed-temperature softmax.
- [x] Review and prepare the stable 0.2 release.
- [ ] Confirm the 0.2.0 upload on pub.dev.

## Later candidates

- R-Learning for average-reward tasks (with its own update semantics).
- Eligibility traces: SARSA(lambda) and Watkins Q(lambda).
- Bandit algorithms under distinct interfaces.
- DQN with optional neural_engine integration in a separate package.
- Explicit checkpoint contract, including a serializable RNG if exact resume is needed.

Continuous-control policy-gradient algorithms require separate design and benchmarks.
