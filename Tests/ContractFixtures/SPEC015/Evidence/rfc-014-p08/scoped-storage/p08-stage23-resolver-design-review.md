# Independent resolver-family design review — 2026-10-18

**READY for a separately authorized bounded candidate.** Reviewed `c9c307d5`:
28 exact declaration sites in five files address the three confirmed resolver
roots. Packet hashes, 19 recorded input identities, all 28 selectors/source hashes,
all 23 mappings to the current frontier and the matched compiler excerpts verify.
The remaining 20 roots partition into staged families with no edit authorization.
No known material omission was found in this selected direct dependency map.

The six wrapper/algorithm bodies require the two enclosing nominals, Identity
aliases and exact storage-protocol/payload signatures to be ABI eligible. The
three generic helpers topmostRecord/record/capturedRecord close the direct
algorithm calls. Selected hit-region fields and BoundActionRecord.hitBounds
cover their additional reads; identity/generation/isEnabled, PointerGestureOutcome,
CapturedAction and ActionGeneration are already ABI qualified. The existing
CapturedAction initializer gains serialization only, preserving both required
parameters and assignments. Rect.contains and concrete equality may remain
ordinary ABI calls; their bodies need no automatic publication.

Both newly ABI-qualified state nominals conform to the already ABI-qualified
InteractionCommittedActionView. Their two committedRecord witnesses therefore
need ABI eligibility under the matched both-scope rule, but not serialized bodies.
The gesture witnesses are the selected six serialized operations. Existing
nonABI Static/Dynamic/StaticTwo/StaticSix storage conformers and fileprivate P08
accesses do not satisfy both scopes; their witnesses need no proposed widening.
The nonABI candidate-builder conformance does not trigger a blanket witness map.

Private-to-internal changes are exactly three framework fields and three generic
helpers, all internal ABI implementation details. OwnedKeyState.state and State's
committedRecords/committedHitRegions are distinct from SPEC-015's protected P08
access/session/supplied/pipeline/retired fields, constructors and 14 loans. Those
normative boundaries, candidate state, checked construction, raw model keys,
authored State references, ownership/lifetime clauses, defaults and algorithms
remain excluded. Ordinary same-package imports must still fail to name the new
internal fields/helpers; no public/package raw-backing route is selected.

The proposed fresh 25 compile, existing 30 privacy plus typed resolver positives/
isolated field-helper negatives, previous ten plus ten new physical roots and
fresh 42-source SIL/matched-object review fit this finite family. New Execution
decode coverage includes the generic CapturedAction initializer. Follow actual
admission through committed record/hit backends, reclassify all 23 current edges,
and stop on a material failure. Backend specialization, generic value cleanup,
metadata/context/observer cost and remaining families remain open; compiler
diagnostics must be collected together without automatic source expansion.

This review grants no source/budget/execution allowance and runs no compiler,
decoder or runtime. Current source stays `1db805a6`, with prior root/helper,
compile 25/privacy 30/physical 10 PASS and actual resolver gate FAIL/STOP retained.
Full 23/all 42 closure, complete safety, strict cold and P08/R07/T8.1/conformance
remain unqualified/unaccepted. Protected external five/pycache remain unstaged.
