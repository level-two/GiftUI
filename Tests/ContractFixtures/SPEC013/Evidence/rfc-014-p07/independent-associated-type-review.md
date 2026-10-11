# P07 independent associated-type review — 2026-10-11

**Not ready for P07 acceptance. Blocker confirmed; the bounded concrete-binding
amendment below is ready for human approval consideration.**

Sequential independent Strong review (`gpt-6-astra`, medium), reviewed clean
`8643d7347f7ea56eb7aa08c042136bddef25fccd`. Scope: the existing four-case proof,
immediately adjacent requirements, prior approval and new partial diffs. No
production/Spec edits, new alternatives study, P08 or full gate. SPEC-013 remains
implementing for ITERATION-003 I3-04 / IT-AC-006; P07, T9.1 and T11.1 stay open.

## Confirmed boundary

The [prior approval](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#scoped-coordinator-constraint-amendment--2026-10-11)
explicitly preserved associated types. Removing them is **not** already-approved
generic forwarding. SPEC-013 lines 580–585 and
`RuntimeCoordinatorContracts.swift:13–18` still require Storage, Handler and
TargetAccess, with target/handler Model equality.

Independent replay of `associated-type-proof/reproduce.py` against the packet's
`tmpuk4e29x5/macos-static` receipt produced:

| Case | Result |
| --- | --- |
| CurrentStorage | Rejects noncopyable S as associated Storage |
| UnsupportedSuppression | Rejects `associatedtype ... & ~Copyable` on Swift 6.3.2 |
| CurrentTarget | Actual scoped target cannot conform to ActionModelTargetAccess |
| ProposedOperational | Smaller protocol with concrete noncopyable storage/model/target fields compiles |

Compiler and input checks passed; additionally verified every artifact hash in
the module receipt. Original evidence restored byte-for-byte. See
[independent replay](independent-associated-type-replay.json).
`StaticProfileStorage.swift:166` confirms actual storage is noncopyable. The
generic negative is not an instantiated full Static owner test. The positive
uses stubs/traps and provides no functioning audit, handler, endpoint or cycle.

The target failure has two causes beyond protocol-level Self suppression:
associated types retain implicit ownership constraints, and the actual checked
target exposes typed mutation rather than the legacy `withCurrentModel` method.
There is no independent Handler compiler failure in this proof. Endpoint/Sink,
finite fact/failure types and the five operational members reveal no further
immediate constraint conflict in this bounded inventory. That is not a guarantee
against later concrete integration failures.

A dummy associated type could satisfy syntax without describing actual owned
storage or the dispatch target; it would not prove the required relationship.
No compatible internal representation has been established. Keeping the exact
declaration therefore keeps this selected integration blocked. This is not a
proof that every alternative representation is impossible.

## Architecture and lost checks

The proposal removes real generic guarantees: a caller constrained only to the
common protocol can no longer name those three types or rely on target/handler
Model equality. No current production conformance or caller using those members
was found. Their absence limits current source breakage; it does not make the
contract change inconsequential. Even the old type requirements did not, by
themselves, prove that a particular stored value or audit matched those types.

The change can preserve accepted architecture **only with concrete binding
obligations**, not merely by deleting declarations. ADR-033's Decision Boundary
leaves exact Swift declarations to Specs; its decision requires one statically
known action domain/handler, current-root targeting and a Runtime-owned join.
ADR-036 requires actual bounded ownership and checked exclusive writes; it does
not require these three associated types on this particular common protocol.
Concrete generic construction can enforce these obligations in the same owner
and dependency graph without a registry, type erasure or dynamic fallback.
Weakening any of those obligations would require upstream architecture review.

The approved RFC-014 amendments have explicit precedence over baseline realization
([approval](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md),
opening paragraph; [review](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-amendment-review.md),
opening authority boundary). SPEC-011's checked typed-write dispatch and
SPEC-010's replacement of raw-reference access govern this path. The retained
SPEC-011 `withCurrentModel` / `handler.handle` baseline spelling is not a demand
to reintroduce raw model callbacks here. Its finite statically known handler,
exact action domain, ordered exactly-once effects and synchronous reporting
semantics still apply. Removing SPEC-013 requirements neither deletes the public
legacy protocols nor authorizes arbitrary operation closures as a new action API.

## Exact decision recommended

Approve one coordinated SPEC-013 amendment:

> Remove only Storage, Handler and TargetAccess (and their Model equality) from
> GiftUIRuntimeProfileCoordinator. Keep Endpoint/Sink, inherited admission and
> opportunity requirements, ownership suppressions and all operational members.
> Concrete coordinator construction MUST bind actual RuntimeProfileStorage and
> its validated audit, common Model/Schema for model/root/target scopes, and one
> immutable finite action domain and statically known handler mapping whose
> checked operations produce that Model.Mutation. Generic protocol conformance
> alone is not evidence of these relationships. Runtime retains the join;
> focused module ownership, all phase/failure/publication/cleanup/resource
> requirements and SPEC-011's amended dispatch semantics remain unchanged.

Record this as an approved correction to the prior “associated types unchanged”
boundary before code changes. A brief SPEC-011 cross-reference may clarify that
its approved checked-write realization takes precedence for RFC-014; no separate
new action API or approval gate is implied. SPEC-015 host construction/activation
remains outside this decision, with its previously recorded P08 boundary.

Required P07 evidence after approval: concrete Dynamic and Static construction;
compiler negatives for mismatched Model/Schema, action domain and mutation type;
copy/escape negatives; actual audit/owner identity agreement; stale action/target
cancellation and exactly-once checked dispatch/reporting; full phase/fault,
refusal/retry, bank reuse and quiescent cleanup transcripts on the required
routes. Type equality alone cannot prove two values share the same owner, so
runtime provenance and lifetime checks must also be exercised. These are existing
integration obligations made explicit at the relocated boundary, not another
investigation budget.

If this relocation of guarantees is not approved, retain the exact contract and
keep P07 stopped. Do not substitute placeholder conformances or infer approval.

## Partial-diff disposition

No additional material defect identified in the bounded validated forwarding
and early-frame cleanup diffs. `db78cf9c` records the cleanup obligation directly
after successful freeze; the real-store regression covers expansion failure,
exact destruction and reuse. It does not cover every later failure. The WIP
workspace/presentation changes in `027bdc11` remain compile-only: qualification,
stale-reference rejection and full behavior still need integration tests.
The compiler proof is native only, not cross-target execution or resource proof.

No P07 acceptance or architecture waiver is granted. Separate completed-package
Strong review remains required. Repair counter remains **0/2**. This current
blocker is not deferred work. Governance and whitespace validation pass.
