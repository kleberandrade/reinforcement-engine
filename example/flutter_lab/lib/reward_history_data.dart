/// Trailing mean including the current episode. Initial windows use only the
/// available observations; no zero padding or future samples are introduced.
List<double> movingAverage(List<double> rewards, int window) {
  if (window < 1) throw ArgumentError.value(window, 'window');
  var sum = 0.0;
  return List<double>.unmodifiable(List.generate(rewards.length, (index) {
    sum += rewards[index];
    if (index >= window) sum -= rewards[index - window];
    return sum / (index + 1 < window ? index + 1 : window);
  }));
}
