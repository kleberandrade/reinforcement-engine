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

For evaluation, **Avaliar ×50** runs 50 greedy GridWorld episodes with a
separate evaluation RNG and fresh environments. It reports success rate and
average steps without changing the learned table or agent exploration.

The lab includes **SARSA(λ)** to the maze selector and **Tarefa contínua**
for an independent maintenance-task screen. R-learning trains 100-step blocks
between timer ticks, preserving state/rho; evaluation uses a fresh environment.
The trace agent uses trainEpisodic so eligibility cannot cross episode boundaries.

## Learning checkpoints / Checkpoints

Open **Salvar e retomar**. Train +100, export the JSON, create a new agent, import
and train again. The page compares greedy evaluations before/after resumed
training. A new RNG stream starts on import; environment identity and counters
are demo-owned. See [English](../../doc/checkpoints.md) /
[Português](../../doc/checkpoints.pt-BR.md) for the boundary contract.

## Watkins and bandits / Watkins e bandits (0.5)

The maze selector includes accumulating **Watkins Q(λ)** using the lifecycle runner.
Open **Bandits** to compare UCB1 and fixed epsilon-greedy on three synthetic options
with success chances .2/.5/.8. Selection bars show lifetime selection shares, not
probabilities that an option is best. Twenty pulls run per timer tick; changing
policy resets the experiment and popping the page cancels its timer.

O seletor do labirinto inclui Watkins Q(λ) acumulativo. Abra **Bandits** para
comparar UCB1 e epsilon-greedy em três opções sintéticas. Barras mostram a fração
das escolhas, não a probabilidade de cada opção ser melhor. Trocar a política
reinicia o experimento; sair da página cancela o treino.
