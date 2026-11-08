# GiftUI Principles

These principles guide design choices and trade-offs as GiftUI grows toward
its [vision](VISION.md). They express values that should endure across tools,
features, languages, and hardware.

- **Embedded constraints shape the design from the beginning.**
  Small devices are first-class environments. Core concepts should remain
  useful under tight resource limits without depending on facilities available
  only on richer systems.

- **Preserve UI meaning across environments.**
  Application structure, state, and interaction should retain their meaning
  across targets. Different environments may realize the same concept
  differently; portability should preserve intent while respecting constraints.

- **Make capabilities and limitations explicit.**
  Developers should be able to understand what an environment supports and
  where behavior differs. Adaptation and graceful degradation should be
  deliberate and predictable, with meaningful differences visible.

- **Make cost visible and proportionate to use.**
  Resource consumption and complexity are part of design quality. Developers
  should be able to understand what they pay for, why it costs what it does,
  and which choices can reduce that cost. Unused functionality should impose
  as little burden as possible.

- **Earn trust through fidelity and evidence.**
  Development tools should reflect the behavior of the systems they represent.
  Distinguish what is known from what is estimated, make uncertainty clear, and
  refine assumptions through observation.

- **Make behavior reproducible and explainable.**
  The same relevant conditions should produce the same results. Sources of
  variation should be understandable so people and tools can reproduce
  failures, compare changes, and reason about cause and effect.

- **Optimize without silently changing meaning.**
  Efficiency should preserve intended behavior. When an improvement requires a
  compromise, make that compromise explicit so developers can judge its value.
  Correctness and resource efficiency are both essential.

- **Keep UI meaning independent of its expression and execution.**
  Application concepts should not be tied unnecessarily to a source syntax,
  renderer, operating system, or display technology. Allow these choices to
  evolve without forcing applications to abandon their intent.

- **Make expression natural to the developer.**
  Favor clear, declarative, composable interfaces that fit their language and
  ecosystem. SwiftUI is an inspiration for the Swift experience; familiarity
  should serve usability without making API imitation or source compatibility
  more important than GiftUI's needs.

- **Respect existing systems and allow gradual adoption.**
  Integration should require a small, understandable boundary and preserve
  useful existing investments. Teams should be able to evaluate and adopt
  GiftUI incrementally, with an honest account of compatibility and differences.

- **Serve humans and automated tools equally.**
  Behavior, costs, and failures should be accessible to both human understanding
  and machine inspection. Automation should produce results that people can
  explain, verify, and control.

- **Prefer the simplest design that serves demonstrated needs.**
  Keep room for evolution without paying for speculative generality. Let
  concrete use cases and evidence justify added abstractions and complexity.
