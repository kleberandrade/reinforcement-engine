# Revisão da 0.3.0

A entrega mantém Dart puro, importação pública única e extensões por composição.
O núcleo numérico é o mesmo do commit b3c1a3b validado na matriz de estabilidade;
a preparação estável altera documentação, versão e validações, sem ajustar defaults
com base apenas em tarefas didáticas.

| Área | Decisão revisada | Evidência |
| --- | --- | --- |
| Compatibilidade | APIs 0.2 preservadas; novas interfaces são aditivas | Testes anteriores e consumidor externo |
| Tarefas contínuas | Sem desconto ou término; estado/rho persistem entre janelas | continuing_and_traces_test.dart |
| Ordem R-Learning | Gate greedy e máximos de rho após atualização Q, inclusive self-loop | Testes numéricos e guia contínuo |
| Rastros | Acumulativos; lambda zero equivale a SARSA | Teste de igualdade com a mesma semente |
| Ciclo de vida | Limpeza garantida por trainEpisodic em término, truncamento e exceção | Testes de fronteira/erro e consumidor externo |
| Aritmética | Atualizações projetadas evitam escrita parcial em overflow | Testes numéricos de multi-células |
| Persistência | Tabelas/estimativa podem ser salvas; não há checkpoint completo | Guias contínuo e de migração |
| Experimentos | 420 execuções, falhas retidas e dados/proveniência publicados | [Estabilidade](benchmarks/stability.pt-BR.md) |

O pacote [validation/contracts_03](../validation/contracts_03/main.dart) implementa
ContinuingAgent e EpisodicAgent por uma aplicação independente, importa somente
a biblioteca pública e executa os runners sem acessar src/. Isso verifica que as
extensões não dependem de classes privadas nem de herança dos agentes prontos.

Limites preservados: rastros custam O(pares ativos) por transição; softmax usa
temperatura fixa; a convergência geral não é garantida; R-Learning não aceita
fronteiras terminais. Nenhum resultado de ambientes reais é alegado.

A release só é marcada no GitHub após os checks hospedados. Confirme o upload no
pub.dev separadamente: CI e tag não significam que o pacote foi publicado.
