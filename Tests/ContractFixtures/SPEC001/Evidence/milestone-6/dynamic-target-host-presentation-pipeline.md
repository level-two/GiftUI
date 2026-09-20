# Dynamic target-host presentation pipeline

## Scope

This T6.7 slice moves the real Dynamic Signal Analyzer presentation stages out
of test-only composition and into the production `SignalAnalyzerTargetHost`
module. `DynamicSignalAnalyzerPresentationPipeline` owns the observable
candidate, semantic expansion and publication storage, layout validation and
resolved-layout storage, Canvas plan workspace, and combined render preflight
workspace.

The target is a composition owner, not a portable Presentation owner. The
portable `SignalAnalyzerPresentation` hierarchy remains unchanged. The
Raspberry Pi executable links the new module so later T6.7 slices can add the
endpoint offer, interaction candidate, clock/pacing, activation, and teardown
owners at that boundary.

## Exact-capacity evidence

`dynamicTargetHostPresentationPipelineUsesExactGeneratedLimits` constructs the
pipeline from `GeneratedSignalAnalyzerPresets.raspberryPiDynamic()` and the
approved 203 recorded traversal-identity evidence capacity. Two consecutive
derivations reproduce the same checked result:

- 48 semantic nodes, 50 modifier applications, 126 retained semantic
  identities, and 203 recorded traversal identities;
- 98 layout scopes at depth 13;
- 5 Canvas occurrences and 5 strokes; and
- 35 combined render operations, 129 positioned glyphs, and clip depth 3.

The repeated derivation verifies that the production-owned workspaces return
to reusable state between cycles.

## Checks

```text
scripts/format-swift.sh
swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE \
  --filter dynamicTargetHostPresentationPipelineUsesExactGeneratedLimits
swift package dump-package | scripts/contracts/check-target-dependencies.rb
swift package dump-package | scripts/contracts/check-spec-001-boundaries.rb
scripts/contracts/check-spec-001-harness.rb
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
scripts/validate-governance.rb
```

All SwiftPM invocations use the repository cache-isolation wrapper in the
actual run. No remote target was accessed, no artifact was deployed, and no
connected display or input claim is made by this evidence.

## Remaining T6.7 work

This slice does not complete T6.7. The production owner still needs to join
interaction derivation and six-action routing, RGB565 endpoint offer/drain,
frame pacing, console-mode ownership/restoration, activation, and teardown.
Connected PiScreen validation remains gated on an explicit connected-hardware
request.
