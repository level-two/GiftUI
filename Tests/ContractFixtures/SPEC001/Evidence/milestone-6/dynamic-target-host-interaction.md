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

The next production slice must instantiate the checked endpoint from the Linux
executable and join pacing plus the seven-step activation/eight-step teardown
lifecycle. Console-mode ownership and connected PiScreen validation remain
separate explicit hardware gates.
## Endpoint Offer Join (2026-09-20)

The production Dynamic target-host pipeline now streams its already-derived
semantic, resolved-layout, and five-Canvas drawing candidates inside one
`RasterBackendEndpoint.offer`. It uses the preflight header as the exact
streaming expectation, maps capacity and sink refusal distinctly, retains the
original producer error, and returns the authoritative offer for interaction
resolution. Dynamic-profile integration records the complete 35-operation,
129-positioned-glyph, and 5-stroke stream before the accepted offer commits
all six staged actions.

This remains hardware-free evidence; Linux executable instantiation, lifecycle
execution, deployment, and connected execution remain open.

## Concrete Pi Endpoint Construction (2026-09-20)

`DynamicSignalAnalyzerPiEndpointFactory` now combines the exact 240 x 240 /
240 x 16 RGB565 descriptor, 7,680-byte tile and payload bounds, reference
bitmap resource, operation-major session, exact-provenance validator, and a
generic synchronous display target. The integration test supplies the real
`PiScreenDisplayTarget` over a hardware-free 480 x 320 framebuffer sink and
streams the full diagnostic-present production candidate successfully.

This closes endpoint construction independently of Linux device opening. The
executable lifecycle/pacing loop and connected PiScreen execution remain open.

## Initial Presentation Ownership (2026-09-20)

`DynamicSignalAnalyzerPiInitialPresentationOwner` now owns the first concrete
Pi presentation transaction. It constructs the production Dynamic pipeline and
exact Pi endpoint from caller-supplied validated limits and effective
presentation, derives the portable analyzer, submits it through the real
`PiScreenDisplayTarget`, and commits the matching interaction candidate only
after the display accepts the frame.

The Dynamic-profile fixture proves an accepted frame enables all six
actions, a physical transport refusal discards the candidate and leaves input
ineligible, a second initial-presentation attempt is rejected, and quiescence
removes eligibility. This is hardware-free lifecycle evidence over a fake
480 x 320 framebuffer sink; it does not claim Linux device access, connected
display operation, input polling, acquisition, pacing, deployment, or flashing.

The owner now also consumes already-normalized pointer events downstream of
the host input gate. It requires the committed physical presentation revision,
preserves source/sequence/ordinal ordering, resolves down/move/up against only
the committed interaction generation, and performs final generation-checked
dispatch. The fixture routes the one-second control through the complete
three-event sequence, rejects a stale revision, and rejects all input after
quiescence. Raw PiScreen contact polling and the `HostNormalizedInputGate`
executable composition remain open.

## Normalized Input Admission (2026-09-20)

`DynamicSignalAnalyzerPiInputCoordinator` now composes the existing
`HostNormalizedInputGate` with a Dynamic-profile bounded pointer queue. Target
contact phases are assigned one source, sequence, ordinal, and committed
presentation revision before execution admission. Accepted events remain
queued until the serialized host opportunity drains them into the production
interaction owner, so platform input cannot synchronously mutate the model.
The coordinator owns the application-opportunity gate rather than relying on
its caller to serialize mutation. Quiescence closes both admission and the
opportunity gate, and later opportunity requests fail as unavailable.
The same opportunity now opens the production `.action` fact-producer scope
around dispatch. A real deterministic source and repository fixture proves
that the Start action queues four initial channel transitions plus the running
state without applying any callback-driven mutation synchronously.

The production Pi presentation owner now reuses its display-owning endpoint
for later candidates. Before each offer it installs the exact new frame
provenance; only an accepted offer and committed interaction candidate replace
the physical presentation revision. The replacement-frame fixture changes the
model, streams a second complete production candidate, accepts input correlated
to the new revision, and rejects the formerly committed revision as stale.

Deferred repository facts now enter a distinct later application opportunity.
That opportunity seals the production fact stores, applies all five Start-
induced facts while the observable root is in its mutation phase, derives and
streams the replacement candidate, and advances normalized-input correlation
only after the replacement frame and interaction candidate commit. The model
remains idle after the input callback opportunity and becomes running only in
this later opportunity.

The hardware-free fixture proves presentation-not-established, unknown-source,
stale-revision, and quiescent rejection; exact down/move/up sequence and ordinal
formation; unchanged model state before the opportunity; one generation-
checked one-second action inside it; and unavailable opportunity rejection
after quiescence. The Start-action fixture also proves five deferred repository
facts survive the opportunity in production admission order. Linux evdev
polling, direct action-dirty rerender joining, wake-loop ownership, and
the complete live activation owner remain open.
