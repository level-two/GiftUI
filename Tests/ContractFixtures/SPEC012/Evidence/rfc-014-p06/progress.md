# RFC-014 P06 progress

## Step 5 — finite witnesses and scoped fixture repair

Strong C3/R3 diagnosed the Standard handoff as fixture lifetime placement:
FrameRead created outside the workspace callback was captured across that
callback. Constructing it inside the callback from the same live InlineArray
span keeps the borrow lexical. No production change, unsafe annotation, or
weakened negative was needed. The exact handoff route passed after formatting:
`.build/contracts/spec-012-protocol-canvas/tmp1zdctush/macos-static/result.json`.
Counter's two witness cases and Analyzer's indexed read execute; generated
case IDs, payload sizes, absent types, out-of-range lookup and mismatched
payload/ID checks pass. Existing error/store/semantic checks remain green.
The retained failure is `tmpt7qpmsm0/macos-static/CanvasStoreProbe.log`.
Counter remains0/2; final evidence and independent review remain open.

## Strong lifetime-fixture handoff — 2026-10-11

Standard `gpt-6-sol`/`medium` committed fixed error-mapping evidence in
`2fbfad32`. The next finite-table fixture reached a scoped-read lifetime
diagnostic and stopped without production changes. Uncommitted work is
`CanvasTableProbe.swift`, its driver registration and the Analyzer fixture's
package initializer. Preserve this diff; do not restart P06 or repeat passed
checks only because of the model switch.

Reproduction: `scripts/contracts/run-spec-012.sh --profile macos-static
--compiler-baseline rfc-014 --giftui-build
.build/contracts/spec-006-rfc-014/f28bb03491f0640c-ot0b940_/macos-static`.
Failure: `.build/contracts/spec-012-protocol-canvas/tmpt7qpmsm0/macos-static/CanvasStoreProbe.log`.
The compiler reports `read`/`analyzerRead` escaping when values derived from
InlineArray spans are passed through the workspace context closure (probe
lines 77/87 and 105/113 at handoff). Existing production source is unchanged.

Strong `gpt-6-astra`/`high`, C3/R3, owns diagnosis of the lexical borrow and
the smallest approved-contract repair. Inspect the actual source and lifetimes;
do not relax escape controls or fabricate backing annotations. Rerun the exact
focused route after a justified change, record proof/cause, and commit a coherent
passing step before resuming remaining fixed evidence. Contract/scope changes
still return to the maintainer. The prior Standard packet remains the bounded
remaining work list; separate final Strong review is still required.
Counter remains **0 of 2** across handoff; no unproductive repair was attempted.

## Step 3 — bounded semantic transfer, ready for sequential evidence slice

The semantic candidate codec now stages the concrete typed union in the existing
generic payload pool with a pendingCanvas tag. Publication and consumer views
reject pending values. CanvasSemanticTransfer transfers occurrence identities
into staged storage and clears semantic values to markers; partial transfer
failure releases its staged prefix and discards the candidate. Published prior
semantics survive, and the next candidate can reuse the same banks. The generic
payload slot size can increase; final resource evidence must include every
reserved slot in both banks rather than only live Canvas payloads.

After formatting, the native owner route passed **216 assertions** (176 prior
stores plus 40 semantic/actual Layout transfer checks), 5 authored lowering
negatives and 6 compiled negatives. The authored ordinary HStack Body remains
inferred. The semantic fixture exercises a real P03 owner, P04 record store,
P05 borrowed Layout/Render consumers and production Layout. Its final draw uses
the actual scoped invocation adapter with the instrumentation workspace; this
is not yet production geometry/raster evidence. Both staged profiles run the
store matrix; the semantic transfer fixture currently uses Static backing.

Exact validation:

- `scripts/format-swift.sh` completed before the final run.
- `scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014`
  passed 28 checks/120 assertions, 30 traversal, 58 bank and 57 records checks
  per profile. Verified core directory
  `.build/contracts/spec-006-rfc-014/110c46dd2d3f6ca3-7luv6r5o/macos-static`;
  copied receipt [step-3-core-regression.json](step-3-core-regression.json).
