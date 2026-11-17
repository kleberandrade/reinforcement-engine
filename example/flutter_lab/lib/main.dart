import 'dart:async';
import 'dart:math';
import 'continuing_page.dart';
import 'checkpoint_page.dart';
import 'bandits_page.dart';
// Keep compatibility with Flutter versions before the material_ui split.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() => runApp(const LearningLab());

enum LabAlgorithm {
  qLearning('Q-Learning'),
  sarsa('SARSA'),
  expectedSarsa('Expected SARSA'),
  doubleQ('Double Q-Learning'),
  sarsaLambda('SARSA(λ)'),
  watkins('Watkins Q(λ)');

  const LabAlgorithm(this.label);
  final String label;
}

class LearningLab extends StatelessWidget {
  const LearningLab({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Reinforcement Engine Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff7c6cff), brightness: Brightness.dark),
          scaffoldBackgroundColor: const Color(0xff101322),
          useMaterial3: true),
      home: const MazePage());
}

class MazePage extends StatefulWidget {
  const MazePage({super.key});
  @override
  State<MazePage> createState() => _MazePageState();
}

class _MazePageState extends State<MazePage> {
  final environment = GridWorld();
  LabAlgorithm algorithm = LabAlgorithm.qLearning;
  late LearningAgent<int, GridAction> agent;
  late EpisodeResult Function() runEpisode;
  Timer? timer;
  int remaining = 0;
  bool training = false, paused = false;
  int seed = 42;
  double initialEpsilon = 1;
  final rewards = <double>[];
  GridWorld? playback;
  Random playbackRandom = Random(7);
  int episodes = 0, position = 0, moves = 0;
  double lastReward = 0;
  String status = 'Treine o agente e acompanhe o caminho aprendido.';
  final visited = <int>{};
  bool get busy => timer != null || paused;
  @override
  void initState() {
    super.initState();
    resetAgent();
  }

  void resetAgent() {
    timer?.cancel();
    timer = null;
    paused = false;
    training = false;
    remaining = 0;
    rewards.clear();
    if (algorithm == LabAlgorithm.sarsaLambda ||
        algorithm == LabAlgorithm.watkins) {
      final EpisodicAgent<int, GridAction> traceAgent =
          algorithm == LabAlgorithm.watkins
              ? WatkinsQLambdaAgent<int, GridAction>(
                  seed: seed, learningRate: 0.2, epsilon: initialEpsilon)
              : SarsaLambdaAgent<int, GridAction>(
                  seed: seed, learningRate: 0.2, epsilon: initialEpsilon);
      agent = traceAgent;
      runEpisode = () => trainEpisodic(
          environment: environment, agent: traceAgent, maxSteps: 200);
    } else {
      agent = switch (algorithm) {
        LabAlgorithm.doubleQ => DoubleQAgent<int, GridAction>(
            seed: seed, learningRate: 0.2, epsilon: initialEpsilon),
        _ => TabularAgent<int, GridAction>(
            algorithm: switch (algorithm) {
              LabAlgorithm.qLearning => LearningAlgorithm.qLearning,
              LabAlgorithm.sarsa => LearningAlgorithm.sarsa,
              _ => LearningAlgorithm.expectedSarsa,
            },
            seed: seed,
            epsilon: initialEpsilon,
            learningRate: 0.2),
      };
      runEpisode = () =>
          trainEpisode(environment: environment, agent: agent, maxSteps: 200);
    }
    episodes = 0;
    position = environment.reset();
    moves = 0;
    lastReward = 0;
    visited.clear();
    status = 'Treine o agente e acompanhe o caminho aprendido.';
  }

  void stop() {
    timer?.cancel();
    timer = null;
  }

  void cancel() => setState(() {
        stop();
        paused = false;
        training = false;
        status = 'Cancelado. O aprendizado foi preservado.';
      });

  void togglePause() => setState(() {
        if (paused) {
          paused = false;
          training ? scheduleTraining() : schedulePlayback();
          status = training
              ? 'Aprendendo…'
              : 'Executando a política sem exploração…';
        } else {
          stop();
          paused = true;
          status = 'Pausado. Continue ou cancele a execução.';
        }
      });

  void train() {
    remaining = 500;
    training = true;
    scheduleTraining();
    setState(() => status = 'Aprendendo…');
  }

