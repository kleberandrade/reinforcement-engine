# Estendendo o engine

Implemente `Environment<S, A>` para fornecer `reset()`, `actions(state)` e
`step(action)`. O ambiente controla seu estado. `reset()` deve retornar um estado
não terminal; cada estado não terminal precisa de ações. `StepResult` distingue
encerramento da tarefa (`terminated`) de um limite externo (`truncated`).

Implemente `TdUpdateRule<S, A>` para substituir o bootstrap. O contrato recebe a
tabela e as ações legais. Retorne um número finito sem modificar a tabela ou a
lista. `requiresNextAction: true` faz o runner amostrar e reutilizar a próxima
ação; o agente valida que ela pertence à lista. O agente calcula a atualização TD.

```dart
final agent = TabularAgent<int, GridAction>(
  updateRule: const Sarsa(),
  seed: 42,
);
```

Uma `updateRule` explícita tem prioridade sobre o atalho `algorithm`. Não é
necessário alterar o enum para criar estratégias. Importe somente
`package:reinforcement_engine/reinforcement_engine.dart`.

O exemplo completo [custom_extensions.dart](../example/custom_extensions.dart)
implementa um corredor e um bootstrap de média uniforme. Essa média é um exemplo
de contrato; não implementa Expected SARSA para uma política epsilon-greedy.

```sh
dart run example/custom_extensions.dart
```
