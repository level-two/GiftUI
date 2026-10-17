# Corrective1: early codegen prerequisite FAIL

The strict Native activity consumed **1/2 corrective cycles**. This overlay is
experimental and unaccepted. Corrective2 has not started. No restoration was
retried; the five external files and pycache were preserved. No cold/reuse
workload, new allocation count, complete linked candidate, source safety gate,
full collection or image build is claimed. P08 remains open.

## Concrete failed gate

The freshly compiled, partial `P08CounterRuntime.o` still emits generic traversal
and concrete-metadata instantiation on the actual host lifecycle path:

| Owner / section-relative range | Retained calls |
| --- | --- |
| `CounterPipelineOwner.beginObservableCandidateAndExpandSemantics`, `__TEXT,__text` `0x53e28..<0x549b0` | mangled-name metadata helpers `0x540b4`, `0x54324`, `0x54648`; generic `CounterScreen._giftUITraverse` at `0x54874` |
| concrete `SemanticRecordStore.expand` clone, `0x1f00..<0x29e8` | metadata helpers `0x1f44`, `0x208c`, `0x22dc`, `0x28e4`; generic traversal `0x2720` |

The second row belongs to the **common `exerciseCounter` semantic probe**, called
at `0x1480`; it is not presented as the host call site. The first row independently
establishes the same failed prerequisite in the host. The host source call is
`CounterPipelineOwner.swift`'s `beginObservableCandidateAndExpandSemantics`.
Generic store candidate/bank operations, traversal `stopped` and
`RecordSink.publishExpansion` remain out of line. This contradicts the design's
required emitted monomorphic closure; it does **not** measure new allocation
counts or prove that every helper allocates on every call.

The provider optimized SIL contains a basic-block body for the generated
`CounterScreen._giftUITraverse`, marked `[heuristic_always_inline]`. The consumer
optimized SIL retains a generic `apply` and only imports its declaration/effects
summary, with that attribute and **no basic-block body**. The same actual object
has the branch relocations above. Source annotations therefore did not supply an
effective client body at this boundary in this diagnostic. It is not justified
to describe this as an inliner rejecting an available recursive body, an
impossibility result, or a Swift defect.

`module-resolution-inventory.json` preserves every command's ordered `-I`
directories, duplicate physical P08/GiftUI module candidates and hashes, module
cache path and plugin identity. The fresh diagnostic directory precedes the
retained owners in the commands. `module-cache-hashes.json` inventories the cache
at freeze. **No import-loader trace or binary serialized-body decode was run**:
physical resolution/serialization is a remaining proof prerequisite, not silently
ruled out by the optimized SIL. Provider and consumer source/commands/modules,
macro commands, plugin hash and compiler hash are frozen for that check.

## Partial implementation and compilation

The overlay changes facts collection to explicit `inout` borrows, adds targeted
serialization/inlining on the mapped finite forwarding paths, replaces generated
glyph tuples with private nongeneric byte owners, and uses equivalent pairwise
raster comparisons. Compiler-required visibility amendments stay module-internal;
unchecked constructors are not public/package source capabilities. The declared
14 loans, Optional initialized ownership, scope/lifetime annotations, capacities,
cleanup and mandatory validation are not intentionally changed. These are source
intent statements, **not passed lifetime/private-client acceptance evidence**.

Successful fresh compiler invocations: TextResources, ReferenceTextResources,
SemanticCore, GiftUI, ObservableState, P08 schema/presentation/table/runtime,
macro tool and lower-source; separate optimized provider/consumer SIL emission.
`GiftUILayout` failed with private `@inlinable`/serialization-dependency errors.
Its existing output in the diagnostic directory is copied candidate1 evidence,
not a newly passed output. Other changed owner modules were not rebuilt; the
runtime diagnostic uses their retained candidate1 dependencies. Thus **the whole
source candidate is not compile-qualified**, and no new runnable recipe is
offered. The proposed result-equality work was not completed.

`verify.py` compares **every ordered glyph byte**, glyph dispatch ID and generation
manifest semantic field to pre-correction `b0c057aa`, including empty records:
bitmap1911 and outline13195 bytes. Catalogue files are unchanged. This source
check does not substitute for ABI, memory-layout, lifecycle or cold execution.

## Final-cycle eligibility / stop boundary

Before a reviewer could authorize spending the final cycle, resolve the exact
generated package-method body boundary: identify which physical
`P08CounterPresentation.swiftmodule` the frozen consumer imported and whether
that file serializes `_giftUITraverse` and its evaluate/state-read body closure.
Compare the matching provider's serialized/body attributes, not only the source
spelling. Then identify the smallest checked store/bank/`stopped` helper closure
needed by this concrete instantiation. A proposed source correction must name
that exact boundary and show why it changes client body availability without
adding public unchecked construction or changing compiler/exclusivity policy.
This packet does not select an unproved stronger annotation or new build flag.

Even if that boundary can be corrected, the mapped Text/Raster/action/TLS rows,
private access/lifetime/partial-initialization gates and original host-first
cold/reuse screen still all have to pass. None can be inferred from fixing this
single failed row. Stop here for independent review; no correction2 is launched.

## Reproduction / provenance

Run from the repository root:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-correction1-result/verify.py
```

The verifier reads the archive without executing compiler/application code.
`diagnostics.tar.gz` contains raw logs (original whitespace), exact commands,
partial modules/objects, generated source, optimized SIL, original disassembly
and source snapshots **before formatting**. The owned maintained Swift files
were then formatted; the exact compiled bytes remain archived. No rebuild after
formatting is claimed. Selected relocation files filter `__TEXT,__text` only;
equal numeric offsets in data sections are excluded. The compiler output
directory under `.build/contracts/p08-native-cold-correction1-codegen` is diagnostic,
not a frozen complete receipt or accepted build.
