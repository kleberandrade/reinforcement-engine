void validateUnit(double value, String name, {bool allowZero = true}) {
  if (!value.isFinite || value > 1 || value < 0 || (!allowZero && value == 0)) {
    throw ArgumentError.value(value, name, 'Expected a value in range');
  }
}
