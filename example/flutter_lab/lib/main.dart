import 'education_page.dart';
import 'learning_content.dart';
import 'lab_navigation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'lab_algorithm.dart';
export 'lab_algorithm.dart' show LabAlgorithm;
import 'lab_locale.dart';
import 'dart:async';
import 'dart:math';
import 'continuing_page.dart';
import 'checkpoint_page.dart';
import 'bandits_page.dart';
import 'reward_history.dart';
import 'paired_training.dart';
import 'lab_widgets.dart';
export 'reward_history.dart' show RewardHistory;
// Keep compatibility with Flutter versions before the material_ui split.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() => runApp(const LearningLab());

class LearningLab extends StatefulWidget {
  const LearningLab({super.key, this.initialLanguage});
  final LabLanguage? initialLanguage;
  @override
  State<LearningLab> createState() => _LearningLabState();
}

class _LearningLabState extends State<LearningLab> {
  late final LabController controller;
  @override
  void initState() {
    super.initState();
    controller = LabController(initialLanguage: widget.initialLanguage);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (context, _) => LabScope(
          controller: controller,
          child: MaterialApp(
              locale: controller.language == LabLanguage.pt
                  ? const Locale('pt', 'BR')
                  : const Locale('en'),
              supportedLocales: const [Locale('pt', 'BR'), Locale('en')],
              // Compatibility with the pre-material_ui Flutter barrel.
              // ignore: deprecated_member_use
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              title: 'Reinforcement Engine Lab',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: const Color(0xffa18aff),
                      brightness: Brightness.dark),
                  scaffoldBackgroundColor: const Color(0xff0a1020),
                  inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: const Color(0xff0d1526),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xff34415c)))),
                  filledButtonTheme: FilledButtonThemeData(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)))),
                  outlinedButtonTheme: OutlinedButtonThemeData(
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xff41506b)))),
                  textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48))),
                  useMaterial3: true),
              home: const LabShell())));
}

class LabShell extends StatefulWidget {
  const LabShell({super.key});
  @override
  State<LabShell> createState() => _LabShellState();
}

class _LabShellState extends State<LabShell> {
  final mazeKey = GlobalKey<_MazePageState>();
  void runPreset(LabPreset preset) {
    mazeKey.currentState?.loadPreset(preset);
    LabScope.of(context)!.showSection(0);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: const LabTopBar(),
      body: IndexedStack(index: LabScope.of(context)!.section, children: [
        MazePage(key: mazeKey),
        LearnPage(onPreset: runPreset),
        ExamplesPage(onPreset: runPreset),
      ]));
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
  PairedTraining? pair;
  LabParameters get parameters =>
      LabParameters(seed: seed, epsilon: initialEpsilon);
  final comparisonRuns = <LabAlgorithm, List<double>>{};
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

