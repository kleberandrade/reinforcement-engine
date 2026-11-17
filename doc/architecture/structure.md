# Source structure

| Location | Responsibility | Dependency rule |
| --- | --- | --- |
| `lib/reinforcement_engine.dart` | Deliberate public exports | No runtime logic |
| `lib/src/domain/` | Transition, episode summary and enums | Dart SDK only |
| `lib/src/values/` | Sparse Q-values and JSON table format | Dart SDK only |
| `lib/src/contracts/` | Environment and TD bootstrap interfaces | Domain and values |
| `lib/src/algorithms/` | Q-Learning and SARSA bootstrap rules | Contracts, values and SDK |
| `lib/src/agents/` | Validation, epsilon-greedy selection and TD update | Contracts, values, domain; built-ins only for constructor defaults |
| `lib/src/training/` | Bounded episode lifecycle and next-action reuse | Environment contract, agent and domain |
| `lib/src/environments/` | Deterministic reference GridWorld | Environment contract and domain |
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
