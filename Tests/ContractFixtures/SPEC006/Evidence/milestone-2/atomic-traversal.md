# SPEC-006 T2.3 Atomic Traversal Evidence

The sole generic `expandSemanticTree` entry now runs one sealed
`_GiftUISemanticTraversalVisitor` over the T2.2 attempt coordinator. The
visitor enters root, declaration-role, custom-body, fixed-child, conditional-
branch, and optional-presence components through the caller-owned workspace;
stages structural and typed semantic events through the caller-owned sink; and
returns only the closed local result.

Focused `SemanticExpansionTraversalTests` prove:

- an empty root succeeds with `maximumObservedDepth == 2` and publishes once;
- nested custom, fixed, selected conditional, and absent optional content runs
  depth-first and left-to-right, evaluates the active custom body exactly once,
  never constructs inactive content, and produces matching counters;
- an action-bearing primitive reserves its semantic node before its action and
  stages the borrowed bounded action value without invocation;
- nested modifiers apply after content with increasing source-order indices,
  while sibling chains restart at zero and do not interleave;
- the next custom body and next path entry are refused before their hooks when
  body or workspace depth capacity is exhausted; and
- every failed traversal discards staged output, publishes nothing, resets the
  workspace to idle, and retains no declaration or payload.

The visitor also detects zero or multiple framework category dispatches as a
local invariant before success. The SPEC-010-owned stateful binding decorator
is not duplicated here: until Milestone 5 installs the combined coordinator,
the stateful category evaluates no body and fails closed.
