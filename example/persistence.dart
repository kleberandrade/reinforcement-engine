import 'dart:convert';

import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final agent = TabularAgent<int, GridAction>(seed: 42);
  final environment = GridWorld();
  for (var episode = 0; episode < 500; episode++) {
    trainEpisode(environment: environment, agent: agent, maxSteps: 200);
  }
  final encoded = jsonEncode(agent.table.toJson(
    encodeState: (state) => state,
    encodeAction: (action) => action.name,
  ));
  final table = QTable.fromJson<int, GridAction>(
    jsonDecode(encoded) as Map<String, dynamic>,
    decodeState: (value) => value as int,
    decodeAction: (value) => GridAction.values.byName(value as String),
  );
  final restored = TabularAgent<int, GridAction>(table: table, seed: 42);
  var state = environment.reset();
  var steps = 0;
  while (state != environment.goal && steps < 100) {
    state = environment
        .step(restored.selectAction(state, environment.actions(state),
            explore: false))
        .state;
    steps++;
  }
  if (state != environment.goal || steps != 8) {
    throw StateError('Restored policy failed');
  }
  print('JSON round trip: ${table.stateCount} states, goal in $steps moves');
}
