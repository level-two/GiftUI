# T9.2 failure and no-replay behavior — 2026-10-02

`partialMutationFailurePreservesExactProgressAndNeverReplaysAcrossProfiles`
runs both actual profile bindings with failures before any effect, after one
and after three. Equal returned records retain the application case. Later
stages are skipped, disposition/finalization occurs once, applied effects stay
dirty with a semantic wake, and the next allowed opportunity rederives without
replaying the consumed effects. Quiescent bindings reject entry without work.
The test scripts are explicitly fixtures, not assembled production pipelines.

First-failure capture retains its exact error and detecting context despite
a later reserved-capacity rejection and safety-not-proven cleanup. The real
SignalAnalyzerRuntimeCondition captureRevisionMismatch and
reservedFailureCapacityExhausted values pass through the generic scheduled
host boundary without any diagnostic store. A semantic wake cannot run a
quiescent host. Existing exhaustive application owner-adapter tests retain
mandatory-effects-before-policy and unsafe-condition mappings. Full production
normalization and assembled fault evidence remain downstream T10.5/T10.6.

`scripts/format-swift.sh` passed.
`swift test --disable-sandbox --filter 'partialMutationFailure|scheduledHostPreserves|SignalAnalyzerOwnerFailureAdapterTests|RuntimeCompletePipelineTests|ProfileDifferentialTests'`
passed 22 tests, including the three mutation-progress cases and five
application owner-policy cases. Existing accepted/refused/failed offers and
all focused errors at every stage still pass. No resource exemption.
