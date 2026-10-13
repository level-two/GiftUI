# SPIKE-075 final result — 2026-10-13

**Bounded native return control: PASS. Experiment work closed.** Sequential
Strong exit review (Sol 6.1 High) accepted the saved diagnostics. No successor
experiment is proposed or authorized by this report.

| Evidence | Result |
| --- | --- |
| Original native shadow declarations and owned/scoped positive client | PASS, run-1 |
| Isolated scoped copying rejection after authorized helper correction | PASS, run-2 |
| Return wrapped state from five caller-owned spans | PASS: exit 0, empty diagnostics, run-3 |
| Return wrapped state whose candidate bank depends on function-local bank0 | PASS: rejected at the return, explicitly naming bank0 as the lifetime dependency, run-3 |

The final [negative diagnostic](evidence/run-3/negative.stderr) identifies the
local variable and its escaping use rather than an annotation or conformance
error. The positive establishes that the return shape itself is usable. This
supports the selected state/lifetime design at this native language boundary.
It does not prove every bank independently, mutable common-session exchange or
the complete host/retirement chain. The accepted lexical-block control from
run-2 remains inconclusive and is not reclassified as unsafe behavior.

## Scope and provenance

- Scope commit: `c2c824a8`; reviewed fixtures: `80f772ab`; raw evidence: `70fdbffd`.
- [Final receipt](evidence/run-3/receipt.json): two object compilations, one
  identity query, 0.381 seconds under the pinned native Swift 6.4 configuration.
- Cumulative: seven experiments, three identity queries, one earlier authorized
  helper correction and zero new repair rounds. Historical production budgets
  and stop counts are unchanged.
- Strong review verified 62 hashes across reused inputs and final evidence;
  commands changed only the control source/output/cache paths from the original
  native client recipe. No source or compiler mismatch was found.
- No linking, execution, target matrix, production change or hardware operation.

## RFC disposition

RFC-015 may cite this bounded native feasibility evidence instead of describing
the tested shadow composition as wholly uncompiled. The candidate was not
falsified by these experiments. Do not claim complete B1 closure, target
acceptance, physical ownership/cleanup proof, resource fit or implementation
readiness. The RFC remains draft; downstream approvals are unchanged.

The requested experiment series ends here. Keep the untested integration and
resource obligations explicit in the RFC and resolve readiness through its
normal design review and approval process; this report creates no automatic
investigation, additional budget or request for another compiler iteration.

Repository validation: `scripts/validate-governance.rb` and `git diff --check`
passed. No maintained Swift source changed; no repository build/test gate was
run beyond the two explicitly bounded disposable compiler checks.
