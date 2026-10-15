# P08 cycle 2 empty-drawing oracle follow-up — 2026-10-15

Candidate `6eaeb9fc` passes the 22 selected compiler controls on both native
profiles, including the corrected six classifier cases and actual async
negative. Dynamic passes all five exclusivity controls. Both counter executions
and Static positive exclusivity now trap in `P08TypedBackingOwner.requireEmpty`,
after initialization: the native stride-tail correction cleared its earlier
failure. Parent's three exact existing-binary LLDB logs, supplied commands,
binary hashes and current focused receipt hashes are pinned in the
[new manifest](p08-suite-cycle2-followup2-source-manifest.json). No debugger was
run in this source correction.

The Static empty oracle improperly reads `summary`, whose existing contract
requires a published plan; fresh/reset storage intentionally has none. Preserve
`!isActive` and inspect the actual supported `strokeCount`, `pointCount`,
`subpathCount` and `normalizedStrokeOperationCount` for zero instead.
`StaticRecordDrawingWorkspace` exposes no aggregate count properties, so the
oracle uses its existing typed `withBase` operation to read those properties
from `StaticCounterDrawingWorkspace`. It changes neither storage nor the public
summary contract. The native typed layout is unchanged.

Same-cause scan found no other scoped empty/preactivation summary read. The
remaining Static/Dynamic drawing-summary reads are in successful render
preflight after the drawing stage publishes its plan; those retain their
existing validation. Unrelated execution/admission summaries are unchanged.

This routine newly exposed assertion fix remains inside coherent **cycle 2/2**;
it creates no third cycle or reset. Earlier source candidates, manifests,
qualifications and failed receipts remain immutable. The driver selects the
[new exact qualification](p08-suite-cycle2-followup2-applicability.json), preserving
the seven untouched noncompiling predecessor identities and pinning current source.

**29 compiler-free tests**, Python AST, current manifest/source hashes, seven
exact receipt applicability proofs, diagnostic log/binary hashes and whitespace
checks pass. No compiler, suite, runtime, formatter, hardware/image operation or
delegation occurred. Parent next runs fresh native `runtime` and
`so06-native-exclusivity` families first, then ARMv6's four selected compiler
families and all 202 Embedded cases. The previous 22 passes describe the prior
compiled-source hash; they are not silently current after this change. Partial
focused coverage, full current-source coverage and P08/fit remain distinct/open.
