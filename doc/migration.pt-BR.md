# Migração de 0.1 para 0.2

A importação pública, o formato JSON de QTable, os construtores de Q-Learning/SARSA
e implementações existentes de TdUpdateRule continuam suportados. A ordem de
chamadas aleatórias do epsilon-greedy padrão foi preservada no mesmo runtime.

- LearningAlgorithm adiciona expectedSarsa. Inclua o caso em switches exaustivos.
- trainEpisode agora aceita LearningAgent, incluindo TabularAgent e DoubleQAgent.
- Use agent.values para avaliar os dois tipos de agente. Agentes simples mantêm
  agent.table. Double Q possui tableA e tableB; serialize ambas separadamente.
- Expected SARSA pelo enum segue as probabilidades reais de comportamento e o
  epsilon atual. Um callback personalizado de probabilidades fica a cargo do consumidor.
- SoftmaxExploration usa temperatura fixa, ignora epsilon e não esfria ao chamar
  decayExploration. explore: false sempre escolhe greedy.

Veja [controle](control.pt-BR.md), [avaliação](evaluation.pt-BR.md) e [persistência](persistence.pt-BR.md).

## De 0.2 para 0.3

As mudanças são aditivas: os contratos de agentes e atualização da 0.2 permanecem.
Use RLearningAgent com trainContinuing em tarefas sem término; carregue finalState
entre janelas sem resetar o ambiente. Use SarsaLambdaAgent com trainEpisodic para
limpar rastros nas fronteiras e em erros. O runner trainEpisode não passa a limpar
rastros automaticamente; loops manuais precisam beginEpisode/endEpisode.
Persistir QTable não salva RNG, rastros ou rho. Para R-Learning, salve rho
separadamente e restaure com initialAverageReward. Veja os guias de
[tarefas contínuas](continuing.pt-BR.md) e [rastros](traces.pt-BR.md).

## 0.3 para 0.4

Construtores, atualizações, ordem de chamadas aleatórias e JSON de QTable mantêm
compatibilidade. `TrainingCheckpoint` é aditivo; veja [checkpoints](checkpoints.pt-BR.md).
Capture entre episódios/janelas. A retomada inicia outra sequência aleatória.
Estratégias personalizadas exigem adaptador da aplicação. O novo indicador público
`TabularAgent.usesBuiltInUpdateRule` identifica regras gerenciadas pelo enum.

## 0.4 para 0.5

Construtores e atualizações existentes mantêm compatibilidade. WatkinsQLambdaAgent
é um EpisodicAgent separado, sem novo caso no enum LearningAlgorithm. Switches
exaustivos não mudam. BanditLearner/BanditPolicy/BanditValues são contratos próprios.
Bandits nativos exigem recompensa finita em [0,1]. O checkpoint Watkins adiciona
um tipo na versão 1 do formato; leitores antigos o rejeitam. Tipos anteriores
mantêm estrutura e comportamento. TrainingCheckpoint não salva estatísticas de
bandits. Veja [Watkins](watkins.pt-BR.md), [bandits](bandits.pt-BR.md) e o
[guia de aprendizado](learning_guide.pt-BR.md).
