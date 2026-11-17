# Revisão da 0.4.0

O aprendizado pode ser salvo entre episódios/janelas e restaurado em outro agente
nativo. Preserva tabelas, configuração, exploração atual e recompensa média do
R-learning. Double Q mantém dois estimadores independentes. SARSA(lambda) exige
traços vazios. Estratégias não suportadas, formatos inválidos e colisões de chaves
são rejeitados. Construtores e JSON existente de QTable mantêm compatibilidade.

O [contrato de checkpoint](checkpoints.pt-BR.md) define a retomada com nova sequência
aleatória, ambiente/contadores/ações pendentes controlados pela aplicação e limites
de estratégias personalizadas. A página Flutter demonstra transferência JSON e
avaliações greedy independentes, sem prometer reprodução exata ou melhoria.

Validação: 70 testes locais do núcleo; análise de núcleo/Flutter/consumidor; oito
exemplos na VM; checkpoint em JavaScript; build web e compatibilidade Wasm. Widgets
locais foram bloqueados por sockets e são executados na CI. A validação local do
pub foi bloqueada por DNS após gerar o pacote. Release/tag e publicação são
verificados separadamente após a CI; este documento não comprova publicação.
