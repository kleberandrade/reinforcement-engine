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
