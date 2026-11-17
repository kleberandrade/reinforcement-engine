import 'dart:math';
import 'action_values.dart';

/// Behavior action selection and its exact probability distribution.
/// Both methods must represent the same policy. Lists must not be mutated.
/// Epsilon is the agent's current schedule value. Policies may ignore it when
/// using their own exploration parameter (for example, softmax temperature).
abstract interface class ExplorationPolicy<S, A> {
  A selectAction(
      {required S state,
      required List<A> actions,
      required ActionValues<S, A> values,
      required double epsilon,
      required Random random});
  List<double> probabilities(
      {required S state,
      required List<A> actions,
      required ActionValues<S, A> values,
      required double epsilon});
}
