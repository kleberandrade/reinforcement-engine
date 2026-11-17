# R-Learning e tarefas contínuas (0.3 em desenvolvimento)

`RLearningAgent<S, A>` aprende valores relativos e uma estimativa de recompensa
média por passo, `averageReward`. Não existe fator de desconto ou estado terminal
nesse contrato. Ele implementa `ContinuingAgent`, separado de `LearningAgent`.

A atualização de valores é `Q(s,a) += alpha * (r - rho + max Q(s',a') - Q(s,a))`.
Após essa atualização, se a ação executada estiver entre as ações greedy do estado
atual, aplica `rho += beta * (r - rho + max Q(s',a') - max Q(s,a))` usando os valores
atualizados. A ordem é explícita: a condição greedy e os dois máximos de rho são
posteriores à atualização Q. Isso também vale se o próximo estado for o atual.
Empates contam como greedy. Entradas e resultados devem ser finitos; a projeção
é validada antes de escrever Q ou rho. Uma taxa beta menor que alpha costuma ser
uma escolha inicial útil; ambas devem estar em (0,1]. Não há garantia de convergência.

```dart
final task = MaintenanceTask();
final agent = RLearningAgent<MachineState, MachineAction>(
  averageRewardRate: 0.005,
  epsilon: 0.1,
  minEpsilon: 0.1,
  seed: 42,
);
final first = trainContinuing(
  environment: task,
  agent: agent,
  initialState: task.reset(),
  steps: 1000,
);
final next = trainContinuing(
  environment: task,
  agent: agent,
  initialState: first.finalState,
  steps: 1000,
);
print(next.meanReward);
```

As janelas apenas limitam o trabalho. O runner não reseta o ambiente, não decai
epsilon e não reinicia rho entre janelas. Passe o estado retornado para a próxima
janela mantendo a mesma instância do ambiente. Transições com `terminated` ou
`truncated` são rejeitadas antes da atualização do agente; use controle episódico
quando esses eventos fazem parte da tarefa. O ambiente pode já ter avançado ao
reportar um evento inválido, portanto o consumidor precisa decidir como recuperá-lo.

`MaintenanceTask` é uma máquina didática com estados pronta/desgastada e ações
trabalhar/manutenção. Trabalhar rende +3 quando pronta e -1 quando desgastada;
manutenção rende 0 e volta ao estado pronto. O melhor ciclo tem média 1,5 por passo.
Execute `dart run example/continuing.dart`. Com os parâmetros e sementes do exemplo,
o teste local obteve rho 1,500 e avaliação greedy com média 1,5 em 1.000 passos.
O laboratório oferece **Tarefa contínua** com treinamento em blocos entre frames.

Para persistir, salve `table` pelo JSON existente e `averageReward` separadamente;
restaure com `table:` e `initialAverageReward:`. RNG, epsilon e estado do mundo não
são um checkpoint serializado. Avalie com outra instância de ambiente e um RNG
próprio para não interferir no treinamento.

[Algorithm reference: Barto, R-learning lecture pseudocode](https://people.cs.umass.edu/~barto/courses/cs687/Chapter%206-printable.pdf).
