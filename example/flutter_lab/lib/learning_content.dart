import 'lab_algorithm.dart';

const learningSourceVersion = '0.5.0';

class LabPreset {
  const LabPreset(this.id, this.pt, this.en, this.descriptionPt,
      this.descriptionEn, this.algorithm, this.seed, this.epsilon,
      {this.paired = false});
  final String id, pt, en, descriptionPt, descriptionEn;
  final LabAlgorithm algorithm;
  final int seed;
  final double epsilon;
  final bool paired;
}

const labPresets = [
  LabPreset(
      'paired-baseline',
      'Comparação com regras iguais',
      'A shared-rules comparison',
      'Q-Learning e SARSA, 500 episódios cada, seed 42 e epsilon 1. Compare as médias móveis.',
      'Q-Learning and SARSA, 500 episodes each, seed 42 and epsilon 1. Compare moving means.',
      LabAlgorithm.qLearning,
      42,
      1,
      paired: true),
  LabPreset(
      'q-exploration',
      'Menos exploração',
      'Less exploration',
      'Q-Learning, seed 7 e epsilon .2. Observe a evolução e avalie separadamente.',
      'Q-Learning, seed 7 and epsilon .2. Observe learning, then evaluate separately.',
      LabAlgorithm.qLearning,
      7,
      .2),
  LabPreset(
      'sarsa-baseline',
      'Seguir o comportamento',
      'Follow the behavior',
      'SARSA com seed 123 e epsilon 1. O alvo usa a ação realmente amostrada.',
      'SARSA with seed 123 and epsilon 1. The target uses the actual sampled action.',
      LabAlgorithm.sarsa,
      123,
      1),
  LabPreset(
      'watkins-traces',
      'Feedback com rastros',
      'Feedback through traces',
      'Watkins Q(λ), seed 42, lambda .8. O runner limpa rastros ao terminar cada episódio.',
      'Watkins Q(λ), seed 42, lambda .8. The runner clears traces at each episode boundary.',
      LabAlgorithm.watkins,
      42,
      1),
];

const learningExample =
    r'''import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final world = GridWorld();
  final agent = TabularAgent<int, GridAction>(
    algorithm: LearningAlgorithm.qLearning,
    seed: 42, learningRate: 0.2,
  );
  for (var i = 0; i < 500; i++) {
    trainEpisode(environment: world, agent: agent, maxSteps: 200);
  }
  final report = evaluatePolicy<int, GridAction>(
    environmentFactory: GridWorld.new,
    policy: GreedyPolicy(agent.values),
    isSuccess: (state, episode) => episode.terminated && state == 24,
    episodes: 50, maxSteps: 100, seed: 7,
  );
  print('${report.successRate} / ${report.meanSteps}');
}''';

class AlgorithmLesson {
  const AlgorithmLesson(this.name, this.pt, this.en, this.formula);
  final String name, pt, en, formula;
}

