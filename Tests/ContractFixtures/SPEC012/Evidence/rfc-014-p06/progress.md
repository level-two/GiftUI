# RFC-014 P06 progress

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
