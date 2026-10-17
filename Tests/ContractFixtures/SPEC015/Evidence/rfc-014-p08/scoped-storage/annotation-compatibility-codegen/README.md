# Witness compatibility codegen — provider/helper PASS; consumer BLOCKED

[Independent package review](../p08-witness-annotation-compatibility-final-independent-review.md)
confirms this bounded PASS and Layout prerequisite blocker. Grouped Layout and
remaining-owner compile-closure review is the next recommendation; no new source
allowance, actual-consumer/strict-cold result or P08 acceptance follows.

`22589fec` remains the exact single source candidate. All17 maintained tests,
fresh providers, five clean privacy controls and the four initial ordinary
positives passed. The [reviewed fixture continuation](../annotation-compatibility-continuation1/README.md)
passes the three corrected public positives and valid same-source FrameRead
positive/isolated package-access negative. The annotation compatibility correction
has no demonstrated failure. No source/test/provider was edited in this inspection.

## Physical bodies and original State helper

One decode uses the same qualified LLVM21 tool/runtime hashes and official Swift
6.4 format0/1003 schema as `24590caf`. All62 function-index entries, identifier
hashes, function offsets and selected raw-bit record prefixes verify. Fresh
physical records contain real serialized bodies:

| CounterScreen operation | FunctionID / bit offset | Serialized kind / blocks |
| --- | --- | --- |
| Evaluate | 32 / 221880 | 1 / 3 |
| Traverse | 37 / 231097 | 1 / 1 |
| State declaration visit | 36 / 229251 | 1 / 1 |
| Traversal read closure | 5 / 141968 | 1 / 3 |
| Original-State modify helper | 3 / 139021 | 1 / 3 |
| Checked key helper | 12 / 172845 | 1 / 3 |

The existing provider object was disassembled with relocation records; optimized
provider SIL was emitted once with identical compiler/SDK/package/lifetime/
optimization flags, replacing only module/object output emission with `-emit-sil`.
There is no compiler-policy or source change. Default CMO serialized helper
operations too, despite the helpers having no source `@inlinable` annotation.

`_modify` yields `struct_element_addr self, #CounterScreen._model`, with empty
resume/unwind blocks. Object0x1028 forwards the original self pointer as the
yielded address; resume0x1038 is `ret`. No temporary State, getter/setter writeback,
box, allocating coroutine context, generic-Self metadata or access TLS occurs on
that helper/continuation. Optimized visitation incorporates the same original
field address; its protocol thunk uses begin/end-apply on that helper. Compiler
synthesized getter/setter wrappers exist but do not replace this mutable route.
This qualifies the owning helper, not the still-uncompiled concrete binder caller.

The key helper's bound branch extracts State's bound case and original key;
the initial branch throws `invalidPhase`. That failure branch calls the nongeneric
AccessFailure Error witness lazy accessor (`swift_getWitnessTable`) and
`swift_willThrowTypedImpl`. Its complete first-use/failure/cold allocation and
stack costs remain **unresolved**. Neither a runtime symbol nor SIL's broad global
summary establishes an allocation; no zero-heap or whole-path cost PASS is claimed.

## Fresh Layout prerequisite blocks the actual consumer

One source-unchanged fresh `GiftUILayout` compile used the stored pinned recipe,
all11 current source hashes and the new GiftUI provider first in its import path.
It failed with **101 errors**; no repair/retry followed:

- `LayoutEngine`: three illegal private `@inlinable` methods, `measureText`,
  `finalizeTextLine`, `placeTextGeometry`.
- `LayoutSemanticValidation`: illegal private `@inlinable` `validateOccurrence`.
- `LayoutPublication`: 97 signature/body ABI diagnostics in `publishLayout`.

Complete raw diagnostics and parsed errors/44 diagnostic note origins are archived.
The diagnosed publication dependency set is LayoutWorkspace/Identity and its
scope/text/glyph/placement/reset operations; LayoutResultSink/Identity and
begin/stageScope/stageTextLine/stageGlyph/publish/discard; LayoutSummary and its
scope/text/glyph counts; LayoutResult.success/failure; LayoutError's capacity/
invariant cases; LayoutPlacement bounds/clip; LayoutTextLine identity/lineIndex/
bounds/baseline/clip; LayoutPositionedGlyph identity/lineIndex/glyphIndex/instance/
glyph/baseline/clip. The exact declarations are in archived LayoutWorkspace,
LayoutResultSink, LayoutValues and LayoutError sources. This inventory is evidence,
not permission to widen access or serialize them.

The prior combined owner-map inventory records each current source hash and
qualification status. Besides Layout, BackendIntegration, Drawing, Execution,
HostConfiguration, Interaction, ObservableState, RasterCore, ReferenceTextResources,
RenderLowering, RuntimeCore/Static, SemanticCore, TextResources and actual Counter
Runtime/Table have no fresh qualification against this provider set. Historical
partial/copy receipts do not accept their current closure. No copied Layout module
was used to claim an actual CounterPipelineOwner/binder/host PASS.

The [exact seven-file diagnosed review boundary](next-review-boundary.json) is
an inventory for the next grouped design review only; no correction realization,
source candidate or execution is selected here.

The actual consumer, safety/failure/cleanup, strict fresh host-first cold/reuse,
broader profiles/images/resources/caller and exit gates are **unrun**. P08/R07/T8.1
and conformance remain open. The [result](result.json), [raw archive](evidence.tar.gz)
and [manifest](manifest.json) preserve exact commands, new module/object, complete
physical index, SIL/object extracts, Layout inputs/full diagnostics and owner
inventory. All81 prior frozen inputs, maintained macro/tests, authored inputs,
five external changes and pycache remain exact. Independent result review precedes
any further work; candidate1/1 and zero automatic source repairs remain unchanged.