- `scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/110c46dd2d3f6ca3-7luv6r5o/macos-static`
  passed. Artifact directory
  `.build/contracts/spec-012-protocol-canvas/tmpcfs5jy8a/macos-static`;
  copied receipt [step-3-macos-static.json](step-3-macos-static.json), including
  source/compiler/macro/artifact hashes and all exact compiler commands.

Failures preserved: `tmpmkoqqz97/macos-static` diagnosed a borrowed copyable
table descriptor captured by the transfer callback; explicit descriptor copy
fixed it. `tmp80xamygc/macos-static` compiled but trapped at semantic assertion12;
an Onone fixture rebuild plus LLDB isolated an incorrect test expectation that
Canvas would flex in HStack. SPEC-007 “Stacks and spacer” transposes the absent
main-axis proposal, and SPEC-012 baseline lines940–941 resolves absent Canvas
axes to zero. Those independent clauses corrected the expected width/origin to
zero; production Layout and its oracles were unchanged. Final optimized run
passed. These were productive narrowed repairs; counter remains **0 of 2**.

### Sequential Standard packet — fixed-rule evidence only

Dispatched after clean Step3 commit `032d827a`: **C2/R2**, Standard
`gpt-6-sol`/`medium`. The bounded assignment adapts enumerated fixtures and
collects fixed evidence under the rules below; it does not own representation,
lifetimes, budget interpretation or package acceptance. No implementation
choices beyond harness plumbing are delegated. Separate Strong review is
mandatory. Counter remains **0/2**; escalation preserves the current diff and
exact failed check rather than restarting this package.

Parent may dispatch Standard `gpt-6-sol` / `medium` after the coherent Step3
commit. No concurrent implementation. Read this receipt, exact Step3 commit,
AGENTS, implementation-executor/deferred-work-curator, SPEC012 amendment and
its baseline, and the current static-canvas design note. Keep P06 open for
separate Strong review. Commit each coherent completed evidence step. Stop and
return ownership/lifetime implementation fixes, unexpected resource excess,
oracle disagreement, or unresolved contract meaning to Strong; do not change
production algorithms, approved constraints, limits or baseline golden vectors.

Fixed work and authority:

1. Extend `RuntimeDerived/CanvasStoreProbe.swift`, `CanvasSemanticProbe.swift`
   and the registered `check-spec-012-protocol-canvas.py` owner route. Exercise
   every generated table case, including Counter EmptyCanvas and Analyzer
   indexed read; dense IDs1...count, ID0/count+1 reject, payload/ID disagreement
   rejects, unknown primitive has no payload, duplicate occurrence rejects,
   exact capacity accepted/first extra rejects, repeated invoke rejects and
   repeated release does not increment. These derive from SPEC012 DR-010 and
   amendment per-type witness/owned-value rules. Test staged copy/escape
   negatives as well as existing source/read negatives. Existing array values
   3/7/3 and sizes5x7/15x21 are fixture inputs, not production-derived oracles.
2. Execute all five AccessFailure-to-DrawingError mappings (amendment): wrong
   owner/schema/stale -> invalidModelAccess; invalid phase -> invalidPhase;
   out-of-bounds -> invalidValue. Execute raw value9 and one-byte production
   enum checks plus `GiftUIDrawingFailureAdapterFixture.fact` mapping to
   invalidIdentity/rendering/activeCycle/contained. The runtime failure adapter
   has the same case but needs only bounded selected evidence, not a new host.
3. Extend semantic transfer coverage to Dynamic staged/semantic backing using
   the same already-tested identity/order/fence assertions. Preserve no
   Canvas value in published semantics. Test empty Canvas, zero occurrences,
   cleanup and fresh retry without adding a P07 coordinator. Existing stores
   cover initial phase/reentry/acquire rejection (caller discard), stale second
   key, path/client error, stroke capacity, layout order mismatch and seal
   failure, each suffix uninvoked and all values released exactly once.
