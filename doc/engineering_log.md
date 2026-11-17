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

## 2026-11-16 — public repository, first release and 0.2 development

Created github.com/kleberandrade/reinforcement-engine and pushed the reviewed 0.1.0
source. The first hosted run passed both Dart jobs and caught Material-import
deprecations on newer Flutter. Reused neural_engine's narrowly scoped compatibility
annotations. The second hosted run passed in full: Dart 3.3 and stable, examples,
JavaScript execution, Flutter analysis/widget tests/web build, publication dry-run.
Created GitHub release v0.1.0 at 50a8cf7. A detached release worktree preserves
those exact files separately from 0.2 development.

An actual local `dart pub publish --force` attempt for 0.1.0 failed while accessing
pub.dev due to the environment's network restriction. Native Terminal access was
also denied. No successful pub.dev upload or publisher transfer is claimed.
The first upload must complete before the package admin transfer is available.

For 0.2.0-dev.1, added explicit ActionPolicy/GreedyPolicy, read-only evaluatePolicy,
immutable aggregate reports, caller-defined success and an independent evaluation
RNG. Extracted greedy selection into one shared implementation to retain the
agent's seeded behavior. Added the deterministic CliffWalking task with penalized
nonterminal falls, a Q-Learning/SARSA comparison and Flutter evaluation controls.
English/Portuguese guides distinguish these additions from the 0.1.0 release.

Validation of the development increment:

- 29 public-API tests passed, including independent RNG preservation, immutable
  reports, terminal/truncation semantics, illegal policy actions and cliff behavior.
- Core and Flutter analysis with fatal infos passed; formatting and doc links clean.
- Evaluation example passed on Dart VM and compiled JavaScript in Node: both
  policies reached the cliff goal on all 100 episodes (13 and 17 moves respectively).
- Flutter web release build and Wasm compatibility dry-run passed.
- Updated widget evaluation test is included for hosted CI; local widget execution
  remains unavailable because loopback sockets are denied.
- Expected SARSA, Double Q-Learning and configurable exploration remain roadmap items.

## 2026-11-16 — repository topics and prerelease metadata

Added eight GitHub topics: dart, flutter, reinforcement-learning, machine-learning,
q-learning, sarsa, gridworld and dart-package. Confirmed they appear on the repository.

Hosted CI for 56b5e9f passed the core behavior, examples, JavaScript execution and
Flutter job, but the publication dry-run rejected the missing 0.2.0-dev.1 changelog
heading. Added that heading while keeping Unreleased for future changes. No runtime
code changed; the fix is validated by the publication check on the next hosted run.
The initial 0.1.0 release worktree and tag remain unchanged.

## 2026-11-16 — verified publisher and complete 0.2 control algorithms

Confirmed the user's first pub.dev upload: reinforcement_engine 0.1.0 is public.
Transferred the package to kleberandrade.dev and verified the public package header
and sidebar show the verified publisher. The package analysis reports 160 points.

Implemented Expected SARSA with probabilities bound to the live exploration policy
and current epsilon. Added independent-estimator DoubleQAgent, read-only ActionValues,
LearningAgent and ExplorationPolicy contracts. The runner now accepts LearningAgent;
it has no concrete agent checks. Shared AgentBehavior owns per-agent random state,
exploration and decay, preserving the v0.1 default RNG call order. Softmax exploration
uses stable exponentiation and a fixed positive temperature; it intentionally ignores
epsilon. Double Q uses a live summed value view, updates only one estimator at a time,
and rejects aliased table inputs. The published TdUpdateRule contract is unchanged.

Expanded the Flutter lab to four algorithms, with new Expected SARSA/Double Q widget
scenarios. Added bilingual control/extension/persistence guidance, source maps and
class diagrams, primary algorithm references, exploration examples and updated CI.
Source is now 0.2.0-dev.2; no second pub.dev version or stable 0.2 release is claimed.

Validation on installed Dart 3.11.5 / Flutter 3.41.9:

