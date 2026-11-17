# Estabilidade de aprendizado — revisão da 0.3.0

Foram executadas **420 combinações de tarefa, parâmetros e semente**, com o núcleo
no commit `b3c1a3b05248218211a7e190ad43e0cc1616db61` e `Dart SDK version: 3.11.5 (stable) (Wed Apr 15 00:36:32 2026 -0700) on "macos_arm64"`. Os dados completos estão em
[learning_stability.json](learning_stability.json), com
[proveniência](provenance.json). Não é um benchmark de velocidade ou de produção.

## Protocolo

- Sementes 0–9, pareadas entre configurações. RNG de avaliação separado do treino;
  ambientes com ruído têm sementes próprias e diferentes para treino/avaliação.
- SARSA/SARSA(λ): GridWorld e Cliff Walking; alpha 0,05/0,1/0,2 e lambda
  0/0,5/0,8/0,95. Lambda zero usa SARSA como controle; a equivalência exata com
  SARSA(λ=0) é coberta pelos testes. Gamma 0,99 e epsilon fixo 0,1.
- Cada execução treina 400 episódios de até 300 passos. Avaliação greedy de
  20 episódios novos, limitados a 200 passos cada. Total: 240 execuções episódicas.
- R-Learning: manutenção determinística e a mesma dinâmica com ruído de recompensa
  uniforme em [-0,2;0,2], alpha 0,05/0,1/0,2 e beta 0,001/0,005/0,01.
  Cada execução treina 10.000 passos e avalia 2.000 passos sem exploração.
  Total: 180 execuções contínuas, sem resets ou decaimento entre janelas.
- Nenhuma execução teve erro numérico. Sucesso não é inferido disso: todos os
  truncamentos contam como falhas. Passos e retornos abaixo incluem os timeouts.

## Resultados episódicos

Taxa média de sucesso sobre dez sementes. Passos são a média de todas as avaliações,
inclusive as que atingem o limite de 200 passos. Menor número de passos não é o
único objetivo de Cliff Walking durante exploração, devido à penalidade da queda.

| Tarefa | Alpha | Lambda | Sucesso | Passos médios | Retorno médio |
| --- | ---: | ---: | ---: | ---: | ---: |
| cliff | 0.05 | 0.0 | 40% | 126.60 | -126.60 |
| cliff | 0.05 | 0.5 | 70% | 71.50 | -71.50 |
| cliff | 0.05 | 0.8 | 90% | 36.30 | -36.30 |
| cliff | 0.05 | 0.95 | 100% | 18.60 | -18.60 |
| cliff | 0.1 | 0.0 | 80% | 52.20 | -52.20 |
| cliff | 0.1 | 0.5 | 100% | 16.80 | -16.80 |
| cliff | 0.1 | 0.8 | 100% | 17.40 | -17.40 |
| cliff | 0.1 | 0.95 | 90% | 36.30 | -36.30 |
| cliff | 0.2 | 0.0 | 100% | 16.80 | -16.80 |
| cliff | 0.2 | 0.5 | 100% | 17.20 | -17.20 |
| cliff | 0.2 | 0.8 | 100% | 17.00 | -17.00 |
| cliff | 0.2 | 0.95 | 100% | 18.60 | -18.60 |
| grid | 0.05 | 0.0 | 100% | 8.00 | 3.00 |
| grid | 0.05 | 0.5 | 100% | 8.00 | 3.00 |
| grid | 0.05 | 0.8 | 100% | 8.20 | 2.80 |
| grid | 0.05 | 0.95 | 100% | 8.00 | 3.00 |
| grid | 0.1 | 0.0 | 100% | 8.00 | 3.00 |
| grid | 0.1 | 0.5 | 100% | 8.00 | 3.00 |
| grid | 0.1 | 0.8 | 100% | 8.00 | 3.00 |
| grid | 0.1 | 0.95 | 100% | 8.20 | 2.80 |
| grid | 0.2 | 0.0 | 100% | 8.00 | 3.00 |
| grid | 0.2 | 0.5 | 100% | 8.00 | 3.00 |
| grid | 0.2 | 0.8 | 90% | 27.20 | -17.30 |
| grid | 0.2 | 0.95 | 100% | 8.00 | 3.00 |

