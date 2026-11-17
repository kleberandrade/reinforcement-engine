import 'dart:convert';

import '../agents/tabular_agent.dart';
import '../agents/double_q_agent.dart';
import '../agents/r_learning_agent.dart';
import '../agents/sarsa_lambda_agent.dart';
import '../contracts/exploration_policy.dart';
import '../domain/learning_algorithm.dart';
import '../policies/epsilon_greedy.dart';
import '../policies/softmax_exploration.dart';
import '../values/q_table.dart';

/// Immutable, versioned learning state at an episode/window boundary.
/// Restoring starts a NEW seeded RNG stream. Environment state, counters,
/// pending SARSA actions and custom strategies are owned by the application.
/// This format does not promise trajectory-exact continuation.
final class TrainingCheckpoint {
  TrainingCheckpoint._(Map<String, Object?> data) : _encoded = jsonEncode(data);

  final String _encoded;

  /// Returns a detached JSON tree; mutating it cannot change this checkpoint.
  Map<String, dynamic> toJson() => jsonDecode(_encoded) as Map<String, dynamic>;

  /// Captures only enum-selected built-in TD rules and built-in exploration.
  static TrainingCheckpoint tabular<S, A>(TabularAgent<S, A> agent,
      {required Object? Function(S) encodeState,
      required Object? Function(A) encodeAction}) {
    if (!agent.usesBuiltInUpdateRule) {
      throw UnsupportedError('Custom TD rules need an application adapter');
    }
    return _capture(
        'tabular',
        agent.table,
        null,
        {
          'algorithm': agent.algorithm.name,
          'learningRate': agent.learningRate,
          'discountFactor': agent.discountFactor
        },
        agent.explorationPolicy,
        agent.epsilon,
        agent.epsilonDecay,
        agent.minEpsilon,
        encodeState,
        encodeAction);
  }

  /// Preserves BOTH estimators independently, including sparse zero entries.
  static TrainingCheckpoint doubleQ<S, A>(DoubleQAgent<S, A> agent,
          {required Object? Function(S) encodeState,
          required Object? Function(A) encodeAction}) =>
      _capture(
          'doubleQ',
          agent.tableA,
          agent.tableB,
          {
            'learningRate': agent.learningRate,
            'discountFactor': agent.discountFactor
          },
          agent.explorationPolicy,
          agent.epsilon,
          agent.epsilonDecay,
          agent.minEpsilon,
          encodeState,
          encodeAction);

  /// Captures relative values and the current average-reward estimate.
  static TrainingCheckpoint rLearning<S, A>(RLearningAgent<S, A> agent,
          {required Object? Function(S) encodeState,
          required Object? Function(A) encodeAction}) =>
      _capture(
          'rLearning',
          agent.table,
          null,
          {
            'learningRate': agent.learningRate,
            'averageRewardRate': agent.averageRewardRate,
            'averageReward': agent.averageReward
          },
          agent.explorationPolicy,
          agent.epsilon,
          agent.epsilonDecay,
          agent.minEpsilon,
          encodeState,
          encodeAction);

  /// Call after endEpisode. Active traces cannot be silently discarded.
  static TrainingCheckpoint sarsaLambda<S, A>(SarsaLambdaAgent<S, A> agent,
      {required Object? Function(S) encodeState,
      required Object? Function(A) encodeAction}) {
    if (agent.traceCount != 0) {
      throw StateError('End the episode before capturing eligibility traces');
    }
    return _capture(
        'sarsaLambda',
        agent.table,
        null,
        {
          'learningRate': agent.learningRate,
          'discountFactor': agent.discountFactor,
          'lambda': agent.lambda
        },
        agent.explorationPolicy,
        agent.epsilon,
        agent.epsilonDecay,
        agent.minEpsilon,
        encodeState,
        encodeAction);
  }

