# Integração com Flutter e a família de engines

O núcleo é síncrono. O laboratório agenda lotes de dez episódios entre ticks e
limita cada episódio a 200 passos. Workloads maiores precisam de lotes menores
ou de um isolate gerenciado pela aplicação. Timers, cancelamento e apresentação
ficam no laboratório, fora do núcleo.

| Pacote | Responsabilidade | Integração possível na aplicação |
| --- | --- | --- |
| `fuzzy_engine` | Regras e graus de pertinência | Transformar observações em estados discretos |
| `genetic_engine` | Otimização por evolução | Buscar hiperparâmetros de treinamento |
| `neural_engine` | Aprendizado de padrões | Aproximação de valores em uma integração futura |
| `reinforcement_engine` | Ações aprendidas por recompensa | Tabela Q e interação com ambiente |

Os pacotes têm núcleos independentes. As integrações da tabela são possibilidades
de composição pela aplicação; não são adaptadores já fornecidos. DQN não está
implementado. Estados contínuos ou imagens não são adequados diretamente à tabela.

Execute o [laboratório](../example/flutter_lab/README.md) para visualizar Q-Learning
e SARSA, treinar em lotes e animar a política aprendida.
