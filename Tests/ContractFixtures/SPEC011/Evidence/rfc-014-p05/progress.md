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
