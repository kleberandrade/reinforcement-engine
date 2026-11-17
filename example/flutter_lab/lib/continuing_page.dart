import 'dart:async';
import 'dart:math';
// Keep compatibility with Flutter versions before the material_ui split.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:reinforcement_engine/reinforcement_engine.dart';

class ContinuingPage extends StatefulWidget {
  const ContinuingPage({super.key});
  @override
  State<ContinuingPage> createState() => _ContinuingPageState();
}

class _ContinuingPageState extends State<ContinuingPage> {
  final environment = MaintenanceTask();
  late RLearningAgent<MachineState, MachineAction> agent;
  Timer? timer;
  int steps = 0;
  String result = 'Treine a política de trabalho e manutenção.';
  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    timer?.cancel();
    timer = null;
    environment.reset();
    steps = 0;
    agent = RLearningAgent(
        learningRate: 0.1,
        averageRewardRate: 0.005,
        epsilon: 0.1,
        minEpsilon: 0.1,
        seed: 42);
    result = 'Treine a política de trabalho e manutenção.';
  }

  void train() {
    var remaining = 100;
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      trainContinuing(
          environment: environment,
          agent: agent,
          initialState: environment.state,
          steps: 100);
      steps += 100;
      if (--remaining == 0) {
        timer?.cancel();
        timer = null;
      }
      setState(() {});
    });
    setState(() {});
  }

  void evaluate() {
    final evaluation = MaintenanceTask();
    final policy = GreedyPolicy(agent.values);
    final random = Random(7);
    var state = evaluation.reset();
    var reward = 0.0;
    for (var step = 0; step < 1000; step++) {
      final transition = evaluation
          .step(policy.selectAction(state, evaluation.actions(state), random));
      state = transition.state;
      reward += transition.reward;
    }
    setState(() {
      result =
          'Recompensa média: ${(reward / 1000).toStringAsFixed(2)} em 1.000 passos sem exploração.';
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('R-Learning: tarefa contínua')),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(padding: const EdgeInsets.all(24), children: [
                  Text('Trabalhar e manter.',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 16),
                  const Text(
                      'Uma máquina didática ganha +3 ao trabalhar pronta e −1 se desgastada. '
                      'Manutenção ganha 0 e deixa a máquina pronta. O melhor ciclo ganha 1,50 por passo.'),
                  const SizedBox(height: 24),
                  Text('Passos: $steps'),
                  Text(
                      'Recompensa média estimada (ρ): ${agent.averageReward.toStringAsFixed(3)}'),
                  Text(
                      'Estado: ${environment.state == MachineState.ready ? 'pronta' : 'desgastada'}'),
                  const SizedBox(height: 24),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    FilledButton(
                        onPressed: timer == null ? train : null,
                        child: const Text('Treinar +10.000')),
                    OutlinedButton(
                        onPressed: timer == null && steps > 0 ? evaluate : null,
                        child: const Text('Avaliar política')),
                    TextButton(
                        onPressed: () => setState(reset),
                        child: const Text('Reiniciar')),
                  ]),
                  const SizedBox(height: 24),
                  Text(result),
                  const SizedBox(height: 24),
                  const Text(
                      'A tarefa nunca termina. Cada lote preserva o estado e ρ; '
                      'a exploração permanece em 10%. A avaliação usa outra máquina e outro gerador aleatório.'),
                ]))),
      );
}