  static TrainingCheckpoint _capture<S, A>(
      String kind,
      QTable<S, A> first,
      QTable<S, A>? second,
      Map<String, Object?> config,
      ExplorationPolicy<S, A> policy,
      double epsilon,
      double decay,
      double minimum,
      Object? Function(S) encodeState,
      Object? Function(A) encodeAction) {
    // Concrete strategy inspection is confined to this built-in format adapter.
    // Training and action-selection paths remain contract-driven.
    final Map<String, Object?> exploration = switch (policy) {
      EpsilonGreedy<S, A>() => {'kind': 'epsilonGreedy'},
      SoftmaxExploration<S, A>() => {
          'kind': 'softmax',
          'temperature': policy.temperature
        },
      _ => throw UnsupportedError(
          'Custom exploration needs an application adapter'),
    };
    return TrainingCheckpoint._({
      'version': 1,
      'kind': kind,
      'resume': 'newRandomStream',
      'config': {
        ...config,
        'epsilon': epsilon,
        'epsilonDecay': decay,
        'minEpsilon': minimum
      },
      'exploration': exploration,
      'tables': [
        first.toJson(encodeState: encodeState, encodeAction: encodeAction),
        if (second != null)
          second.toJson(encodeState: encodeState, encodeAction: encodeAction)
      ],
    });
  }

  /// Validates the envelope/configuration before returning a detached snapshot.
  /// Typed key decoding and collision validation happen during restore.
  factory TrainingCheckpoint.fromJson(Map<String, dynamic> json) {
    final checkpoint = TrainingCheckpoint._(json);
    checkpoint._validate();
    return checkpoint;
  }

  void _validate() {
    final data = toJson();
    if (data['version'] != 1 ||
        data['resume'] != 'newRandomStream' ||
        data['config'] is! Map ||
        data['exploration'] is! Map ||
        data['tables'] is! List) {
      throw const FormatException('Unsupported training checkpoint');
    }
    final kind = data['kind'];
    if (!['tabular', 'doubleQ', 'rLearning', 'sarsaLambda'].contains(kind)) {
      throw const FormatException('Unknown checkpoint kind');
    }
    final tables = data['tables'] as List;
    if (tables.length != (kind == 'doubleQ' ? 2 : 1)) {
      throw const FormatException('Incorrect estimator count');
    }
    for (final table in tables) {
      if (table is! Map<String, dynamic>) {
        throw const FormatException('Invalid estimator');
      }
      QTable.fromJson<Object?, Object?>(table,
          decodeState: (key) => key, decodeAction: (key) => key);
    }
    final c = data['config'] as Map;
    double number(String name,
        {double? minimum, double? maximum, bool positive = false}) {
      final value = c[name];
      if (value is! num ||
          !value.isFinite ||
          (minimum != null && value < minimum) ||
          (maximum != null && value > maximum) ||
          (positive && value <= 0)) {
        throw FormatException('Invalid $name');
      }
      return value.toDouble();
    }

    number('learningRate', minimum: 0, maximum: 1, positive: true);
    final epsilon = number('epsilon', minimum: 0, maximum: 1);
    number('epsilonDecay', minimum: 0, maximum: 1, positive: true);
    number('minEpsilon', minimum: 0, maximum: epsilon);
    if (kind == 'rLearning') {
      number('averageRewardRate', minimum: 0, maximum: 1, positive: true);
      number('averageReward');
    } else {
      number('discountFactor', minimum: 0, maximum: 1);
    }
    if (kind == 'sarsaLambda') number('lambda', minimum: 0, maximum: 1);
    if (kind == 'tabular' &&
        !LearningAlgorithm.values.any((v) => v.name == c['algorithm'])) {
      throw const FormatException('Unknown TD algorithm');
    }
    _policy<Object?, Object?>(data);
  }

  static ExplorationPolicy<S, A> _policy<S, A>(Map<String, dynamic> data) {
    final p = data['exploration'] as Map;
    if (p['kind'] == 'epsilonGreedy') return EpsilonGreedy<S, A>();
    final t = p['temperature'];
    if (p['kind'] == 'softmax' && t is num && t.isFinite && t > 0) {
      return SoftmaxExploration<S, A>(temperature: t.toDouble());
    }
    throw const FormatException('Unsupported exploration strategy');
  }

  Map<String, dynamic> _data(String kind) {
    final data = toJson();
    if (data['kind'] != kind) throw StateError('Expected $kind checkpoint');
    return data;
  }

