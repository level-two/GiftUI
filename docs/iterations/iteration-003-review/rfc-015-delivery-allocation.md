# RFC-015 delivery allocation — 2026-10-13

## Maintainer direction

Eugene explicitly requested: “Please include full RFC 015 scope work into the
next iteration, while preserving P08 staying focused on the only necessary changes”.
This approves ITERATION-004 revision 4's I4-07 / I4-AC-008 delivery addition.
ITERATION-003's existing outcomes remain unchanged. It does not accept ADR-039,
approve the proposed Spec amendments, change architecture, or renew execution budgets.

## P08: minimum complete dependency path

P08 owns only the changes required to make its existing finite counter routes
safe and fit the unchanged resource limits. Before source work, SO-01 records
each proposed change, its concrete P08 caller/dependency or failing gate, and its
necessary evidence. A change with no such dependency belongs to I4-07. Audit all
callers affected by shared declarations; migrate only those that must change to
preserve compilation and existing behavior. Keep the selected analyzer and retained
dispatcher paths owned; do not convert them to scoped storage for uniformity.

| Obligation | Required in P08 | ITERATION-004 I4-07 completion |
| --- | --- | --- |
| B1 / IN-SO-001, HC-SO-001 | Exact adopted shared declarations and complete lifetime chain of the finite counter, including all five banks, geometry, supplied/pipeline/coordinator/host/retirement, owned compatibility and applicable negative controls on the four existing configurations | Reconcile every remaining RFC declaration, caller and test case against the final source; complete full contract conformance without rerunning unchanged valid evidence |
| B2 / IN-SO-002, RP-SO-001/002, HC-SO-002 | Concrete final typed inventory, common session, pair-capacity/exchange checks, all reachable initialization/failure/cleanup/repeat-session paths, backing-last proof and correct physical accounting | Close residual full-scope documentation/evidence coverage and refresh paths changed during iteration-4 integration |
| B3 / IN-SO-003, RP-SO-003, HC-SO-003 | Transitive impact audit and required compatibility fixes; four counter routes, early Pi/nRF artifacts, actual nested-stack/IRQ and allocation/resource evidence required by existing P08/R07 gates | Complete the RFC-wide migration/conformance reconciliation and integration handoff; retain owned-only consumers selected by the RFC |
| B4 / authority and execution | Accept the governing decision and approve contracts required by the P08 slice; derive its ready tasks and separately bounded allowance | Complete outstanding downstream approvals, plans and conformance dispositions for full RFC delivery |

The rows allocate delivery, not weaker safety criteria. An obligation needed by
an adopted P08 path cannot be deferred because its evidence is expensive or fails.
Shared protocol changes may require multiple modules; file count is not the scope
test. SO-01 must identify a coherent slice before implementation. If the selected
architecture makes a proposed deferral inseparable, keep that dependency in P08
and report it; a different contract or expanded scope requires maintainer direction.

SO-01–09 remain the ordered work breakdown, filtered by this dependency test.
P08 exit reviews all applicable obligations and the existing P08/R07/T8.1 gates;
it does not claim all nine new criteria or full RFC-015 delivery complete. No
criterion may be marked fully met from partial coverage. Carry exact residual
rows, source identities and reusable evidence into I4-07, including an explicit
empty residual list if P08 necessarily supplies all implementation evidence.

The 58,648-byte construction frame still fails the 27,648-byte ceiling. No
stack exception, reduced workload, omitted dependency, unchecked lifetime fallback,
new experiment, budget reset or P09–P12 work is authorized by this allocation.

## ITERATION-004: full RFC delivery

I4-07 owns completion of approved RFC-015's entire selected scope: downstream
decision/Spec/plan amendments, remaining implementation, complete caller and
criterion mapping, migration compatibility, physical/lifetime/resource evidence,
conformance review and documentation. Reuse P08's qualified results and implement
only the residual; scheduling the full scope does not require duplicate work.

This is a delivery commitment under the normal lifecycle gates, distinct from
I4-06 / FW-037's Core-wide ownership assessment. It does not extend RFC-015 to a
universal owner abstraction, new public extension surface or scoped analyzer
migration. External packaging belongs to I4-01–04; coordinate those changes and
refresh affected evidence without expanding the RFC's selected architecture.

Entry: consume the P08 boundary report and residual matrix at iteration-4 planning.
Inventory may proceed while P08 remains open; production integration still obeys
the iteration's existing entry gates. Exit: every RFC B1–B4 obligation and adopted
IN-SO/RP-SO/HC-SO criterion has an exact current-source conformance disposition;
missing or failed evidence stays unmet unless explicitly excepted by the maintainer.

## Records

- [ITERATION-004 revision 4](../iteration-004-backend-and-application-integration.md)
- [Approved RFC-015](../../rfcs/rfc-015-p08-scoped-storage-ownership.md)
- [Proposed Spec packet](rfc-015-spec-amendments.md)
- [Conditional P08 handoff](rfc-015-p08-handoff.md)

The earlier downstream review at `3640bb5e` covers its original package; this
allocation supersedes that package's blanket assignment of full RFC completion
to P08. It preserves the contract text and all required safety/resource evidence.
