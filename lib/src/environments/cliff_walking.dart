import '../contracts/environment.dart';
import '../domain/grid_action.dart';
import '../domain/step_result.dart';

/// Deterministic cliff task. The bottom row contains start, cliff and goal.
/// A cliff fall costs -100 and resets to start without ending the episode.
/// Other steps cost -1, including the terminal goal transition.
final class CliffWalking implements Environment<int, GridAction> {
  CliffWalking({this.width = 12, this.height = 4}) {
    if (width < 3 || height < 2) throw ArgumentError('Invalid cliff geometry');
    _state = start;
  }

  final int width;
  final int height;
  int get start => width * (height - 1);
  int get goal => width * height - 1;
  Set<int> get cliffCells => Set.unmodifiable(
      Iterable.generate(width - 2, (index) => start + index + 1));
  late int _state;
  int get state => _state;

  @override
  int reset() => _state = start;

  @override
  List<GridAction> actions(int state) => state == goal ? [] : GridAction.values;

  @override
  StepResult<int> step(GridAction action) {
    if (_state == goal) throw StateError('Reset a terminated environment');
    final (dx, dy) = switch (action) {
      GridAction.up => (0, -1),
      GridAction.right => (1, 0),
      GridAction.down => (0, 1),
      GridAction.left => (-1, 0),
    };
    final x = (_state % width + dx).clamp(0, width - 1);
    final y = (_state ~/ width + dy).clamp(0, height - 1);
    final next = y * width + x;
    if (next > start && next < goal) {
      _state = start;
      return StepResult(state: _state, reward: -100);
    }
    _state = next;
    return StepResult(state: _state, reward: -1, terminated: _state == goal);
  }
}
