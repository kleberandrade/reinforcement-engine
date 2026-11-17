# Learning stability — 0.3.0 review

Executed **420 task/parameter/seed combinations** against core commit `b3c1a3b05248218211a7e190ad43e0cc1616db61` on
`Dart SDK version: 3.11.5 (stable) (Wed Apr 15 00:36:32 2026 -0700) on "macos_arm64"`. Full data is in [learning_stability.json](learning_stability.json), with
[provenance](provenance.json). This is neither a speed nor a production benchmark.

## Protocol

- Seeds 0–9, paired across configurations. Evaluation RNG is independent from
  training; noisy environments use separate training/evaluation seeds.
- SARSA/SARSA(lambda): GridWorld and Cliff Walking; alpha 0.05/0.1/0.2 and lambda
  0/0.5/0.8/0.95. Lambda zero uses SARSA as the control; exact equivalence with
  SARSA(lambda=0) is covered by tests. Gamma 0.99 and fixed epsilon 0.1.
- Each run trains 400 episodes capped at 300 steps. Greedy evaluation uses 20 fresh
  episodes, capped at 200 steps each. Total: 240 episodic runs.
- R-learning: deterministic maintenance and the same transitions with uniform
  reward noise in [-0.2,0.2], alpha 0.05/0.1/0.2 and beta 0.001/0.005/0.01.
  Each run trains 10,000 steps and evaluates 2,000 steps without exploration.
  Total: 180 continuing runs, without window resets or implicit epsilon decay.
- No numerical errors occurred. This does not imply task success: every truncation
  counts as failure. Reported steps/returns include capped unsuccessful evaluations.

## Episodic results

Success rate averaged over ten seeds. Mean steps include every evaluation,
including those reaching the 200-step cap. Step count is not Cliff Walking's
only training objective under exploration because cliff falls incur penalties.

| Task | Alpha | Lambda | Success | Mean steps | Mean return |
| --- | ---: | ---: | ---: | ---: | ---: |
| cliff | 0.05 | 0.0 | 40% | 126.60 | -126.60 |
| cliff | 0.05 | 0.5 | 70% | 71.50 | -71.50 |
| cliff | 0.05 | 0.8 | 90% | 36.30 | -36.30 |
| cliff | 0.05 | 0.95 | 100% | 18.60 | -18.60 |
| cliff | 0.1 | 0.0 | 80% | 52.20 | -52.20 |
| cliff | 0.1 | 0.5 | 100% | 16.80 | -16.80 |
| cliff | 0.1 | 0.8 | 100% | 17.40 | -17.40 |
| cliff | 0.1 | 0.95 | 90% | 36.30 | -36.30 |
| cliff | 0.2 | 0.0 | 100% | 16.80 | -16.80 |
| cliff | 0.2 | 0.5 | 100% | 17.20 | -17.20 |
| cliff | 0.2 | 0.8 | 100% | 17.00 | -17.00 |
| cliff | 0.2 | 0.95 | 100% | 18.60 | -18.60 |
| grid | 0.05 | 0.0 | 100% | 8.00 | 3.00 |
| grid | 0.05 | 0.5 | 100% | 8.00 | 3.00 |
| grid | 0.05 | 0.8 | 100% | 8.20 | 2.80 |
| grid | 0.05 | 0.95 | 100% | 8.00 | 3.00 |
| grid | 0.1 | 0.0 | 100% | 8.00 | 3.00 |
| grid | 0.1 | 0.5 | 100% | 8.00 | 3.00 |
| grid | 0.1 | 0.8 | 100% | 8.00 | 3.00 |
| grid | 0.1 | 0.95 | 100% | 8.20 | 2.80 |
| grid | 0.2 | 0.0 | 100% | 8.00 | 3.00 |
| grid | 0.2 | 0.5 | 100% | 8.00 | 3.00 |
| grid | 0.2 | 0.8 | 90% | 27.20 | -17.30 |
| grid | 0.2 | 0.95 | 100% | 8.00 | 3.00 |

## Continuing results

All 180 runs learned work when ready and service when worn. Every deterministic
greedy mean was 1.5. With reward noise, means ranged from 1.494946 to 1.504441.
Maximum absolute rho error against the optimal 1.5 mean was 0.000331 without
noise and 0.016156 with noise.

| Task | Alpha | Beta | Optimal policy | Mean return | Max rho error |
| --- | ---: | ---: | ---: | ---: | ---: |
| maintenance | 0.05 | 0.001 | 100% | 1.500000 | 0.000147 |
| maintenance | 0.05 | 0.005 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.05 | 0.01 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.1 | 0.001 | 100% | 1.500000 | 0.000190 |
| maintenance | 0.1 | 0.005 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.1 | 0.01 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.2 | 0.001 | 100% | 1.500000 | 0.000331 |
| maintenance | 0.2 | 0.005 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.2 | 0.01 | 100% | 1.500000 | 0.000000 |
| noisy_maintenance | 0.05 | 0.001 | 100% | 1.500144 | 0.006395 |
| noisy_maintenance | 0.05 | 0.005 | 100% | 1.500144 | 0.010715 |
| noisy_maintenance | 0.05 | 0.01 | 100% | 1.500144 | 0.016156 |
| noisy_maintenance | 0.1 | 0.001 | 100% | 1.500144 | 0.006366 |
| noisy_maintenance | 0.1 | 0.005 | 100% | 1.500144 | 0.010634 |
| noisy_maintenance | 0.1 | 0.01 | 100% | 1.500144 | 0.015902 |
| noisy_maintenance | 0.2 | 0.001 | 100% | 1.500144 | 0.006333 |
| noisy_maintenance | 0.2 | 0.005 | 100% | 1.500144 | 0.010422 |
| noisy_maintenance | 0.2 | 0.01 | 100% | 1.500144 | 0.015213 |

## Interpretation and release decision

- In GridWorld, 119 of 120 runs learned a policy succeeding on every evaluation;
  alpha 0.2/lambda 0.8 failed for one seed.
- In Cliff Walking, 107 of 120 runs succeeded on every evaluation. With alpha 0.05,
  SARSA reached 40% mean success versus 100% for lambda 0.95. This suggests faster
  reward propagation under this budget, not general superiority.
- Alpha 0.1/lambda 0.5 and alpha 0.1/lambda 0.8 reached 100% success on both tasks
  for these seeds/limits. Defaults are unchanged: budget, exploration risk and task
  affect the choice, and these examples alone do not establish general settings.
- R-learning results cover only one small process with and without additive noise.
  They validate neither convergence on general processes nor real-world performance.
- Review found no implementation defect requiring a core change. The observed
  limitations are documented for the 0.3.0 release.

## Reproduce

```sh
dart run benchmark/learning_stability.dart > /tmp/learning_stability.json
dart run benchmark/learning_stability.dart --smoke > /tmp/learning_smoke.json
```

CI runs only smoke to check experiment compatibility. The results above come from
the full local matrix; smoke is not a substitute for that measurement. The same
seed guarantees no bitwise identity across SDKs or platforms.
