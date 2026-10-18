# Independent grouped module closure design review — 2026-10-18

**FAIL / not ready: explicit caller serialization frontiers remain incomplete.**
Reviewed `1c3f3e2e`, its [activity](p08-grouped-module-closure-activity.md),
[15-site map](grouped-module-closure-design/candidate-map.json), current source and
the amended pipeline note. Initial0/1 and corrections0/2 remain unconsumed. No
compiler, decoder, application, runtime or maintained-source edit occurred here.

Removing the eight illegal private annotations and both implementation attributes
on three bodyless requirements is appropriate. The latter changes neither the
requirement signature nor conformance dispatch, and cannot itself provide an
implementation body. Removing four explicit serialized entry boundaries also
preserves private implementation access. However, removing a callee's annotation
does not make a retained source `@inlinable` caller legal. The source checker
validates the caller before optimizer incorporation/default CMO. The reduced map
therefore omits known, directly affected boundaries:

| File / enclosing type | Additional existing `@inlinable` sites requiring grouped disposition | Concrete private/source dependency |
| --- | --- | --- |
| `HostActivationController.swift` / `MVPHostActivationController` | `activate`, `teardown` | Private `record`/`contain`, restricted field setters, package progress/owner/result contracts. |
| `InteractionState.swift` / `InteractionState` | `append`, `resolveDown`, `resolveMove`, `resolveUp` | Private banks/phase/error, `failCandidate`, `matchingCommittedGeneration`, `topmostRecord`, `capturedRecord`. |
| `CanvasStagedValues.swift` / `CanvasStagedValues` | `stage` | Private `state`/`entries`/`capacity`, fileprivate entry payload and metadata setters; package table/limits contracts. |
| `SignalAnalyzerPresetHostInstance.swift` / `SignalAnalyzerPresetHostInstance` | `activate`, `runOpportunity`, `teardown` | Private `invariantFailure`, restricted owner/controller setters, ordinary lifecycle/protocol operations; calls the controller boundary above. |
| `InteractionOwnedKeyState.swift` / `InteractionOwnedKeyState` | Both `append(record:in:...)` and `append(identity:...)`, `resolveDown`, `resolveUp` | Private `state`/staging/failure/component accounting; calls the InteractionState boundary above. |
| `FullSurfaceRGBA8888Buffer.swift` / `FullSurfaceRGBA8888Buffer` | Concrete `withBytes` witness | Package storage/type/requirement dependency remains non-ABI after the bodyless requirement attributes are removed. |
| `ObservableCanvasInvocationSource.swift` / `ObservableCanvasInvocationSource` | `invokeCanvas` | Private `models`/`values`/`table`; invokes the same staged Canvas/read ownership chain. |

These are 16 additional exact sites in seven files, not an instruction to edit
them or a blanket finding about every serialized method. The two additional files
outside the original nine-file map need an explicit amendment. The coherent
private-body mechanism is to consider withholding source `@inlinable` at these
named boundaries while retaining existing legal inline hints, exact access,
signatures, bodies, checks, lifetime annotations and storage. Inspect their direct
caller closure in the same amendment. Do not promote private fields/types, remove
unrelated qualified annotations or use the 144/85 lexical inventory as an edit
script. Existing ordinary callers `layout` and Static/Dynamic Canvas
`withLifetime` already lack source serialization directives and need no removal.
This is the concrete known frontier, not proof that every remaining owner is
source-ABI clean. Independently diagnosed owner blockers still belong in one
grouped sweep/disposition rather than serial trial repairs.

The proposed fresh compile strategy otherwise passes design review. All 292 map
hash entries match; all 15 frozen source prefixes exist; the 25 owners form a
valid prerequisite order and listed direct project imports have no missing DAG
edge. The actual CounterRuntime lists 42 source inputs; this count does not
replace the independent 42-origin physical pipeline map. Stage exact argv and
source/tool/generated/module hashes before execution, rebuild the unchanged
macro, and lower Counter afresh. Admit only fresh qualified project modules;
record resolved import identities/hashes and block transitive dependents on any
failure. Sequentially attempt every independently runnable owner and collect all
its errors without editing during the sweep or accepting copied/cached successes.

Default CMO remains a candidate, not a source-access bypass or serialization
guarantee. A passing fresh compile/privacy closure must precede physical bodies,
private callee closure and actual concrete binder/domain/host SIL/object/cleanup
qualification for all required origins. Key-failure witness first-use cost stays
unresolved. Only then may complete safety and strict host-first cold/reuse run;
any Static allocation fails. Preserve 14 loans, Optional/lifetime union,
provenance, exclusivity, failure ordering and backing-last cleanup.

Amend and review the finite caller boundary once before source or compiler work.
This review grants no source allowance, consumes no candidate/correction and
changes no prior exhausted budget. SPEC-015 remains implementing, its plan active
and P08/R07/T8.1/conformance open. The five external changes and pycache match their
protected hashes. No new deferred item is needed for this current blocker.
