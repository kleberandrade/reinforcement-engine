# Algoritmos de controle tabular

As estratégias de uma tabela aplicam `Q(s,a) += alpha * (recompensa + gamma * bootstrap - Q(s,a))`.

| Estratégia | Bootstrap não terminal | Próxima ação |
| --- | --- | --- |
| `QLearning<S, A>` | Máximo dos valores das próximas ações legais | Amostrada após a atualização |
| `Sarsa<S, A>` | Valor da próxima ação de comportamento amostrada | Amostrada antes da atualização e reutilizada |
| `ExpectedSarsa<S, A>` | Média ponderada pela política de comportamento | Não amostra no bootstrap |

Pares ainda não visitados valem zero. Q-Learning ignora ações ilegais e preserva
máximos negativos. Transições terminais usam bootstrap zero. Truncamentos encerram
o episódio, mas preservam o bootstrap: o último estado ainda precisa de ações
legais. O limite `maxSteps` segue essa mesma regra de truncamento.

Epsilon-greedy explora com probabilidade epsilon; caso contrário, escolhe uma ação
de maior valor e desempata aleatoriamente. A cada episódio retornado, aplica
`max(minEpsilon, epsilon * epsilonDecay)`. Em loops manuais, chame
`decayExploration()` ao encerrar cada episódio. Na avaliação, use `explore: false`;
os empates continuam aleatórios. Para configurar `epsilon: 0`, defina também
`minEpsilon: 0`.

A mesma semente reproduz execuções com o mesmo runtime, ordem de ações, tabela
inicial e comportamento do ambiente. Ambientes estocásticos precisam de sua própria
semente. Não há garantia de igualdade entre runtimes nem de convergência geral.

Execute `dart run example/reinforcement_engine_example.dart` para treinar Q-Learning no labirinto padrão. O caminho mínimo possui oito movimentos.
Esse exemplo é didático; não é um benchmark para aplicações reais.

Veja [controle e exploração](control.pt-BR.md) para Expected SARSA, Double Q-Learning e softmax.

## Além das regras de um passo

| Agente | Alvo/feedback | Ciclo de vida |
| --- | --- | --- |
| DoubleQAgent | Bootstrap descontado cruzando tabelas | trainEpisode |
| SarsaLambdaAgent | Próximo Q amostrado e traços acumulativos | trainEpisodic |
| WatkinsQLambdaAgent | Próximo Q máximo e corte após ação seguinte não greedy | trainEpisodic |
| RLearningAgent | Recompensa menos média e próximo valor relativo | trainContinuing |
| BanditAgent | Recompensa imediata normalizada atualiza média amostral | trainBandit ou selectArm/observe |

Com Q=2, alpha=.25, recompensa=1, gamma=.8 e bootstrap=4, o valor novo é
`2 + .25 * (1 + .8*4 - 2) = 2.55`. No término, o resultado seria 1.75.
O cálculo mostra por que truncamento não pode ser confundido com término.

Comece pelo [guia de aprendizado](learning_guide.pt-BR.md), depois veja
[Watkins](watkins.pt-BR.md), [traços](traces.pt-BR.md), [tarefas contínuas](continuing.pt-BR.md)
ou [bandits](bandits.pt-BR.md).