## Resultados contínuos

Todas as 180 execuções aprenderam trabalhar quando pronta e fazer manutenção quando
desgastada. A média greedy determinística foi 1,5 em todas as configurações.
Com ruído, as médias ficaram entre 1,494946 e 1,504441. Erro absoluto máximo de rho
em relação à média ótima 1,5: 0,000331 sem ruído e 0,016156 com ruído.

| Tarefa | Alpha | Beta | Política ótima | Retorno médio | Maior erro de rho |
| --- | ---: | ---: | ---: | ---: | ---: |
| maintenance | 0.05 | 0.001 | 100% | 1.500000 | 0.000147 |
| maintenance | 0.05 | 0.005 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.05 | 0.01 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.1 | 0.001 | 100% | 1.500000 | 0.000190 |
| maintenance | 0.1 | 0.005 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.1 | 0.01 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.2 | 0.001 | 100% | 1.500000 | 0.000331 |
| maintenance | 0.2 | 0.005 | 100% | 1.500000 | 0.000000 |
| maintenance | 0.2 | 0.01 | 100% | 1.500000 | 0.000000 |
| noisy_maintenance | 0.05 | 0.001 | 100% | 1.500144 | 0.006395 |
| noisy_maintenance | 0.05 | 0.005 | 100% | 1.500144 | 0.010715 |
| noisy_maintenance | 0.05 | 0.01 | 100% | 1.500144 | 0.016156 |
| noisy_maintenance | 0.1 | 0.001 | 100% | 1.500144 | 0.006366 |
| noisy_maintenance | 0.1 | 0.005 | 100% | 1.500144 | 0.010634 |
| noisy_maintenance | 0.1 | 0.01 | 100% | 1.500144 | 0.015902 |
| noisy_maintenance | 0.2 | 0.001 | 100% | 1.500144 | 0.006333 |
| noisy_maintenance | 0.2 | 0.005 | 100% | 1.500144 | 0.010422 |
| noisy_maintenance | 0.2 | 0.01 | 100% | 1.500144 | 0.015213 |

## Interpretação e decisão

- No GridWorld, 119 das 120 execuções aprenderam uma política que chega ao objetivo
  em todas as avaliações; alpha 0,2/lambda 0,8 falhou em uma semente.
- No Cliff Walking, 107 das 120 execuções tiveram sucesso em todas as avaliações.
  Com alpha 0,05, SARSA chegou a 40% e lambda 0,95 a 100% de sucesso médio.
  Isso sugere propagação mais rápida nesse orçamento, não superioridade geral.
- Alpha 0,1/lambda 0,5 e alpha 0,1/lambda 0,8 tiveram 100% de sucesso nos dois
  ambientes para estas sementes e limites. Não alteramos defaults com base apenas
  nesses exemplos: o orçamento, o risco de exploração e a tarefa mudam a escolha.
- Os resultados de R-Learning cobrem somente um pequeno processo com e sem ruído
  aditivo. Não validam convergência em processos gerais ou aplicações reais.
- A revisão não encontrou uma falha de implementação que justificasse mudar o
  núcleo. Os limites observados estão documentados para a publicação da 0.3.0.

## Reproduzir

```sh
dart run benchmark/learning_stability.dart > /tmp/learning_stability.json
dart run benchmark/learning_stability.dart --smoke > /tmp/learning_smoke.json
```

A CI executa somente smoke para verificar compatibilidade do experimento. Os números
acima são da matriz completa local; smoke não substitui essa medição. A mesma semente
não garante igualdade de bits entre SDKs ou plataformas.
