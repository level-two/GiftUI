# SPEC-008 Implementation Review

**Not ready:** the approved Specification is internally inconsistent at two
Milestone 5 requirements. Independent T5.2-T5.4 work remains valid, but T5.1,
T5.5, and later milestone gates cannot be completed without guessing or
changing the approved contract.

## Blocker 1: caller-owned foreground storage has no protocol seam

- `RenderProductionWorkspace` is declared as an exact package protocol with
  capacity, structural capacity, activity, acquisition, two ordinal-visit
  operations, and reset.
- T5.1 and the normative workspace behavior require a bounded foreground stack
  in caller-owned workspace.
- None of the approved protocol operations can push, read, or pop a foreground
  value. The current recursive foreground parameter is bounded by traversal
  depth but lives in call frames, not caller-owned workspace.

Required correction: a reviewed Specification amendment must either define the
exact bounded foreground-storage seam and its failure/reset behavior or revise
the ownership requirement consistently with the accepted static-memory and
stack constraints. An implementer cannot choose between those contracts.

## Blocker 2: rendering arithmetic failure is unconstructible

- Every `.arithmeticOverflow` return in Render Lowering guards
  `LayoutGeometry.intersection`.
- SPEC-002 `Rect` construction proves each exclusive edge representable and
  each size nonnegative. The intersection width and height cannot exceed either
  input extent, so intersection of two constructible rectangles cannot
  overflow.
- The remaining lowering arithmetic is count/depth accounting, which SPEC-008
  classifies as `.capacityExhausted`.
- T5.5 and T6.3 nevertheless require arithmetic-site injection and coincident
  arithmetic precedence evidence.

Required correction: a reviewed Specification amendment must identify a
constructible rendering arithmetic boundary, or remove the unreachable local
error path and revise the required fault/precedence evidence. Tests must not
manufacture an invalid `Rect` through representation tricks.

## Impact

T5.1 and T5.5 remain open. Milestone 6 entry conditions require all focused
semantics to be independently testable, so T6-T8 do not yet meet their entry
gates. No implementation or conformance claim is made for the blocked work.

## Draft amendment disposition

The review amendment adds exact foreground current/push/pop operations, binds
their physical storage to `maximumTraversalDepth`, and replaces impossible
producer arithmetic injection with checked-branch and direct-mapping evidence.
These corrections introduce no new architectural choice. They remain
non-authoritative until explicit human approval returns SPEC-008 to an
implementation status.
