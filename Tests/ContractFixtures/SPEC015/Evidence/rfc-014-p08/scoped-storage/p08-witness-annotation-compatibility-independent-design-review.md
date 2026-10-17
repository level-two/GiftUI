# Independent witness annotation compatibility design review — 2026-10-17

**PASS for the bounded plan, with concrete syntax guards incorporated.** Reviewed
`e157f5d4`, its [activity](p08-witness-annotation-compatibility-activity.md),
[pre-edit boundary](annotation-compatibility-candidate1/source-boundary.json),
current macro/lowerer/tests and implementing SPEC-006/010/015 with accepted
ADR-036/039/040. This is derived ITERATION-003 I3-04/I3-05 work retaining the
closed MVP analyzer/state/stack regression duties. It creates no public macro,
ownership, compiler-policy, privacy or zero-heap contract change.

The [amended design](../../../../../../docs/implementation-designs/spec-015-p08-checked-state-serialization.md#annotation-eligibility-amendment--2026-10-17)
now makes finite-shape selection precise: complete existing checked pairs for
every State, exact single non-pack domain parameter and evaluation signature,
ABI-usable host/Domain/evaluation, and conservative enclosing-context handling.
Unknown, generic or extension/local contexts cannot become positive by a name
heuristic. SwiftSyntax's checked-in lexical-context API documents that the host
may be the first context and member bodies are stripped; eligibility must inspect
headers and every actual enclosing context. The provider compiler qualifies the
constraint's real read-domain refinement and full ABI dependency closure.

Implement only the two existing paired attribute emissions and pure eligibility
helpers in the listed macro file. Retain complete helper validation, all witness
operations/access/signatures and lexical State order. Both annotations must be
withheld together on every ordinary route, including ABI-visible hosts with
private State or nonserialized evaluation. Malformed reserved helpers retain the
existing diagnostic/no-witness result. Do not add marker names, widen access,
repair output, change the finite lowerer or redefine supported public inputs.

Focused tests must distinguish actual freshly lowered Counter expansion from
ordinary private/fileprivate/internal/package/public and enclosing-private hosts,
and exercise the clarified generic/context/evaluation/Domain negatives plus an
ABI-usable enclosing positive. Preserve all existing parser/helper negatives.
Fresh compile controls qualify compatibility; expansion-only matching is
insufficient. The repaired FrameRead fixture has D directly in `D.Type`; the
identical same-module positive/negative twins may change only package identity
and output receipts. Every negative error must be the intended access failure.

The working macOS setup2 link/runtime3 environment is the correct retained
harness input. Freeze exact registered methods/counts, argv, hashes, environment
and runner bytes before execution. After all focused/provider/privacy gates PASS,
review concrete physical-body/opaque-helper/actual-consumer commands before
running them; strict host-first cold gates require their PASS. No compile, test,
runtime, decoder or maintained-source edit occurred in this review.

Candidate remains **0/1 with zero automatic source repairs**. Historical checked
State initial1/1/corrections2/2 and Native pipeline2/2 stay closed; the combined
source is unaccepted. Stop and freeze the first material gate failure. P08,
R07/T8.1 and conformance remain open. Five external modifications and pycache
were read only and preserved. No deferred item is needed: these guards concern
current correctness. Whitespace and protected-file hashes were checked before
committing this review; no broader source or execution acceptance is claimed.
