/// Sparse action values. States and actions must have stable equality/hashCode.
class QTable<S, A> {
  final Map<S, Map<A, double>> _rows = {};

  /// Returns zero for unseen pairs without allocating a row.
  double value(S state, A action) => _rows[state]?[action] ?? 0;
  void set(S state, A action, double value) {
    if (!value.isFinite) throw ArgumentError.value(value, 'value');
    (_rows[state] ??= {})[action] = value;
  }

  int get stateCount => _rows.length;
  void clear() => _rows.clear();

  /// Serializes values only; this is not an agent/RNG checkpoint.
  Map<String, Object?> toJson(
          {required Object? Function(S) encodeState,
          required Object? Function(A) encodeAction}) =>
      {
        'version': 1,
        'entries': [
          for (final row in _rows.entries)
            for (final cell in row.value.entries)
              {
                'state': encodeState(row.key),
                'action': encodeAction(cell.key),
                'value': cell.value
              }
        ],
      };

  /// Decoders must return keys with stable equality and hash codes.
  static QTable<S, A> fromJson<S, A>(Map<String, dynamic> json,
      {required S Function(Object?) decodeState,
      required A Function(Object?) decodeAction}) {
    if (json['version'] != 1 || json['entries'] is! List) {
      throw const FormatException('Unsupported Q-table format');
    }
    final table = QTable<S, A>();
    for (final entry in json['entries'] as List) {
      if (entry is! Map ||
          !entry.containsKey('state') ||
          !entry.containsKey('action') ||
          entry['value'] is! num) {
        throw const FormatException('Invalid Q-table entry');
      }
      final value = (entry['value'] as num).toDouble();
      if (!value.isFinite) throw const FormatException('Non-finite Q value');
      table.set(
          decodeState(entry['state']), decodeAction(entry['action']), value);
    }
    return table;
  }
}
