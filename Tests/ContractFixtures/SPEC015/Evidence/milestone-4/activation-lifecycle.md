# Activation lifecycle evidence

`HostActivationControllerTests` embeds the production activation controller in
a concrete `MVPHostInstance` fixture with a finite inline failure sum. The
fixture proves the seven activation operations run in their specified order,
each operation preserves its original failure payload, partial runtime,
observation, and source progress triggers ordered mandatory containment, and
success reaches `active`.

Repeated activation from both `active` and `failed` returns the fixture's exact
invariant case without calling an owner. Four distinct finite, inline
activation-failure sums preserve runtime, endpoint, display, configuration,
pacing, and invariant payloads for macOS Dynamic, macOS Static, Raspberry Pi
Dynamic, and nRF52840 Static.

`SignalAnalyzerPresetHostInstance` is the concrete live-owner lifecycle seam.
Its four matching construction functions reject a report for another preset,
delegate all seven activation steps, preserve the first focused payload, and
enter the runtime owner only while active. The four-preset fixture verifies the
same exact activation order and wrong-state behavior for every failure type.

The same fixture proves synchronous teardown calls all eight required owner
operations in order from `valid`, `active`, and `failed`, invalidates runtime
use of the assembly report only after profile storage reset, reaches
`quiescent`, and makes repeated teardown a no-op. Concrete identity retirement,
stale-callback poisoning, and teardown reentry while `activating` or
`quiescing` remain target-root integration evidence.
