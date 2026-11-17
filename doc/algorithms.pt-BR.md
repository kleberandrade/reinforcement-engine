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
