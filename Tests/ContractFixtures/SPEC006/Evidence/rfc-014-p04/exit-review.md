# RFC-014 P04 independent exit review

**Recommendation: PASS for the finite P04 package exit.** No blocking finding
was identified. This does not pass SPEC-006 T10.1, any complete DV-RD criterion,
production adoption, or an `implemented` transition. The parent owns package
disposition; this review changes no plan or contract.

## Reviewed state and authority

- Review date: 2026-10-11; separate Strong review under the dispatch in
  [progress.md](progress.md), committed `433ef64c`.
- Implementation: `3a6927c4..593e2cf9`; the four final builds identify clean
  compiled source `7be2c8374690faa87d8a252031f614597e249f26`. The tree was clean
  when review began. Later commits in that range record evidence, not new
  compiled source.
- Authority: accepted ADR-035/036; approved SPEC-006 runtime amendment and
  retained traversal/counting/identity requirements; the explicitly approved
  scoped visitor correction; SPEC-013/015 physical-bound amendments. The
  current SPEC-006 owner checkpoint/matrix and RFC-014 P04 package row define
  the reviewed delivery boundary. The runtime-bank design note is explanatory.
- Lifecycle: SPEC-006 is implementing, its plan active. ITERATION-003 I3-04
  requires actual runtime derivation for analyzer/counter; the closed MVP's
  common declarative presentation, State, actions and four configurations
  supply regression constraints. Historical completed boxes and experimental
  results were not treated as current conformance.
- Implementation-executor, conformance-reviewer and lifecycle-reviewer role
  instructions were read. This is a package review receipt, not the final
  all-criteria conformance report in `docs/conformance/`.

## Findings and invariant assessment

**Blocking findings: none.** No contract/scope decision, repair or new deferred
work is requested. The following records the inspected evidence and its limits.

| P04 obligation | Review result and exact source locations |
| --- | --- |
| Actual declarations produce topology | PASS. `SemanticRecordExpansion.swift:47–96` translates the existing visitor's path entries; `GiftUISemanticCore.swift:1228–1279` emits one record at each encountered declaration role. No new occurrence table, stored expanded tree or second traversal was introduced. `ScopedTraversalProbe.swift:248–284` independently expects nested-State counts and 3→5→3 branch topology, scalar values and once-only body counts. This supports the P04 portion of DV-RD-002 and DV-003/015. |
| Exact identity algebra | PASS. `SemanticRuntimeRecords.swift:24–30,47–65` validates component fields and compares length plus every complete component; `:205–250` appends initialized parent-first prefixes and rejects malformed/duplicate children. `SemanticRecordStore.swift:236–269` reconstructs complete role-ended paths and compares complete keys. `SemanticRecordExpansion.swift:71–93` preserves body, fixed-child, branch, optional and concrete-role components. The role codec must assign stable distinct finite roles; unknown roles refuse. Neither hash values nor bank-local indices establish equality. |
| Bounded paired matching | PASS. `SemanticRuntimeRecords.swift:330–365` only searches children of the already-matched published parent. A missing parent match prevents descendant matches; every compared component includes kind, ordinal, role and modifier. Each of N prefixes performs at most K comparisons; insertion also scans only the bounded sibling list. No all-pairs path comparison exists in this route. `RecordBankProbe.swift:162–183` independently expects 22 comparisons for 12 prefixes at fanout five, below N×K=60. |
| Actual backing and scoped lifetimes | PASS by source/negative evidence. `SemanticRecordStore.swift:15–56` validates typed extents, nests borrows of the actual five backing regions and slices disjoint banks. The store/view initializers at `:69–78,188–197` are fileprivate; an Escapable callback result prevents returning the borrowed view. The pointer descriptor is not the lifetime proof. Static lends initialized spans (`StaticSemanticRecordStorage.swift:14–23`); Dynamic retains exact configured arrays and guards reentry (`DynamicSemanticRecordStorage.swift:15–46`). The four final builds reject the exact non-Escapable-result diagnostic. |
| Bank publication, retirement and reuse | PASS. `SemanticRecordStore.swift:93–112` chooses only an idle unread bank and refuses revision wrap. `:114–141` retires a borrowed discarded candidate or prior publication; `:155–168` returns it to idle only after the last reader ends, including thrown callbacks. Checked references require owner, bank, revision and initialized ordinal (`:217–222`). `RecordBankProbe.swift:52–93` exercises an old reader across publication, refusal while both banks are occupied, last-reader reuse, stale-reference rejection and independently copied complete keys. Actual committed Interaction routing is P05, not established here. |
| Payload ownership and atomic failure | PASS for the finite standard codec. `SemanticRuntimeRecords.swift:293–327` checks slot, scalar and byte capacity before storing an owned value or mutating its record; successful slot count advances after the non-failing copy. `:192–197` clears every acquired typed optional slot and retains revision. `SemanticRecordExpansion.swift:183–200` clears the complete failed traversal candidate, while published storage is disjoint. Standard payload cases are owned scalar/style/layout/action values (`SemanticStandardPayload.swift:5–20`); no declaration, model or closure is retained. The reviewed clear/retire paths avoid clearing under a live reader. Canvas's acquired callable lifetime remains P06. |
| First-excess pool coverage | PASS for the package boundary. `RecordBankProbe.swift:100–132` covers exact-at-limit and first excess for record count, prefix count, component depth, payload slots, scalar slots and payload bytes, preserving previous publication and reusability. `:144–149` separately covers fanout. These primitive fixtures explicitly call discard after failure; they do not alone prove automatic traversal cleanup. That cleanup is present in the production wrapper at `SemanticRecordExpansion.swift:195–200`, and the actual unknown-role failure checks preserved publication at `ScopedTraversalProbe.swift:317–320`. Broad coincident-failure/counting regression remains P10. |
| Finite codec completeness and modifier/action order | PASS within P04's vocabulary. `SemanticStandardPayload.swift:36–48,104–135` covers the existing stack/spacer/layout/style/disabled/action payloads by exact generic type equality before copying. Text uses admitted UTF-8 and bounded 96-scalar scratch (`:49–100`); `BoundedText.swift:29,52–71` proves that bound. The invalid-text sentinel preserves downstream validation. Unsupported codecs refuse; Canvas is explicitly P06. `GiftUISemanticCore.swift:1199–1225` emits modifiers inner-to-outer with source-call indices, while `:1172–1196` stages action before label. The fixture independently checks payload order, modifier indices, payload-independent identity and action-before-child. |
| State binding and read order | PASS. `ObservableSemanticBodyBinding.swift:47–56` binds the transient declaration before the body reservation and scoped read. Returning the owned Body ends `models.withRead` before `GiftUISemanticCore.swift:991–1002` recursively traverses it. Semantic, binding and access failures stop later work and retain separate result routes (`GiftUISemanticCore.swift:900–906,1388–1399`). The generated nested-State fixture succeeds without retaining the parent read, suppresses body/counts on binding failure, and suppresses a later sibling after access failure. Repeated exact State keys preserve model/seed meaning after semantic bank reuse. |
| Prefix/payload envelope and physical costs | PASS as component evidence. The implementation keeps depth 34 and logical ceilings 126 records, 48 semantic nodes, 14 bodies, 50 modifiers and six actions. At most one role plus two incoming boundary components per declaration gives 378 prefixes; at most nodes+modifiers gives 98 payload slots, with 224 independently bounded text scalars. Both are conservative finite derivations, not measured application peaks. Actual fixture peaks are 5 records, 11 prefixes, 3 payloads, 2 scalars, depth 9 and 100 payload bytes. All four target layouts report 29,832 reserved bytes for the configured two banks; complete keys are 206 bytes. P08/P09 must validate actual application vocabulary/workload before adoption, and P11 must account for complete storage/stack/IRQ/allocator costs. |

