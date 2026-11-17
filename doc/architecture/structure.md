# Source structure

| Location | Responsibility | Dependency rule |
| --- | --- | --- |
| `lib/reinforcement_engine.dart` | Deliberate public exports | No runtime logic |
| `lib/src/domain/` | Transition, episode summary and enums | Dart SDK only |
| `lib/src/values/` | Sparse Q-values, sum view and JSON table format | SDK and ActionValues contract |
| `lib/src/contracts/` | Environment, learner, exploration and value-reading interfaces | SDK/domain; legacy TD contract also references QTable |
| `lib/src/algorithms/` | Q-Learning, SARSA and Expected SARSA bootstraps | Contracts, values and SDK |
| `lib/src/agents/` | Single/double control, shared behavior/RNG/schedule and validation | Contracts, values, domain; built-ins only for constructor defaults |
| `lib/src/training/` | Bounded episode lifecycle and next-action reuse | Environment/LearningAgent contracts and domain |
| `lib/src/policies/` | Greedy reading, epsilon-greedy/softmax behavior, probability validation | Policy contract, Q-values and SDK |
| `lib/src/evaluation/` | Fresh evaluation episodes, independent RNG and aggregate report | Environment/policy contracts and domain only |
| `lib/src/environments/` | Deterministic GridWorld and Cliff Walking | Environment contract and domain |
| `test/` | Public-contract behavior and integration | Public package entry point |
| `example/*.dart` | Runnable consumer scenarios | Public package entry point |
| `example/flutter_lab/` | Rendering, scheduling and interaction | Public package; owns Flutter dependencies |

Keep one responsibility in each file. Add an algorithm by implementing
`TdUpdateRule<S, A>`, not by extending `TabularAgent`. The constructor imports
built-in rules only to provide the enum convenience API. Update and runner paths
dispatch through the selected contract; they never check concrete strategy types.

Keep experiments, widgets and file storage outside `lib/`. Consumers use the
public library, never `src/` imports. Existing public names remain exported after
this structural refactor.
