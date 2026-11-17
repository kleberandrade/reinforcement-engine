# Visão geral da arquitetura

O padrão da família usa contratos explícitos, composição de estratégias, resultados
imutáveis e exportações públicas deliberadas. A aplicação combina ambiente, agente
e uma tabela Q opcional. `trainEpisode` coordena a interação; interface,
agendamento e armazenamento pertencem à aplicação.

`Environment<S, A>` controla o mundo e suas ações legais. `TabularAgent<S, A>`
controla o gerador aleatório e a exploração. Sua tabela é mutável e pode ser
fornecida para continuar o aprendizado. `TdUpdateRule<S, A>` calcula apenas o
bootstrap. Recompensa, taxa de aprendizado e desconto ficam em uma única equação
no agente. A estratégia informa se a próxima ação deve ser amostrada e reutilizada.
Transições terminais ignoram o bootstrap; truncamentos continuam utilizando-o.

`StepResult` e `EpisodeResult` possuem campos finais. A imutabilidade é superficial:
estados e ações personalizados precisam manter igualdade e hash estáveis.
Não existe estado global de treinamento, registro de estratégias ou worker interno.

O construtor valida a configuração. Recompensas e valores Q devem ser finitos.
Estados não terminais precisam de ações disponíveis. SARSA exige uma próxima ação
legal. O runner limita o trabalho com `maxSteps`.

O construtor por enum continua funcionando. Uma `updateRule` explícita tem prioridade;
`algorithm` registra o atalho escolhido, mas não representa a estratégia efetiva
quando há sobrescrita. Consulte `agent.updateRule` para identificar o comportamento.

## Famílias de agentes e persistência

EpisodicAgent adiciona limpeza de fronteiras para SARSA(lambda) e Watkins Q(lambda).
ContinuingAgent representa R-learning sem contrato descontado ou terminal.
BanditLearner representa feedback imediato, composto com BanditPolicy e uma visão
BanditValues de leitura. Cada runner depende da interface correspondente.

TrainingCheckpoint é um adaptador externo de formato que depende de agentes
nativos e cria novos agentes. A aplicação controla estado do ambiente, feedback
assíncrono, IO e agendamento. Veja o [mapa](structure.pt-BR.md) e o
[guia de aprendizado](../learning_guide.pt-BR.md).
