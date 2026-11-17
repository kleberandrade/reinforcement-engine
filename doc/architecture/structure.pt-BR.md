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

## Persistência de aprendizado (0.4)

`lib/src/persistence/` contém o adaptador de formato dos checkpoints nativos,
validação e restauração em agentes novos. Depende de agentes, políticas, valores,
domínio e SDK. Agentes e runners não importam essa camada. A inspeção de tipos
nativos fica restrita ao adaptador de serialização; treino e seleção continuam
por contratos. Estratégias personalizadas exigem um adaptador da aplicação.

## Bandits e Watkins (0.5)

BanditAgent compõe BanditPolicy e expõe BanditValues somente para leitura.
trainBandit depende de BanditLearner, sem exigir um agente concreto. BanditStatistics
valida recompensas normalizadas e mantém médias/contagens. WatkinsQLambdaAgent
implementa EpisodicAgent; o runner existente não verifica tipos concretos.
