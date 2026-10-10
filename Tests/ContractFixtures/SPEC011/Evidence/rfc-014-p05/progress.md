# RFC-014 P05 progress

## Entry and implementation dispatch — 2026-10-11

- Input `2aa5c7cc`, clean working tree. P04 passed at its finite package boundary
  after independent Strong review `037607c7`; P01–P04 prerequisites are satisfied.
- Package: P05 Layout and committed action keys. Governing criteria:
  SPEC-007 LY-RD-001–002 / owner T9.1 and SPEC-011 IN-RD-001–002 / owner T12.1,
  with applicable retained baseline criteria. No successor package is in scope.
- Authority/context: read the bounded sequence/task context guide, both owner
  checkpoints and matrices, both runtime amendments and referenced baseline
  clauses, accepted ADR-032/033/035/036, applicable dependencies and the P04
  receipt/design note. Required repository/role orientation remains in force.
- Allowed files/output: Semantic Core Layout projection, narrow Layout/Render
  consumer joins, GiftUIInteraction candidate/committed storage, runtime-composed
  target bridge, corresponding fixtures/tests/owner drivers and narrow build
  wiring; existing owner implementation/conformance/traceability records.
- Source entry points: `SemanticLayoutView.swift`, `SemanticRecordStore.swift`,
  `SemanticRecordExpansion.swift`, `InteractionStorage.swift`; follow the existing
  Layout producer, Interaction candidate/commit/dispatch and profile adapters.
  Exemplars: `SemanticLayoutViewTests.swift`,
  `InteractionCandidateAppendTests.swift`, and the independent baseline oracles.
- Settled rules: Layout borrows one immutable bank/revision without model access
  or another graph; geometry remains owned. Interaction copies complete bounded
  keys before append returns, independently of semantic bank reuse. Semantic
  publication never commits routing; only accepted offer does. Stale registration
  targets do not resolve to replacement models. Existing scope/depth/generation,
  failure and geometry contracts remain unchanged.
- Independently expected results: unchanged Layout/oracle geometry and limits;
  every failure ends acquired borrows and preserves publication; committed keys
  remain valid through repeated bank reuse and refused offers; changed exact
  path/role/modifier/target/action follows existing generation rules; key-pool
  excess atomically aborts the candidate; stale target/releases cancel dispatch.
- Remaining implementation choices: internal scoped adapter realization and
  bounded key storage within approved contracts. Strong resolves only local
  implementation choices; contract/scope decisions return to the maintainer.
- C2/R3 → Strong `gpt-6-astra` / `high` for lifetime and action-routing risk.
  Standard=`gpt-6-sol`/`medium`, Economy=`gpt-6-luna`/`medium` if a later exact
  bounded handoff is useful. Execution is sequential; no concurrent assignments.
- Required checks: format maintained Swift with `scripts/format-swift.sh` before
  validation; record exact focused commands before execution; migrate/register
  the SPEC-007/011 owner routes under `--compiler-baseline rfc-014` as required
  for `macos-dynamic`, `macos-static`, `raspberry-pi-armv6` and
  `nrf52840-embedded` without weakening historical checks. Read platform skills
  before cross builds. Preserve artifact/compiler/input identities and separate
  native execution from cross-build evidence. P10 retains the broad gate.
- Commit each coherent completed step with its evidence disposition; mark Specs
  implementing/plans active when implementation begins, never implemented.
  A separate Strong review is required before the P05 package can pass.
- Consecutive unproductive repair count: **0 of 2**. Stop after two attempts on
  the same blocker without a new passing check or narrowed cause; preserve the
  count across all handoffs. No scope/contract change has been identified.
- Result: implementation dispatched; P05 exit pending.

## Step 1 — borrowed Layout/Render projection

SPEC-007/011 are now implementing and owner plans active; both owner reports
link this single receipt and retain P10–P12 obligations. This work is required
by ITERATION-003 I3-04/05 runtime-derived analyzer/counter delivery; the closed
MVP's stack/layout/interaction behavior remains the regression oracle.

Semantic Core lends nonescapable Layout and Render projections of the exact P04
bank/owner/revision. Layout generics propagate the lifetime suppression; query
signatures, engine algorithms, geometry and limits are unchanged. Each modifier
record is one scoped wrapper; transparent declarations add no layout scope.
Render skips structural records using existing links and retains no second graph.
The original declaration-result staging extensions are separated into existing
owner files; they remain historical migration inputs, excluded from the selected
component compile rather than supplied with compatibility shims. Full module
adoption stays in its later owner packages.

Command after completed `scripts/format-swift.sh`:
` scripts/contracts/run-spec-007.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/a1acc9ca8fb45d5e-830jmqh3/macos-static `
passes 152 runtime assertions and two expected compiler escape rejections.
[Exact receipt](step-1-layout-receipt.json) records compiler, source/input hashes,
commands and artifacts; raw output lives at its corresponding `.build` path.
Full GiftUILayout compiles with selected SemanticCore/P03 profile components.
This is not a full application, all-baseline-fixture, cross-target, resource-fit
or full RenderLowering execution result. Broader P05 geometry/oracle and failure
coverage and four-route receipts remain pending, before separate exit review.

Independent expected values come from SPEC007's fixed100-under-parent50 and
padding2 rules, not production output. Actual declarations expand to three
layout scopes; first-excess scope/depth checks, invalid declaration, sink begin,
stage and publish refusal preserve publication. The fixture repeatedly reuses
banks, rejects stale references, and verifies Render/Layout identity joins.

Failed checks retained: [fixture witness label](step-1-fixture-label-failure.log)
used `identity:` rather than the exact `structuralIdentity:` requirement; its
correction passed compilation. The next check correctly rejected Array escape
but its matcher omitted the word `protocol` in the actual diagnostic; fixing
that diagnostic spelling produced the required two negative passes. No production
repair, oracle change or contract decision occurred. Consecutive unproductive
repairs remain **0 of 2**. P05 exit is pending.