- 46 core behavioral tests passed. Tests include exact Expected SARSA weights,
  live epsilon decay, custom softmax distributions, invalid probabilities,
  both cross-estimator branches, negative/illegal next values, independent JSON
  restoration, default RNG compatibility and Double Q seeded replay.
- Both new agents learn the eight-step GridWorld policy in 500 episodes.
- Core and Flutter analysis with fatal infos passed; formatting and doc links clean.
- Cliff comparison and exploration examples passed on VM and compiled JavaScript.
  With the documented settings, all four policies succeed; greedy paths were
  13, 17, 15 and 17 steps for Q-Learning, SARSA, Expected SARSA and Double Q.
- Existing custom-extension and JSON examples still pass.
- Flutter web release build passed, including the Wasm compatibility dry-run.
- New widget scenarios require hosted execution because local loopback sockets
  remain restricted. Hosted checks are verified separately after pushing.

## 2026-11-16 — stable 0.2.0 preparation

Consolidated the unpublished prerelease notes into 0.2.0, updated version and
bilingual guides, and added migration notes covering the new enum case, common
agent/value contracts and two-table persistence. Runtime code is unchanged from
c86f969, whose complete hosted CI passed. A dedicated release worktree preserves
0.2.0 while 0.3 development proceeds. Publishing success is verified separately;
no upload is inferred from a tag or metadata change.

## 2026-11-16 — 0.2 publication confirmed and 0.3 initial implementation

Stable 0.2.0 source at 6f39516 passed complete hosted CI, including publication
dry-run. Created GitHub release v0.2.0. The local upload attempt failed due to
network isolation, so a preserved 0.2 worktree was provided for the user's upload.
Subsequently verified pub.dev serves reinforcement_engine 0.2.0 under verified
publisher kleberandrade.dev with 160 points; updated the release notes accordingly.

Implemented RLearningAgent with a distinct ContinuingAgent contract, bounded
trainContinuing windows and MaintenanceTask. Post-update greedy gating and rho
maxima follow the cited Barto pseudocode, with self-loop semantics tested explicitly.
Projected value reads validate the complete update before Q/rho writes. Windows
preserve environment state, rho and exploration; terminal boundaries are rejected.

Implemented accumulating SarsaLambdaAgent with explicit EpisodicAgent lifecycle
and trainEpisodic. The wrapper reuses the existing episode loop and guarantees
cleanup after termination, truncation or environment exceptions, with no concrete
agent type checks. Trace updates are validated before any multi-cell table write.
No true-online/replacing-trace or general convergence claim is made.

Added executable continuing/trace examples, bilingual guides, source maps and
class diagrams, plus a SARSA(lambda) maze option and a separate continuing-task
Flutter screen. Source is 0.3.0-dev.1; the development version is not published.

Validation on the installed Dart 3.11.5 / Flutter 3.41.9:

- 60 core behavioral tests passed, including lambda-zero SARSA equivalence,
  accumulating/discounted traces, truncation/error cleanup, atomic overflow,
  R-learning greedy/non-greedy/self-loop semantics and continuing window state.
- Core and Flutter static analysis passed; formatting and local doc links clean.
- New examples passed on Dart VM and compiled JavaScript in Node.
- Maintenance greedy evaluation averages 1.5 reward per step; SARSA(lambda)
  learns the eight-move maze with no eligibility retained between episodes.
- Flutter release web build and Wasm compatibility dry-run passed.
- New widget scenarios and minimum-SDK validation are run in hosted CI after push;
  local widget execution remains blocked by loopback socket restrictions.

## 2026-11-16 — 0.3 stability review and stable preparation

Ran the full learning-stability-v1 protocol: 420 task/parameter/seed combinations
on ten paired seeds. Stored every raw result, SDK/source provenance and bilingual
reports in doc/benchmarks. All runs remained numerically finite. GridWorld had
119/120 fully successful runs, Cliff Walking 107/120, and both continuing tasks
learned the expected maintenance policy in all 180 runs. Failed capped evaluations
are retained in success rates, steps and returns, never discarded. These finite
synthetic tasks establish no general convergence or production-performance claim.

