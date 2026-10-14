# P08 final corrective cycle 2 source freeze — 2026-10-14

Input `ddace151`; source `1716673d`, independent review `e9c10de0`. Under the
[broader activity](p08-integrated-activity.md), this is corrective cycle **2/2
consumed**, source candidate unreviewed/unexecuted. Initial cells4 (3passed/1failed),
cycle1 affected counter rerun1 failed, cycle2 rerun pending, images0. Further frozen
source or validation failure invokes the budget stop; no automatic cycle remains.

The [preserved cycle1 failure](integrated-cycle1-counter/manifest.json) freezes
wrapper argv/result/stdout/stderr, counter-model log and 19 commands for
`.build/contracts/p08-counter-nejareok`. Its sole emitted compiler error is the
UInt64/Int sum at CounterScopedStorage909. Earlier diagnostic groups are no longer
emitted; later ownership/codegen/runtime failures may remain masked. This is
narrowed evidence, not compiler or conformance success. The six packet hashes
match the parent-preserved files and are committed unchanged with this correction.

The reviewed local correction converts `DynamicRenderWorkspace.reservedPayloadBytes`
(the existing Int property) using `UInt64(exactly:)`, rejecting a negative payload
extent before adding it to UInt64 inline bytes. The exact sum, overflow/resource
duties and all limits remain. No clamp, changed allocation/workload, compiler flag,
platform, ownership mechanism, new variant or broader source repair is selected.
The extra scalar/conversion branch remains subject to actual frame accounting.
B01/O01 and the other cycle1 mechanisms are unchanged from their reviewed source.

[New manifest](p08-integrated-cycle2-source-manifest.json) pins nine current source
files, the two changed paths, qualification and failure-packet manifest hashes.
[New cycle2 qualification](p08-integrated-cycle2-applicability.json) pins the same
three successful predecessor receipts/original source hashes and the exact new
CounterScopedStorage hash. Driver selects cycle2 explicitly and otherwise retains
all exact input/artifact/compiler/macro/flags/recipe and historical r06 checks.
Original whole-source applicability manifests remain historical; the source was
not compiled by those components, whose actual inputs remain unchanged. No passed
component rerun or historical receipt rewrite occurred. The verified conservative
recorded `.swift` argv-path counts are **112/173/53**, including generated/output
paths; cycle1 freeze prose's 110/171/52 was inaccurate. Its frozen record remains
untouched; this receipt corrects the account.

Independent Strong assessment is next, then the parent's single affected counter
rerun with the already registered exact macOS Dynamic form and the original
successful SPEC-013/scoped-host paths. No compiler/build/formatter/harness/runtime/
IR/probe or hardware ran in this source correction. Changed Swift is a formatter-
excluded contract fixture; parent owns the validation boundary. Labels remain
384/202 scoped compiler controls, five Native exclusivity controls and 13 per
route/26 total, positive twins first. No target, image, resource or acceptance claim.
All nine SO criteria, HC-RD-003/P08/R07/T8.1, historical 58,648-byte failure versus
27,648 ceiling, I4-07/P09–12/hardware/timing and lifecycle gates remain open.
Specs implementing, plans active; no optional deferred discovery or authority change.
Permitted consistency checks pass: nine source hashes/two changed files,
qualification/three predecessor hashes and 112/173/53 recorded Swift paths, six
failed-evidence files, 26 labels, driver AST without invocation, 165 local Markdown
targets and whitespace. These checks establish no Swift compiler/runtime result.
