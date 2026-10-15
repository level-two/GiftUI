# P08 control-resident payload — correction 1 source freeze

**Correction 1/2 consumed; independent SOURCE PASS at `8e747182`.**
[Focused reassessment](p08-control-resident-cycle1-independent-source-review.md)
closes B01 and finds the candidate ready for its first registered measurement. This addresses only
B01/G03 from [initial source review](p08-control-resident-initial-independent-source-review.md)
under the [current activity](p08-control-resident-implementation-activity.md).
Original `aa36a4ae` source, freeze, patch, qualification and review remain immutable.
No compiler/build/runtime/image has run; no acceptance or fit is claimed.

`CounterBackendObservation` is a pure owned Equatable value containing the actual
backend active flag, reservation/submission/finish/cancellation counts, submitted
bytes/rows and health, plus endpoint-health observation and existing construction/
projection/envelope diagnostics. It is independent of endpoint/adapter counters.
Native and Tiled each project all 13 nonpayload stored facts from a **borrowing
parameter bound to the actual original backend field**. Native UInt16 rows widen
exactly to UInt32; Tiled reads its actual UInt32 rows. No zero value substitutes
for either source. There is no whole-Control/backend copy, mutation, callback,
pointer or stored capability in the returned observation.

The existing CounterRuntimeSlotObservation now owns this value. Consequently the
same preexisting P08ReuseFingerprint and duplicate/wrong-owner `before` baseline
compare it before/after operations; neither baseline is refreshed or replaced.
Full four keys, all 64 recording records and independent accepted lastFrame remain.
Payload arrays/foreign write callback are not copied into this scalar observation;
the original complete pixel controls and synchronous callback contract remain.
No actual state operation, field loan, protocol, constructor, cleanup, capacity,
required label or resource limit changes.

Scope: three fixture files (CounterPipelineOwner, CounterNativeRaster,
CounterTiledRaster), one compiler-free regression file and exact qualification/
driver pins. New coverage checks derive nonpayload backend field inventory from
both actual declarations, require original-value projections, reject mutations
that omit/fabricate completion values, check exact row-width handling and verify
that backend facts reach the same Equatable slot/fingerprint/guard comparison.
All **75 compiler-free tests PASS**, including these four; pinned formatter and
whitespace checks pass (fixtures excluded by repository format policy).

The [new exact qualification](p08-control-resident-cycle1-applicability.json) is
pinned by hash in the driver. Fresh checks verify all eight candidate exclusions
against seven actual compiler argvs, 895 compiled/generated Swift inputs, 180 core
Swift inputs, artifacts/compilers/macros and 11 exact dependency receipts. This
still qualifies only metadata mismatches, never changed counter compiled input.
Cycle 1 manifest/patch are `control-resident-cycle1-source/manifest.json` and
`source.patch`; original contract/C/layout/decoder logic stays unchanged.

After source PASS use the initial freeze's collecting fresh nRF measurement
recipe. Strictly decoded facts remain diagnostic-only until the measured exact
Swift/C reservation update and affected verification. The old 32,000-byte spacing
is unchanged; its expected mismatch remains planned initial sizing completion,
not another corrective cycle. Complete current behavior, exclusivity, corpus,
image and resource proof remain outstanding; P08 remains open.
