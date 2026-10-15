# P08 original-control payload — focused design reassessment

**DESIGN PASS at `26872845`; G01–G03 closed at design scope.** The revised
[assessment/design](../../../../../../docs/implementation-designs/spec-015-p08-physical-representation-assessment.md)
is concrete enough to recommend a separately bounded source candidate under
existing authority. It requires no ADR/Spec amendment merely for its proposed
private physical layout. This review does not authorize implementation or a new
repair/compiler allowance; current activity remains assessment only.

G01 now identifies five direct payload fields, rather than a whole-payload inout,
and separate endpoint/streams/geometry/semantic formal loans. The producer captures
no pipeline or control. Boundary/phase/claim work precedes those loans; backend
health/envelope/lastFrame publication follows them. Concrete Tiled/Native leaves
and backend field paths are included, not hidden behind whole-Control mutation.
Actual OneShotRasterBackendEndpoint.offer accepts a synchronous nonescaping body;
its resolve path finishes accepted transfer or discards/cancels before return
(lines 99–178). OperationMajorRGB565RasterSession exposes target and public phase/
outcome observations (lines 32–35, 93–96); existing fixture adapters expose their
own recording/target fields. Proposed observations need no core getter change.
Native surface versus payload and Tiled tile/coverage loans are separately named.

This is a plausible ordinary Swift realization, not a proof that the compiler
accepts or optimizes the final lvalues. In source review, direct Optional endpoint
projection, sibling streams loan and every backend callback must actually retain
this separation; no whole-parent method or raw-pointer alias excuse may replace it.
The current fixture has one concrete endpoint caller, PipelineOwner:526. The two
concrete endpoint implementations call only their actual backend endpoint. Thus
moving diagnostic publication to this caller has a concrete supported path; preserve
all invalid-envelope/body/reservation and health checks exactly once. Supplemental
native positive/overlap controls are explicitly additional to the original five.

G02 supplies the missing private claim/phase/serial and responsible-value matrix.
Checked monotonic serial is distinct from optional producer origin, so ordinary
unbound construction remains valid. Pre-runtime/inert exits stay vacant; duplicate
or wrong-owner access rejects before side effects; only matching quiesced pipeline
consumption clears the installed values. Scoped retirement and owned returnWorkspaces
are both covered. The actual owned coordinator callers take a quiesced opportunity
before returnWorkspaces (CounterCoordinatorProbe:29,34). Endpoint idle/backend
inactive is checked after existing synchronous finish/cancel, not by invoking it
inside a clear/observation loan. Existing eight hooks, early returns, repeated
teardown and same-address reconstruction are accounted for. Serial resets only
with lawful destruction/reinitialization after old scoped users end.

Retain every original logical key update, including root/action nil assignments
at terminatePresentation, at its original operation point; physical slot release
later does not postpone those semantics. The design's matching direct field get/set
mapping supports this. No active whole-Control copy/reconstruction is admitted;
owned snapshots extract only named fields. The new metadata tracks storage claim
lifecycle, not a second Interaction transaction machine or arbitrary capability.

G03 names complete independent four-key and endpoint/recording observations,
including all 64 Optional glyph records, while keeping lastFrame independent.
It does not invent raw access to maintained private core phase/work storage;
existing public phase/outcome and full behavior controls retain that boundary.
Vacancy/installation/quiescence, unbound release, failed activation, prefix and
reconstruction duties are explicit. Four enlarged original control regions,
serial/phase metadata, Optional/alignment padding, C reservation, all temporaries,
Dynamic costs and feasible caller/IRQ paths must be measured. No savings or fit
is inferred from measured member sizes or the old illustrative RAM arithmetic.

The proposed minimal source package is now concrete: CounterPipelineOwner,
CounterScopedStorage, CounterTiledRaster, CounterNativeRaster, CounterProfileStorage,
CounterCoordinatorProbe; measured Embedded layout/C reservation and exact pins as
needed. Admission/Wake edits are conditional on a discovered violation, not a new
behavioral feature. Independently checked all six fixture paths are excluded from
the seven predecessor receipts' actual Swift argv; any future qualification must
still pin exact changed metadata and artifacts. Every changed counter input needs
current validation. The previous 120 facts were not redundantly decoded again.

Recommendation: authorize that bounded implementation package with independent
source review and the registered early rejection screen, followed by current full
behavior/resource gates only if promising. No architecture amendment is presently
needed. If concrete realization requires another owner/lender, an escaping pointer,
weakened protocol/state case, key form or limit, stop for that precise upstream
decision. The current review selects none. Historical 2/2 and diagnostic 1/1 remain
closed/consumed; source stays `f7e56cf0`, and P08 fit remains failed/open. No source,
compiler, build, test, runtime, link, image or hardware action occurred here.
