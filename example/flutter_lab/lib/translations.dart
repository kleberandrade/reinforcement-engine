// User-facing source strings remain stable keys; learners and stored feedback
// never depend on the selected language. Dynamic feedback uses whole templates.
const _messages = <String, String>{
  "Treine o agente e acompanhe o caminho aprendido.":
      "Train the agent and follow its learned route.",
  "Cancelado. O aprendizado foi preservado.":
      "Cancelled. Learned values have been kept.",
  "Executando a política sem exploração…":
      "Running the policy without exploration…",
  "Pausado. Continue ou cancele a execução.":
      "Paused. Resume or cancel the run.",
  "Treinando Q-Learning e SARSA com os mesmos parâmetros…":
      "Training Q-Learning and SARSA with shared settings…",
  "Aprendendo…": "Learning…",
  "Treino concluído. Execute a política aprendida.":
      "Training complete. Run the learned policy.",
  "Limite atingido. Treine mais episódios.":
      "Step limit reached. Train more episodes.",
  "Tabela e exploração preservadas.": "Values and exploration preserved.",
  "Tarefa contínua": "Continuing task",
  "Salvar e retomar": "Save and resume",
  "01 / CONFIGURAR": "01 / CONFIGURE",
  "Seu experimento": "Your experiment",
  "Uma seed. As mesmas regras. Duas formas de aprender.":
      "One seed. Shared rules. Two ways to learn.",
  "Algoritmo individual": "Individual algorithm",
  "Semente aleatória": "Random seed",
  "Quanto explorar antes de seguir a política.":
      "How much to explore before following the policy.",
  "Limite: 200 passos": "Limit: 200 steps",
  "Treinar juntos": "Train together",
  "Q-Learning + SARSA · 500 episódios cada.\nInicia uma comparação nova, desde o zero.":
      "Q-Learning + SARSA · 500 episodes each.\nStarts a fresh comparison from zero.",
  "Treinar +500": "Train +500",
  "Progresso do treino": "Training progress",
  "Progresso dos dois agentes": "Paired training progress",
  "Pausar": "Pause",
  "Continuar": "Resume",
  "Cancelar": "Cancel",
  "Reiniciar": "Reset",
  "episódios": "episodes",
  "pares de episódios": "episode pairs",
  "Mudar seed ou epsilon reinicia o aprendizado e limpa a comparação.":
      "Changing seed or epsilon resets learning and clears the comparison.",
  "02 / OBSERVAR": "02 / OBSERVE",
  "Cada movimento é uma decisão.": "Every move is a decision.",
  "Comparação Q-Learning × SARSA · o grid mostra Q-Learning.":
      "Q-Learning × SARSA comparison · the grid shows Q-Learning.",
  "EPISÓDIOS": "EPISODES",
  "EXPLORAÇÃO ATUAL": "CURRENT EXPLORATION",
  "ÚLTIMO RETORNO": "LATEST RETURN",
  "Executar": "Run policy",
  "Avaliar ×50": "Evaluate ×50",
  "↑ → ↓ ← Melhores ações · empates mostram várias setas.\nBandeira: objetivo · blocos: paredes · trilha: caminho executado.":
      "↑ → ↓ ← Best actions · ties show several arrows.\nFlag: goal · blocks: walls · trail: executed route.",
  "−1 por passo · +10 no objetivo · rota mínima: 8 passos (retorno +3).":
      "−1 per step · +10 at the goal · shortest route: 8 steps (return +3).",
  "6 algoritmos · 1 gridworld": "6 algorithms · 1 gridworld",
  "Aprenda com cada decisão.": "Learn from every decision.",
  "Explore, treine e compare. Transforme recompensas em uma política que encontra o caminho.":
      "Explore, train and compare. Turn rewards into a policy that finds the way.",
  "03 / COMPARAR": "03 / COMPARE",
  "UM LABORATÓRIO PARA EXPERIMENTAR": "A LABORATORY FOR EXPLORATION",
  "Treinar altera os valores. Avaliar e executar usam ambientes e seeds independentes. Uma comparação com uma seed não representa um ranking estatístico dos algoritmos.":
      "Training changes values. Evaluation and playback use independent environments and seeds. A single-seed comparison is not a statistical ranking of algorithms.",
  "Curvas de aprendizado": "Learning curves",
  "Use Treinar juntos para comparar Q-Learning e SARSA com a mesma configuração. Seed, epsilon e Reiniciar limpam as curvas.":
      "Use Train together to compare Q-Learning and SARSA with shared settings. Seed, epsilon and Reset clear the curves.",
  "Mostrar retornos por episódio": "Show per-episode returns",
  "Retornos por episódio": "Per-episode returns",
  "Média dos últimos N episódios, incluindo o atual. No início, usa apenas os episódios disponíveis.":
      "Mean of the last N episodes, including the current one. Initial windows use only available episodes.",
  "atual": "current",
  "comparação": "comparison",
  "Treine para ver a evolução desde o episódio 1.":
      "Train to see progress from episode 1.",
  "Linhas fortes: média móvel · linhas suaves: retorno bruto. SARSA tracejada; Q-Learning contínua. Maior é melhor (máximo +3).":
      "Strong lines: moving mean · faint lines: raw return. Dashed SARSA; solid Q-Learning. Higher is better (maximum +3).",
  "Uma execução por algoritmo; mesma seed não significa as mesmas ações. Este gráfico mostra treino com exploração, não avaliação da política.":
      "One run per algorithm; the same seed does not mean the same actions. This chart shows exploratory training, not policy evaluation.",
  "Bandits: aprender a escolher": "Bandits: learning to choose",
  "Três opções, uma recompensa imediata.":
      "Three options, one immediate reward.",
  "Cada escolha retorna 1 em caso de sucesso e 0 em caso de falha. As chances reais são 20%, 50% e 80%. O agente só vê os resultados.":
      "Each choice returns 1 for success and 0 for failure. The true chances are 20%, 50% and 80%. The agent sees only the outcomes.",
  "Experimentar +1.000": "Try +1,000",
  "As barras mostram a participação de cada opção nas escolhas, não a probabilidade de ela ser a melhor. Trocar a estratégia reinicia o experimento. Este cenário sintético não garante resultados em outras tarefas.":
      "Bars show each option’s share of choices, not the probability that it is best. Switching strategy resets the experiment. This synthetic scenario does not guarantee results on other tasks.",
  "Treine, exporte o JSON e importe para continuar.":
      "Train, export JSON and import it to continue.",
  "Ainda não avaliado": "Not evaluated yet",
  "Treinando em lotes…": "Training in batches…",
  "JSON exportado. Copie para guardar.": "JSON exported. Copy it to save.",
  "Checkpoint importado. Continue com Treinar +100.":
      "Checkpoint imported. Continue with Train +100.",
  "JSON inválido ou incompatível. Agente preservado.":
      "Invalid or incompatible JSON. Agent preserved.",
  "Checkpoints de aprendizado": "Learning checkpoints",
  "Os valores e a exploração são restaurados. A retomada usa uma nova sequência aleatória e reinicia o ambiente a cada episódio.":
      "Values and exploration are restored. Resuming starts a new random stream and resets the environment for each episode.",
  "Treinar +100": "Train +100",
  "Exportar JSON": "Export JSON",
  "Importar JSON": "Import JSON",
  "Agente reiniciado; JSON mantido.": "Agent reset; JSON kept.",
  "Novo agente": "New agent",
  "Treine a política de trabalho e manutenção.":
      "Train the work and maintenance policy.",
  "R-Learning: tarefa contínua": "R-Learning: continuing task",
  "Trabalhar e manter.": "Work and maintain.",
  "Uma máquina didática ganha +3 ao trabalhar pronta e −1 se desgastada. Manutenção ganha 0 e deixa a máquina pronta. O melhor ciclo ganha 1,50 por passo.":
      "A teaching machine earns +3 for working while ready and −1 when worn. Maintenance earns 0 and makes it ready. The best cycle earns 1.50 per step.",
  "Treinar +10.000": "Train +10,000",
  "Avaliar política": "Evaluate policy",
  "A tarefa nunca termina. Cada lote preserva o estado e ρ; a exploração permanece em 10%. A avaliação usa outra máquina e outro gerador aleatório.":
      "The task never terminates. Each batch preserves state and ρ; exploration stays at 10%. Evaluation uses another machine and a separate RNG.",
  "pronta": "ready",
  "desgastada": "worn",
  "parede": "wall",
  "objetivo": "goal",
  "agente": "agent",
  "livre": "open",
  "Laboratório": "Laboratory",
  "Aprender": "Learn",
  "Exemplos": "Examples",
  "Documentação / GitHub": "Documentation / GitHub",
  "Idioma": "Language",
  "Navegação": "Navigation",
  "Copiar link": "Copy link",
  "Link copiado": "Link copied",
  "Fechar": "Close",
  "Voltar ao laboratório": "Back to the laboratory",
  "Abrir no laboratório": "Open in laboratory",
  "Abrir exemplo reinicia o experimento atual.":
      "Opening an example resets the current experiment.",
  "Documentação da versão 0.5.0": "Source documentation · version 0.5.0",
  "Guia de aprendizado": "Learning guide",
  "Algoritmos": "Algorithms",
  "Avaliação": "Evaluation",
  "Rastros de Watkins": "Watkins traces",
  "EXPERIMENTAR": "EXPERIMENT",
  "Exemplos que você pode executar": "Examples you can run",
  "Cada exemplo usa os algoritmos e o GridWorld implementados neste projeto.":
      "Each example uses algorithms and GridWorld implemented in this project.",
};
final _rules = <(RegExp, String)>[
  (
    RegExp("^Objetivo alcançado em (\\d+) movimentos!\$"),
    "Goal reached in {1} moves!"
  ),
  (
    RegExp(
        "^Avaliação: (.+)% de sucesso, (.+) passos em média\\. Tabela e exploração preservadas\\.\$"),
    "Evaluation: {1}% success, {2} mean steps. Values and exploration preserved."
  ),
  (RegExp("^Epsilon inicial: (.+)\$"), "Initial epsilon: {1}"),
  (
    RegExp("^Exploração inicial (.+) por cento\$"),
    "Initial exploration {1} percent"
  ),
  (RegExp("^(\\d+) / 500 (episódios|pares de episódios)\$"), "{1} / 500 {2}"),
  (
    RegExp("^Política de (.+) no grid 5 × 5\\.\$"),
    "{1} policy in the 5 × 5 grid."
  ),
  (RegExp("^Episódios: (.+)\$"), "Episodes: {1}"),
  (
    RegExp("^SARSA · (.+) episódios · ε (.+)%\$"),
    "SARSA · {1} episodes · ε {2}%"
  ),
  (
    RegExp("^Seed (.+) · ε inicial (.+) · α (.+) · γ (.+)\$"),
    "Seed {1} · initial ε {2} · α {3} · γ {4}"
  ),
  (
    RegExp("^(\\d+) episódios registrados · histórico completo\$"),
    "{1} episodes recorded · full history"
  ),
  (RegExp("^Média móvel: (.+)\$"), "Moving mean: {1}"),
  (
    RegExp("^([━┄]) (.+) \\((atual|comparação)\\) · (\\d+) episódios\$"),
    "{1} {2} ({3}) · {4} episodes"
  ),
  (
    RegExp("^Episódios (.+) · retorno por episódio\$"),
    "Episodes {1} · per-episode return"
  ),
  (
    RegExp(
        "^Gráfico de recompensas desde o episódio 1 até (.+)\\. Escala comum de menos 200 a mais 3\\. Use o seletor de episódio para consultar os valores\\.\$"),
    "Reward chart from episode 1 to {1}. Shared scale from minus 200 to plus 3. Use the episode selector to inspect values."
  ),
  (RegExp("^Episódio (\\d+)\$"), "Episode {1}"),
  (RegExp("^Inspecionar episódio (.+)\$"), "Inspect episode {1}"),
  (RegExp("^(.+): sem episódio (\\d+)\$"), "{1}: no episode {2}"),
  (RegExp("^(.+): retorno (.+) · média (.+)\$"), "{1}: return {2} · mean {3}"),
  (
    RegExp("^Célula (\\d+), (.+), política (.+)\$"),
    "Cell {1}, {2}, policy {3}"
  ),
  (RegExp("^Decisões: (.+)\$"), "Decisions: {1}"),
  (RegExp("^Recompensa observada: (.+)\$"), "Observed reward: {1}"),
  (
    RegExp("^Opção (\\d+): (.+) escolhas; média estimada (.+)\$"),
    "Option {1}: {2} choices; estimated mean {3}"
  ),
  (RegExp("^Participação da opção (.+)\$"), "Selection share of option {1}"),
  (RegExp("^(.+)% sucesso; (.+) passos\$"), "{1}% success; {2} steps"),
  (RegExp("^Depois de continuar: (.+)\$"), "After continuing: {1}"),
  (RegExp("^Episódios salvos e novos: (.+)\$"), "Saved and new episodes: {1}"),
  (RegExp("^Exploração: (.+)\$"), "Exploration: {1}"),
  (RegExp("^Ao importar: (.+)\$"), "On import: {1}"),
  (
    RegExp("^Recompensa média: (.+) em 1\\.000 passos sem exploração\\.\$"),
    "Mean reward: {1} over 1,000 steps without exploration."
  ),
  (RegExp("^Passos: (.+)\$"), "Steps: {1}"),
  (
    RegExp("^Recompensa média estimada \\(ρ\\): (.+)\$"),
    "Estimated average reward (ρ): {1}"
  ),
  (RegExp("^Estado: (.+)\$"), "State: {1}"),
  (RegExp("^Célula (\\d+), (.+)\$"), "Cell {1}, {2}"),
];
String translate(String source) {
  final direct = _messages[source];
  if (direct != null) return direct;
  for (final (pattern, template) in _rules) {
    final match = pattern.firstMatch(source);
    if (match != null) {
      return template.replaceAllMapped(RegExp(r'\{(\d+)\}'),
          (slot) => translate(match.group(int.parse(slot.group(1)!)) ?? ''));
    }
  }
  return source;
}
