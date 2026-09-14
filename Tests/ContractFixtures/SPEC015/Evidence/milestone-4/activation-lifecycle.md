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

The controller and four-preset fixtures prove synchronous teardown calls all
eight required owner operations in order from `valid`, `activating`, `active`,
and `failed`; a reentrant call observed during `quiescing` and every later call
from `quiescent` is an owner-call-free no-op. Teardown refuses delivery and
input before stopping observations, cancels callbacks before finalization,
retires registration/routing identity before releasing platform owners, resets
profile storage seventh, and invalidates report runtime use last.

Every concrete preset reaches `quiescent`, rejects later runtime opportunity
and activation calls without entering an owner, and preserves the exact
eight-step transcript across repeated teardown. The failed-activation fixture
proves the same retirement path after the first focused failure. Fresh identity
allocation and whole-host reconstruction remain Milestone 5/T6 evidence; no
old instance or assembly report is reused here.
