# Learning checkpoints (0.4)

[Português](checkpoints.pt-BR.md)

`TrainingCheckpoint` is an immutable, version-1 JSON snapshot of built-in learner
state. Run `dart run example/checkpoint.dart`; it trains, transfers through JSON,
restores and continues learning on Dart VM and compiled JavaScript.

| Capture | Restore | Preserved state |
| --- | --- | --- |
| `TrainingCheckpoint.tabular` | `restoreTabular` | Enum algorithm, Q-table, alpha, gamma |
| `TrainingCheckpoint.doubleQ` | `restoreDoubleQ` | Both independent Q-tables, alpha, gamma |
| `TrainingCheckpoint.rLearning` | `restoreRLearning` | Relative Q-table, alpha, beta, average reward |
| `TrainingCheckpoint.sarsaLambda` | `restoreSarsaLambda` | Q-table, alpha, gamma, lambda; empty traces |

All formats preserve current epsilon, decay, floor and the built-in exploration
strategy (epsilon-greedy or fixed-temperature softmax). Typed codecs encode keys;
decoders must preserve stable equality/hash codes and distinguish every key.
Duplicate decoded state/action pairs fail restoration. `toJson` returns a detached
tree. Capturing copies data, so later learner mutations cannot alter the snapshot.
Every restore builds fresh independent tables; existing learners are never mutated.

```dart
final saved = TrainingCheckpoint.tabular(agent,
  encodeState: (state) => state,
  encodeAction: (action) => action.name);
final loaded = TrainingCheckpoint.fromJson(saved.toJson());
final resumed = loaded.restoreTabular<int, GridAction>(
  decodeState: (key) => key as int,
  decodeAction: (key) => GridAction.values.byName(key as String),
  seed: 99);
```

## Boundary and reproducibility contract

Capture between episodes or bounded continuing windows, with no pending update.
For SARSA(lambda), call `endEpisode` (or use `trainEpisodic`) first. Nonempty traces
are rejected. An empty trace map alone cannot establish a boundary (lambda zero,
gamma zero or a freshly sampled pending action can also have no traces); the caller
must enforce the boundary for all algorithms.

Restoration starts a **new random stream** from the supplied seed, or a runtime
seed when omitted. Two restored agents with the same seed and call order reproduce
each other within the same runtime; they do not continue the original RNG position.
The serialized `resume: newRandomStream` field makes this distinction explicit.
No cross-runtime RNG-sequence guarantee or trajectory-exact resume is made.

Environment identity/state, counters, transition RNGs, pending SARSA actions and
storage belong to the application. Reset an episodic environment before resuming.
For a continuing task, explicitly restore or choose its next state and document
that choice. Do not feed an interrupted episode to this boundary-only format.

Custom update rules (including directly injected built-in rule instances) and
custom exploration policies are rejected, preventing accidental semantic changes.
They need an application-owned persistence adapter. The enum Expected SARSA path
restores its probability callback bound to the new agent's current policy/epsilon.

The existing version-1 `QTable.toJson/fromJson` format remains unchanged and can
still import/export values only. A table file is not a training checkpoint.
Versions, estimator counts, configuration bounds and finite values are validated;
unsupported versions/kinds and incompatible restore methods fail explicitly.
Applications must validate codecs, environment identity and input size as needed.

## Flutter lab

Open **Salvar e retomar**, train +100, export JSON, create a new agent and import.
The imported policy is evaluated on 20 independent greedy episodes, then continuing
training produces an after-training evaluation using the same evaluation seed.
A before/after comparison measures this maze only; it promises no improvement.
Copy/paste owns transfer; there is no automatic filesystem or network access.
The demo wraps the core checkpoint with its environment identifier and episode
counter, rejects incompatible envelopes, and keeps the current agent on bad input.

## 0.5 additions

`TrainingCheckpoint.watkinsQLambda` / `restoreWatkinsQLambda` preserve Watkins
configuration, Q-table and exploration at episode boundaries with empty traces.
The new `watkinsQLambda` kind keeps envelope version 1; older readers reject that
kind. Existing kinds remain unchanged. Bandit statistics are not supported by
this format; applications own any bandit persistence.