4. Preserve/run `scripts/contracts/check-spec-012-raster-vectors.rb` and its
   `Tests/ContractFixtures/SPEC012/raster-vectors.yaml` Q160 oracle unchanged.
   The Ruby checker alone is not a production pixel check. Add selected
   production geometry/raster fixture execution to the owner route, reusing
   the immutable expected masks/bytes and geometry expectations in
   `Tests/GiftUIRasterCoreTests/RasterStrokeCoverageTests.swift`,
   `Tests/GiftUIDrawingTests/PathConstructionTests.swift`,
   `StrokeSnapshotTests.swift`, `DrawingLifetimeTests.swift` and
   `DrawingWorkspaceFixtures.swift`. RasterStrokeCoverage.rasterize's direct
   API is shown in the golden-mask test at line381. Adapt only harness plumbing
   for the selected compiler/modules; do not derive expected outputs from the
   implementation. Full app/old host closure migration remains P07/P10 scope;
   compilation difficulty is not permission to omit finite P06 oracle checks.
5. Record target ABI size/stride/alignment using constant exported functions
   and LLVM IR under the selected profile flags (see
   `scripts/contracts/check-spec-006-runtime-records.py` for established pattern).
   Include Counter/Analyzer concrete Canvas values, generated unions, witness
   descriptors, staged entries with SemanticRecordReference, metadata, source
   adapter, semantic wrapper and optional wrapper versus old standard payload.
   Report both98-slot banks, unchanged224 scalar slots per bank, and configured
   staged occurrence counts; do not present union enlargement as only live
   payload cost. Inspect selected Embedded artifacts for closure fallback/heap
   dependencies and report actual reachable component limitations. Complete
   application stack/linked resources remain P11 and must not be claimed here.
6. Read platform skills before cross checks. Doctors already passed earlier,
   but rerun if environment changed. For each of macos-dynamic, macos-static,
   raspberry-pi-armv6, nrf52840-embedded run
   `scripts/contracts/run-spec-006.sh --profile <profile> --compiler-baseline rfc-014`,
   then `scripts/contracts/run-spec-012.sh --profile <profile> --compiler-baseline rfc-014 --giftui-build <the verified core directory>`.
   Compiler inputs/macro must match, as enforced by the driver. Native runs
   execute; cross results are compile/ABI/artifact evidence, not board execution.
   Output roots remain `.build/contracts`, `.build/raspberry-pi/contracts`,
   `.build/nrf52840/contracts`. Format before validation; do not run the optional
   global dependency checker that was unverified in P05.

Evidence destination remains this one directory/receipt. Copy final per-profile
result JSON and a small index of paths/hashes; update T10.1 evidence mappings and
the existing static-canvas note as needed. Register any additional focused
checks within the current owner route. Preserve actual failure output and
counter. Do not mark P06 passed. At completion provide parent exact committed
span and separate Strong review packet with scope/limitations/residual findings.

Remaining implementation choices are **not delegated**: any needed ownership
repair, representation/resource-budget change, new generic suppression beyond
approved exact corrections, error-precedence ambiguity, or geometry change.
Current code is a local realization under existing limits; tests/resource
measurements may expose issues requiring Strong. No successor task is started.

## Approved resumption dispatch — 2026-10-11

