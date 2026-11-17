# Architecture overview

The family pattern is explicit contracts, strategy composition, immutable result
values and a deliberate public library. The application composes an environment,
an agent and an optional existing Q-table. `trainEpisode` coordinates interaction;
it does not own UI scheduling or storage.

`Environment<S, A>` owns world state and legal actions. `TabularAgent<S, A>` owns
its RNG and exploration probability. Its table is mutable and may be supplied
explicitly for continued learning. `TdUpdateRule<S, A>` computes only the next
value: the agent owns reward, learning rate and discount in one update equation.
A rule declares whether a next behavior action must be sampled and reused.
Terminal transitions bypass the rule; truncated transitions still bootstrap.

`StepResult` and `EpisodeResult` have final fields. This is shallow immutability:
custom states and actions must themselves have stable equality and hash codes.
No global run state, registry, service locator or execution worker exists.

Configuration is checked at construction. Rewards and table values must be
finite. Nonterminal transitions require a nonempty action list. SARSA requires
a legal next action. The runner bounds work through `maxSteps`.

The enum constructor remains supported. An explicit `updateRule` takes precedence;
`algorithm` records the convenience selector and is not the effective strategy
when an override is present. Use `agent.updateRule` to inspect execution behavior.

## Learner families and persistence

EpisodicAgent adds boundary cleanup for SARSA(lambda) and Watkins Q(lambda).
ContinuingAgent models R-learning without a terminal/discounted update contract.
BanditLearner models immediate feedback, composed from BanditPolicy and a read-only
BanditValues view. Each runner depends on the corresponding interface.

TrainingCheckpoint is an outer format adapter depending on built-in agents. It
creates new learners rather than injecting persistence into the learning loop.
Applications own environment state, async feedback, IO and scheduling. See the
[dependency map](structure.md) and [learning guide](../learning_guide.md).
