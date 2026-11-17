// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'lab_locale.dart';
import 'lab_widgets.dart';
import 'lab_navigation.dart';
import 'learning_content.dart';

class ExamplesPage extends StatelessWidget {
  const ExamplesPage({super.key, required this.onPreset});
  final ValueChanged<LabPreset> onPreset;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(24), children: [
        Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LabHeading(
                          'EXPERIMENTAR',
                          'Exemplos que você pode executar',
                          'Cada exemplo usa os algoritmos e o GridWorld implementados neste projeto.'),
                      const LabText(
                          'Abrir exemplo reinicia o experimento atual.'),
                      const SizedBox(height: 20),
                      for (final preset in labPresets) ...[
                        PresetCard(
                            preset: preset, onRun: () => onPreset(preset)),
                        const SizedBox(height: 16),
                      ],
                      const LabText(
                          'Os resultados dependem da seed e do runtime; observe também falhas.',
                          english:
                              'Results depend on seed and runtime; keep failures visible too.'),
                    ]))),
      ]);
}

class PresetCard extends StatelessWidget {
  const PresetCard({super.key, required this.preset, required this.onRun});
  final LabPreset preset;
  final VoidCallback onRun;
  @override
  Widget build(BuildContext context) => LabPanel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LabText(preset.pt,
            english: preset.en, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        LabText(preset.descriptionPt, english: preset.descriptionEn),
        const SizedBox(height: 16),
        FilledButton.icon(
            key: ValueKey('preset-${preset.id}'),
            onPressed: onRun,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const LabText('Executar exemplo', english: 'Run example')),
      ]));
}

