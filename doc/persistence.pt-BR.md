# Persistência da tabela Q

`QTable.toJson` gera um envelope versão 1 com uma lista `entries` de registros
`state`, `action` e `value`. A aplicação fornece os codecs reversíveis de estados
e ações. Esses valores devem ser compatíveis com JSON e ter igualdade/hash estáveis
quando decodificados. Valores Q precisam ser finitos.

`QTable.fromJson` rejeita versões desconhecidas, entradas malformadas e valores
não finitos. Erros do codec são propagados ao consumidor. Entradas duplicadas para
o mesmo par sobrescrevem as anteriores na ordem de leitura.

O exemplo [persistence.dart](../example/persistence.dart) treina, serializa,
restaura e verifica uma política. A tabela não salva configuração, epsilon,
progresso do RNG ou estado do ambiente. Não é um checkpoint de continuação exata.
IO, armazenamento e criptografia pertencem à aplicação.

```sh
dart run example/persistence.dart
```

## Double Q-Learning (0.2)

Serialize `agent.tableA` e `agent.tableB` individualmente com os codecs da aplicação.
Restaure as duas tabelas com `QTable.fromJson` e forneça `tableA` e `tableB` ao
construtor de `DoubleQAgent`. Não salve apenas a soma: isso perde os estimadores
independentes necessários para continuar Double Q-Learning. `agent.values` é uma
visão de leitura, não um formato serializado. Não há checkpoint de RNG/epsilon.

Para salvar o estado de agentes nativos além dos valores, use
[TrainingCheckpoint](checkpoints.pt-BR.md) (0.4), entre episódios/janelas, com uma
nova sequência aleatória na retomada. O JSON existente de QTable não muda.
