# Checkpoints de aprendizado (0.4)

[English](checkpoints.md)

`TrainingCheckpoint` é um snapshot JSON imutável e versionado dos agentes nativos.
Execute `dart run example/checkpoint.dart`: treina, transfere por JSON, restaura e
continua aprendendo, tanto na VM Dart quanto em JavaScript compilado.

| Captura | Restauração | Estado preservado |
| --- | --- | --- |
| `TrainingCheckpoint.tabular` | `restoreTabular` | Algoritmo do enum, tabela Q, alpha, gamma |
| `TrainingCheckpoint.doubleQ` | `restoreDoubleQ` | Duas tabelas Q independentes, alpha, gamma |
| `TrainingCheckpoint.rLearning` | `restoreRLearning` | Valores relativos, alpha, beta, recompensa média |
| `TrainingCheckpoint.sarsaLambda` | `restoreSarsaLambda` | Tabela Q, alpha, gamma, lambda; traços vazios |

Todos preservam epsilon atual, decaimento, mínimo e exploração nativa:
epsilon-greedy ou softmax com temperatura fixa. Os codecs devem preservar igualdade
e hash estáveis e distinguir todas as chaves. Colisões entre pares decodificados
são rejeitadas. A captura copia os dados e `toJson` devolve uma árvore independente.
Cada restauração cria tabelas novas, sem modificar o agente original.

```dart
final salvo = TrainingCheckpoint.tabular(agent,
  encodeState: (state) => state,
  encodeAction: (action) => action.name);
final carregado = TrainingCheckpoint.fromJson(salvo.toJson());
final retomado = carregado.restoreTabular<int, GridAction>(
  decodeState: (key) => key as int,
  decodeAction: (key) => GridAction.values.byName(key as String),
  seed: 99);
```

## Fronteiras e reprodução

Capture entre episódios ou janelas contínuas, sem atualização pendente. Para
SARSA(lambda), chame `endEpisode` ou use `trainEpisodic` antes. Traços ativos são
rejeitados. Traços vazios não comprovam uma fronteira: lambda/gamma zero ou uma
ação SARSA já amostrada também podem não ter traços. O chamador deve garantir a
fronteira para todos os algoritmos.

A restauração inicia uma **nova sequência aleatória** com a semente fornecida;
sem semente, usa a escolhida pelo runtime. Dois agentes restaurados com a mesma
semente e ordem de chamadas reproduzem um ao outro no mesmo runtime. Eles não
continuam a posição do gerador original. O JSON registra `resume: newRandomStream`.
Não há promessa de retomada exata da trajetória nem de sequência entre runtimes.

Identidade/estado do ambiente, contadores, geradores externos, ações SARSA pendentes
e armazenamento pertencem à aplicação. Reinicie o ambiente episódico ao retomar.
Em tarefas contínuas, restaure ou escolha explicitamente o próximo estado e
documente essa escolha. Este formato não retoma episódios interrompidos.

Regras TD personalizadas, incluindo instâncias nativas injetadas diretamente, e
políticas personalizadas são rejeitadas. Elas exigem um adaptador da aplicação.
Expected SARSA selecionado pelo enum restaura seu callback ligado à exploração
e ao epsilon do novo agente.

O formato versão 1 de `QTable.toJson/fromJson` continua disponível e inalterado,
mas contém apenas valores. O checkpoint valida versão, algoritmo, quantidade de
tabelas, limites e números finitos; rejeita restauração por método incompatível.
A aplicação valida seus codecs, a identidade do ambiente e limites de entrada.

## Laboratório Flutter

Abra **Salvar e retomar**, treine +100, exporte o JSON, crie um novo agente e importe.
A política importada é avaliada em 20 episódios greedy independentes. Continuar o
treino produz outra avaliação com a mesma semente de avaliação. A comparação vale
para esse labirinto e não promete melhoria. A transferência usa copiar/colar,
sem acesso automático a disco ou rede. O exemplo adiciona identidade do ambiente
e contador de episódios ao envelope e preserva o agente quando a entrada é inválida.

## Adições na 0.5

`TrainingCheckpoint.watkinsQLambda` / `restoreWatkinsQLambda` preservam configuração,
Q e exploração de Watkins entre episódios sem traços ativos. O tipo novo
`watkinsQLambda` mantém a versão 1 do envelope; leitores antigos o rejeitam.
Tipos anteriores não mudam. Este formato não salva bandits; a aplicação controla
sua eventual persistência.
