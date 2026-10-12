# P08 step 3 — actual finite State, semantic and Canvas owners

2026-10-12; Strong Sol6.1 High, sequential. PASS **804 assertions**:92model
controls plus712actual owner/semantic controls on Static and Dynamic. The real
CounterScreen State is materialized through maintained root adapters, read and
expanded for each0–9 value into actual two-bank storage; exact title/digit text,
actions0/1, disabled boundaries and one generated Canvas capture are inspected.
Every candidate capture is explicitly transferred and released once. Actual
root storage proves2scalar slots/4tickets/2pins/0capture banks. Nonzero scalar
replacement seed3 succeeds after the explicit-final-ticket API's independently
retained cache claim is released; former keys fail and new scoped read returns3.
This is not a blanket claim that independent scalar backing always needs old
backing reclamation: it tests the chosen existing final-ticket-transfer API.

`CounterOwnedModel.isEmptyReplacement` is true for every finite scalar value:
this shared replacement witness describes populated capture backing, and counter
has none. SPEC010's Analyzer replacement transaction expressly states counter
scalar slots are independent; SPEC015's approved amendment selects0capture banks
and separately requires final-ticket transfer or refusal under SPEC010. No new
value0 emptiness rule is imposed. The initial Cycle-model false sentinel was
corrected; an intermediate value0-only interpretation was rejected before commit.

The first field spelling compile error was narrowed to `firstTextScalar`.
Diagnostic executions then narrowed an identity lookup: maintained
`visitStatefulCustomView` calls `beginBody`/`enterCustomBody` before State binding,
so the owning target identity is declaration identity plus customBody. The oracle
now derives that from the traversal rule (also the P07 bridge's existing rule),
not emitted path counts. All ten values passed before replacement correction.
Raw diagnostic outputs remain `.build/contracts/p08-counter-{urr2b6s2,51hdo83a,
6mz2c7iv,uiw7g75u,l6qyftxf,w59dh9tu,wd5klg7u}`. No same-blocker unproductive
repair occurred; guard0/2. Frozen final result is
`.build/contracts/p08-counter-jvrh8z0z/result.json`, all hashes reverified.

Command: `python3 scripts/contracts/check-spec-015-counter.py --runtime-build
.build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static`.
Format lint, governance and diff checks also pass. Full layout/drawing/render,
interaction/coordinator, nine-stage actual host report/audits and four routes /
early linked images remain open; this is no package self-acceptance.
