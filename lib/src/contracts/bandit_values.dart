/// Read-only statistics for normalized, immediate-reward bandit decisions.
/// Counts are nonnegative; means are finite and in [0, 1]. Unseen arms mean zero.
abstract interface class BanditValues<A> {
  int get observations;
  int count(A arm);
  double mean(A arm);
}
