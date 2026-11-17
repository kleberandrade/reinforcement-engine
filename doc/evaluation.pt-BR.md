# Avaliação de políticas e Cliff Walking

Disponível em `0.2.0`; não faz parte da primeira versão `0.1.0`.

Treinar modifica a tabela e a exploração. Avaliar mede uma política fixa usando
`ActionPolicy<S, A>`. `GreedyPolicy` consulta os valores Q e desempata com o RNG
da avaliação. O avaliador não usa o agente, seu epsilon ou seu gerador aleatório.
A fábrica deve criar um ambiente independente por episódio; ambientes estocásticos
precisam de sementes próprias. Não modifique a tabela por callbacks durante a avaliação.

```dart
final report = evaluatePolicy<int, GridAction>(
  environmentFactory: GridWorld.new,
  policy: GreedyPolicy(agent.table),
  isSuccess: (state, episode) => episode.terminated && state == 24,
  episodes: 50,
  maxSteps: 100,
  seed: 7,
);
print(report.successRate);
print(report.meanReward);
print(report.meanSteps);
```

`isSuccess` é obrigatório: terminar uma tarefa pode representar fracasso.
O relatório possui lista imutável de episódios, contagem de sucessos e taxas de
sucesso, término e truncamento. Cada recompensa é validada; overflow do retorno,
ações ilegais e listas vazias são rejeitados. `maxSteps` trunca episódios que não
terminaram. Um ambiente pode sinalizar término e truncamento simultaneamente;
nesse caso ambas as taxas contabilizam o episódio. As médias usam ponto flutuante.

## Cliff Walking

O ambiente padrão possui 12 colunas e 4 linhas. Estados são índices de células
por linha. O início é 36, o objetivo é 47, e as células 37–46 formam o penhasco.

| Evento | Recompensa | Resultado |
| --- | --- | --- |
| Passo normal ou colisão com a borda | -1 | Continua |
| Queda no penhasco | -100 | Retorna ao início sem terminar |
| Chegada ao objetivo | -1 | Termina |

O menor caminho seguro possui 13 movimentos. Execute:

```sh
dart run example/evaluation.dart
```

O exemplo treina 2.000 episódios com epsilon fixo 0,1, alpha 0,5 e desconto 1,
e avalia 100 episódios sem exploração. No runtime local com semente 42 para treino
e 7 para avaliação: Q-Learning fez 13 movimentos e SARSA fez 17, com 100% de sucesso
nos dois casos. O resultado ilustra as políticas aprendidas em um ambiente
específico; não estabelece superioridade geral ou desempenho em ambientes reais.
O laboratório Flutter oferece **Avaliar ×50** para o GridWorld sem alterar o treino.
