# Estrutura do código

| Local | Responsabilidade | Dependências permitidas |
| --- | --- | --- |
| `lib/reinforcement_engine.dart` | Exportações públicas explícitas | Sem lógica de execução |
| `lib/src/domain/` | Transição, resultado de episódio e enums | Apenas SDK Dart |
| `lib/src/values/` | Tabela Q esparsa e formato JSON | Apenas SDK Dart |
| `lib/src/contracts/` | Interfaces de ambiente e atualização TD | Domínio e valores |
| `lib/src/algorithms/` | Bootstrap de Q-Learning e SARSA | Contratos, valores e SDK |
| `lib/src/agents/` | Validação, epsilon-greedy e atualização TD | Contratos, valores, domínio; algoritmos apenas para defaults |
| `lib/src/training/` | Ciclo do episódio e reutilização da próxima ação | Contrato de ambiente, agente e domínio |
| `lib/src/policies/` | Seleção de ações; desempate greedy compartilhado | Contrato de política, tabela Q e SDK |
| `lib/src/evaluation/` | Episódios de avaliação e métricas com RNG próprio | Contratos de ambiente/política e domínio |
| `lib/src/environments/` | GridWorld e Cliff Walking | Contrato de ambiente e domínio |
| `test/` | Testes comportamentais e de integração | Entrada pública |
| `example/*.dart` | Exemplos executáveis | Entrada pública |
| `example/flutter_lab/` | Interface e agendamento | Pacote público e dependências Flutter próprias |

Cada arquivo possui uma responsabilidade. Para adicionar um algoritmo, implemente
`TdUpdateRule<S, A>` em vez de herdar de `TabularAgent`. O construtor conhece as
estratégias prontas para oferecer o atalho por enum. A atualização e o runner
operam pelo contrato, sem verificar tipos concretos de estratégia.

Widgets, experimentos e armazenamento ficam fora de `lib/`. Consumidores importam
somente a biblioteca pública. Os nomes públicos anteriores continuam exportados.
