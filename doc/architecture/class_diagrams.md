# Implemented contracts / Contratos implementados

```mermaid
classDiagram
  class Environment {
    <<interface>>
    reset()
    actions(state)
    step(action)
  }
  class GridWorld
  class StepResult
  Environment <|.. GridWorld
  Environment ..> StepResult : returns
```

```mermaid
classDiagram
  class TdUpdateRule {
    <<interface>>
    requiresNextAction
    bootstrap()
  }
  class QLearning
  class Sarsa
  class TabularAgent {
    selectAction()
    update()
    decayExploration()
  }
  class QTable {
    value()
    set()
    toJson()
    fromJson()
  }
  TdUpdateRule <|.. QLearning
  TdUpdateRule <|.. Sarsa
  TabularAgent --> TdUpdateRule : composes
  TabularAgent --> QTable : updates
  TdUpdateRule ..> QTable : reads
```

The episode runner samples the next behavior action only when the strategy
requires it, then reuses that action at the next environment step. This is
necessary for on-policy SARSA correctness.

O runner amostra a próxima ação quando exigido pela estratégia e reutiliza essa
mesma ação no próximo passo do ambiente. Isso preserva a semântica on-policy de SARSA.
