import 'dart:async';
import 'dart:math';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:reinforcement_engine/reinforcement_engine.dart';

/// Synthetic feedback only. The agent never receives the hidden probabilities.
class BanditsPage extends StatefulWidget {
  const BanditsPage({super.key});
  @override
  State<BanditsPage> createState() => _BanditsPageState();
}

class _BanditsPageState extends State<BanditsPage> {
  static const probabilities = [.2, .5, .8];
  late BanditAgent<int> agent;
  late List<Random> rewards;
  bool ucb = true;
  Timer? timer;
  double total = 0;
  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    timer?.cancel();
    timer = null;
    total = 0;
    agent = BanditAgent<int>(
        arms: [0, 1, 2],
        seed: 42,
        policy:
            ucb ? const Ucb1<int>() : EpsilonGreedyBandit<int>(epsilon: .1));
    rewards = List.generate(3, (i) => Random(100 + i));
  }

  void train() {
    var remaining = 1000;
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final result = trainBandit(
          agent: agent,
          pulls: 20,
          reward: (arm) =>
              rewards[arm].nextDouble() < probabilities[arm] ? 1 : 0);
      total += result.reward;
      remaining -= 20;
      if (remaining == 0) {
        timer?.cancel();
        timer = null;
      }
      setState(() {});
    });
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Bandits: aprender a escolher')),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const Text('Três opções, uma recompensa imediata.',
              style: TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          const Text(
              'Cada escolha retorna 1 em caso de sucesso e 0 em caso de falha. '
              'As chances reais são 20%, 50% e 80%. O agente só vê os resultados.'),
          const SizedBox(height: 16),
          Wrap(spacing: 16, runSpacing: 12, children: [
            DropdownButton<bool>(
                value: ucb,
                items: const [
                  DropdownMenuItem(value: true, child: Text('UCB1')),
                  DropdownMenuItem(value: false, child: Text('Epsilon-greedy'))
                ],
                onChanged: timer != null
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            ucb = value;
                            reset();
                          });
                        }
                      }),
            FilledButton(
                onPressed: timer != null ? null : train,
                child: const Text('Experimentar +1.000')),
            TextButton(
                onPressed: () => setState(reset),
                child: const Text('Reiniciar')),
          ]),
          const SizedBox(height: 16),
          Text('Decisões: ${agent.values.observations}'),
          Text(
              'Recompensa observada: ${agent.values.observations == 0 ? "—" : (total / agent.values.observations).toStringAsFixed(3)}'),
          const SizedBox(height: 24),
          for (var arm = 0; arm < 3; arm++) ...[
            Text('Opção ${arm + 1}: ${agent.values.count(arm)} escolhas; '
                'média estimada ${agent.values.mean(arm).toStringAsFixed(3)}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
                value: agent.values.observations == 0
                    ? 0
                    : agent.values.count(arm) / agent.values.observations,
                minHeight: 16,
                semanticsLabel: 'Participação da opção ${arm + 1}'),
            const SizedBox(height: 20),
          ],
          const Text(
              'As barras mostram a participação de cada opção nas escolhas, '
              'não a probabilidade de ela ser a melhor. Trocar a estratégia reinicia '
              'o experimento. Este cenário sintético não garante resultados em outras tarefas.'),
        ]),
      );
}
