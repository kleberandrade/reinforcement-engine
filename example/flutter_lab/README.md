# Reinforcement Engine Lab

Interactive 5×5 maze with Q-Learning, SARSA, Expected SARSA and Double Q-Learning, using the parent Dart package.

```sh
flutter pub get
flutter run -d chrome
```

Select an algorithm, train 500 episodes per click, then execute the greedy policy.
Reset cancels active timers and clears training. Switching algorithms also resets.
Each training episode is bounded to 200 steps; playback is bounded to 100 steps.
The shortest path is eight moves. Walls and boundary collisions cost a step.

The lab schedules batches of ten episodes between timer ticks. For substantially
larger environments, use an isolate rather than increasing synchronous batch size.

```sh
flutter analyze
flutter test
flutter build web
```

Web scaffolding is included. To run on another platform, generate that platform
with `flutter create --platforms=android,ios,macos .` on a configured machine.

In 0.2 development, **Avaliar ×50** runs 50 greedy GridWorld episodes with a
separate evaluation RNG and fresh environments. It reports success rate and
average steps without changing the learned table or agent exploration.

The 0.3 development lab adds **SARSA(λ)** to the maze selector and **Tarefa contínua**
for an independent maintenance-task screen. R-learning trains 100-step blocks
between timer ticks, preserving state/rho; evaluation uses a fresh environment.
The trace agent uses trainEpisodic so eligibility cannot cross episode boundaries.
