# Estrutura do código

| Local | Responsabilidade | Dependências permitidas |
| --- | --- | --- |
| `lib/reinforcement_engine.dart` | Exportações públicas explícitas | Sem lógica de execução |
| `lib/src/domain/` | Transição, resultado de episódio e enums | Apenas SDK Dart |
| `lib/src/values/` | Tabela Q, soma e formato JSON | SDK e contrato ActionValues |
| `lib/src/contracts/` | Ambiente, agentes episódicos/contínuos, ciclo de vida, exploração e valores | SDK/domínio; contrato TD legado também referencia QTable |
| `lib/src/algorithms/` | Bootstrap de Q-Learning, SARSA e Expected SARSA | Contratos, valores e SDK |
| `lib/src/agents/` | Controle descontado, recompensa média e rastros; comportamento e RNG compartilhados | Contratos, valores, domínio; algoritmos apenas para defaults |
| `lib/src/training/` | Ciclo do episódio, rastros, janelas contínuas e próxima ação | Contratos Environment/LearningAgent e domínio |
| `lib/src/policies/` | Políticas greedy, epsilon-greedy e softmax; validação de probabilidades | Contrato de política, tabela Q e SDK |
| `lib/src/evaluation/` | Episódios de avaliação e métricas com RNG próprio | Contratos de ambiente/política e domínio |
| `lib/src/environments/` | GridWorld, Cliff Walking e MaintenanceTask | Contrato de ambiente e domínio |
| `test/` | Testes comportamentais e de integração | Entrada pública |
| `example/*.dart` | Exemplos executáveis | Entrada pública |
| `example/flutter_lab/` | Interface e agendamento | Pacote público e dependências Flutter próprias |

Cada arquivo possui uma responsabilidade. Para adicionar um algoritmo, implemente
`TdUpdateRule<S, A>` em vez de herdar de `TabularAgent`. O construtor conhece as
estratégias prontas para oferecer o atalho por enum. A atualização e o runner
operam pelo contrato, sem verificar tipos concretos de estratégia.

Widgets, experimentos e armazenamento ficam fora de `lib/`. Consumidores importam
somente a biblioteca pública. Os nomes públicos anteriores continuam exportados.
