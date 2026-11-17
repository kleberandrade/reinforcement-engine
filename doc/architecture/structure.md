# Source structure

| Location | Responsibility | Dependency rule |
| --- | --- | --- |
| `lib/reinforcement_engine.dart` | Deliberate public exports | No runtime logic |
| `lib/src/domain/` | Transition, episode summary and enums | Dart SDK only |
| `lib/src/values/` | Sparse Q-values, sum view and JSON table format | SDK and ActionValues contract |
| `lib/src/contracts/` | Environment, episodic/continuing learners, lifecycle, exploration and value-reading interfaces | SDK/domain; legacy TD contract also references QTable |
| `lib/src/algorithms/` | Q-Learning, SARSA and Expected SARSA bootstraps | Contracts, values and SDK |
| `lib/src/agents/` | Discounted, average-reward and trace control; shared behavior/RNG/schedule | Contracts, values, domain; built-ins only for constructor defaults |
| `lib/src/training/` | Episode lifecycle, trace boundaries, continuing windows and next-action reuse | Environment/LearningAgent contracts and domain |
| `lib/src/policies/` | Greedy reading, epsilon-greedy/softmax behavior, probability validation | Policy contract, Q-values and SDK |
| `lib/src/evaluation/` | Fresh evaluation episodes, independent RNG and aggregate report | Environment/policy contracts and domain only |
| `lib/src/environments/` | Deterministic GridWorld, Cliff Walking and MaintenanceTask | Environment contract and domain |
| `lib/src/persistence/` | Built-in checkpoint format adapter, validation and fresh-agent restoration | Agents, policies, values, domain and SDK; never imported by training |
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

Checkpoint persistence is an outer adapter. It inspects supported built-in policy
types only at serialization; learning/runner dispatch remains contract-driven.
Custom TD callbacks and custom exploration require an application-owned adapter.
