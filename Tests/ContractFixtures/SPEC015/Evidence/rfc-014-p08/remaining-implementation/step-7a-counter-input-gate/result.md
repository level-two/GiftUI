# P08 step7a — actual target-local input gate

2026-10-12, sequential Strong Sol6.1 High. PASS **3,687 assertions /23controls**.
Command: `python3 scripts/contracts/check-spec-015-counter.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static`.
Final receipt: `.build/contracts/p08-counter-vs_qqlzj/result.json`. All input and
artifact hashes reverified. Formatter/lint, governance and diff checks pass.
No Swift repair; guard0/2, historical guards preserved.

CounterControl physically owns exactly one existing HostNormalizedInputGate.
Every gesture in both actual scoped host corpora is now physical down/up submitted
through this gate into the coordinator's same admission controller. Generated
sequence, ordinal and presentation revisions are checked independently. Wrong
source, stale presentation and malformed input each reject before admission and
leave the actual queue empty. Existing full text/action/disabled/stroke corpus passes.
Accepted interaction commits install the accepted presentation revision. Host
termination quiesces the gate, including partial activation; both repeated teardown
and post-teardown input reject without queued facts or pointers. The complete
live CounterControl charge includes gate storage automatically via MemoryLayout.

The gate and admission controller occupy disjoint fields in the stable enclosing
allocation, retained for the scoped host and callbacks. Callback submission remains
synchronous, uses the same controller/context, and owns no model/ticket alias.
This closes gate/coordinator/lifecycle wiring at the current recording endpoint
boundary. Acceptance is not yet physical display evidence: actual endpoint/health,
raster pixel, wake and live graph joins remain required, followed by registered
four routes and early linked target RAM/stack/allocator/ABI evidence. No P08 exit
or implemented transition is claimed.
