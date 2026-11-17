enum LabAlgorithm {
  qLearning('Q-Learning'),
  sarsa('SARSA'),
  expectedSarsa('Expected SARSA'),
  doubleQ('Double Q-Learning'),
  sarsaLambda('SARSA(λ)'),
  watkins('Watkins Q(λ)');

  const LabAlgorithm(this.label);
  final String label;
}
