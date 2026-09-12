# SPEC-012 Canvas Plan Producer Workspace Seam Blocker

Resolution: corrected by the approved 2026-09-12 SPEC-012 amendment through
`DrawingPlanConstructionWorkspace`. The diagnostic below remains historical
implementation evidence.

Plan task: `SPEC-012 T4.2`

Status: blocked in Specification review.

The exact declared producer is generic over `Workspace: DrawingPlanWorkspace`.
That protocol exposes only:

- immutable `DrawingPlanView` access;
- `capacity` and `isActive`;
- `acquire()`, `discard()`, and `reset()`.

After acquisition, the producer has no normative operation that can create a
`GraphicsContext` backed by the concrete workspace, begin/end its one live
Path, append a validated `StrokeSnapshotProducer` result, translate points, or
seal and publish `DrawingPlanSummary`. The package `GraphicsContext`
initializer requires an opaque pointer and C-compatible operation table, but a
generic `DrawingPlanWorkspace` supplies neither. The focused T3 implementation
protocols cannot be used from the normative signature because it does not
constrain the workspace to them.

This is an implementation-contract gap, not permission to cast the generic
workspace to a hidden existential, use global/thread-local storage, add an
unapproved generic constraint, or duplicate dynamic/static branches inside
`GiftUIDrawing`. Any of those choices changes ownership, static-profile
behavior, or the specified API.

An approved correction needs one typed, allocation-free workspace construction
and commit seam reachable from the exact producer signature. It must preserve
the existing caller-owned storage, noncapturing facade operations, static
compatibility, atomic publication, and `DrawingPlanWorkspace` view/lifecycle
semantics. Once approved, T4.2 can implement phase/identity/order validation
and T4.3-T4.5 can complete invocation, translation, and cleanup.

Reproduce the surface audit from the repository root:

```text
rg -n "GraphicsContext\\(|DrawingPlanMutationStorage|appendStroke|seal\\(|stageCanvas|DrawingPlanWorkspace" Sources docs/specs/spec-012-canvas-path-stroke-drawing.md
```
