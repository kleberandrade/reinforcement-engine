import 'dart:math';

void validateProbabilities(List<double> probabilities, int count) {
  if (count == 0 ||
      probabilities.length != count ||
      probabilities.any((p) => !p.isFinite || p < 0 || p > 1)) {
    throw ArgumentError('Expected one finite probability per legal action');
  }
  final sum = probabilities.fold(0.0, (sum, value) => sum + value);
  if ((sum - 1).abs() > 1e-10) {
    throw ArgumentError.value(sum, 'probability sum', 'Expected one');
  }
}

int sampleProbability(List<double> probabilities, Random random) {
  validateProbabilities(probabilities, probabilities.length);
  final target = random.nextDouble();
  var cumulative = 0.0;
  var lastPositive = 0;
  for (var i = 0; i < probabilities.length; i++) {
    if (probabilities[i] > 0) lastPositive = i;
    cumulative += probabilities[i];
    if (target < cumulative) return i;
  }
  // Floating-point normalization may leave a tiny remainder.
  return lastPositive;
}