  static QTable<S, A> _table<S, A>(Map<String, dynamic> data, int index,
      S Function(Object?) decodeState, A Function(Object?) decodeAction) {
    final seen = <(S, A)>{};
    final raw = (data['tables'] as List)[index] as Map<String, dynamic>;
    final table = QTable<S, A>();
    for (final entry in raw['entries'] as List) {
      final state = decodeState(entry['state']);
      final action = decodeAction(entry['action']);
      if (!seen.add((state, action))) {
        throw const FormatException('Duplicate decoded state/action key');
      }
      table.set(state, action, (entry['value'] as num).toDouble());
    }
    return table;
  }

  /// Creates a fresh learner with an explicitly NEW RNG seed (or runtime seed).
  TabularAgent<S, A> restoreTabular<S, A>(
      {required S Function(Object?) decodeState,
      required A Function(Object?) decodeAction,
      int? seed}) {
    final d = _data('tabular');
    final c = d['config'] as Map;
    return TabularAgent<S, A>(
        algorithm: LearningAlgorithm.values.byName(c['algorithm'] as String),
        learningRate: (c['learningRate'] as num).toDouble(),
        discountFactor: (c['discountFactor'] as num).toDouble(),
        epsilon: (c['epsilon'] as num).toDouble(),
        epsilonDecay: (c['epsilonDecay'] as num).toDouble(),
        minEpsilon: (c['minEpsilon'] as num).toDouble(),
        seed: seed,
        explorationPolicy: _policy<S, A>(d),
        table: _table(d, 0, decodeState, decodeAction));
  }

  DoubleQAgent<S, A> restoreDoubleQ<S, A>(
      {required S Function(Object?) decodeState,
      required A Function(Object?) decodeAction,
      int? seed}) {
    final d = _data('doubleQ');
    final c = d['config'] as Map;
    return DoubleQAgent<S, A>(
        learningRate: (c['learningRate'] as num).toDouble(),
        discountFactor: (c['discountFactor'] as num).toDouble(),
        epsilon: (c['epsilon'] as num).toDouble(),
        epsilonDecay: (c['epsilonDecay'] as num).toDouble(),
        minEpsilon: (c['minEpsilon'] as num).toDouble(),
        seed: seed,
        explorationPolicy: _policy<S, A>(d),
        tableA: _table(d, 0, decodeState, decodeAction),
        tableB: _table(d, 1, decodeState, decodeAction));
  }

  RLearningAgent<S, A> restoreRLearning<S, A>(
      {required S Function(Object?) decodeState,
      required A Function(Object?) decodeAction,
      int? seed}) {
    final d = _data('rLearning');
    final c = d['config'] as Map;
    return RLearningAgent<S, A>(
        learningRate: (c['learningRate'] as num).toDouble(),
        averageRewardRate: (c['averageRewardRate'] as num).toDouble(),
        initialAverageReward: (c['averageReward'] as num).toDouble(),
        epsilon: (c['epsilon'] as num).toDouble(),
        epsilonDecay: (c['epsilonDecay'] as num).toDouble(),
        minEpsilon: (c['minEpsilon'] as num).toDouble(),
        seed: seed,
        explorationPolicy: _policy<S, A>(d),
        table: _table(d, 0, decodeState, decodeAction));
  }

  SarsaLambdaAgent<S, A> restoreSarsaLambda<S, A>(
      {required S Function(Object?) decodeState,
      required A Function(Object?) decodeAction,
      int? seed}) {
    final d = _data('sarsaLambda');
    final c = d['config'] as Map;
    return SarsaLambdaAgent<S, A>(
        learningRate: (c['learningRate'] as num).toDouble(),
        discountFactor: (c['discountFactor'] as num).toDouble(),
        lambda: (c['lambda'] as num).toDouble(),
        epsilon: (c['epsilon'] as num).toDouble(),
        epsilonDecay: (c['epsilonDecay'] as num).toDouble(),
        minEpsilon: (c['minEpsilon'] as num).toDouble(),
        seed: seed,
        explorationPolicy: _policy<S, A>(d),
        table: _table(d, 0, decodeState, decodeAction));
  }
}
