# 0.3.0 review

The delivery retains pure Dart, one public import and composition-based extension.
The numerical core is unchanged from b3c1a3b, used by the stability matrix. Stable
preparation changes docs, version and validation without tuning defaults solely
from educational tasks.

| Area | Reviewed decision | Evidence |
| --- | --- | --- |
| Compatibility | 0.2 APIs retained; new interfaces are additive | Previous tests and external consumer |
| Continuing tasks | No discount or termination; state/rho persist across windows | continuing_and_traces_test.dart |
| R-learning order | Greedy gate and rho maxima follow Q update, including self-loops | Numerical tests and continuing guide |
| Traces | Accumulating; lambda zero matches SARSA | Same-seed equality test |
| Lifecycle | trainEpisodic guarantees cleanup on termination, truncation and exceptions | Boundary/error tests and external consumer |
| Arithmetic | Projected updates prevent partial overflow writes | Multi-cell numerical tests |
| Persistence | Tables/estimate can be saved; no complete checkpoint | Continuing and migration guides |
| Experiments | 420 runs, failures retained, raw data/provenance published | [Stability](benchmarks/stability.md) |

The [validation/contracts_03](../validation/contracts_03/main.dart) independent
package implements ContinuingAgent and EpisodicAgent, imports only the public
library and runs the lifecycle without src/ imports. It verifies extensions need
neither private classes nor inheritance from built-in agents.

Preserved limits: traces cost O(active pairs) per transition; softmax temperature
is fixed; general convergence is not guaranteed; R-learning rejects terminal
boundaries. No real-world environment results are claimed.

The GitHub release is created only after hosted checks. Confirm pub.dev upload
separately: CI and tags do not mean publication succeeded.
