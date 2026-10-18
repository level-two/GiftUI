# Grouped initial1 — required physical body/callee gate FAIL

Registered compilation [passes](../grouped-module-closure-registered-result/README.md),
but the unchanged `b89c4fac` candidate does not pass the next codegen gate.
Initial1/1 remains frozen; corrections0/2. This inspection ran only hash-qualified
LLVM21 read tools, with official Swift6.4 schema0/1003. No compiler, application,
source change or runtime/cold execution occurred.

All six changed provider modules decode successfully; **2,069 function-index
entries** verify identifier hashes, FunctionIDs, offsets and raw-bit record
prefixes. The [six exact symbols](six-absent-bodies.json) have **serializedKind0,
zero basic blocks** in their physical records:

| Module / required operation | FunctionID | Bit offset | Current actual consumer evidence |
| --- | ---: | ---: | --- |
| Drawing / `withCanvasStagedValues` | 71 | 221893 | Actual scoped lender closure branches to generic entry at object `0x675dc`. |
| HostConfiguration / `SignalAnalyzerPresetHostInstance.activate` | 783 | 1131904 | Concrete P08 host lifecycle specialization calls generic entry at `0xbc5c`/`0xbd7c`. |
| HostConfiguration / `SignalAnalyzerPresetHostInstance.teardown` | 784 | 1132352 | Same concrete lifecycle calls generic entry at `0xbdc0`/`0xbe04`; original-session cleanup also uses outlined forwarding. |
| Layout / `publishLayout` | 128 | 346524 | Actual Static geometry calls generic `layout` at `0x11cac`; maintained `Layout.swift:85` calls publication. No direct publication edge is claimed in the host object. |
| RuntimeCore / `ObservableCanvasInvocationSource.invokeCanvas` | 583 | 1025757 | Actual Static draw calls generic `CanvasPlanProducer.derive` at `0x11e84`; its maintained line77 invokes this source through the protocol. No direct host edge is claimed. |
| RuntimeCore / `RuntimeRecordInteractionBridge.dispatch` | 678 | 1059525 | Actual CounterPipelineOwner dispatch calls generic entry at `0x26d94`. |

Some wrappers and `runOpportunity` have real serialized bodies. Ordinary source
access plus an inline hint therefore does **not** guarantee the needed callee
closure. The failed gate is physical body availability and concrete specialization,
independent of diagnostic-print allocation attribution. Neither source syntax nor
successful module compilation replaces this proof. The archive also records the
33 reviewed sites and current hashes/status for all42 original mapped origins;
remaining rows are blocked/unqualified, not invented passes.

## Metadata and observer distinction

The actual Static session function at `0x6607c` calls `_OUTLINED_FUNCTION_851`
at `0x660dc`/`0x6618c`. The [exact helper](metadata-edge.txt) loads the demangling
cache for the concrete scoped `SignalAnalyzerPresetHostInstance<CounterHostOwner<
P08GeometryAccess,P08CandidateAccess,P08CommittedAccess,P08HitAccess>>`, then
branches to `__swift_instantiateConcreteTypeFromMangledName`, whose cold branch
calls `swift_getTypeByMangledNameInContext2` at `0x25f98`.

This is **not a measured allocation failure**. The registered object contains
`counterTrace`/reuse/corpus printing and associated allocation calls. The
[accepted ordinary/silent shape comparison](observer-comparison.json) verifies
CounterPipelineOwner's exact quiet derivation and unchanged three Static factory/
session function bodies. The older scoped-storage quiet copy also suppresses a
role label and predates reviewed physical-facts changes, so it cannot be reused
as a current artifact. Full current quiet-shape optimizer attribution remains
unexecuted. Required framework cost versus observer-induced metadata materialization
is unresolved. Key-failure Error witness first-use cost also remains unresolved.

## Next bounded work

Read-only corrective1 design must follow matched compiler CMO eligibility and the
six signature/body dependency closures; preserve source privacy, checked
constructors, ownership/lifetime union, fourteen loans and strict zero heap. No
blanket annotation restoration, ABI sweep or source edit follows from this result.
Independent design PASS precedes a corrective1 source change; budget remains0/2.

Fresh applicable privacy/lifetime controls, optimized actual-host SIL, complete
private-callee closure, safety, strict original host-first cold/reuse and broader
profiles/images remain **unrun** because this required gate failed early.
P08/R07/T8.1 stay open. Full commands, exact modules/object, raw dumps/index,
disassembly/relocations, current source maps and derivation scripts are preserved
in [evidence.tar.gz](evidence.tar.gz), with [member hashes](manifest.json).
The original five external files and pycache remain unchanged.
