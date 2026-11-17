# 0.4.0 review

Learning can be saved at an episode/window boundary and restored into a fresh
built-in agent. Preserve tables, configuration, current exploration and R-learning
average reward. Double Q retains both independent estimators. SARSA(lambda)
requires empty traces. Unsupported strategies and malformed/colliding keys fail
explicitly. Existing constructors and QTable JSON remain compatible.

The [checkpoint contract](checkpoints.md) specifies new-RNG-stream resume,
caller-owned environment/counters/pending actions and custom strategy limits.
The Flutter page demonstrates JSON transfer and independently seeded greedy
before/after evaluation; neither exact resume nor guaranteed improvement is claimed.

Validation: 70 local core tests; root/Flutter/consumer analysis; eight VM examples;
checkpoint compiled JS; Flutter web build/Wasm compatibility. Local widgets are
blocked by socket restrictions and run on hosted CI. Local pub validation is
blocked by pub.dev DNS after archive creation. Release/tag and hosted publication
are verified separately after CI; this review alone does not prove either.
