# Flutter and engine family integration

The core is synchronous. The lab schedules ten-episode batches between timer
ticks and bounds each episode to 200 steps. Larger workloads need smaller
batches or an application-managed isolate. Timers, cancellation and rendering
belong to the lab, outside the core.

| Package | Responsibility | Possible application composition |
| --- | --- | --- |
| `fuzzy_engine` | Rules and membership degrees | Transform observations into discrete states |
| `genetic_engine` | Evolutionary optimization | Search training hyperparameters |
| `neural_engine` | Learning patterns | Future value-function approximation |
| `reinforcement_engine` | Learning actions from rewards | Q-table and environment interaction |

The packages have independent cores. These are possible application compositions,
not shipped adapters. DQN is not implemented. Raw images and continuous states are
not directly suitable for a Q-table.

Run the [lab](../example/flutter_lab/README.md) to compare Q-Learning and SARSA,
train in batches and animate the learned policy.
