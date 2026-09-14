# SPEC-013 T7.5 Signal Analyzer Workload Evidence

Evidence kind: macOS host execution and source inspection. Cross-build report
modes retain this host-execution classification for timing and do not imply
simulator, connected-target, deployment, service restart, or flashing evidence.

## Result

The registered small workload executes 1,000 accepted calls through the shared
`RuntimeCompletePipeline` owner and verifies the fixed result checksum 8,000.
The approved Signal Analyzer workload executes 100 paired Dynamic and Static
integrated opportunities. Each profile opportunity admits and applies twenty
facts, traverses all eleven pipeline stages, dispatches the current six-case
action owner, records five Drawing strokes, publishes one semantic revision,
and accepts the frame. The paired normalized result checksum is 3,600.

Timing uses `ContinuousClock` strictly around the repeated workload body, so
SwiftPM compilation and test-process launch are excluded. The driver records
total nanoseconds, iteration count, checksum, evidence class, and profile
binding in `workload-timing.tsv` inside each immutable SPEC-013 report.

Reproduce the focused workload directly with:

```sh
scripts/contracts/check-spec-013-workloads.sh --profile macos-dynamic --output /tmp/spec-013-workload.tsv
```

The other three exact `run-spec-013.sh` modes run the same host timing oracle
alongside their own truthful host-execution or cross-build profile evidence.