Reviewed the API/lifecycle boundaries, arithmetic, persistence and migration, and
validated an independent application implementing ContinuingAgent/EpisodicAgent
using only public exports. No implementation defect required a numerical core
change. Verified its source digest still matches the recorded b3c1a3b core.

Prepared 0.3.0 stable metadata, additive migration notes and release review.
CI now checks the independent consumer and a reduced experiment smoke run on the
minimum and stable Dart SDKs. Full matrix numbers are local measurements, not
attributed to the smoke job. The stable upload and GitHub release are verified
separately after the review; neither a tag nor a dry-run implies publication.

Local validation:
- 60 behavioral tests passed; root/consumer analysis passed with fatal infos.
- Independent public-contract consumer ran successfully.
- Formatting and all local Markdown links checked; core source unchanged.
- Full experiment has 420 unique rows, all ten seeds per task and no numeric errors.
- Previous hosted run 44002809344 passed core, JS and Flutter checks for this exact
  numerical implementation; final stable metadata/consumer CI runs after pushing.

## 2026-11-16 — 0.4 boundary checkpoints

Added an immutable version-1 TrainingCheckpoint outer adapter for built-in
TabularAgent, DoubleQAgent, RLearningAgent and SarsaLambdaAgent. Snapshots retain
configuration, live epsilon/schedule, exploration strategy, independent estimators
and rho. They create fresh agents/tables with a NEW RNG stream. Kept existing RNG
implementation/call order and numerical update paths unchanged. Exact trajectory
resume needs serializable agent/environment RNGs and is explicitly out of scope.

Reject custom TD callbacks/policies instead of replacing their behavior. Reject
active eligibility traces and decoded key collisions; callers own true episode
boundaries, pending actions and environment identity. Concrete policy inspection
is isolated to the format adapter, never placed in the learning/runner paths.

Added a bounded Flutter JSON transfer/resume page with application-owned counters
and environment envelope, independent before/after evaluation and invalid-input
preservation. Updated bilingual guides, architecture, diagrams, migration and
release metadata. Extended the independent public consumer and VM/JS CI example.

Local validation:
- 70 behavioral tests passed, including 10 checkpoint scenarios.
- Root, Flutter and independent-consumer analysis passed with fatal infos.
- All eight CLI examples ran; checkpoint compiled JavaScript ran successfully.
- Flutter release web build and Wasm compatibility dry run passed.
- Widget execution blocked by local loopback socket permissions; hosted CI runs it.
- Publish dry run built/inspected a 122 KB archive, then failed DNS accessing
  pub.dev. Hosted validation and actual upload are tracked separately.

## 2026-11-17 — Watkins, bandits and didactic 0.5 source

Added accumulating WatkinsQLambdaAgent on the existing EpisodicAgent contract.
Pinned pre-write greedy ties/self-loops, maximum bootstrap, cut-after-update
semantics, terminal propagation, truncation cleanup and atomic overflow rejection.
Added a new boundary checkpoint kind while retaining old schemas and RNG behavior.

Added separate BanditLearner/BanditPolicy/BanditValues contracts, fixed-arm agent,
normalized sample-mean feedback, fixed-epsilon and UCB1 policies, and a bounded
feedback runner. Core paths use composition; bandits do not pretend to have next
states. Feedback ownership, stationary-reward assumptions, delayed observations
and the absence of bandit persistence are explicit in English/Portuguese guides.

Rebuilt both READMEs as learning paths: glossary links, decision table, complete
examples, numerical updates and original visuals. Added six deterministic SVGs
and their dependency-free Dart generator, dedicated learning/Watkins/bandit guides
and a verified scientific bibliography at the end of each README. Distinguished
primary articles from the 2018 textbook and its 2015 draft used for Watkins order.
No paper figures were copied and the old 420-run matrix is not attributed to new
algorithms. Added Flutter Watkins selection and a bounded bandit simulation whose
bars show selection shares, not success probabilities.

