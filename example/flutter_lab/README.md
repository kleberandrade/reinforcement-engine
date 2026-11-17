# Reinforcement Engine Lab

Interactive 5×5 maze with Q-Learning and SARSA, using the parent Dart package.

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
