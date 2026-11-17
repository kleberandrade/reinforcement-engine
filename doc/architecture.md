# Architecture / Arquitetura

The stable consumer entry point is `package:reinforcement_engine/reinforcement_engine.dart`.
Internal source paths are not a compatibility contract. The core is pure Dart,
with no Flutter, IO, HTTP or runtime package dependencies.

| Document | Contents / Conteúdo |
| --- | --- |
| [Overview](architecture/overview.md) / [Visão geral](architecture/overview.pt-BR.md) | Boundaries, ownership, design decisions |
| [Source structure](architecture/structure.md) / [Estrutura](architecture/structure.pt-BR.md) | Folder map and dependency rules |
| [Class diagrams / Diagramas](architecture/class_diagrams.md) | Implemented interfaces and collaborators |
| [Continuing tasks](continuing.md) / [Tarefas contínuas](continuing.pt-BR.md) | R-learning and window semantics (0.3 development) |
| [Eligibility traces](traces.md) / [Rastros](traces.pt-BR.md) | SARSA(lambda) and explicit episode lifecycle (0.3 development) |
| [Control](control.md) / [Controle](control.pt-BR.md) | Expected SARSA, Double Q-Learning and exploration (0.2 development) |
| [Algorithms](algorithms.md) / [Algoritmos](algorithms.pt-BR.md) | Updates, termination, truncation and exploration |
| [Extending](extending.md) / [Extensibilidade](extending.pt-BR.md) | Custom environments and TD strategies |
| [Evaluation](evaluation.md) / [Avaliação](evaluation.pt-BR.md) | Fixed policies, episode metrics and Cliff Walking (0.2 development) |
| [Persistence](persistence.md) / [Persistência](persistence.pt-BR.md) | Versioned table format and limits |
| [Integration](integration.md) / [Integração](integration.pt-BR.md) | Flutter execution and engine family boundaries |

These documents describe implemented code. Future work is explicitly listed
in the [roadmap](roadmap.md).
