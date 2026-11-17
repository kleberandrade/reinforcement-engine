# Q-table persistence

`QTable.toJson` produces a version 1 envelope with an `entries` list containing
`state`, `action` and `value` records. The application provides reversible state
and action codecs. Encoded values must be JSON-compatible and decoded keys must
have stable equality/hash codes. Q-values must be finite.

`QTable.fromJson` rejects unknown versions, malformed entries and nonfinite
values. Codec errors propagate to the caller. Duplicate state/action pairs
overwrite previous values in input order.

The runnable [persistence.dart](../example/persistence.dart) trains, serializes,
restores and checks a policy. A table does not save configuration, epsilon,
RNG progress or environment state. It is not an exact continuation checkpoint.
IO, storage and encryption belong to the application.

```sh
dart run example/persistence.dart
```

## Double Q-Learning (0.2)

Serialize `agent.tableA` and `agent.tableB` individually using application codecs.
Restore each through `QTable.fromJson` and pass `tableA` and `tableB` to the
`DoubleQAgent` constructor. Saving only the sum loses the independent estimators
required to continue Double Q-Learning. `agent.values` is a read-only view, not a
serialized format. No RNG/epsilon checkpoint is provided.
