# P08 grouped lifetime continuation — independent Strong SOURCE review

**Disposition: source ready for the one authorized exact counter invocation.**
Independent Sol 6.1 High review of clean `cab1c415`, diff from `86fca501`,
[combined activity/freeze](p08-compiler-compatibility2-source-freeze.md),
[manifest](p08-compiler-compatibility2-source-manifest.json),
[qualification](p08-compiler-compatibility2-applicability.json) and the
[L01–L03 diagnosis](p08-compiler-compatibility1-result.md). Accepted ADR-039 and
approved S11/S13/S15 remain authority. No source fix, compiler, build, formatter,
probe, driver/runtime or subagent during review. This is source readiness, not
acceptance of the previously rejected source shape or measured compiler success.

| Group / boundary | Independent source disposition |
| --- | --- |
| L01 | Five fileprivate concrete helpers at `CounterScopedStorage.swift:1695–1730` take the exact InlineArray fields by inout, derive `field.mutableSpan` directly and complete the buffer visitor before returning. The selected caller at 1752–1764 nests original records128/paths384/payloads256/scalars128/Canvas entries1 field loans through the full body. No pointee-derived mutableSpan remains in these sites. This supplies an actual typed field-loan anchor instead of the rejected pointer-parameter dependence. No array contents are copied, new storage protocol introduced or lifetime override/raw-span substitute used; Embedded's original bound-field route is unchanged. Compiler enforcement of these exact nested lifetimes remains unproved. |
| Exclusive original backing | Root/semantic/Canvas/control typed scopes and five disjoint field loans still enclose the same physical owner/body. Helper callbacks are nonescaping; their default Escapable Result cannot return a scoped value. All actual helper call sites belong to this synchronous selected factory and ultimately return owned counts. No new raw pointer return, stored callback or public extraction capability is added. Existing address/disjointness/provenance validation and original inventory/reset/destruction duties remain. Runtime exclusivity and real helper-frame costs need execution evidence. |
| L02 | Both consuming body calls at 1993/2127 now use `semantic.borrowedStore()` and `values.borrowedValues()` inside the current lender lifetimes. The original callback facades remain borrowed. Both existing projection APIs and their private constructors retain `@_lifetime(copy self/copy other)`, forwarding the same lender dependence into the unchanged consuming supplied/pipeline/coordinator/host/retirement union. No lender callback becomes consuming, scoped facade becomes Copyable, backing is copied or second mutable transaction owner created. The former direct consumption of borrowed semantic/values is removed; exact nested compiler acceptance remains unproved. |
| L03 | `p08VerifyRoleTranscript` at 2295–2310 reads count into an owned scalar before precondition, loop and return. The transcript itself is read directly only to project each already-owned event. Exactly twelve entries/six commits and all ID/address/extent/count/exchange assertions remain. No live control-pointee check is replaced by a snapshot. |
| Preserved source behavior | Graph live assertions, same-address two-host reuse, terminal rejection, original producer/capture guards, actual seal/mutating dispatch, stale fingerprints, explicit observation clearing before physical release and all earlier C01–C05/B01/O01 corrections remain. No flag/platform/workload/resource/contract change, copied view, checking suppression or new ownership architecture. New helper/span/projection frames require actual family24/nested-stack/IRQ accounting; source shape establishes no fit. |

Driver changes only select and assert the named compatibility2 qualification.
Read-only verification confirms nine source hashes/exactly two changed paths,
qualification hash and exact corrected source hash, the same three predecessor
receipt hashes/original applicability hashes, conservative recorded Swift-path
counts/hashes **112/173/53**, source exclusion and sole noncompiled applicability
mismatch. All actual compiled-source/artifact/compiler/macro/flags/recipe checks
and historical r06 fallback remain. Historical receipts/qualifications are not
rewritten or made globally current; unchanged passed components need no hash-only
rerun. All six immutable prior failure-file hashes also match.

The 26 unique route labels match the prior manifest; 384/202 compiler controls,
five Native exclusivity controls and positive-before-negative order remain.
Driver AST without invocation, whitespace and local review links pass. No further
bounded source blocker or optional deferred discovery is found. These three
source mechanisms directly address the emitted relationships, but further compiler,
ownership/code-generation, runtime or resource failures may still appear.

Current new allowance: **candidate1/1 consumed, invocation0/1, automatic repairs0**.
Parent may format at the validation boundary and invoke the one exact registered
macOS Dynamic counter command using the original successful predecessor paths.
Stop/report at this activity boundary; no repair, probe/variant, second invocation
or remaining-profile/image continuation is automatically authorized. Historical
integrated2/2 and compatibility1 candidate/run failure remain closed, with the
cumulative guard intact. Only this independent review is committed; parent owns
subsequent evidence/navigation/boundary reporting.

All nine SO criteria, HC-RD-003/P08/R07/T8.1, runtime/target and fit remain open.
The historical **58,648-byte failure / unchanged 27,648-byte main-stack ceiling**
is not replaced. I4-07/P09–12, hardware/timing and lifecycle obligations remain
separate; Specs implementing, plans active. No implemented transition or contract
decision follows from this source-ready disposition.
