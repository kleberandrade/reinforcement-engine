# reinforcement_engine

[![Dart CI](https://github.com/kleberandrade/reinforcement-engine/actions/workflows/ci.yml/badge.svg)](https://github.com/kleberandrade/reinforcement-engine/actions/workflows/ci.yml)
[![MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Pure Dart tabular reinforcement learning for Flutter apps, games and simulations.
Q-Learning, SARSA, Expected SARSA and Double Q-Learning, with no runtime dependencies or Flutter imports in the core.

[Português](README.pt-BR.md) · [Flutter lab](example/flutter_lab/README.md) ·
[Architecture](doc/architecture.md) · [Roadmap](doc/roadmap.md) · [Contributing](CONTRIBUTING.md)


## Version 0.4.0

Learning checkpoints preserve built-in agent state and resume with a new RNG stream.
See the [checkpoint guide](doc/checkpoints.md), run `dart run example/checkpoint.dart`
and open **Salvar e retomar** in the Flutter lab.


## Version 0.3.0

Version `0.3.0` added [R-learning and continuing tasks](doc/continuing.md)
and [SARSA(lambda) with accumulating traces](doc/traces.md). The `v0.2.0` reference
preserves the previous stable delivery. See the [stability review](doc/benchmarks/stability.md) and [API review](doc/release_0.3.0.md).


## Version 0.2.0

`0.2.0` adds policy evaluation, metrics and Cliff Walking.
See the [evaluation guide](doc/evaluation.md) and run
`dart run example/evaluation.dart`. See the [migration guide](doc/migration.md) before updating from 0.1.


## Guides and runnable examples

| Topic | Dart example | Guide |
| --- | --- | --- |
| Q-Learning and SARSA | [Maze](example/reinforcement_engine_example.dart) | [Algorithms](doc/algorithms.md) |
| Custom contracts | [Environment and strategy](example/custom_extensions.dart) | [Extending](doc/extending.md) |
| JSON Q-table | [Save and restore](example/persistence.dart) | [Persistence](doc/persistence.md) |
| Flutter and engine family | [Lab](example/flutter_lab/README.md) | [Integration](doc/integration.md) |


## Status

Initial release line: 0.1.0. Current source: 0.4.0.
Requires Dart 3.3 or newer. Intended for finite, discrete state/action spaces.

## Quick start

From this checkout:

```sh
dart pub get
dart run example/reinforcement_engine_example.dart
```

To use the local package from a neighboring project:

```yaml
dependencies:
  reinforcement_engine:
    path: ../reinforcement_engine
```

```dart
import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final maze = GridWorld();
  final agent = TabularAgent<int, GridAction>(
    algorithm: LearningAlgorithm.qLearning, // or LearningAlgorithm.sarsa
    learningRate: 0.2,
    discountFactor: 0.99,
    epsilon: 1,
    epsilonDecay: 0.995,
    minEpsilon: 0.01,
    seed: 42,
  );

  for (var episode = 0; episode < 1500; episode++) {
    trainEpisode(environment: maze, agent: agent, maxSteps: 200);
  }

  var state = maze.reset();
  for (var step = 0; step < 100 && state != maze.goal; step++) {
    final action = agent.selectAction(state, maze.actions(state), explore: false);
    state = maze.step(action).state;
    print(state);
  }
}
```

The default maze has 25 cells, three walls, a reward of −1 per step and +10 at
its goal. Its shortest path is eight moves. This example is educational; it does
not establish performance on other environments or guarantee convergence.

## Algorithms

| Algorithm | Update target for a nonterminal transition |
| --- | --- |
| Q-Learning | `reward + gamma * max Q(nextState, legalNextAction)` |
| SARSA | `reward + gamma * Q(nextState, sampledNextAction)` |

Both apply `Q = Q + alpha * (target - Q)`. Terminal targets are just the reward.
Unseen state/action pairs have value zero. Greedy ties are randomized. Exploration
decays once per completed or truncated training episode, down to `minEpsilon`.
For `epsilon: 0`, also set `minEpsilon: 0`; for evaluation use `explore: false`.

## Custom environments

Implement `Environment<S, A>`:

- `reset()` returns a nonterminal initial state.
- `actions(state)` lists legal actions; every nonterminal state must have at least one.
- `step(action)` advances internal state and returns a `StepResult`.

States and actions may be enums, integers, strings or immutable value objects
with stable `==` and `hashCode`. Avoid mutable collections as map keys.
`GridWorld` uses integer row-major cell indices. Pass an explicit `walls` set
when changing its dimensions; the default walls are for its 5×5 maze. Custom
mazes are not checked for reachability, so keep a step limit.

`terminated` means the task has ended and the target must not bootstrap.
`truncated` means an external boundary ended the episode, such as a time limit;
its target still bootstraps, so the returned state must have legal actions.
The runner also truncates at `maxSteps`. SARSA samples one next action and
carries that exact action into the next transition.

For manual interaction, use `agent.selectAction` and `agent.update` directly.
For SARSA, pass the next sampled action and reuse it when stepping the environment.
Call `decayExploration()` yourself at episode boundaries in a manual loop.

## JSON persistence

```dart
import 'dart:convert';

final text = jsonEncode(agent.table.toJson(
  encodeState: (state) => state,
  encodeAction: (action) => action.name,
));

final table = QTable.fromJson<int, GridAction>(
  jsonDecode(text) as Map<String, dynamic>,
  decodeState: (value) => value as int,
  decodeAction: (value) => GridAction.values.byName(value as String),
);
final restoredAgent = TabularAgent<int, GridAction>(table: table, seed: 42);
```

Choose JSON-compatible, reversible encodings. Codecs belong to the application;
invalid decoded types may throw codec errors. Table data has a versioned envelope
and rejects nonfinite values. It stores Q-values only: configuration, epsilon,
RNG progress and environment state are not saved. Restoring a table is not an
exact continuation checkpoint. Storage and file IO belong to your application.

## Flutter

```sh
cd example/flutter_lab
flutter pub get
flutter run -d chrome
```

The lab switches between Q-Learning and SARSA, trains in small batches and animates
the learned policy. The synchronous core does not spawn isolates: schedule short
batches between frames or move expensive runs to an isolate in your application.

## Reproducibility and limits

The same seed, runtime, initial table, action order and deterministic environment
produce the same action sequence. A stochastic environment needs its own seed.
No cross-SDK or cross-platform bit-for-bit guarantee is made. Tabular storage
grows with visited state/action pairs and is not suitable for raw images or large
continuous spaces. Deep Q-Networks and neural_engine integration are future work.

## Validation

```sh
dart format --output=none --set-exit-if-changed lib test example
dart analyze
dart test
dart run example/reinforcement_engine_example.dart
cd example/flutter_lab
flutter analyze
flutter test
flutter build web
```

MIT License. Copyright (c) 2026 Kleber Andrade.

## Strategy composition

The enum constructor remains available. For explicit composition:

```dart
final agent = TabularAgent<int, GridAction>(
  updateRule: const Sarsa(), // or const QLearning()
  seed: 42,
);
```

Implement `TdUpdateRule<S, A>` for custom strategies. An explicit `updateRule`
takes precedence over `algorithm`. Contracts, domain, algorithms, agent, values
and training follow the [source responsibility map](doc/architecture/structure.md).

## Control and exploration in 0.2

Expected SARSA, Double Q-Learning and epsilon-greedy/softmax exploration are
implemented in 0.2.0. See the [control guide](doc/control.md).
The Flutter lab supports all four algorithms. Stable version `0.2.0` is published on
[pub.dev](https://pub.dev/packages/reinforcement_engine) under verified publisher
[kleberandrade.dev](https://pub.dev/publishers/kleberandrade.dev).
