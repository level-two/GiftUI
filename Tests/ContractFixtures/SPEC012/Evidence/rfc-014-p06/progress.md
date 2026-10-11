# RFC-014 P06 progress

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