  void scheduleTraining() {
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      for (var i = 0; i < 10 && remaining > 0; i++, remaining--) {
        final result = runEpisode();
        episodes++;
        lastReward = result.reward;
        rewards.add(result.reward);
      }
      if (remaining == 0) {
        stop();
        training = false;
      }
      setState(() {
        status = remaining == 0
            ? 'Treino concluído. Execute a política aprendida.'
            : 'Aprendendo…';
      });
    });
  }

  void play() {
    training = false;
    playback = GridWorld();
    playbackRandom = Random(7);
    position = playback!.reset();
    moves = 0;
    visited.clear();
    schedulePlayback();
    setState(() => status = 'Executando a política sem exploração…');
  }

  void schedulePlayback() {
    timer = Timer.periodic(const Duration(milliseconds: 220), (_) {
      final world = playback!;
      final action = GreedyPolicy(agent.values)
          .selectAction(position, world.actions(position), playbackRandom);
      final result = world.step(action);
      visited.add(position);
      position = result.state;
      moves++;
      if (result.terminated || moves >= 100) {
        stop();
        status = result.terminated
            ? 'Objetivo alcançado em $moves movimentos!'
            : 'Limite atingido. Treine mais episódios.';
      }
      setState(() {});
    });
  }

  String policyAt(int cell) {
    final actions = environment.actions(cell);
    final best = actions.map((a) => agent.values.value(cell, a)).reduce(max);
    const arrows = ['↑', '→', '↓', '←'];
    return actions
        .where((a) => agent.values.value(cell, a) == best)
        .map((a) => arrows[a.index])
        .join();
  }

  void evaluate() {
    final report = evaluatePolicy<int, GridAction>(
      environmentFactory: GridWorld.new,
      policy: GreedyPolicy(agent.values),
      isSuccess: (state, episode) =>
          episode.terminated && state == environment.goal,
      episodes: 50,
      maxSteps: 100,
      seed: 7,
    );
    setState(() {
      status =
          'Avaliação: ${(report.successRate * 100).toStringAsFixed(0)}% de sucesso, '
          '${report.meanSteps.toStringAsFixed(1)} passos em média. '
          'Tabela e exploração preservadas.';
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: ListView(padding: const EdgeInsets.all(24), children: [
                    Text('REINFORCEMENT ENGINE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(0xffb3aaff), letterSpacing: 3)),
                    const SizedBox(height: 12),
                    Text('Aprender explorando.',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    const Text(
                        'Um agente, um labirinto e recompensas. Cada episódio melhora suas decisões.'),
                    const SizedBox(height: 24),
                    Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                              width: 280,
                              child: DropdownButton<LabAlgorithm>(
                                  isExpanded: true,
                                  itemHeight: null,
                                  value: algorithm,
                                  onChanged: busy
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            setState(() {
                                              algorithm = value;
                                              resetAgent();
                                            });
                                          }
                                        },
                                  items: LabAlgorithm.values
                                      .map((v) => DropdownMenuItem(
                                          value: v,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              child: Text(v.label))))
                                      .toList())),
                          if (busy) ...[
                            OutlinedButton(
                                onPressed: togglePause,
                                child: Text(paused ? 'Continuar' : 'Pausar')),
                            TextButton(
                                onPressed: cancel,
                                child: const Text('Cancelar')),
                          ],
                          FilledButton(
                              onPressed: busy ? null : train,
                              child: const Text('Treinar +500')),
                          OutlinedButton(
                              onPressed: busy || episodes == 0 ? null : play,
                              child: const Text('Executar')),
                          OutlinedButton(
                              onPressed:
                                  busy || episodes == 0 ? null : evaluate,
                              child: const Text('Avaliar ×50')),
                          OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const ContinuingPage())),
                              child: const Text('Tarefa contínua')),
                          OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const CheckpointPage())),
                              child: const Text('Salvar e retomar')),
                          OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (_) => const BanditsPage())),
                              child: const Text('Bandits')),
                          TextButton(
                              onPressed: () => setState(resetAgent),
                              child: const Text('Reiniciar')),
                        ]),
                    const SizedBox(height: 16),
                    Wrap(spacing: 16, runSpacing: 8, children: [
                      DropdownButton<int>(
                          value: seed,
                          onChanged: busy
                              ? null
                              : (value) => setState(() {
                                    seed = value!;
                                    resetAgent();
                                  }),
                          items: [42, 7, 123]
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text('Seed $value')))
                              .toList()),
                      SizedBox(
                          width: 260,
                          child: Column(children: [
                            Text(
                                'Epsilon inicial: ${initialEpsilon.toStringAsFixed(2)}'),
                            Slider(
                                value: initialEpsilon,
                                min: 0.01,
                                max: 1,
                                label: initialEpsilon.toStringAsFixed(2),
                                semanticFormatterCallback: (value) =>
                                    'Exploração inicial ${(value * 100).round()} por cento',
                                onChanged: busy
                                    ? null
                                    : (value) => setState(() {
                                          initialEpsilon = value;
                                          resetAgent();
                                        })),
                          ])),
                    ]),
                    const Text(
                        'Mudar algoritmo, seed ou epsilon reinicia o aprendizado.'),
                    const SizedBox(height: 16),
                    Wrap(spacing: 24, runSpacing: 8, children: [
                      Text('Episódios: $episodes'),
                      Text(
                          'Exploração: ${(agent.epsilon * 100).toStringAsFixed(1)}%'),
                      Text(
                          'Última recompensa: ${lastReward.toStringAsFixed(0)}'),
                    ]),
                    const SizedBox(height: 24),
                    Center(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 450),
                            child: AspectRatio(
                                aspectRatio: 1,
                                child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: 25,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 5,
                                            crossAxisSpacing: 6,
                                            mainAxisSpacing: 6),
                                    itemBuilder: (context, cell) {
                                      final wall =
                                          environment.walls.contains(cell);
                                      final here = position == cell;
                                      return Semantics(
                                          label:
                                              'Célula $cell, ${wall ? "parede" : cell == environment.goal ? "objetivo" : here ? "agente" : "livre"}${!wall && cell != environment.goal && episodes > 0 ? ", política ${policyAt(cell)}" : ""}',
                                          child: ExcludeSemantics(
                                              child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 160),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: here
                                                          ? const Color(
                                                              0xff7c6cff)
                                                          : wall
                                                              ? const Color(
                                                                  0xff414657)
                                                              : cell ==
                                                                      environment
                                                                          .goal
                                                                  ? const Color(
                                                                      0xff17685c)
                                                                  : visited.contains(
                                                                          cell)
                                                                      ? const Color(
                                                                          0xff35305e)
                                                                      : const Color(
                                                                          0xff202638)),
                                                  child: Center(
                                                      child: here
                                                          ? const Icon(
                                                              Icons
                                                                  .smart_toy_outlined,
                                                              size: 30)
                                                          : cell ==
                                                                  environment
                                                                      .goal
                                                              ? const Icon(
                                                                  Icons
                                                                      .flag_outlined,
                                                                  size: 30)
                                                              : wall
                                                                  ? const Icon(
                                                                      Icons
                                                                          .block,
                                                                      color: Colors
                                                                          .white38)
                                                                  : Text(
                                                                      episodes ==
                                                                              0
                                                                          ? '$cell'
                                                                          : policyAt(
                                                                              cell),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.white))))));
                                    })))),
                    const SizedBox(height: 24),
                    const Text(
                        'Setas: ações de maior valor Q; empates mostram várias direções.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    RewardHistory(rewards: rewards),
                    const SizedBox(height: 16),
                    Semantics(
                        liveRegion: true,
                        child: Text(status, textAlign: TextAlign.center)),
                    const SizedBox(height: 16),
                    Text(
                        'Recompensa: −1 por passo, +10 ao alcançar a bandeira. '
                        'As paredes bloqueiam o movimento. O caminho mínimo tem 8 movimentos. '
                        'O treino usa seed $seed e até 200 passos por episódio. ',
                        textAlign: TextAlign.center),
                  ])))));
}

