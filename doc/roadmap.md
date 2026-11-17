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

## 0.2.0 — stable source release

- [x] Expected SARSA and Double Q-Learning.
- [x] Evaluation runner with aggregate success/reward/step metrics.
- [x] Cliff Walking environment and algorithm comparisons.
- [x] Exploration strategy composition: epsilon-greedy and fixed-temperature softmax.
- [x] Review and prepare the stable 0.2 release.
- [x] Create GitHub release v0.2.0 after complete hosted CI.
- [x] Confirm the 0.2.0 upload on pub.dev (verified publisher, 160 points).

## 0.3.0 — stable release preparation

- [x] R-Learning and explicit continuing-task/window contracts.
- [x] Accumulating SARSA(lambda) and guaranteed episode trace cleanup.
- [x] Continuing MaintenanceTask, executable examples and bilingual guides.
- [x] Flutter continuing-task demo and SARSA(lambda) maze control.
- [x] Compare learning across 420 task/parameter/seed combinations.
- [x] Review API, migration, guides and independent contract consumers.
- [x] Confirm stable 0.3.0 publication and GitHub release.

## 0.4.0 — learning checkpoints

- [x] Versioned immutable snapshots with typed state/action codecs.
- [x] Restore configuration, exploration, independent estimators and average reward.
- [x] Reject custom strategies and active traces; document new RNG stream.
- [x] Flutter JSON transfer, resume and before/after evaluation.
- [x] Bilingual guides and numerical round-trip/error tests.
- [ ] Confirm full hosted CI, GitHub release and pub.dev publication.

## 0.5.0 — Watkins, bandits and didactic documentation

- [x] Accumulating Watkins Q(lambda), greedy ties, cuts and lifecycle tests.
- [x] Separate bandit contracts, epsilon-greedy and UCB1 selection.
- [x] Normalized rewards, sample means, feedback windows and behavioral tests.
- [x] Watkins boundary checkpoints and explicit bandit persistence limitations.
- [x] VM/JS examples, Flutter maze selector and bandit visualization.
- [x] Bilingual learning guides, original SVG diagrams and scientific references.
- Final source validation is tracked by [CI](https://github.com/kleberandrade/reinforcement-engine/actions/workflows/ci.yml) on Dart 3.3/stable and Flutter.
- [ ] Publish 0.5.0 separately when requested.

## Later candidates

- Replacing and true-online traces.
- Contextual bandits and adaptive/nonstationary estimators.
- DQN with optional neural_engine integration in a separate package.
- Trajectory-exact checkpoints with serializable RNG and environment state.

Continuous-control policy-gradient algorithms require separate design and benchmarks.
