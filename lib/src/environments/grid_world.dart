import '../contracts/environment.dart';
import '../domain/step_result.dart';
import '../domain/grid_action.dart';

/// Small deterministic maze. States are row-major integer cell indices.
class GridWorld implements Environment<int, GridAction> {
  GridWorld(
      {this.width = 5,
      this.height = 5,
      this.start = 0,
      int? goal,
      Set<int> walls = const {7, 12, 17}})
      : goal = goal ?? width * height - 1,
        walls = Set.unmodifiable(walls) {
    if (width <= 0 ||
        height <= 0 ||
        start < 0 ||
        start >= width * height ||
        this.goal < 0 ||
        this.goal >= width * height ||
        start == this.goal ||
        this.walls.any((w) => w < 0 || w >= width * height) ||
        this.walls.contains(start) ||
        this.walls.contains(this.goal)) {
      throw ArgumentError('Invalid grid geometry');
    }
    _state = start;
  }
  final int width;
  final int height;
  final int start;
  final int goal;
  final Set<int> walls;
  late int _state;
  int get state => _state;
  @override
  int reset() => _state = start;
  @override
  List<GridAction> actions(int state) => state == goal ? [] : GridAction.values;
  @override
  StepResult<int> step(GridAction action) {
    if (_state == goal) throw StateError('Reset a terminated environment');
    final x = _state % width;
    final y = _state ~/ width;
    final (dx, dy) = switch (action) {
      GridAction.up => (0, -1),
      GridAction.right => (1, 0),
      GridAction.down => (0, 1),
      GridAction.left => (-1, 0),
    };
    final nx = x + dx;
    final ny = y + dy;
    final target = ny * width + nx;
    if (nx >= 0 &&
        nx < width &&
        ny >= 0 &&
        ny < height &&
        !walls.contains(target)) {
      _state = target;
    }
    return StepResult(
        state: _state,
        reward: _state == goal ? 10 : -1,
        terminated: _state == goal);
  }
}
