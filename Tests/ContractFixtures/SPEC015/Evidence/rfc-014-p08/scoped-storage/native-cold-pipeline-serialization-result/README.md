# Physical SIL body absence and proposed correction — 2026-10-17

**Body absent in the exact frozen module.** One qualified analysis-only decode
ran; no consumer/provider compilation, application source edit, optimization
policy change, runtime, restoration or corrective2 ran. **1/2 cycles consumed.**

## Physical record proof

Input44856 bytes, SHA256
`aa24dafcd48c8dc1079bae766633e723f980767af04240b7f11bd4b125e71439`,
unchanged before/after. LLVM21.1.8 `llvm-bcanalyzer --dump --dump-blockinfo
--show-binary-blobs` exited0 with empty stderr. The dump recognizes Swift's
metadata version0/1003, matching the official6.4.0 schema. The analysis tool and
its checksum-verified dependencies are isolated in `.toolchains/p08-serialization-decoder`;
the application compiler/runtime were not replaced. This is a conda-forge
analysis binary, not a claim of an official Swift-distributed decoder.

`interpret.py` follows the complete64-bucket/31-entry SIL function index, resolves
identifier strings with the six reserved identifier IDs, verifies every name's
hash, and maps FunctionID to the physical bit offset. Raw module bits independently
confirm the record abbreviation and first seven fields at the selected offsets.

| Exact CounterScreen method | Identifier / Function ID | Bit offset | Linkage / serializedKind | Basic blocks |
| --- | --- | --- | --- | --- |
| `_giftUITraverse` |26 /28|167594|7 `PUBLIC_EXTERNAL` /0|0|
| `_giftUIEvaluate` |30 /27|167146|7 `PUBLIC_EXTERNAL` /0|0|
| state-declaration visit (control) |24 /3|138202|0 `PUBLIC` /1|1|

Traversal's record ends at167948 and has exactly two trailing argument-effects
records. Evaluate has four such records. Neither contains a serialized body.
The complete index has no private read-closure function entry for either method.
The positive control demonstrates that this physical module does contain real
serialized SIL bodies. This proof does not infer absence from optimized SIL.

## Eligibility rule and minimum supported direction

Matching release source is pinned to official
[`swift-6.4.0-RELEASE`](https://github.com/swiftlang/swift/tree/swift-6.4.0-RELEASE),
commit `b8189d766d86ad7fc8106787d6ce9e402f38dd72`; format0/1003 matches the artifact.
The binary displays `swift-6.4-RELEASE`; the canonical source tag includes `.0`.
All consulted source and its license are archived with hashes.

1. `DeclContext.cpp`, `FragileFunctionKindRequest`, checks **formal access scope
   is public** before honoring `@inlinable`. `Decl.cpp`'s formal-scope calculation
   caps a member by its enclosing nominal. The generated package `CounterScreen`
   lacks `@usableFromInline`, so method attributes alone do not cross this gate.
   `-enable-testing` raises **effective** access/SIL linkage, not this formal-scope
   check. [Release implementation](https://github.com/swiftlang/swift/blob/swift-6.4.0-RELEASE/lib/AST/DeclContext.cpp).
2. Default cross-module optimization can independently serialize eligible
   functions, explaining why the control need not have the same final kind.
   Its `canSerializeFunction` explicitly rejects an otherwise unmarked function
   with an opaque result; evaluate and its read closure have opaque results.
   The exact first CMO rejection for traversal was **not observed**; do not claim
   the closure rule alone proves its entire optimization history.
   [Release implementation](https://github.com/swiftlang/swift/blob/swift-6.4.0-RELEASE/lib/SILOptimizer/IPO/CrossModuleOptimization.cpp).
3. `SerializeSIL.cpp` writes a declaration when `DeclOnly`/external and emits no
   blocks; its body eligibility requires serialized kind or serialize-all, after
   earlier exclusions. The decoded declaration is therefore sufficient to
   explain why this frozen module cannot supply that body to the consumer.
   No stronger inline hint can manufacture a missing body in that consumer.

**Proposed final grouped correction:** make the generated enclosing finite
nominals ABI-usable with `@usableFromInline`, retaining their **package source
access**, and retain the existing targeted method `@inlinable` annotations.
This targets the demonstrated formal-scope gate, rather than guessing a stronger
method hint or enabling package-CMO. It is an unexecuted proposal for independent
review, not proof that all private dependencies compile or all allocations vanish.

The exact existing emitter is `GiftUIMacros/FiniteSourceLowering.swift`:
`Lowerer.visit(StructDeclSyntax)` owns generated generic View/Canvas declarations.
It must emit the enclosing ABI annotation; an attached member macro cannot edit
its own enclosing declaration. `ObservableStateHostMacro.swift` remains the owner
of the existing generated method annotations. **Authored Counter.swift is not an
annotation edit site.** No application-name special case or algorithm fork is
proposed.

Named signature/body dependencies for review in that same finite emitter are
`CounterReadDomain`, `CounterModelSchema`, `CounterModelSchemaSeed`, `CounterRead`,
`CounterAction`, and `counterText`, plus the generated view/canvas fields and
existing facade accessors actually referenced by serialized bodies. Their source
access stays package/internal; constructors must remain checked and no unchecked
scope initializer becomes source-accessible. This is a bounded dependency
amendment, **not** permission to publish fields or annotate every declaration.
Private `@State` backing access must be resolved by the existing generated checked
mechanism while preserving private-construction controls; if that cannot compile
without exposing a capability or changing ownership/lifetimes, stop rather than
widen it. No feasibility probe or source correction occurred here.

## Earliest final-cycle gates

At the first corrective2 source edit, mark **2/2 in progress**; compilation/codegen
failure consumes it. First compile the macro tool and its freshly generated
schema/presentation with unchanged policy, then check private access/construction.
Before wider owner work, require physical serialized bodies for this exact
traversal, evaluate and needed read closure, then a concrete consumer emitted path
without the rejected generic-metadata seam. Do not mistake source attributes or a
compiler exit for that gate. Failure stops the final cycle; no new allowance.

Only after that gate, finish the existing reviewed pipeline rows, including the
known Layout compile errors and all changed owner modules. Preserve14 loans,
Optional/lifetimes/capacities/cleanup, all payload bytes/IDs/digests and all counts.
The full private-client/lifetime/partial-initialization and original host-first
cold/reuse screens remain mandatory; full collections/images follow only if those
screens pass. This proposal does not authorize a compiler/runtime/API policy
change, warmup or guarantee of whole cold zero heap.

## Offline reproduction

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-serialization-result/verify.py
```

`evidence.tar.gz` preserves the one raw decode, input module, tool help/version,
argv/environment, package/runtime hashes and official schema/implementation.
Readable interpretation is reproducible without running the decoder. The tool
download setup encountered a display-tag404, a sandbox DNS failure and an
alternate-label libc++ URL404 before final qualification; none caused a module
decode retry. Five external edits and the existing pycache are preserved.