class RewardHistory extends StatelessWidget {
  const RewardHistory({super.key, required this.rewards});
  final List<double> rewards;

  @override
  Widget build(BuildContext context) {
    final recent = rewards.skip(max(0, rewards.length - 50)).toList();
    final mean =
        recent.isEmpty ? 0.0 : recent.reduce((a, b) => a + b) / recent.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Recompensas por episódio',
          style: Theme.of(context).textTheme.titleMedium),
      Text(
          '${rewards.length} episódios registrados · média dos últimos ${recent.length}: ${mean.toStringAsFixed(1)}'),
      const Text(
          'Últimos 50: altura indica retorno de −200 a +3; maior é melhor.'),
      const SizedBox(height: 8),
      Semantics(
          label:
              'Histórico de recompensas. Última: ${rewards.isEmpty ? "nenhuma" : rewards.last.toStringAsFixed(1)}. Média recente ${mean.toStringAsFixed(1)}.',
          child: ExcludeSemantics(
              child: SizedBox(
                  height: 64,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < recent.length; i++)
                        Expanded(
                            child: Tooltip(
                                message:
                                    'Episódio ${rewards.length - recent.length + i + 1}: ${recent[i]}',
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    child: Container(
                                        height: 4 +
                                            60 *
                                                ((recent[i] + 200) / 203)
                                                    .clamp(0, 1),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary))))
                    ],
                  )))),
    ]);
  }
}