const algorithmLessons = [
  AlgorithmLesson(
      'Q-Learning',
      'Usa a melhor estimativa legal no próximo estado. Aprende um alvo guloso enquanto o comportamento ainda explora.',
      'Uses the largest legal next-state estimate. Learns a greedy target while behavior still explores.',
      'bootstrap = max Q(s′, a′)'),
  AlgorithmLesson(
      'SARSA',
      'Usa o valor da próxima ação realmente escolhida. A ação é amostrada antes da atualização e reutilizada no próximo passo.',
      'Uses the value of the actual next action. That action is sampled before the update and reused on the next step.',
      'bootstrap = Q(s′, a′)'),
  AlgorithmLesson(
      'Expected SARSA',
      'Faz a média dos valores seguintes segundo as probabilidades da política de comportamento, sem amostrar o bootstrap.',
      'Averages next values using behavior-policy probabilities, without sampling the bootstrap.',
      'bootstrap = Σ π(a′|s′) Q(s′, a′)'),
  AlgorithmLesson(
      'Double Q-Learning',
      'Separa seleção e avaliação entre duas tabelas. O exemplo mostra a soma das estimativas; não há promessa de superioridade.',
      'Separates selection and evaluation across two tables. The example exposes summed estimates; superiority is not guaranteed.',
      'target A = r + γ Q_B(s′, argmax Q_A(s′, ·))'),
  AlgorithmLesson(
      'SARSA(λ)',
      'Rastros acumulativos levam o erro TD a pares recentemente visitados. O runner é trainEpisodic; lambda padrão .8 neste laboratório.',
      'Accumulating traces carry TD error to recently visited pairs. Use trainEpisodic; this lab uses default lambda .8.',
      'Q ← Q + α δ e; e ← γ λ e'),
  AlgorithmLesson(
      'Watkins Q(λ)',
      'Usa o máximo para bootstrap e corta rastros após uma ação seguinte não gulosa. Limpa os rastros nas fronteiras de episódio.',
      'Uses maximum bootstrap and cuts traces after a nongreedy next action. Clears traces at episode boundaries.',
      'δ = r + γ max Q(s′, ·) − Q(s,a); a′ ∉ argmax Q(s′, ·) ⇒ e = 0'),
  AlgorithmLesson(
      'R-Learning',
      'Tarefa contínua sem desconto: estima valores relativos e recompensa média ρ. A página de manutenção preserva estado entre lotes.',
      'An undiscounted continuing task: estimates relative values and average reward ρ. Maintenance preserves state between batches.',
      'Q ← Q + α [r − ρ + max Q(s′, ·) − Q(s,a)]'),
  AlgorithmLesson(
      'Bandits · UCB1 / epsilon-greedy',
      'Feedback imediato em [0,1], sem próximo estado. UCB1 visita braços novos primeiro; seu índice não é uma probabilidade.',
      'Immediate feedback in [0,1], without a next state. UCB1 visits unseen arms first; its index is not a probability.',
      'UCB_i = mean_i + √(2 ln(t) / n_i)'),
];

class LabExercise {
  const LabExercise(
      this.pt, this.en, this.goalPt, this.goalEn, this.donePt, this.doneEn);
  final String pt, en, goalPt, goalEn, donePt, doneEn;
}

const labExercises = [
  LabExercise(
      'Compare com a mesma seed',
      'Compare with the same seed',
      'Treine a dupla com seed 42 e leia as duas curvas.',
      'Train both with seed 42 and inspect both curves.',
      'Registre o retorno e a média móvel do episódio 500 para ambos.',
      'Record raw return and moving mean at episode 500 for both.'),
  LabExercise(
      'Mude a exploração',
      'Change exploration',
      'Compare epsilon 1 e .2, mantendo seed e limite.',
      'Compare epsilon 1 and .2 while keeping seed and cap fixed.',
      'Anote os dois resultados, inclusive falhas, sem concluir um ranking geral.',
      'Record both outcomes, including failures, without claiming a general ranking.'),
  LabExercise(
      'Separe treino de avaliação',
      'Separate training from evaluation',
      'Observe uma política sem atualizar sua tabela.',
      'Observe a policy without updating its values.',
      'Avalie e execute; confirme que episódios e epsilon não mudaram.',
      'Evaluate and play; confirm episode count and epsilon did not change.'),
  LabExercise(
      'Calcule uma atualização',
      'Calculate an update',
      'Use Q=2, r=1, α=.25, γ=.8 e bootstrap=4.',
      'Use Q=2, r=1, α=.25, γ=.8 and bootstrap=4.',
      'Obtenha 2.55 sem término e 1.75 com término; explique a diferença.',
      'Obtain 2.55 without termination and 1.75 with termination; explain why.'),
  LabExercise(
      'Teste uma fronteira',
      'Test a boundary',
      'Pause e cancele uma dupla; depois repita do zero.',
      'Pause and cancel a paired run, then repeat from zero.',
      'Confirme contagens iguais ao pausar/cancelar e 500/500 após repetir.',
      'Confirm equal counts when pausing/cancelling and 500/500 after repeating.'),
];
