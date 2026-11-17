import 'package:reinforcement_engine/reinforcement_engine.dart';
import 'package:test/test.dart';

void main() {
  test('falling into the cliff penalizes and resets without terminating', () {
    final environment = CliffWalking();
    expect(environment.reset(), 36);
    final fall = environment.step(GridAction.right);
    expect(fall.state, 36);
    expect(fall.reward, -100);
    expect(fall.terminated, isFalse);
    expect(fall.truncated, isFalse);
    expect(environment.cliffCells, {37, 38, 39, 40, 41, 42, 43, 44, 45, 46});
    expect(() => environment.cliffCells.clear(), throwsUnsupportedError);
  });
  test('safe shortest route takes 13 moves with reward -13', () {
    final environment = CliffWalking();
    environment.reset();
    var reward = environment.step(GridAction.up).reward;
    for (var i = 0; i < 11; i++) {
      reward += environment.step(GridAction.right).reward;
    }
    final end = environment.step(GridAction.down);
    reward += end.reward;
    expect(end.state, environment.goal);
    expect(end.terminated, isTrue);
    expect(reward, -13);
    expect(environment.actions(end.state), isEmpty);
    expect(() => environment.step(GridAction.left), throwsStateError);
    expect(environment.reset(), environment.start);
  });
  test('bounds and geometry validation', () {
    final environment = CliffWalking(width: 3, height: 2);
    expect(environment.step(GridAction.left).state, 3);
    expect(environment.step(GridAction.down).state, 3);
    expect(environment.step(GridAction.up).state, 0);
    expect(environment.step(GridAction.up).state, 0);
    expect(() => CliffWalking(width: 2), throwsArgumentError);
    expect(() => CliffWalking(height: 1), throwsArgumentError);
  });
}
