# Engineering log

## 2026-11-16 — initial local implementation

Implemented pure Dart Q-Learning and SARSA, sparse typed Q-tables, versioned JSON
codecs and a bounded environment runner. The runner distinguishes terminal and
truncated transitions and carries SARSA's selected action into the next step.
Added a deterministic GridWorld, CLI example, interactive Flutter lab, bilingual
README, architecture notes, roadmap, MIT license and CI definition.

Validation on Dart 3.11.5 / Flutter 3.41.9:

- Core behavioral suite: 16 tests passed.
- Static analysis: no issues in core or Flutter lab.
- Formatting: clean.
- CLI example: goal reached in eight moves after training.
- Flutter release web build: succeeded, including the Wasm compatibility dry run.
- Flutter widget tests: blocked before execution because this environment denies
  binding a loopback server socket. Tests are included for execution in CI or on
  an unrestricted development machine. No widget test pass is claimed.
- Hosted CI and Dart 3.3 minimum-version checks: configured, not executed locally.
- Remote repository and pub.dev publication: pending.

SDK caches are read-only in this environment. Local validation used writable
scratch cache metadata and disabled command analytics without changing the system SDK.

## 2026-11-16 — align with the engine family

Compared the local neural_engine, fuzzy_engine and genetic_engine architecture,
public exports, contributor workflow, source style and documentation. Pinned the
existing behavior with all 16 core tests before restructuring.

Separated contracts, domain values, algorithms, agents, values, training and
reference environments. Extracted QLearning/Sarsa behind TdUpdateRule so new
bootstrap strategies compose without editing the agent or runner. Kept existing
public names and enum-based construction. Added finite custom-bootstrap validation,
explicit strategy precedence and tests for seeded behavior parity and SARSA reuse.

Added bilingual algorithm, extension, persistence, integration, architecture
structure and overview guides, implemented class diagrams, runnable custom-contract
and JSON examples, contributor instructions and synchronized Unreleased notes.
Expanded CI to run examples and JavaScript portability checks.

Validation on the installed Dart 3.11.5 / Flutter 3.41.9:

- 20 public-API behavioral tests passed (16 previous, 4 new).
- Core and Flutter analysis with fatal infos: no issues.
- Formatting check clean; all local Markdown links resolve.
- CLI maze reaches goal in eight moves; custom corridor in three moves.
- JSON example restores a policy reaching the goal in eight moves.
- New extension and persistence examples compile to JavaScript and run in Node.
- Flutter release web build passed, including Wasm compatibility dry run.
- Flutter widget tests remain blocked by denied loopback socket binding before
  test execution; no pass is claimed.
- Minimum Dart SDK and hosted CI remain configured, not locally executed.
- Remote repository creation and publication remain pending.

Used the installed Dart binary and existing writable Flutter cache metadata to
avoid modifying the read-only SDK. Suppressed analytics per invocation. Ran the
core test runner directly against the existing package configuration to avoid
writes to the read-only package cache. These environment adaptations do not
change package code or dependencies.
