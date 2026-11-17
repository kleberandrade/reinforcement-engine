# Engineering workflow

This package is a pure Dart tabular reinforcement learning framework.
Keep Flutter, IO, network, storage and execution workers outside its core.

- Follow `doc/architecture.md` and its source dependency map.
- Prefer explicit typed contracts and strategy composition over concrete type
  checks, mutable registries or inheritance from the agent.
- Keep results immutable and run state local. State/action keys need stable equality.
- Pin public behavior before structural refactors. Use public imports in tests
  and examples and meaningful numerical and lifecycle tests.
- Validate configuration at construction and rewards/bootstrap/table values at
  the numeric boundary. Preserve termination versus truncation semantics.
- Keep English and Portuguese documentation and Unreleased notes synchronized.
- Run CONTRIBUTING.md checks; record action/reason/validation in the engineering log.
- Use semantic commits. Do not publish or claim configured checks have passed.
- Preserve unrelated work and caches.