Eugene approved the precise source-constraint proposal at `67331c11` with
“Approved. Please proceed”. The [approval record](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#scoped-canvas-source-constraint-amendment--2026-10-11)
and updated SPEC-012 resolve the contract blocker; the proof/earlier stop remain
historical. Input tree was clean at `67331c11`. Safe step 1 is `58cf89c7`.

Resume the existing P06 packet below using Strong `gpt-6-astra`/`high`, C3/R3.
Implement only the approved protocol/producer/helper suppressions and their
lifetime-bearing adapter, then the already-scoped staged stores, semantic joins,
runtime/negative/geometry/error/resource checks and four-profile receipts.
Keep all method signatures, bounds, error order and caller cleanup duties.
The concrete adapter lifetime must depend on actual owner and staged backing.
Record exact commands before checks, preserve independent oracles and artifact
identities, format before validation, commit each coherent step and stop at P06.
The prior implementation context/receipt remains the handoff; do not restart
passed work solely due to this approval. Separate Strong exit review remains
required. Counter **0 of 2** is preserved, not reset by resumption.
No successor work or further contract/scope change is authorized.

## Entry and implementation dispatch — 2026-10-11

- Input `a17724b2`, clean tree. P03/P04 prerequisite exits passed; sequential
  P05 exit also passed after separate Strong review `42b5f639`.
- Package: P06 protocol Canvas; SPEC-012 DR-RD-001–004 applicable portions,
  retained DR requirements, owner T10.1. No successor package is authorized here.
- Read AGENTS/implementation-executor and required governance/orientation, the
  bounded sequence/task context, SPEC-012 current checkpoint/matrix and runtime
  amendment with referenced baseline clauses, accepted ADR-035/036/037 and
  retained geometry/raster ADRs, P02 lowering/P03 ownership/P04 banks/P05 borrowed
  Layout/Render receipts and current relevant design notes.
- Allowed footprint: GiftUI Canvas, GiftUIMacros finite witness lowering,
  GiftUIDrawing invocation/plan adapters, both profile staged-value stores,
  directly necessary semantic/consumer joins and corresponding tests/fixtures/
  registered owner driver/build wiring. Update existing traceability/design
  records; do not create a new design-note workstream or alter algorithms.
- Source entry points: `Sources/GiftUI/Canvas.swift`,
  `Sources/GiftUIMacros/FiniteSourceLowering.swift`,
  `Sources/GiftUIDrawing/CanvasPlanProducer.swift`; exemplars
  `Tests/GiftUIDrawingTests/CanvasPlanProducerTests.swift` and
  `DrawingLifetimeTests.swift`, preserved geometry/pixel controls.
- Settled contract: authored Canvas protocol refines View with Never Body;
  finite lowering supplies typed `_giftUIDraw` with a fresh exact-model read;
  ordinary custom Body inference remains. No escaping Canvas closure fallback.
  Stage once per actual occurrence, invoke after Layout in painter order using
  checked local bounds, preserve scoped two-inout withPath and geometry/raster.
  Each acquired staged value/read is discharged exactly once; caller retains
  cleanup duty on rejection before producer acquisition. No staged value reaches
  publication/backend; existing one-shot geometry offer/retry rules remain.
- Expected independent results: zero/multiple/repeated occurrences, exact model
  selection, local dimensions/order, missing witness/wrong-domain/escape/effect
  rejection, all early/binding/draw/plan failures release correctly and suppress
  later invocation; unchanged geometry/pixel oracles. Error addition/mapping and
  one-byte/compact bounds follow the approved amendment exactly.
- Remaining implementation choices: bounded concrete-value/profile store and
  private invocation bridge realization within the contract. Strong may decide
  local realization only; missing authority or contract/scope conflict goes to
  the maintainer before affected work continues.
- C3/R3 → Strong `gpt-6-astra`/`high`. Standard=`gpt-6-sol`/`medium` and
  Economy=`gpt-6-luna`/`medium` only after an exact bounded packet is supplied.
  All execution remains sequential; separate Strong review follows implementation.
- Checks: `scripts/format-swift.sh` before validation; exact focused commands
  recorded before running; preserve/register the SPEC-012 migration owner route
  under `--compiler-baseline rfc-014` for macos-dynamic, macos-static,
  raspberry-pi-armv6 and nrf52840-embedded, using pinned verified inputs. Read
  platform skills first, record source/compiler/artifact identities, actual
  payload/witness layouts and native versus target compile/ABI limitations.
  Keep independent geometry/pixel controls intact. P10 owns the broad gate.
- Commit each coherent completed step and evidence disposition. Mark SPEC-012
  implementing/plan active when implementation begins; leave T10.1 and final
  conformance gates open. Never mark implemented or P06 passed before review.
- Consecutive unproductive repair count **0 of 2**; preserve across handoffs.
  Stop after two same-blocker attempts without a new pass or narrowed cause.
- Result: dispatched; P06 exit pending. No contract/scope issue identified.

## Step 1 — protocol declarations and finite draw lowering

SPEC-012 is now implementing and its plan active. T10.1 remains open. The
Canvas declaration is the compiled fixed-domain protocol; only Canvas receives
the Never leaf/default traversal. Its private bridge constructs a checked
zero-origin Rect. FiniteSourceLowering emits a typed `_giftUIDraw`, preserves
ordinary Body inference, supports scoped two-parameter withPath, and emits
schema-specific drawing access mapping. The approved invalidModelAccess case
and drawing/owner failure mappings are present; runtime mapping execution is
still part of the remaining P06 tests.

Validation after `scripts/format-swift.sh`:

- `scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014`
  passed 28 P02 checks / 120 native assertions, then 30 scoped traversal,
  58 bank and 57 actual-record assertions per profile. Core receipt:
  `.build/contracts/spec-006-rfc-014/d18dacad362b4a35-znvim124/macos-static/result.json`.
- `scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/d18dacad362b4a35-znvim124/macos-static`
  passed the selected declaration/lowering route. Counter and analyzer authored
  Canvas compile; ordinary custom Body remains inferred. Missing authored and
  compiled witnesses, async/effect/inout uses, legacy closure initialization,
  wrong domain, stored read and escaping context all reject for named diagnostics.
  Receipt: `.build/contracts/spec-012-protocol-canvas/tmpouxbcgc3/macos-static/result.json`;
  copied to `step-1-macos-static.json`. The receipt records dirty-source hashes,
  exact compiler/core/commands and object/module identities. This is component
  compile evidence, not invocation/storage or complete application validation.
- Governance and `git diff --check` pass. Pi/nRF toolchain doctors passed after
  reading all four platform toolchain/build skills; cross compilation has not
  yet run for this step. Full four-profile package evidence remains required.

Preserved development failures were each narrowed and repaired: the private
bridge initially passed a failable Rect directly (core run
`ea4421c9d6f286d8-0awfhpu3`); withPath parsing initially accepted only unparenthesized
parameters (`tmpvacp67bz`); the emitted draw method initially lost leading trivia
(`tmpqx0rf08e`). Their logs remain in the named .build run roots. Each correction
advanced the failing stage and the final native route passes. Consecutive
unproductive repair count remains **0/2**.

Remaining P06: finite witness tables, both bounded staged-value stores, actual
scoped exact-model invocation and cleanup, semantic transfer/consumer joins,
full focused runtime/error/layout/resource checks, and four-profile receipts.
The next adapter step exposed a potential exact-protocol constraint conflict:
actual P03 ObservableModelScope is noncopyable/nonescapable while the normative
CanvasInvocationSource and producer Source are implicitly Copyable/Escapable.
No production constraint change is applied. A concrete minimal compile proof
and narrow proposed correction are being prepared for parent/maintainer review.
No P06 exit or acceptance criterion is marked passed.

## Scoped-source contract boundary — 2026-10-11

Safe step 1 committed as `58cf89c7`. The next adapter step is held at the
[exact Source constraint issue](scoped-source-constraint.md). A reproducible
native compiler proof uses the actual P03 owner scope, distinguishes Copyable
and Escapable rejection, and shows only the proposed protocol/generic changes
compiling. The proposal is confined to Evidence; production constraints and
normative specification declarations are unchanged. No static storage,
invocation adapter or semantic join was started under unapproved constraints.

Parent/maintainer decision is required before the proposed exact package API
amendment. This is a current blocker, not deferred work or a new package. All
remaining P06 exit work and separate Strong review remain open. Counter **0/2**.

## Step 2 — scoped source, typed tables and profile storage

Applied only the approved Source protocol/producer/helper suppressions. Finite
lowering now optionally emits the host/schema-owned typed witness table and
concrete payload union; IDs are per concrete type, not occurrence. Both profile
stores lend bounded initialized entries; the adapter's lifetime depends on the
actual P03 model scope and staged-value scope. Reads open freshly per invocation,
end before release, and closed typed errors cross the boundary without `any Error`.
The static table and directly necessary existing forwarding now accept FrameRead.

After formatter, the registered native command
`scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/4a218bc367aa4292-4mpnphal/macos-static`
passes. Latest receipt at `.build/contracts/spec-012-protocol-canvas/tmpm_plhbb9/macos-static/result.json`
records exact source/compiler/module/object identities. It executes **176 native
assertions** across both profile stores using actual P03 backing and generated
Counter Canvas. Independent expected values are A/B/A = 3/7/3, local endpoint
sizes 5×7 and 15×21 (surface origin remains workspace-owned), all releases once,
and two model destructions. Eleven cases include zero occurrences/dimensions,
invalid later identity, client/path/plan failure, invalid layout, early phase/
reentrancy/acquisition rejection, and seal failure. Entering discovery immediately
after invocation proves its read ended. New source copy/escape negatives reject.
The table corpus now includes a second empty Canvas witness; its invocation and
full coverage boundary checks remain part of the next focused test extension.

Development failures and narrowed repairs: `tmp7haws0a2` metadata setter scope;
`tmp7zq88ntb` explicit descriptor copying and lifetime-preserving clone initializer;
`tmpr4gke2_4` driver singleton tuple; `tmpg772le3d` explicit copy of stateless table
into Dynamic lender callback; `tmp88hhj22r` fixture initializer visibility. Final
native checks pass; consecutive unproductive repairs remain **0/2**. No failure
was worked around by a raw lifetime descriptor, escaping callback or weakened
expected result.

Selected modules are listed by the driver. Static model backing is used in both
native cases; full Dynamic coordinator/model-owner adoption, old host wrappers,
complete modules/applications, cross builds, resource certification and P07+
integration are not claimed. P06 still requires semantic payload transfer,
finite coverage/error/boundary extension, retained geometry/pixel controls and
four-profile matched receipts before its independent review.

## Step 4a — fixed drawing error mapping fixture

The registered P06 owner route now compiles the selected drawing failure
adapter and runs 13 independent assertions for all five approved access-error
cases, raw value 9, one-byte enum size/stride, and the four fields of the
invalid-model-access failure fact. This maps SPEC-012's amended failure
requirements to T10.1. The fixture does not change production error semantics.

After `scripts/format-swift.sh`, the exact commands were:

```
scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014
scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/f28bb03491f0640c-ot0b940_/macos-static
```

The core receipt is `.build/contracts/spec-006-rfc-014/f28bb03491f0640c-ot0b940_/macos-static/result.json`;
the P06 report is `.build/contracts/spec-012-protocol-canvas/tmpoaxq75u3/macos-static/result.json`.
The native result says `stores assertions=216 errorMappings=13 failures=0`.
The report includes all selected compile and negative checks passing; its
`source_dirty=true` reflects this pre-commit fixture validation. The pinned
compiler SHA-256 is `d8e40107da0e2c1c59640a983faea326d5d2bddfe81f7609db14bade43c4a5b9`.
The report's core-receipt SHA-256 is
`255a8b48f34f85d2ff6626729dc7ca774e8a9cc594722a2f67102709860e745b`.
This is a partial native mapping check. P06 and T10.1 remain open, and the
consecutive unproductive-repair counter remains **0/2**.
