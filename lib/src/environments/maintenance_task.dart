import '../contracts/environment.dart';
import '../domain/machine_action.dart';
import '../domain/machine_state.dart';
import '../domain/step_result.dart';

/// Educational continuing task: work earns 3 when ready, -1 when worn.
/// Service earns 0 and returns to ready. The optimal ready/work, worn/service
/// cycle earns 1.5 per step. No transition terminates or truncates.
final class MaintenanceTask
    implements Environment<MachineState, MachineAction> {
  MachineState _state = MachineState.ready;
  MachineState get state => _state;
  @override
  MachineState reset() => _state = MachineState.ready;
  @override
  List<MachineAction> actions(MachineState state) => MachineAction.values;
  @override
  StepResult<MachineState> step(MachineAction action) {
    final reward = switch (action) {
      MachineAction.work => _state == MachineState.ready ? 3.0 : -1.0,
      MachineAction.service => 0.0,
    };
    _state = action == MachineAction.service
        ? MachineState.ready
        : MachineState.worn;
    return StepResult(state: _state, reward: reward);
  }
}