class LearnPage extends StatelessWidget {
  const LearnPage({super.key, required this.onPreset});
  final ValueChanged<LabPreset> onPreset;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(24), children: [
        Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LabText('APRENDER / REINFORCEMENT ENGINE',
                          english: 'LEARN / REINFORCEMENT ENGINE',
                          style: TextStyle(
                              color: labCyan,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      LabText('Das recompensas à política.',
                          english: 'From rewards to a policy.',
                          style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 12),
                      const LabText(
                          'Conteúdo baseado nos guias do projeto, versão $learningSourceVersion. Sem redes neurais ou recursos de roadmap.',
                          english:
                              'Based on the project guides, version $learningSourceVersion. No neural networks or roadmap features are presented as implemented.'),
                      const SizedBox(height: 24),
                      _lesson(context, '01 / Fundamentos', '01 / Foundations', [
                        const LabText(
                            'Agente: quem aprende. Ambiente: o sistema que responde. Estado: a célula atual. Ações: cima, direita, baixo e esquerda. Política: regra de escolha. Q(s,a): estimativa do retorno ao escolher a ação a no estado s.',
                            english:
                                'Agent: the learner. Environment: the system that responds. State: the current cell. Actions: up, right, down and left. Policy: a selection rule. Q(s,a): estimated return from choosing action a in state s.'),
                        const SizedBox(height: 12),
                        const LabText(
                            'Uma colisão também custa −1. O movimento terminal paga +10 no lugar de −1: oito movimentos somam +3. O retorno mostrado no gráfico é a soma não descontada, embora Q use gamma.',
                            english:
                                'A collision also costs −1. The terminal move pays +10 instead of −1: eight moves total +3. The plotted return is the undiscounted sum, even though Q uses gamma.'),
                      ]),
                      _lesson(context, '02 / Uma atualização, passo a passo',
                          '02 / An update, step by step', [
                        const _Formula(
                            'Qnew = Qold + α [r + γ · bootstrap − Qold]'),
                        const LabText(
                            'α controla o tamanho do ajuste; γ pondera o futuro; r é o feedback imediato. O termo entre colchetes é o erro TD. O bootstrap muda conforme o algoritmo.',
                            english:
                                'α controls update size; γ weights the future; r is immediate feedback. The bracketed term is TD error. Bootstrap depends on the algorithm.'),
                        const SizedBox(height: 12),
                        const _Formula('2 + .25 × (1 + .8 × 4 − 2) = 2.55'),
                        const LabText(
                            'Ao terminar, bootstrap = 0 e o resultado é 1.75. Um limite de passos é truncamento: termina a coleta, mas mantém o bootstrap. Não confunda truncamento com término.',
                            english:
                                'On termination, bootstrap = 0 and the result is 1.75. A step cap is truncation: it ends collection but retains bootstrap. Do not confuse truncation with termination.'),
                        const SizedBox(height: 12),
                        const _Formula('εnext = max(.01, ε × .995)'),
                        const LabText(
                            'Epsilon é a chance de explorar; ele decai após cada episódio. Avaliar e executar usam política gulosa com RNG e ambiente próprios e não alteram o treino.',
                            english:
                                'Epsilon is the exploration probability; it decays after each episode. Evaluation and playback use a greedy policy with their own RNG and environment and do not change training.'),
                      ]),
                      _lesson(context, '03 / Algoritmos implementados',
                          '03 / Implemented algorithms', [
                        for (final lesson in algorithmLessons)
                          Material(
                              color: Colors.transparent,
                              child: ExpansionTile(
                                  title: Text(lesson.name),
                                  childrenPadding: const EdgeInsets.all(12),
                                  children: [
                                    LabText(lesson.pt, english: lesson.en),
                                    const SizedBox(height: 10),
                                    _Formula(lesson.formula)
                                  ])),
                      ]),
                      _lesson(context, '04 / Execute e depois meça',
                          '04 / Run, then measure', [
                        const LabText(
                            'Mesma seed não significa as mesmas ações. Uma execução não comprova convergência nem superioridade. Compare também sucesso, truncamento e passos; preserve falhas.',
                            english:
                                'The same seed does not mean the same actions. One run proves neither convergence nor superiority. Also compare success, truncation and steps; retain failures.'),
                        const SizedBox(height: 16),
                        PresetCard(
                            preset: labPresets.first,
                            onRun: () => onPreset(labPresets.first)),
                        const SizedBox(height: 16),
                        const LabText(
                            'Exemplo Dart completo: import público, seed explícita e avaliação separada.',
                            english:
                                'Complete Dart example: public import, explicit seed and separate evaluation.'),
                        const SizedBox(height: 10),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: const Color(0xff0a1020),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SelectableText(learningExample,
                                    style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13)))),
                      ]),
                      _lesson(
                          context, 'Fontes e limites', 'Sources and limits', [
                        const LabText(
                            'Guias reais do repositório. Treino tabular finito; sem DQN, controle contínuo ou armazenamento persistente do agente. Checkpoints iniciam um novo fluxo aleatório ao importar.',
                            english:
                                'Actual repository guides. Finite tabular training; no DQN, continuous control or persistent agent storage. Checkpoints start a new random stream on import.'),
                        const SizedBox(height: 14),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (var i = 0; i < documentationPaths.length; i++)
                            OutlinedButton.icon(
                                onPressed: () => openDocumentation(
                                    context,
                                    LabScope.of(context)?.language ==
                                            LabLanguage.en
                                        ? documentationPaths[i]
                                        : documentationPaths[i]
                                            .replaceFirst('.md', '.pt-BR.md')),
                                icon: const Icon(Icons.open_in_new, size: 15),
                                label: LabText(documentationLabels[i])),
                        ]),
                      ]),
                      _lesson(context, 'Cinco exercícios práticos',
                          'Five practical exercises', [
                        for (var i = 0; i < labExercises.length; i++)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LabText('${i + 1}. ${labExercises[i].pt}',
                                        english:
                                            '${i + 1}. ${labExercises[i].en}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    LabText(
                                        'Objetivo: ${labExercises[i].goalPt}',
                                        english:
                                            'Objective: ${labExercises[i].goalEn}'),
                                    LabText(
                                        'Conclusão: ${labExercises[i].donePt}',
                                        english:
                                            'Completion: ${labExercises[i].doneEn}'),
                                  ])),
                      ]),
                    ]))),
      ]);

  Widget _lesson(
          BuildContext context, String pt, String en, List<Widget> body) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: LabPanel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                LabText(pt,
                    english: en, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ...body,
              ])));
}

class _Formula extends StatelessWidget {
  const _Formula(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(value,
              style: const TextStyle(
                  fontFamily: 'monospace', color: labCyan, fontSize: 15))));
}
