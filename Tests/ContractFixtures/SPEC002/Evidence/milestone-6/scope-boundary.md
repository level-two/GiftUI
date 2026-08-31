# SPEC-002 Scope-Boundary Audit

Implementation-plan task `T6.3` reviews SPEC-002-owned production source,
compile/semantic/resource fixtures, implementation records, and the split
owner-adapter locations against PF-010.

## Result

- `Sources/GiftUI/GiftUI.swift` contains only portable geometry, checked local
  arithmetic, and bounded normalized pointer values. It defines no declarative
  hierarchy, state behavior, layout policy, failure disposition/diagnostics,
  capability resolution, input admission/dispatch, backend policy, or host
  product policy.
- The SPEC-002 Swift/C fixtures compile, exercise, measure, or reject only that
  Foundation surface. They introduce no downstream owner vocabulary or policy.
- `GiftUI` remains a dependency-free target. Its public/package interface and
  forbidden-import fixtures continue to prevent an upward import or re-export.
- The three cross-owner seams remain outside the Foundation leaf and outside
  SPEC-002-owned fixture source: Foundation-to-failure and Foundation-to-
  capability are test-only boundaries; capability-to-failure is an
  unpublished downstream fixture owned jointly by those concepts.
- SPEC-002 has no implementation design note. Review of its plan, fixture
  README, migration records, and milestone evidence found only derived work
  ordering, reproduction, measurements, and explicit scope dispositions; no
  record introduces normative downstream behavior.

No new need was discovered for an upstream RFC, ADR, Specification revision,
or deferred-work item. Existing downstream concepts remain governed by their
own approved/implementing Specifications. This audit is PF-010 evidence, not a
claim that SPEC-002 is implemented.

## Reproduction

```text
scripts/contracts/check-spec-002-scope.rb
scripts/contracts/check-spec-002-traceability.rb
scripts/contracts/run-spec-002.sh --profile macos-dynamic
```

The scope checker fails if the Foundation leaf acquires downstream vocabulary
or dependencies, if SPEC-002-owned Swift/C fixtures define another owner's
vocabulary, if a cross-owner adapter disappears from its split boundary, or if
an untracked SPEC-002 design note appears without a recorded trigger.
