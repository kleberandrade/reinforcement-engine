import 'dart:convert';
import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  final environment = GridWorld();
  final agent = TabularAgent<int, GridAction>(seed: 42, learningRate: 0.2);
  for (var i = 0; i < 1500; i++) {
    trainEpisode(environment: environment, agent: agent, maxSteps: 200);
  }
  var state = environment.reset();
  final path = [state];
  for (var i = 0; i < 100 && state != environment.goal; i++) {
    final action =
        agent.selectAction(state, environment.actions(state), explore: false);
    state = environment.step(action).state;
    path.add(state);
  }
  print('Learned path: ${path.join(' -> ')}');
  print(jsonEncode(
      agent.table.toJson(encodeState: (s) => s, encodeAction: (a) => a.name)));
}
