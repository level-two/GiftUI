# Native strict-construction compiler probe — 2026-10-17

**Synthetic feasibility evidence; implementation design remains open.** The
maintainer chose “Please proceed with strict contract, that makes sense” after
[the independently confirmed first-use failure](p08-native-allocation-independent-review.md).
This authorizes one new candidate and at most two corrective cycles for this
strict-zero-heap effort. Previous source allowances remain closed. No maintained
application/framework source, receipt, accepted image, resource limit or contract
changed here; no application candidate or corrective cycle has been executed.

The [packet](native-strict-construction-probe/manifest.json) preserves nine tiny
separate-module probes, exact sources/commands/compiler hash, loaded-library
identities, results, object imports and caller disassembly. They use the unchanged
matched-observation C driver/observer, fresh processes, opaque C input (7), and a
C volatile read of escaped storage, preventing the whole computation from being
constant folded. Each cold/reuse entry returns42. All coverage/failure flags are
zero. These are diagnostics, not the required P08 route or allocation coverage.

| Mechanism | Cold allocations | Requested / malloc usable bytes | Retained bytes | Reuse new allocations |
|---|---:|---:|---:|---:|
| Ordinary per-module WMO |139|10687 /11200|3664|0|
| Full CMO + enable-cmo-everything |139|10687 /11200|3664|0|
| Targeted serialized generic dispatch/root bodies |27|1488 /1488|352|0|
| Additionally force constructor inline |27|1488 /1488|352|0|
| Generic root with two named Optional fields |25|1424 /1424|336|0|
| Private nongeneric root with two named Optional fields |0|0 /0|0|0|
| Same concrete root, retaining actual contiguous InlineArray |0|0 /0|0|0|
| Concrete InlineArray -> MutableSpan -> serialized generic scoped callback |0|0 /0|0|0|
| Generic root with forced client body emission |27|1488 /1488|352|0|

The last two preserve the same targeted serialized generic dispatch and change
only the root representation. The generic pair result rejects the hypothesis
that replacing `InlineArray` alone suffices. Remaining serialized-root stacks
enter Swift canonical prespecialized generic metadata registration; the concrete
control removes that rooted metadata construction. It establishes a compiler
mechanism, not a proof that the real host can use it unchanged. The measured
runtime remains system `libswiftCore`, UUID83794fb3de9b3d23ab5e2c1d5d30f134.
Requested/usable sizes exclude allocator arenas and observer overhead.

## Actual mapping boundary

`StaticObservableModelStorage<Model,Schema>` owns an `InlineArray<2,Model?>` and
lends its actual contiguous `MutableSpan` to `withObservableModelScope`.
`ObservableModelScope.withRead` separately constructs an inline array of two
read slots. The actual admission/gesture/dispatch sites also cross generic
conformance boundaries. A concrete wrapper around an unchanged generic
constructor would therefore leave the demonstrated cause intact.

[ADR-036](../../../../../../docs/adrs/adr-036-scoped-model-access-and-bounded-ownership.md#fixed-domain-access-and-source-transformation)
requires generic authored/read contracts and a host/profile bridge against
concrete storage. SPEC-013 S13.1 and ADR-039 require actual typed ownership,
fixed-capacity inventory, disjoint banks and the original lifetime dependencies.
They do not require `InlineArray` as the private representation. An internal
concrete realization is permitted only while preserving those contracts. This
probe does **not** license tuple-contiguity assumptions, unsafe layout casts,
untyped loans, changed capacities, bypassed checks or cache warmup.

The [focused design](../../../../../../docs/implementation-designs/spec-015-p08-native-cold-static.md) selects concrete owning storage with serialized scope construction. The scoped control proves the contiguous span and generic noncopyable/nonescapable callback shape can remain; it does not implement the actual registration/read bridge. That design must map concrete construction through the existing
contiguous model span, read scope, Optional typed owner and all fourteen loans;
then screen an actual cold construction/action route before a source candidate
is selected. Public generic read/context contracts must remain unchanged. No
claim of implementation readiness, zero heap for GiftUI, complete Native/Pi
stack/physical bounds or P08 completion is made.

## Verification and opt-in reproduction

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-strict-construction-probe/verify.py
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-strict-construction-probe/reproduce.py --variant concrete-pair --output .build/contracts/p08-strict-concrete-reproduction
```

Reproduction requires the hash-pinned retained observer/driver and pinned local
compiler. The failed preliminary annotation-access control and early exploratory
variants remain disposable `.build` diagnostics; these nine preserved controls
are the decision evidence. Existing external changes in two SignalAnalyzer
sources, nRF CMake/build and Pi build plus Python cache remain excluded.
