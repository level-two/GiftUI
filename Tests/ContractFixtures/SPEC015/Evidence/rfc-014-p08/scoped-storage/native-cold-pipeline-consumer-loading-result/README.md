# Consumer loading diagnostic and next observer recipe — 2026-10-17

**The single consumer replay passed.** This repairs the optional diagnostic flag
conflict from [e4f130df's replay](../native-cold-pipeline-module-resolution-diagnostic-replay/README.md).
Only `-Xfrontend -emit-loaded-module-trace-path -Xfrontend <path>` was removed;
outputs were redirected. Source snapshots, pinned compiler/plugin, target/SDK,
all ordered imports, original cache and optimization/lifetime flags were retained.
`-Rmodule-loading`, `-Rmacro-loading` and `-Rmodule-serialization` stayed enabled.
No provider replay, maintained source change, policy change, runtime or corrective2
occurred. Corrective accounting remains **1/2**; P08 stays open.

## Established observations

The consumer finished in18.243112 seconds, exit0. Its loading remarks identify
the fresh frozen `P08CounterPresentation`, `P08CounterSchema`, `GiftUI`,
`GiftUISemanticCore` and `GiftUIObservableState` modules in the first diagnostic
import directory. Physical loaded-file hashes match the frozen inventory.
The presentation module is `aa24dafcd48c8dc1079bae766633e723f980767af04240b7f11bd4b125e71439`,
also identical to the preceding successful provider output. Duplicate retained
modules elsewhere in the search path do not explain **this replay**.

The preceding provider's actual macro expansion contains `@inlinable` and
`@inline(__always)` on `_giftUITraverse` and the state-declaration visitor.
The fresh consumer optimized SIL retains the generic traversal `apply` in the
actual `CounterPipelineOwner.beginObservableCandidateAndExpandSemantics` as well
as the common semantic probe. The original object's host call at `0x54874`
remains the instruction evidence; this replay emitted SIL, not a new object.

These diagnostics do **not** identify whether the physical module lacks a
serialized function body, deserialization did not request/provide it, or an
earlier optimizer stage had a body but did not specialize/use it. A declaration
in final optimized SIL cannot distinguish those cases. No Swift defect,
recursive-specialization impossibility or supported final source repair is
claimed. The old result's partial-module qualification remains applicable.
The original three-file cache is byte-identical before/after; all29 loaded module
identities, commands, source hashes, logs and final SIL are in the frozen packet.

## Exact next source-unchanged diagnostic

The pinned binary inventory has no `sil-opt`, `swift-sil-opt`,
`sil-func-extractor` or `llvm-bcanalyzer` executable. No direct physical-module
body-decoding command has been established. A local observational route **is**
available: a help-only query of the pinned frontend confirms
`-Xllvm -sil-print-all`, `-Xllvm -sil-print-functions=<substring>` and
`-Xllvm -sil-print-pass-name`. Binary inspection also identifies the
`performance-linker` pass as deserializing referenced SIL functions. This does
not change optimization policy.

The [exact next argv](next-observer-command.json) adds those three observers to
the successful consumer command, filtered to `0B6ScreenV15_giftUITraverse`, with
a new output directory. One replay is authorized for sequential mechanical
execution, **not run in this packet**:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-consumer-loading-result/run-next-observer.py
```

The runner verifies compiler, SDK, plugin, all archived source inputs, physical
loaded modules and original cache before execution. It refuses an existing output
directory, captures raw untruncated stdout/stderr and cache inventories, and never
retries or changes flags. It creates only diagnostic outputs. No workload runs.

- A basic-block body observed at an intermediate pass proves body availability
  **at that stage**, defeating a claim of complete body absence. Its last observed
  stage and concrete generic substitutions can then guide a precise checked
  source repair or optimizer explanation. It does not prove cold zero heap.
- No body in the filtered trace does **not** prove the physical file lacks one.
  Record which linker/optimizer passes ran and stop. Direct serialized-body
  inspection or a deserializer reason for this exact symbol is then the remaining
  tooling/compiler prerequisite. Do not spend corrective2 on a stronger-annotation
  guess or begin a compiler-policy campaign.
- Any diagnostic/compiler/cache qualification failure stops that replay without
  fallback. Neither a successful compiler exit nor a trace closes the mapped
  Text/Raster/action/TLS, lifetime/private-client or actual cold/reuse gates.

## Offline verification

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-consumer-loading-result/verify.py
```

`diagnostic.tar.gz` retains raw logs/whitespace, commands, source-hash preflight,
consumer SIL/module, previous provider expansion/module and help/tool inventory.
The help query without a frontend action exited1; the help-only `/dev/null`
query exited0 and printed option help, with no consumer inputs or new source.
The five external edits and pycache remain untouched. This packet selects no
source repair and claims no additional corrective cycle or acceptance.