Paths in the table are under `Sources/GiftUISemanticCore/`, except the named
Observable State/profile files and `Tests/ContractFixtures/SPEC006/RuntimeRecords/`
fixtures. Line references describe the frozen reviewed source.

## Evidence applicability and checks

The [final profile snapshots](final-profile-receipts.json) were independently
verified against their saved receipts, current source/recipe inputs, compiler
binaries and every listed generated artifact. All **646 hash/size entries**
matched; embedded snapshot objects also equaled their saved JSON receipts.
The read-only verification is reproducible from the repository root:

```sh
python3 Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p04/verify-review-receipts.py
git diff --check 3a6927c4..593e2cf9
git diff --check
```

All three checks passed. The review inspected the dispatch-to-head source diff,
the canonical baseline traversal/identity rules, the independently authored
fixture expectations and the exact recorded command arrays. No production
source was changed, no full route was rerun and no connected device was used.

| Route | Reused result | What it establishes |
| --- | --- | --- |
| macOS Static | 120 P02 assertions; 30 scoped checks; 58 bank checks; 57 Static + 57 Dynamic actual-record checks, all passing | Native execution of the selected components and both record storage adapters, plus negative lifetime compilation and layouts. The model owner in both cases is the P03 Static owner. |
| macOS Dynamic | Same passing counts | Second configured native compiler route with the same explicit component scope. |
| Raspberry Pi ARMv6 | Passing selected-component compilation, ARMv6/VFP ABI, negative lifetime compilation and layouts | Cross-build evidence only; no target execution, full image or connected measurement. |
| nRF52840 Embedded | Passing selected-component compilation, v7E-M/VFP-register ABI, negative lifetime compilation and layouts | Embedded cross-build evidence only; no board execution, allocation certification or complete image fit. |

The reviewer did not infer whole-module compilation or broad baseline regression
from a selected-file driver. Existing whole-module callers remain scheduled
migration inputs. P02's fresh receipts accompany the P04 builds; P03's already
passed owner boundary supplies the dependency, rather than a new ownership
implementation being claimed here. Source inspection supports the unchanged
canonical traversal rules; the complete baseline corpus still needs fresh P10
applicability/dispositions. Passing implementation-authored fixtures alone was
not used to decide identity or lifetime correctness.

## Remaining gates and handoff

P04's output is suitable for the next dependency-gated package. The following
remain explicitly unpassed under the existing sequence:

- P05: borrowed Layout projection, consumer equivalence, independently owned
  candidate/committed Interaction keys and accepted/refused-offer routing.
- P06/P07: finite Canvas ownership/cleanup and coordinated semantic/State/action
  publication and failure ordering.
- P08/P09: schema/workload validation and both real application vocabularies,
  full traversal peaks and host/profile integration.
- P10/P11/P12: broad four-configuration regression, complete allocation and
  physical/stack/IRQ/connected evidence, adoption/cutover and owner conformance
  dispositions. The 29,832-byte subtotal excludes model owner storage, Dynamic
  headers/allocator overhead, descriptors, Interaction key pools, 384-byte text
  scratch and complete recursive/body-return stack costs; none is counted as zero.

These are existing successor obligations, not new exceptions or hidden P04
repairs. No requirement or capacity was waived. The consecutive unproductive
repair count remains **0 of 2**. Parent may record P04 passed; the owner matrix
and SPEC-006 T10.1 must remain open.
