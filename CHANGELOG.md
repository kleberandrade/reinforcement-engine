## Unreleased

- Plot the entire Flutter training history from episode 1, with configurable
  trailing means, optional raw returns and an accessible episode inspector.
- Preserve Q-Learning/SARSA reference runs across algorithm changes, sharing
  axes and settings; clear comparisons on seed/epsilon changes and reset.
- Gráfico completo desde o episódio 1, média móvel ajustável e comparação
  Q-Learning/SARSA na mesma escala, com consulta dos valores por episódio.

- Complete the Flutter gridworld lab with policy arrows, per-episode returns,
  seed/epsilon controls, pause/resume/cancel and independent playback RNG.
- Add responsive/accessibility and observation-isolation regression tests;
  gate GitHub Pages deployment on Dart and Flutter checks.
- Laboratório Flutter: política, retornos, seeds/epsilon, pausa/retomada/cancelamento,
  simulação independente e publicação Pages condicionada aos testes.

## 0.5.0

- Add accumulating WatkinsQLambdaAgent with pre-update greedy-tie semantics,
  nongreedy trace cutting, atomic value updates and episode cleanup.
- Add BanditLearner/BanditPolicy/BanditValues contracts, fixed-arm BanditAgent,
  fixed epsilon-greedy and UCB1 policies, sample means and bounded trainBandit.
- Add boundary-only Watkins checkpoints without changing existing snapshot kinds;
  older readers reject the new kind. Bandit persistence remains application-owned.
- Rebuild English/Portuguese READMEs around explanations, worked calculations,
  visual examples, selection guidance and verified scientific references.
- Add bilingual learning/Watkins/bandit guides, reproducible original SVG diagrams,
  executable VM/JS examples, Flutter Watkins selection and interactive bandit bars.

## 0.4.0

- Add immutable versioned TrainingCheckpoint snapshots for built-in tabular,
  Double Q, R-learning and boundary-only SARSA(lambda) agents.
- Preserve configuration, current epsilon, both Double Q estimators and average
  reward; restore with an explicitly new random stream and typed key codecs.
- Reject unsupported custom strategies, active eligibility traces, malformed
  formats and decoded key collisions without mutating an existing learner.
- Add JSON transfer/resume and before/after evaluation to the Flutter lab,
  bilingual checkpoint guides, VM/JavaScript example and behavioral tests.

## 0.3.0

- Validate learning stability across 420 task/parameter/seed combinations; publish
  raw results, provenance and bilingual reports retaining capped unsuccessful runs.
- Validate independent public-contract consumers; document continuing/episodic
  lifecycle, persistence limitations and additive migration from 0.2.
- Add RLearningAgent with relative values and an average-reward estimate, using
  explicit post-update greedy gating and validated projected table updates.
- Add ContinuingAgent, trainContinuing and MaintenanceTask for bounded continuing
  windows that preserve environment state and reward estimates.
- Add accumulating SarsaLambdaAgent, EpisodicAgent and trainEpisodic, including
  bootstrap-preserving truncation and trace cleanup after episode errors.
- Add bilingual continuing/trace guides, executable examples and Flutter demos.

## 0.2.0

- Add Expected SARSA with behavior probabilities bound to the current policy
  and exploration schedule, including greedy ties and distribution validation.
- Add DoubleQAgent with two independent estimators and cross-table bootstraps.
- Add LearningAgent, ActionValues and ExplorationPolicy contracts, epsilon-greedy
  and stable fixed-temperature softmax policies, preserving the default seeded API.
- Add four-algorithm Flutter controls, algorithm/policy tests, bilingual control
  guides and runnable exploration/comparison examples.
- Add `expectedSarsa` to LearningAlgorithm; exhaustive consumer switches may
  require a new branch. Existing TdUpdateRule implementations remain compatible.

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