  void resetAgent({bool preserveComparison = false}) {
    if (!preserveComparison) comparisonRuns.clear();
    pair = null;
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
                  seed: seed,
                  learningRate: parameters.learningRate,
                  epsilon: initialEpsilon)
              : SarsaLambdaAgent<int, GridAction>(
                  seed: seed,
                  learningRate: parameters.learningRate,
                  epsilon: initialEpsilon);
      agent = traceAgent;
      runEpisode = () => trainEpisodic(
          environment: environment,
          agent: traceAgent,
          maxSteps: parameters.maxSteps);
    } else {
      agent = switch (algorithm) {
        LabAlgorithm.doubleQ => DoubleQAgent<int, GridAction>(
            seed: seed,
            learningRate: parameters.learningRate,
            epsilon: initialEpsilon),
        _ => parameters.createAgent(switch (algorithm) {
            LabAlgorithm.qLearning => LearningAlgorithm.qLearning,
            LabAlgorithm.sarsa => LearningAlgorithm.sarsa,
            _ => LearningAlgorithm.expectedSarsa,
          }),
      };
      runEpisode = () => trainEpisode(
          environment: environment,
          agent: agent,
          maxSteps: parameters.maxSteps);
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

  void detachPair() {
    if (pair == null) return;
    comparisonRuns[LabAlgorithm.sarsa] = pair!.sarsaRewards;
    pair = null;
  }

  void trainTogether() {
    algorithm = LabAlgorithm.qLearning;
    resetAgent();
    pair = PairedTraining(parameters);
    agent = pair!.qAgent;
    remaining = 500;
    training = true;
    scheduleTraining();
    setState(() =>
        status = 'Treinando Q-Learning e SARSA com os mesmos parâmetros…');
  }

  void train() {
    detachPair();
    remaining = 500;
    training = true;
    scheduleTraining();
    setState(() => status = 'Aprendendo…');
  }

  void scheduleTraining() {
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      for (var i = 0; i < 10 && remaining > 0; i++, remaining--) {
        final result = pair?.trainPair() ?? runEpisode();
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

  void loadPreset(LabPreset preset) {
    setState(() {
      algorithm = preset.algorithm;
      seed = preset.seed;
      initialEpsilon = preset.epsilon;
      resetAgent();
    });
    preset.paired ? trainTogether() : train();
  }

  void changeAlgorithm(LabAlgorithm value) {
    setState(() {
      if (pair != null) comparisonRuns[LabAlgorithm.sarsa] = pair!.sarsaRewards;
      if (rewards.isNotEmpty &&
          (algorithm == LabAlgorithm.qLearning ||
              algorithm == LabAlgorithm.sarsa)) {
        comparisonRuns[algorithm] = List.unmodifiable(rewards);
      }
      algorithm = value;
      resetAgent(preserveComparison: true);
    });
  }

  void openLab(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  Widget navigation() => Wrap(spacing: 10, runSpacing: 10, children: [
        OutlinedButton.icon(
            onPressed: busy ? null : () => openLab(const ContinuingPage()),
            icon: const Icon(Icons.all_inclusive, size: 18),
            label: const LabText('Tarefa contínua')),
        OutlinedButton.icon(
            onPressed: busy ? null : () => openLab(const CheckpointPage()),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const LabText('Salvar e retomar')),
        OutlinedButton.icon(
            onPressed: busy ? null : () => openLab(const BanditsPage()),
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: const LabText('Bandits')),
      ]);

  Widget controls(BuildContext context) => LabPanel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const LabHeading('01 / CONFIGURAR', 'Seu experimento',
            'Uma seed. As mesmas regras. Duas formas de aprender.'),
        InputDecorator(
            decoration:
                const InputDecoration(label: LabText('Algoritmo individual')),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<LabAlgorithm>(
                    iconDisabledColor: labMuted,
                    value: algorithm,
                    isExpanded: true,
                    itemHeight: null,
                    onChanged: busy ? null : (value) => changeAlgorithm(value!),
                    items: LabAlgorithm.values
                        .map((v) => DropdownMenuItem(
                            value: v,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: LabText(v.label,
                                    style: const TextStyle(
                                        color: Color(0xffd7def1))))))
                        .toList()))),
        const SizedBox(height: 18),
        InputDecorator(
            decoration:
                const InputDecoration(label: LabText('Semente aleatória')),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                    iconDisabledColor: labMuted,
                    value: seed,
                    isExpanded: true,
                    onChanged: busy
                        ? null
                        : (value) => setState(() {
                              seed = value!;
                              resetAgent();
                            }),
                    items: [42, 7, 123]
                        .map((value) => DropdownMenuItem(
                            value: value,
                            child: LabText('Seed $value',
                                style:
                                    const TextStyle(color: Color(0xffd7def1)))))
                        .toList()))),
        const SizedBox(height: 20),
        LabText('Epsilon inicial: ${initialEpsilon.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const LabText('Quanto explorar antes de seguir a política.',
            style: TextStyle(color: labMuted, fontSize: 12)),
        Slider(
            value: initialEpsilon,
            min: .01,
            max: 1,
            label: initialEpsilon.toStringAsFixed(2),
            semanticFormatterCallback: (value) => tr(context,
                'Exploração inicial ${(value * 100).round()} por cento'),
            onChanged: busy
                ? null
                : (value) => setState(() {
                      initialEpsilon = value;
                      resetAgent();
                    })),
        Wrap(spacing: 8, runSpacing: 8, children: [
          LabBadge('α ${parameters.learningRate.toStringAsFixed(2)}',
              color: const Color(0xffc2b6ff)),
          LabBadge('γ ${parameters.discountFactor.toStringAsFixed(2)}',
              color: const Color(0xffc2b6ff)),
          const LabBadge('Limite: 200 passos', color: labMuted),
        ]),
        const SizedBox(height: 24),
        FilledButton.icon(
            onPressed: busy ? null : trainTogether,
            icon: const Icon(Icons.compare_arrows_rounded),
            label: const LabText('Treinar juntos')),
        const SizedBox(height: 8),
        const LabText(
            'Q-Learning + SARSA · 500 episódios cada.\nInicia uma comparação nova, desde o zero.',
            style: TextStyle(color: labMuted, fontSize: 12),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        OutlinedButton.icon(
            onPressed: busy ? null : train,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const LabText('Treinar +500')),
        if (busy) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.tonalIcon(
                onPressed: togglePause,
                icon: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                label: LabText(paused ? 'Continuar' : 'Pausar')),
            TextButton(onPressed: cancel, child: const LabText('Cancelar')),
          ]),
        ],
        if (training) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(
              value: (500 - remaining) / 500,
              semanticsLabel: tr(
                  context,
                  pair == null
                      ? 'Progresso do treino'
                      : 'Progresso dos dois agentes')),
          const SizedBox(height: 8),
          LabText(
              '${500 - remaining} / 500 ${pair == null ? "episódios" : "pares de episódios"}',
              style: const TextStyle(color: labMuted, fontSize: 12)),
        ],
        const SizedBox(height: 12),
        TextButton.icon(
            onPressed: () => setState(resetAgent),
            icon: const Icon(Icons.restart_alt_rounded),
            label: const LabText('Reiniciar')),
        const Divider(height: 28),
        const LabText(
            'Mudar seed ou epsilon reinicia o aprendizado e limpa a comparação.',
            style: TextStyle(color: labMuted, fontSize: 12)),
      ]));

  Widget stage(BuildContext context) => LabPanel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LabHeading(
            '02 / OBSERVAR',
            'Cada movimento é uma decisão.',
            pair == null
                ? 'Política de ${algorithm.label} no grid 5 × 5.'
                : 'Comparação Q-Learning × SARSA · o grid mostra Q-Learning.'),
        Wrap(spacing: 10, runSpacing: 10, children: [
          LabMetric('EPISÓDIOS', value: 'Episódios: $episodes'),
          LabMetric('EXPLORAÇÃO ATUAL',
              value: '${(agent.epsilon * 100).toStringAsFixed(1)}%',
              color: const Color(0xffc2b6ff)),
          LabMetric('ÚLTIMO RETORNO',
              value: lastReward.toStringAsFixed(0), color: labCyan),
        ]),
        if (pair != null) ...[
          const SizedBox(height: 12),
          LabBadge(
              'SARSA · ${pair!.sarsaRewards.length} episódios · ε ${(pair!.sarsaAgent.epsilon * 100).toStringAsFixed(1)}%'),
        ],
        const SizedBox(height: 20),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xff0d1526),
                borderRadius: BorderRadius.circular(12)),
            child: Semantics(
                liveRegion: true,
                container: true,
                child: LabText(status,
                    style: const TextStyle(color: Color(0xffd7def1))))),
        const SizedBox(height: 24),
        Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: MazeGrid(
                    world: environment,
                    position: position,
                    visited: visited,
                    trained: episodes > 0,
                    policyAt: policyAt))),
        const SizedBox(height: 20),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
              onPressed: busy || episodes == 0 ? null : play,
              icon: const Icon(Icons.route_rounded, size: 18),
              label: const LabText('Executar')),
          OutlinedButton.icon(
              onPressed: busy || episodes == 0 ? null : evaluate,
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const LabText('Avaliar ×50')),
        ]),
        const SizedBox(height: 14),
        const LabText(
            '↑ → ↓ ← Melhores ações · empates mostram várias setas.\n'
            'Bandeira: objetivo · blocos: paredes · trilha: caminho executado.',
            style: TextStyle(color: labMuted, fontSize: 12)),
        const SizedBox(height: 8),
        const LabText(
            '−1 por passo · +10 no objetivo · rota mínima: 8 passos (retorno +3).',
            style: TextStyle(color: labMuted, fontSize: 12)),
      ]));

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(child: LayoutBuilder(builder: (context, viewport) {
        final wide = viewport.maxWidth >= 960;
        return ListView(
            padding: EdgeInsets.all(viewport.maxWidth < 600 ? 16 : 32),
            children: [
              Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LabBadge('6 algoritmos · 1 gridworld'),
                            const SizedBox(height: 22),
                            LabText('Aprenda com cada decisão.',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                        fontSize: wide ? 40 : 30,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1)),
                            const SizedBox(height: 10),
                            const LabText(
                                'Explore, treine e compare. Transforme recompensas em uma política que encontra o caminho.',
                                style: TextStyle(
                                    color: labMuted,
                                    fontSize: 16,
                                    height: 1.5)),
                            const SizedBox(height: 22),
                            navigation(),
                            const SizedBox(height: 28),
                            if (wide)
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        width: 330, child: controls(context)),
                                    const SizedBox(width: 24),
                                    Expanded(child: stage(context)),
                                  ])
                            else ...[
                              controls(context),
                              const SizedBox(height: 20),
                              stage(context)
                            ],
                            const SizedBox(height: 24),
                            LabPanel(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  const LabText('03 / COMPARAR',
                                      style: TextStyle(
                                          color: labCyan,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2)),
                                  const SizedBox(height: 10),
                                  LabBadge(
                                      'Seed $seed · ε inicial ${initialEpsilon.toStringAsFixed(2)} · α ${parameters.learningRate} · γ ${parameters.discountFactor}',
                                      color: labMuted),
                                  const SizedBox(height: 16),
                                  RewardHistory(
                                      rewards: List.unmodifiable(rewards),
                                      algorithm: algorithm.label,
                                      comparison: pair?.sarsaRewards ??
                                          comparisonRuns[switch (algorithm) {
                                            LabAlgorithm.qLearning =>
                                              LabAlgorithm.sarsa,
                                            LabAlgorithm.sarsa =>
                                              LabAlgorithm.qLearning,
                                            _ => algorithm,
                                          }] ??
                                          const [],
                                      comparisonAlgorithm:
                                          algorithm == LabAlgorithm.sarsa
                                              ? 'Q-Learning'
                                              : 'SARSA'),
                                ])),
                            const SizedBox(height: 24),
                            const LabText('UM LABORATÓRIO PARA EXPERIMENTAR',
                                style: TextStyle(
                                    color: labMuted,
                                    fontSize: 11,
                                    letterSpacing: 2)),
                            const SizedBox(height: 8),
                            const LabText(
                                'Treinar altera os valores. Avaliar e executar usam ambientes e seeds independentes. '
                                'Uma comparação com uma seed não representa um ranking estatístico dos algoritmos.',
                                style: TextStyle(
                                    color: labMuted,
                                    fontSize: 12,
                                    height: 1.5)),
                            const SizedBox(height: 20),
                          ]))),
            ]);
      })));
}
