import 'lab_navigation.dart';
import 'lab_locale.dart';
import 'dart:async';
import 'dart:convert';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:reinforcement_engine/reinforcement_engine.dart';

/// The application owns JSON transfer, environment identity and episode counts.
class CheckpointPage extends StatefulWidget {
  const CheckpointPage({super.key});
  @override
  State<CheckpointPage> createState() => _CheckpointPageState();
}

class _CheckpointPageState extends State<CheckpointPage> {
  final json = TextEditingController();
  TabularAgent<int, GridAction> agent = TabularAgent(seed: 42);
  Timer? timer;
  int episodes = 0;
  String status = 'Treine, exporte o JSON e importe para continuar.';
  String before = 'Ainda não avaliado';
  bool get busy => timer != null;

  String report() {
    final result = evaluatePolicy<int, GridAction>(
        environmentFactory: GridWorld.new,
        policy: GreedyPolicy(agent.values),
        isSuccess: (state, episode) => episode.terminated && state == 24,
        episodes: 20,
        maxSteps: 100,
        seed: 7);
    return '${(result.successRate * 100).toStringAsFixed(0)}% sucesso; '
        '${result.meanSteps.toStringAsFixed(1)} passos';
  }

  void train() {
    var remaining = 100;
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      for (var i = 0; i < 5 && remaining > 0; i++, remaining--) {
        trainEpisode(environment: GridWorld(), agent: agent, maxSteps: 200);
        episodes++;
      }
      if (remaining == 0) {
        timer?.cancel();
        timer = null;
        status = 'Depois de continuar: ${report()}';
      }
      setState(() {});
    });
    setState(() => status = 'Treinando em lotes…');
  }

  void export() {
    json.text = const JsonEncoder.withIndent('  ').convert({
      'demoVersion': 1,
      'environment': 'defaultGridWorld',
      'episodes': episodes,
      'checkpoint': TrainingCheckpoint.tabular(agent,
          encodeState: (state) => state,
          encodeAction: (action) => action.name).toJson(),
    });
    setState(() => status = 'JSON exportado. Copie para guardar.');
  }

  void restore() {
    try {
      final data = jsonDecode(json.text);
      if (data is! Map<String, dynamic> ||
          data['demoVersion'] != 1 ||
          data['environment'] != 'defaultGridWorld' ||
          data['episodes'] is! int ||
          (data['episodes'] as int) < 0 ||
          data['checkpoint'] is! Map<String, dynamic>) {
        throw const FormatException('Formato ou ambiente incompatível');
      }
      final restored = TrainingCheckpoint.fromJson(
              data['checkpoint'] as Map<String, dynamic>)
          .restoreTabular<int, GridAction>(
              decodeState: (value) {
                if (value is! int || value < 0 || value > 24) {
                  throw const FormatException('Estado inválido');
                }
                return value;
              },
              decodeAction: (value) =>
                  GridAction.values.byName(value as String),
              seed: 99);
      setState(() {
        agent = restored;
        episodes = data['episodes'] as int;
        before = report();
        status = 'Checkpoint importado. Continue com Treinar +100.';
      });
    } catch (_) {
      setState(
          () => status = 'JSON inválido ou incompatível. Agente preservado.');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    json.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const LabTopBar(back: true),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const LabText('Checkpoints de aprendizado',
              style: TextStyle(fontSize: 26)),
          const SizedBox(height: 12),
          const LabText(
              'Os valores e a exploração são restaurados. A retomada usa uma '
              'nova sequência aleatória e reinicia o ambiente a cada episódio.'),
          const SizedBox(height: 16),
          LabText('Episódios salvos e novos: $episodes'),
          LabText('Exploração: ${agent.epsilon.toStringAsFixed(4)}'),
          LabText('Ao importar: $before'),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: [
            FilledButton(
                onPressed: busy ? null : train,
                child: const LabText('Treinar +100')),
            OutlinedButton(
                onPressed: busy ? null : export,
                child: const LabText('Exportar JSON')),
            OutlinedButton(
                onPressed: busy ? null : restore,
                child: const LabText('Importar JSON')),
            TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                          agent = TabularAgent(seed: 42);
                          episodes = 0;
                          before = 'Ainda não avaliado';
                          status = 'Agente reiniciado; JSON mantido.';
                        }),
                child: const LabText('Novo agente')),
          ]),
          const SizedBox(height: 16),
          LabText(status),
          const SizedBox(height: 16),
          TextField(
              controller: json,
              enabled: !busy,
              minLines: 8,
              maxLines: 16,
              decoration: const InputDecoration(
                  labelText: 'Checkpoint JSON', border: OutlineInputBorder())),
        ]),
      );
}
