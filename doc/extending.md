# Extending the engine

Implement `Environment<S, A>` to provide `reset()`, `actions(state)` and
`step(action)`. The environment owns its state. Reset returns a nonterminal state;
every nonterminal state needs legal actions. `StepResult` distinguishes task
termination (`terminated`) from an external boundary (`truncated`).

Implement `TdUpdateRule<S, A>` to replace the bootstrap. The contract receives the
table and legal actions. Return a finite number without mutating either input.
`requiresNextAction: true` tells the runner to sample and reuse the next action;
the agent validates its membership. The agent computes the TD update itself.

```dart
final agent = TabularAgent<int, GridAction>(
  updateRule: const Sarsa(),
  seed: 42,
);
```

An explicit `updateRule` takes precedence over the `algorithm` convenience
selector. New rules need no enum changes. Import only
`package:reinforcement_engine/reinforcement_engine.dart`.

The complete [custom_extensions.dart](../example/custom_extensions.dart) implements
a corridor and uniform mean bootstrap. This demonstrates the contract; it is not
Expected SARSA for an epsilon-greedy behavior policy.

```sh
dart run example/custom_extensions.dart
```
