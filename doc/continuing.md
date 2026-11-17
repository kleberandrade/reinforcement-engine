# R-learning and continuing tasks (0.3 development)

`RLearningAgent<S, A>` learns relative action values and an average reward per
step estimate, `averageReward`. This contract has neither discount nor terminal
targets. It implements `ContinuingAgent`, separately from `LearningAgent`.

The value update is `Q(s,a) += alpha * (r - rho + max Q(s',a') - Q(s,a))`.
After that update, if the executed action is among the current state's greedy
actions, apply `rho += beta * (r - rho + max Q(s',a') - max Q(s,a))` using the
updated table. The order is explicit: the greedy gate and both rho maxima use
post-update values, including self-loops. Ties qualify as greedy. Inputs/results
must be finite; a projected update is validated before committing Q or rho.
A beta smaller than alpha is a useful starting choice; both must be in (0,1].
No convergence guarantee is provided.

```dart
final task = MaintenanceTask();
final agent = RLearningAgent<MachineState, MachineAction>(
  averageRewardRate: 0.005,
  epsilon: 0.1,
  minEpsilon: 0.1,
  seed: 42,
);
final first = trainContinuing(
  environment: task,
  agent: agent,
  initialState: task.reset(),
  steps: 1000,
);
final next = trainContinuing(
  environment: task,
  agent: agent,
  initialState: first.finalState,
  steps: 1000,
);
print(next.meanReward);
```

Windows only bound work. The runner never resets the environment, decays epsilon
or resets rho between windows. Carry the returned state into the next window
using the same environment instance. Terminated or truncated transitions are
rejected before updating the agent; use episodic control for tasks with those
boundaries. The environment may already have advanced before reporting an invalid
boundary, so recovery remains the caller's responsibility.

`MaintenanceTask` is an educational ready/worn machine with work/service actions.
Work earns +3 when ready and -1 when worn; service earns 0 and returns to ready.
The optimal cycle averages 1.5 per step. Run `dart run example/continuing.dart`.
With its documented settings/seeds, the local run reached rho 1.500 and a greedy
mean of 1.5 over 1,000 evaluation steps. The Flutter lab offers **Tarefa contínua**
with bounded training blocks scheduled between frames.

To persist, store `table` through the existing JSON codec and `averageReward`
separately; restore with `table:` and `initialAverageReward:`. RNG, epsilon and
world state are not a serialized continuation checkpoint. Evaluate using a fresh
environment instance and independent RNG to avoid affecting training.

[Algorithm reference: Barto, R-learning lecture pseudocode](https://people.cs.umass.edu/~barto/courses/cs687/Chapter%206-printable.pdf).
