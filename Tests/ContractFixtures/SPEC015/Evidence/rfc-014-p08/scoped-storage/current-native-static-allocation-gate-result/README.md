# Compiler-enforced P08 allocation gate

The enforcement mechanism works; the **current product gate fails**. The [independent review](final-review.md) accepts this finite enforcement mechanism. This is a diagnostic result, not allocation-safety acceptance.

Run the maintained compile-only check from the repository root, under the existing external bounded process guard:

```sh
python3 scripts/contracts/check-spec-015-counter-allocation.py \
  --counter-build .build/contracts/p08-counter-8erdhh4s
```

The check authenticates the accepted Native recipe and reused compiler, module, source and prerequisite identities. It freshly compiles the exact 42-source Counter module with `-experimental-performance-annotations -D GIFTUI_COUNTER_ALLOCATION_GATE`. The actual existing `p08CounterStaticResourceEntryV1` definition carries the conditional `@_noAllocation`; no warmup wrapper or source overlay is used. Fresh Counter source edits are recorded as explicit baseline/current deltas, without transferring the baseline's functional PASS. Changed reused dependencies are rejected. This first gate has no replacement-prerequisite arguments; it is limited to the authenticated dependency set and does not support arbitrary library migration edits before a new matching provenance set exists.

The harmless positive compiles. The escaping-class negative is rejected by the allocation diagnostic. A stale imported Semantic Core input is refused before any compiler command. The real entry then exits nonzero at this chain:

`p08CounterStaticResourceEntryV1` → `p08CounterGraph` → `p08CheckGraphDefinition` → `HostComponentGraphValidation.validate(CounterHostGraph())` at `CounterScopedStorage.swift:3070`.

The complete [diagnostic](actual-static-entry.stderr) says generic function calls can cause metadata allocation or locks. This is a compiler rejection of the promise, not observed allocation or locking. Later entry paths remain unqualified; no global provider, foreign-code, stack, timing, resource, no-lock or P08 conclusion follows. P09 remains dependent on P08 exit.

[Current results](maintained-result.json), [classification](result.json), [source identities](source-freeze.json), and [exact preservation map](preservation.json) retain the commands and raw diagnostics. The initial isolated assessment and first maintained precompiler provenance stop remain preserved. The single correction requires the exact owning artifact hash for generated imported source. No missing-hash fallback, suppression, product source remedy, full suite, runtime, live process, hardware action or download occurred.

Removing only the three conditional annotation lines reproduces the accepted ordinary entry source hash exactly. The formatter and lint passed without modifying unrelated maintained Swift. The ordinary functional suite was not rerun and no new functional PASS is claimed. Raw build/cache/module files and the accepted prerequisite receipts named by these records remain local `.build`/`.toolchains` reproducibility dependencies; binary corpora are not copied into this packet.