Validation before final source commit:
- 92 behavioral core tests passed (22 additional scenarios).
- Ten VM examples ran, including the two new methods.
- Both new examples compiled to JavaScript and ran in Node.
- All four complete README Dart examples were extracted and executed successfully.
- Independent public-contract consumer validates a custom BanditLearner and Watkins.
- Root/consumer analysis, local documentation links and six SVG/XML files passed.
- Flutter web release build and Wasm compatibility dry run passed.
- Flutter widget execution is delegated to hosted CI because local sockets are
  restricted; CI also validates minimum Dart 3.3, stable and publish dry-run.
- Source version is 0.5.0. This task commits source; registry publication is a
  separate action and is not inferred from the version number or a passing CI.

## 2026-11-17 — Complete interactive maze laboratory

- Inspected root/project instructions, clean working copy, origin and existing
  lab/engine contracts; fetched origin to confirm no divergence. Read steering
  workflow/guide as a reference without editing it; preserved release checkouts.
- Added failing lifecycle tests first. Implemented pause/resume/cancel, selected
  seeds and initial epsilon, all-greedy-tie policy arrows and per-episode returns.
  Kept scheduling and visualization in Flutter; pure Dart core is unchanged.
- Separated playback environment and RNG after identifying that the old UI
  consumed training RNG. Added a 1,000-episode observation-isolation regression.
- Added all-six-algorithm interaction coverage, active reset, narrow/large-text
  checks and accessible label/target checks. Fixed both dropdown width issues
  found during these checks; disposed test semantics handles before test end.
- Used a dedicated Flutter 3.50 SDK copy, upgraded compatible dependencies and
  tracked the application lockfile; documented SDK-pinned incompatibilities.
- Ran required Dart examples/analysis/tests, external consumer and JS execution;
  ran Flutter interaction tests/analysis and Web release build. Inspected real
  Chrome desktop/mobile runs and saved screenshots; see lab_validation.md.
- Invoked crapper, dryer and mutator scan: installed tools do not support Dart;
  did not report empty scans as quality/mutation passes.
- Rewrote the English lab guide with scenarios, seeds, learning parameters,
  limits and Portuguese control notes. Synchronized both READMEs and Unreleased.
- Enabled Actions-based Pages and added publication gated on core and Flutter
  checks, with repository base-href. Hosted verification is recorded separately.

Publication verification: Actions run 44168240494 passed Dart 3.3/stable, Flutter
and Pages for dbbeb66. Site, bootstrap, application JS and bundled CanvasKit all
returned 200 with the correct base path. Updated About description/homepage and
retained eight topics; verified pub 0.5.0 and CI badge endpoints. Added visible
links to both READMEs. The final docs-only evidence commit skips duplicate CI
because the application sources and deployed artifact are unchanged.

## 2026-11-17 — Full reward history and Q-Learning/SARSA comparison

- Replaced the last-50 bars after reproducing their loss of the initial learning
  trajectory. Wrote mean/episode-inspection tests before adding the new chart.
- Extracted a pure trailing-mean helper inside the lab, with partial starting
  windows and no future data. Added whole-history raw paths, adjustable smoothing
  (10/25/50/100), shared −200/+3 scale, legends and a keyboard/touch episode slider.
- Preserved immutable Q-Learning/SARSA run snapshots when switching algorithms.
  Seed/epsilon changes and explicit reset clear both runs; other algorithms keep
  their own full-history plot. Reference paths stop at their actual last sample.
- Moved status ahead of the grid so training/evaluation feedback stays visible
  when the chart is tall. Kept training, evaluation and playback RNG ownership.
- Tested numeric windows, window selection, episode 1 after 100 records, unequal
  histories, saved-run isolation and seed/reset invalidation. The populated
  200%-text test found axis-label wrapping; scaled axis label space to fix it.
- Validation: 19 Flutter tests, fatal-info Flutter analysis and release Web build
  passed. All 92 core tests, required examples, JS consumer, independent consumer,
  SVG consistency and formatting checks passed. Installed crapper/dryer/mutator
  still report no Dart support; their empty scans are not counted as passes.
- Inspected real 500-episode Q-Learning and SARSA runs in Chrome desktop/390px,
  changed the moving window and saved new captures. Updated English/Portuguese
  guidance and Unreleased notes. Hosted validation is recorded after deployment.
