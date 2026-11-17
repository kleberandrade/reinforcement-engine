# reinforcement_engine

[![Dart CI](https://github.com/kleberandrade/reinforcement-engine/actions/workflows/ci.yml/badge.svg)](https://github.com/kleberandrade/reinforcement-engine/actions/workflows/ci.yml)
[![MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Aprendizado por reforço tabular em Dart puro, com Q-Learning e SARSA.
O núcleo não depende de Flutter, bibliotecas nativas ou serviços externos.

Versão inicial: **0.1.0**. Código atual: **0.2.0-dev.1**.


## Próxima versão em desenvolvimento

`0.2.0-dev.1` adiciona avaliação de políticas, métricas e Cliff Walking.
Veja o [guia de avaliação](doc/evaluation.pt-BR.md) e execute
`dart run example/evaluation.dart`. A primeira versão `0.1.0` está preservada na
referência de release; a versão em desenvolvimento ainda não foi publicada.


## Guias e exemplos executáveis

| Tema | Exemplo Dart | Documentação |
| --- | --- | --- |
| Q-Learning e SARSA | [Labirinto](example/reinforcement_engine_example.dart) | [Algoritmos](doc/algorithms.pt-BR.md) |
| Contratos personalizados | [Ambiente e estratégia](example/custom_extensions.dart) | [Extensibilidade](doc/extending.pt-BR.md) |
| Tabela Q em JSON | [Salvar e restaurar](example/persistence.dart) | [Persistência](doc/persistence.pt-BR.md) |
| Flutter e família de engines | [Laboratório](example/flutter_lab/README.md) | [Integração](doc/integration.pt-BR.md) |


## Começar

```sh
dart pub get
dart run example/reinforcement_engine_example.dart
```

O exemplo treina um agente para navegar em um labirinto 5×5. Ele recebe −1 por
passo e +10 ao alcançar o objetivo. O caminho mínimo tem oito movimentos.

## Laboratório Flutter

```sh
cd example/flutter_lab
flutter pub get
flutter run -d chrome
```

Selecione Q-Learning ou SARSA, clique em **Treinar +500** e depois em **Executar**.
**Reiniciar** apaga o aprendizado. Trocar o algoritmo também reinicia o agente.
O treino acontece em pequenos lotes para permitir a atualização da interface.

## Conceitos

| Conceito | Significado |
| --- | --- |
| Estado | Situação atual do ambiente |
| Ação | Uma escolha disponível ao agente |
| Recompensa | Retorno numérico recebido após agir |
| Tabela Q | Estimativa do retorno futuro para cada par estado/ação |
| Epsilon | Probabilidade de explorar uma ação aleatória |
| Q-Learning | Usa o maior valor Q entre as próximas ações legais |
| SARSA | Usa o valor Q da próxima ação realmente escolhida |

Implemente `Environment<S, A>` para criar ambientes próprios. Estados e ações
precisam de igualdade e hash estáveis. `reset()` deve retornar um estado não
terminal, com pelo menos uma ação disponível.

`terminated` encerra a tarefa sem estimativa de valor futuro. `truncated` encerra
somente o episódio, por exemplo por limite de tempo, preservando essa estimativa.
Use `maxSteps` para limitar episódios, inclusive em ambientes sem saída.

A tabela pode ser exportada e importada em JSON com codificadores fornecidos
pela aplicação. Isso salva valores Q; não salva progresso do gerador aleatório,
epsilon, configuração ou estado do ambiente. Portanto, não é um checkpoint
completo para retomada exata.

O escopo inicial é de estados e ações discretos. DQN, espaços contínuos e integração
com redes neurais ficam para versões futuras. O resultado do labirinto é um exemplo
didático, não uma garantia de convergência em qualquer ambiente.

Consulte o [README completo](README.md) para API, persistência e limitações;
a [arquitetura](doc/architecture.md) e o [roadmap](doc/roadmap.md) para evolução.

## Composição de estratégias

O construtor por enum continua disponível. Para composição explícita:

```dart
final agent = TabularAgent<int, GridAction>(
  updateRule: const Sarsa(), // or const QLearning()
  seed: 42,
);
```

Implemente `TdUpdateRule<S, A>` para estratégias próprias. Uma `updateRule`
explícita tem prioridade sobre `algorithm`. Contratos, domínio, algoritmos,
agente, valores e treinamento seguem a [estrutura por responsabilidade](doc/architecture/structure.pt-BR.md).
