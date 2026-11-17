# SARSA(λ) e rastros de elegibilidade (0.3 em desenvolvimento)

`SarsaLambdaAgent<S, A>` implementa SARSA tabular com rastros acumulativos.
Não é true-online SARSA nem uma implementação de rastros substitutivos.
`lambda` e `discountFactor` devem estar em [0,1].

Para cada transição, calcula `delta = r + gamma * Q(s',a') - Q(s,a)`, incrementa
`e(s,a)` em 1, aplica `Q(x,u) += alpha * delta * e(x,u)` a todos os rastros ativos
e decai `e *= gamma * lambda`. Em término, o bootstrap é zero e os rastros são
apagados após a propagação. Em truncamento, o bootstrap é preservado e os rastros
são apagados ao encerrar o episódio. Os novos valores são validados antes de
qualquer escrita: overflow não deixa uma atualização parcial da tabela.

```dart
final agent = SarsaLambdaAgent<int, GridAction>(lambda: 0.8, seed: 42);
for (var episode = 0; episode < 500; episode++) {
  trainEpisodic(environment: GridWorld(), agent: agent, maxSteps: 200);
}
```

Use **`trainEpisodic`**, que recebe o contrato `EpisodicAgent` e garante
`beginEpisode`/`endEpisode`, inclusive se o ambiente lançar uma exceção. Ele reutiliza
o loop de `trainEpisode`, sem testes de tipos concretos. Para loops manuais,
chame os métodos de ciclo de vida nas fronteiras do episódio e reutilize exatamente
a próxima ação amostrada no bootstrap. `trainEpisode` isoladamente não gerencia
rastros no truncamento; use o runner com ciclo de vida.

Com lambda zero, os valores e resultados reproduzem SARSA com a mesma configuração
e semente no mesmo runtime. O aprendizado mantém custo proporcional ao número de
pares com rastros ativos; valores não são podados por limiar e só saem ao zerar
numericamente ou terminar o episódio. Tarefas extensas precisam de limites adequados.
O começo/fim limpa somente rastros, preservando Q, RNG e exploração.

Execute `dart run example/eligibility_traces.dart`. O exemplo aprende o caminho
de oito passos do GridWorld e verifica que não restam rastros entre episódios.
O laboratório oferece SARSA(λ) entre os algoritmos do labirinto.
Salve QTable apenas para retomar entre episódios; rastros e RNG não são persistidos.

[Algorithm reference: Sutton and Barto, eligibility traces](https://web.stanford.edu/class/psych209/Readings/SuttonBartoRL.pdf).
