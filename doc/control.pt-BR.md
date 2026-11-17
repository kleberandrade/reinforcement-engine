# Controle tabular e estratégias de exploração

Implementado em `0.2.0-dev.2`, ainda não publicado. A versão `0.1.0` permanece
com Q-Learning e SARSA; as APIs antigas continuam disponíveis.

## Escolha do agente

| Algoritmo | Construção | Bootstrap não terminal |
| --- | --- | --- |
| Q-Learning | `TabularAgent(algorithm: LearningAlgorithm.qLearning)` | Maior valor Q entre ações legais |
| SARSA | `TabularAgent(algorithm: LearningAlgorithm.sarsa)` | Valor da próxima ação amostrada e reutilizada |
| Expected SARSA | `TabularAgent(algorithm: LearningAlgorithm.expectedSarsa)` | Soma de `probabilidade(a) * Q(próximo estado, a)` |
| Double Q-Learning | `DoubleQAgent()` | Seleciona com uma tabela e avalia com a outra |

`LearningAgent<S, A>` permite usar os quatro agentes em `trainEpisode`. O contrato
expõe valores para leitura, seleção de ação, atualização e decaimento por episódio.
`ActionValues<S, A>` é a interface mínima de leitura. `QTable` a implementa;
`SumActionValues` combina dois estimadores sem copiar ou alterar as tabelas.

## Expected SARSA

```dart
final agent = TabularAgent<int, GridAction>(
  algorithm: LearningAlgorithm.expectedSarsa,
  epsilon: 0.2,
  epsilonDecay: 0.995,
  minEpsilon: 0.01,
  seed: 42,
);
```

O construtor conecta o bootstrap às probabilidades da política de comportamento
atual, incluindo o epsilon após cada decaimento. Para epsilon-greedy, cada ação
recebe `epsilon / número de ações`; a parcela `1 - epsilon` é dividida entre todas
as ações de maior valor. Empates e valores negativos seguem a seleção real.

O bootstrap não amostra uma ação. Transições terminais usam somente a recompensa;
truncamentos preservam o bootstrap. Probabilidades precisam ser finitas, não negativas,
ter o mesmo tamanho das ações legais e somar 1 com tolerância `1e-10`.
Se instanciar `ExpectedSarsa(probabilities: ...)` diretamente, o consumidor precisa
fornecer uma função coerente com sua política. O construtor por enum faz essa ligação
automaticamente. Não há conversão do exemplo anterior de média uniforme em um
algoritmo epsilon-greedy: aquele exemplo continua sendo apenas um contrato didático.

## Double Q-Learning

```dart
final agent = DoubleQAgent<int, GridAction>(seed: 42);
final result = trainEpisode(environment: GridWorld(), agent: agent, maxSteps: 200);
final policy = GreedyPolicy(agent.values);
```

O agente mantém `tableA` e `tableB` independentes; fornecer a mesma instância para
as duas é rejeitado. A política de comportamento consulta a soma dos valores.
Cada atualização escolhe uma tabela com probabilidade 0,5. Ao atualizar A, escolhe
uma ação greedy usando A no próximo estado e consulta B para avaliar essa ação.
A atualização de B é simétrica. Apenas a tabela escolhida é escrita. `update()`
retorna o novo valor desse estimador, não a soma. Valores combinados são uma visão
viva e somente de leitura. A mesma semente e ordem de chamadas reproduzem ambas
as tabelas no mesmo runtime. Salve e restaure cada tabela separadamente; isso não
salva epsilon, RNG ou ambiente e não garante continuação exata.

## Exploração por composição

```dart
final agent = TabularAgent<int, GridAction>(
  algorithm: LearningAlgorithm.expectedSarsa,
  explorationPolicy: SoftmaxExploration(temperature: 0.5),
  seed: 42,
);
```

`ExplorationPolicy<S, A>` fornece seleção e probabilidades coerentes entre si.
`EpsilonGreedy` é o padrão e preserva a ordem de chamadas aleatórias da `0.1.0`.
`SoftmaxExploration` usa temperatura positiva fixa e subtrai o maior valor antes
da exponenciação para evitar overflow positivo. Softmax ignora epsilon; o decaimento
do agente não esfria a temperatura. Na avaliação, `explore: false` e `GreedyPolicy`
escolhem greedy, independentemente da estratégia de treino. Campos de exploração
no laboratório descrevem epsilon-greedy, que permanece sua política padrão.

O engine não verifica tipos concretos de políticas. Estratégias personalizadas
precisam manter seleção e probabilidades equivalentes e não modificar valores
ou listas recebidas. Ações retornadas fora da lista legal são rejeitadas.

## Exemplos e limites

```sh
dart run example/evaluation.dart
dart run example/exploration.dart
```

Com 2.000 episódios de Cliff Walking, alpha 0,5, desconto 1, epsilon fixo 0,1,
semente 42 e avaliação greedy com semente 7: Q-Learning fez 13 passos, SARSA 17,
Expected SARSA 15 e Double Q 17 no runtime local. Todos os 100 episódios de avaliação
chegaram ao objetivo. Esses resultados são didáticos e não demonstram superioridade
geral. O laboratório permite escolher os quatro algoritmos e avaliar o GridWorld.

Adicionar `expectedSarsa` ao enum pode exigir uma nova ramificação em switches
exaustivos dos consumidores. O contrato `TdUpdateRule` da `0.1.0` não mudou.

## Referências

- [Sutton and Barto, Reinforcement Learning: An Introduction, chapter 6](https://www.andrew.cmu.edu/course/10-703/textbook/BartoSutton.pdf).
- [Hado van Hasselt, Double Q-learning, NeurIPS 2010](https://proceedings.neurips.cc/paper/2010/file/091d584fced301b442654dd8c23b3fc9-Paper.pdf).
