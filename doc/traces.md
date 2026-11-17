# SARSA(lambda) and eligibility traces (0.3 development)

`SarsaLambdaAgent<S, A>` implements tabular SARSA with accumulating traces.
It is neither true-online SARSA nor replacing-trace SARSA.
`lambda` and `discountFactor` must be in [0,1].

Each transition computes `delta = r + gamma * Q(s',a') - Q(s,a)`, increments
`e(s,a)` by one, applies `Q(x,u) += alpha * delta * e(x,u)` to all active traces,
then decays `e *= gamma * lambda`. Termination uses zero bootstrap and clears
traces after propagation. Truncation retains bootstrap and clears traces at the
episode boundary. All proposed values are validated before any table writes:
overflow cannot leave a partially updated table.

```dart
final agent = SarsaLambdaAgent<int, GridAction>(lambda: 0.8, seed: 42);
for (var episode = 0; episode < 500; episode++) {
  trainEpisodic(environment: GridWorld(), agent: agent, maxSteps: 200);
}
```

Use **`trainEpisodic`**, which takes `EpisodicAgent` and guarantees
`beginEpisode`/`endEpisode`, including environment exceptions. It reuses the
`trainEpisode` loop without concrete type checks. Manual loops must call lifecycle
methods at episode boundaries and reuse exactly the next sampled bootstrap action.
`trainEpisode` alone does not manage trace cleanup on truncation; use the
lifecycle-aware runner.

With lambda zero, values and episode outcomes match SARSA under the same settings,
seed and runtime. Work scales with the number of active trace pairs. No threshold
pruning is applied: entries leave on numerical zero or at the episode boundary.
Long tasks need suitable limits. Begin/end clears only traces, preserving Q,
RNG and exploration.

Run `dart run example/eligibility_traces.dart`. It learns GridWorld's eight-step
path and verifies no traces remain between episodes. The lab includes SARSA(lambda)
in its maze algorithm selector. Persist QTable to resume between episodes; traces
and RNG are not persisted.

[Algorithm reference: Sutton and Barto, eligibility traces](https://web.stanford.edu/class/psych209/Readings/SuttonBartoRL.pdf).
