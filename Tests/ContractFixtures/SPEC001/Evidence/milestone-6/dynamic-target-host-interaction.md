# Dynamic target-host interaction join

## Scope

This T6.7 slice joins the production Dynamic interaction candidate to the real
Signal Analyzer semantic, layout, and observable candidates. The target-host
owner derives exactly six `RuntimeInteractionOccurrence` values from the six
portable actions and their resolved bounds, stages them through
`DynamicInteractionState`, and uses `RuntimeInteractionCandidateCoordinator`
for target-generation binding and bounded action-generation allocation.

`DynamicObservableStateReconciler` now supplies the existing
`ObservableStateTargetView` contract by forwarding candidate and committed
generation queries to its root adapter. The target-host wrapper records the
single state declaration identity during real state-bound semantic expansion;
it does not infer that identity from render or layout nodes.

## Behavioral evidence

`dynamicTargetHostPresentationPipelineUsesExactGeneratedLimits` now proves:

- exactly six interaction occurrences, committed actions, and hit regions;
- accepted presentation revisions 1 and 2 commit in order;
- unchanged actions preserve all six action generations across the second
  accepted presentation;
- down, move, and up resolve against the real one-second control bounds; and
- final dispatch passes the observable target-generation guard and changes
  the shared model's visible window to one second.

The candidate remains pending after derivation and is committed or discarded
only from the frame-offer result. This preserves the accepted pipeline order
without pretending that an endpoint offer has already happened.

## Checks

```text
scripts/format-swift.sh
swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE \
  --filter dynamicTargetHostPresentationPipelineUsesExactGeneratedLimits
swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE \
  --filter GiftUIHostConfigurationTests
swift package dump-package | scripts/contracts/check-target-dependencies.rb
swift package dump-package | scripts/contracts/check-spec-001-boundaries.rb
scripts/contracts/check-spec-001-harness.rb
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
scripts/validate-governance.rb
```

The actual SwiftPM invocations use the repository cache-isolation wrapper.
The ARMv6 check is a local cross-build only. No remote machine, deployment,
framebuffer, input device, or connected board is accessed.

## Remaining T6.7 work

The next production slice must construct the checked 240 x 16 RGB565 Pi
endpoint at the executable boundary and join pacing plus the seven-step
activation/eight-step teardown lifecycle. Console-mode ownership and connected
PiScreen validation remain separate explicit hardware gates.
## Endpoint Offer Join (2026-09-20)

The production Dynamic target-host pipeline now streams its already-derived
semantic, resolved-layout, and five-Canvas drawing candidates inside one
`RasterBackendEndpoint.offer`. It uses the preflight header as the exact
streaming expectation, maps capacity and sink refusal distinctly, retains the
original producer error, and returns the authoritative offer for interaction
resolution. Dynamic-profile integration records the complete 35-operation,
129-positioned-glyph, and 5-stroke stream before the accepted offer commits
all six staged actions.

This remains hardware-free evidence; concrete Pi endpoint construction,
lifecycle execution, deployment, and connected execution remain open.
