# SPEC-012 Canvas Invocation Seam Specification Review

Disposition: **resolved by approved source correction**

Date: 2026-09-12

## Approval blocker

SPEC-012 requires `Canvas` to retain its client drawing closure privately,
stage that callable in `GiftUISemanticCore` under the exact semantic identity,
and expose it only through the later drawing-attempt input. The same contract
forbids a public or package callable lookup. The approved source and package
APIs do not define any operation that transfers or invokes the private callable
across the `GiftUI` to `GiftUISemanticCore` module boundary.

The existing generic SPEC-006 visitor cannot supply that missing operation. It
receives only a borrowed `_GiftUISemanticPrimitivePayload`; its contract
forbids retaining a payload or closure beyond the visitor call unless a later
contract explicitly transfers or copies it. SPEC-012 authorizes the later
lifetime semantically, but provides no exact transfer, storage, or invocation
surface. Copying the `Canvas` value into semantic storage would preserve its
private field, but neither `GiftUISemanticCore` nor `GiftUIDrawing` could invoke
that field without adding the forbidden or otherwise unspecified cross-module
access.

The static profile makes the gap independently observable: its public
`Canvas` initializer intentionally retains no closure, while the future source
generator is required to substitute a callable ID and capture record. No
semantic staging payload or generated-expression hook is specified for that
substitution.

## Required correction

Specification review must define the exact typed cross-module staging and
invocation seam, including:

- which owner can extract or receive the dynamic closure without making it a
  general public/package lookup;
- the semantic-result view used by the drawing-attempt adapter;
- the corresponding static callable-ID and capture-record staging hook;
- copy, borrow, release, failure, and reset behavior at the module boundary;
- four-profile source and symbol evidence that the seam introduces no
  existential, reflection, allocator, or retained static closure path.

The correction must preserve ADR-028's post-layout, at-most-once invocation
and cycle-local release rules and SPEC-006's single expansion engine. Selecting
one of several possible Swift dispatch or storage mechanisms is a human-reviewed
contract decision; the implementation plan cannot invent it.

## Scope and residual work

This blocks T2.1 and every production task that depends on a real staged Canvas
callable. It does not block additive closed-enum cases, Render-Core stroke
values, direct synthetic views, or bounded Path/plan workspace work that does
not claim production semantic-callable integration.

No accepted ADR is contradicted by the intended behavior. The defect is a
missing implementable Specification seam rather than evidence that ADR-028's
ownership or lifetime decision must change.

## Resolution

The human-approved 2026-09-12 SPEC-012 correction defines a non-returning
package `_giftUIInvokeCanvas(context:size:)` bridge on the concrete `Canvas`
payload. Only the profile semantic-result adapter's
`CanvasInvocationSource.invokeCanvas` implementation may reference it. The
dynamic adapter stores a bounded identity-keyed copy of the private-closure
payload; static source generation substitutes the private representation with
a nonzero callable ID and inline capture record and emits the bridge's finite
table dispatch. Production static builds reject unlowered closure-based Canvas
expressions.

The bridge never returns or borrows the callable, so the existing public API,
SPEC-006 generic visitor, exact identity relation, ADR-028 invocation phase,
at-most-once rule, and release lifecycle remain unchanged. T2.1 is unblocked;
its implementation and four-profile evidence remain outstanding.
