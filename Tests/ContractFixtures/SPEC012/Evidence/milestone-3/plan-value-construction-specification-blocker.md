# SPEC-012 Plan Value Construction Specification Review

Disposition: **resolved by approved source correction**

Date: 2026-09-12

## Approval blocker

SPEC-012 assigns `StraightLineStrokeHeader` to `GiftUIRenderCore`, assigns the
plan producer to `GiftUIDrawing`, and requires runtime-profile modules to
supply concrete `DrawingPlanWorkspace` storage. The normative type declaration
lists package fields for `StraightLineStrokeHeader` but no package initializer.
Swift therefore synthesizes an `internal` memberwise initializer, which is not
callable from `GiftUIDrawing` or a runtime-profile module.

The pinned compiler reports the boundary directly when a `GiftUIDrawing` test
attempts construction:

```text
error: 'StraightLineStrokeHeader' initializer is inaccessible due to
'internal' protection level
```

The emitted package interface confirms that the fields and type are package
visible while no initializer is exported. This prevents the owning producer
from forming the header returned by `DrawingPlanView.strokeHeader` and prevents
a conforming external workspace from storing that exact value.

`DrawingPlanSummary` has the same omitted-construction problem for the
runtime-profile workspace that must implement `DrawingPlanView.summary`.
Although code inside `GiftUIDrawing` can use its internal memberwise
initializer, the profile-owned conformer cannot construct the required value.

## Required correction

Specification review must either add exact package initializers for these
cross-module constructed values or define an alternative exact owner/factory
surface. The correction must state validation responsibility and preserve the
existing field meanings, value-size ceilings, module ownership, and backend
independence.

Adding an unreviewed initializer or factory in implementation would change the
package contract. This is a source-level Specification omission; the accepted
ADR ownership and lifecycle decisions do not need to change.

## Scope and residual work

This blocks T3.2's conforming plan workspace and the T3.4-T3.5 snapshot/view
path that must form these values. Limit validation and the public scoped Path
facade remain valid. T3.3 implementation may be designed independently, but
its ordered snapshot integration cannot be claimed complete until this value
construction seam is approved.

## Resolution

The human-approved 2026-09-12 SPEC-012 correction adds exact nonfailing package
initializers for `DrawingPlanSummary` and `StraightLineStrokeHeader`. They copy
their already-validated arguments without normalization. The drawing producer
and profile workspace retain responsibility for all applicable limits, ranges,
geometry, style, clip, identity, and summary-consistency checks before
construction; impossible values observed downstream remain
`.invariantViolation`.

The field meanings, module ownership, value-size ceilings, and backend
independence are unchanged. T3.2 and its dependent T3.4-T3.5 work are
unblocked; implementation and conformance evidence remain outstanding.
