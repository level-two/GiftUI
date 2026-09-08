# SPEC-010 Milestone 3 Evidence

Milestone 3 implements candidate binding and structural reconciliation without
selecting the production dynamic/static storage owned by SPEC-013 and later
SPEC-010 milestones.

## Task evidence

| Task | Commit | Evidence | Primary validation |
| --- | --- | --- | --- |
| T3.1 | `0edc1d2` | [Candidate lifecycle](candidate-lifecycle.md) | Checked begin/reserve/finish lifecycle, bounded capacities, sticky failure, and reuse |
| T3.2 | `2aafebc` | [Binding decorator](binding-decorator.md) | Generated lexical binding, transient copy, bind-before-body, and body suppression |
| T3.3 | `cfa3314` | [Structural reconciliation](structural-reconciliation.md) | Materialization, preservation, ordinal identity, removal, retirement, reinsertion, discard, and shutdown |
| T3.4 | `ddf6283` | [Reconciliation faults](reconciliation-faults.md) | Reservation, association, attachment, detach, finish, rollback, and body-suppression fault matrix |

## Milestone exit statement

The finite fixture candidate reserves before binding, visits every direct
wrapper in lexical order, evaluates the body only after complete successful
binding, and publishes additions/removals together. Discard invalidates and
detaches candidate-only routes while preserving the prior live set. Published
removal and shutdown retire routes before detachment; shutdown is idempotent
and final.

The following acceptance criteria remain intentionally pending in
`required-evidence.tsv`:

- OS-002 still requires T6.1 shared profile identity/preservation evidence.
- OS-003 still requires T4.1-T4.2 generation and replacement evidence.
- OS-005 still requires T7.1-T7.3 mapping, mandatory-effect, and policy
  evidence.

Milestone 3 therefore closes its implementation-plan boundary without
claiming whole-criterion or Specification conformance.

## Validation

```sh
swift test
ruby scripts/contracts/check-spec-010-candidate-lifecycle.rb
ruby scripts/contracts/check-spec-010-binding-decorator.rb
ruby scripts/contracts/check-spec-010-structural-reconciliation.rb
ruby scripts/contracts/check-spec-010-reconciliation-faults.rb
ruby scripts/contracts/check-spec-010-milestone-3.rb
```

The full Swift test gate passed 121 Swift Testing cases after T3.4. The
registered checks keep the mechanisms internal, enforce their exact owner
boundaries, and reject dynamic storage, reflection, suspension, and prohibited
imports.
