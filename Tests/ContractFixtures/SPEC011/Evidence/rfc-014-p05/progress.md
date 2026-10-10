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

## Step 2 — owned Interaction keys and target bridge

Interaction owns complete inline identity values in distinct candidate and
committed typed stores. Logical component usage is independently limited per
candidate/committed pool; first excess poisons the candidate without publishing
partial routing. Exact equality/generation, hit testing and offer disposition
algorithms remain the existing implementations. The unchanged accepted-offer
resolution is factored from the coordinator for selected-component compilation.

SPEC-013 runtime amendment “Limits, ownership and storage” requires separate
candidate/committed key pools and permits finite typed side pools; it does not
require separate heap allocations. The realization uses inline key regions:
three candidate copies per slot (candidate record, prepared committed record,
hit map), two committed copies (record, hit map). Every physical copy must be
counted in the P05 layout evidence and later audit, with record bytes excluding
key regions. These six-slot fixture capacities are not a production preset or
fit claim. SPEC-015 requires actual immutable workload equality and complete
audit at production adoption; P07/P09/P10 retain those integration obligations.

The package host bridge validates action domain/code and publishable P03 target
generation before staging. Dispatch uses the current target registration and
P03 checked mutation authority. Its narrow operation-thunk overload admits the
mutation phase before lowering an action, avoiding user work during rejected
access. It preserves typed preflight/commit/reporting and the authored handler
contract; no P07 coordinator is introduced. Parent confirmed this lies within
the named P05 host target bridge, subject to independent review.

After formatting, registered command:
`scripts/contracts/run-spec-011.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/a1acc9ca8fb45d5e-830jmqh3/macos-static`
passes **199 P05 assertions and 183 P03 root regressions**. See
[exact receipt](step-2-interaction-receipt.json). Expected outcomes derive from
SPEC-011 generation/offer rules and SPEC-010 registration/retirement: twelve
semantic publications including ten refused offers retain old routing, restored
complete keys preserve generation, changed keys/action/target/enabled state need
new generation, exact component bounds admit and first excess rejects atomically,
stale releases/retired targets cancel before operation execution. Model replacement
refusal retains the old target; independent model retention cannot preserve a
removed registration target. These are selected-owner fixtures, not complete
coordinator/application or broad conformance evidence.

Failed checks: [borrow-check diagnostic](step-2-borrow-check-failure.log) narrowed
to Swift consuming borrowed self through boolean autoclosures; copying scalar
limits/counts to locals passes. [Fixture diagnostic](step-2-fixture-typed-throws-failure.log)
needed an explicit ObservableStateError annotation on a nested closure. Both
corrections passed the subsequent owner route; consecutive unproductive repairs
remain **0 of 2**. Four-profile receipts and broader Layout oracle evidence remain
pending before independent Strong exit review.

## Step 3 — broader oracle and physical key evidence

Fresh native Dynamic and Static owner routes agree at **196 Layout assertions**
and **215 Interaction assertions**, plus **183 P03 root regressions**. Layout now
also compiles full RenderLowering. The declaration path selects actual Dynamic
semantic backing under the Dynamic flag; Interaction selects actual Dynamic
or Static table adapters. [Layout receipt](step-3-layout-receipt.json) and
[physical key receipt](step-3-key-layout-receipt.json) are intermediate evidence;
clean-revision four-profile exit receipts follow.

The new hand-seeded canonical-bank oracle fixture isolates the borrowed adapter;
it is not a substitute for actual declaration traversal (the first fixture
continues to exercise that). Expectations are fixed from the retained
LayoutStackTests/LayoutTextTests and SPEC-007 rules: early spacer remainder,
minimum overflow, stack clipping/capping, horizontal and overlay behavior,
empty stack, wrapping/newlines/empty text, padding/insets/fixed/flexible frames,
and disabled passthrough. Exact depth13 and scopes98 pass, configured12/97 fail
before sink publication. Malformed child lookup releases workspace and bank
borrow. Invalid action domains and codes are rejected in established precedence;
key-pool excess leaves a prior accepted revision and capture usable.

The IR layout fixture measures every retained table-key copy: six slots times
three candidate and two committed regions. On native arm64 the exact owned key
stride is206, candidate key regions3708 bytes, committed2472, and complete Static
state7108 (928 remaining control/non-key/padding bytes). Dynamic slot strides
are also reported without assuming Array allocator overhead. Execution's external
pointer capture is212 bytes and owns another206-byte key; it is outside the
Interaction state total and must be counted by its actual coordinator owner.
Transient argument/return copies, Dynamic allocator overhead and call-stack
high-water remain explicit P07/P11 host audit obligations. No zero-allocation,
whole-host resource-fit or production-workload claim is made by this fixture.

Failed checks retained: [optional insets/unsupported alignment fixture spelling](step-3-modifier-fixture-failure.log),
then [unsupported trailing spelling](step-3-alignment-fixture-failure.log).
Existing supported center/bottom alignment replaced the uncontracted fixture
case before execution; its explicit zero-child origin is(4,6). No implementation
or contract changed. Governance passed authority graph191nodes/1939edges but
reported the six new step1/2 P05 files unreferenced in SPEC-011 task-evidence.yaml;
T12.1 now links shared artifacts without claiming completion. SPEC-007 has no
separate task-evidence YAML; its T9.1 plan and conformance share this receipt.
All narrowed corrections subsequently pass; unproductive repairs remain0/2.
