# GiftUI Runtime Profile Migration Plan

**Status:** Active migration plan

**Scope:** Prepare the existing dynamic proof of concept for a portable/static
runtime without implementing the static runtime in the first iteration.

## 1. Review of the current implementation

The existing package has useful module boundaries for the framebuffer backend,
the dynamic application runtime, and platform adapters. `StateStorage` and
`RenderOperationSink` are already replaceable contracts. Those are the seams to
preserve.

The `GiftUI` module is not yet a portable core, however. It currently contains
several dynamic-profile choices:

| Area | Current representation | Why it is dynamic |
| --- | --- | --- |
| Text declarations and render runs | `String` | Storage and interpolation are unbounded |
| Button actions | Escaping `() -> Void` | Captures may allocate and require runtime ownership |
| View graph | Classes and `[ViewNode]` | Retained, dynamically growing tree |
| Composition | Escaping builder closures and arrays | Dynamically allocated child staging |
| State binding | Class boxes, `any StateStorage`, `@TaskLocal` | Reference and runtime-local machinery |
| Dynamic state store | `[StateKey: Any]` | Heterogeneous dictionary storage |
| Interaction snapshot | Arrays and a callback dictionary | Unbounded retained action storage |
| Display list | `[RenderOperation]` | Unbounded retained render storage |

The current `GiftUIRuntimeDynamic` target owns invalidation, dynamic state, the
application loop, and input serialization, but it consumes a graph whose
storage and callback representation are still defined by `GiftUI`. Therefore,
adding an empty `GiftUIRuntimeStatic` target now would not prove static-profile
support.

## 2. Target dependency direction

```text
GiftUIDynamicConveniences (optional String and closure APIs)
                         |
                         v
GiftUI (portable declarations and semantic contracts)
            ^                         ^
            |                         |
GiftUIRuntimeDynamic          GiftUIRuntimeStatic
            ^                         ^
            |                         |
  macOS/Linux products       host-static/nRF products
```

Profile selection is expressed by target dependencies and associated profile
types. It must not be a runtime branch inside a view declaration.

`GiftUI` is the existing package name and remains the portable-core product
name. Renaming it to `GiftUICore` would add churn without strengthening the
boundary.

## 3. Migration rules

1. A public API in `GiftUI` must have portable semantics and a bounded or
   statically knowable representation path.
2. Heap-permitting conveniences live in `GiftUIDynamicConveniences` and depend
   on `GiftUI`; `GiftUI` never depends on them.
3. Runtime implementations declare their profile through an associated type,
   so profile identity is compile-time information.
4. Shared semantics are tested through profile-neutral fixtures. Storage
   capacity and failure behavior are tested by each runtime.
5. Every temporary dynamic representation that remains in `GiftUI` stays in
   this inventory until it is removed or replaced. Module names alone are not
   accepted as evidence of static readiness.
6. The static host harness precedes the nRF52840 integration. It must detect
   overflow and forbidden conveniences without requiring hardware.

## 4. Staged implementation

### Stage A — make profile selection explicit

**Status:** Complete in the first preparation iteration.

- Add compile-time profile marker types and a runtime-profile declaration
  protocol to `GiftUI`.
- Declare `DynamicRuntime` as the dynamic profile.
- Test the declaration without adding runtime profile switches.

### Stage B — split the application-facing DSL

**Status:** Complete in the first preparation iteration.

- Add a portable button action-identifier initializer.
- Teach the dynamic application runtime to dispatch identified actions.
- Keep `StaticString` text and identified actions in `GiftUI`.
- Move `String` text and closure button initializers to
  `GiftUIDynamicConveniences`.
- Make current macOS/Linux examples opt in to that product explicitly.

Stage B establishes an enforceable public boundary even though the current
internal graph remains dynamic.

### Stage C — replace the retained graph boundary

- Replace `View._makeNode` with runtime-neutral traversal/build contracts.
- Let the dynamic runtime build its current class/array graph.
- Add bounded node, child, hit-region, action, and render sinks for a host
  static runtime.
- Move `DisplayList`, callback tables, and other retained storage out of the
  portable module.
- Replace string structural paths with a bounded structural identity.

This is the largest migration stage because the current `View` protocol names
the dynamic `ViewNode` representation directly.

**Progress:** The public `View` boundary now uses `ViewVisitor`, tuple staging
is generic rather than closure/array backed, and the portable declaration
subset compiles as an ARM Embedded Swift module. The remaining retained graph
and bounded-runtime work is tracked in
[`GiftUI_Embedded_Layer_Inventory.md`](GiftUI_Embedded_Layer_Inventory.md).

The first bounded runtime now builds an index-linked node arena, performs
layout, and records identified hit regions with explicit capacity failures.
The dynamic runtime continues to build its retained class/array graph through
the same visitor contract.

### Stage D — provide portable state and text

- Replace the core `@State` class box/task-local dependency with an explicit
  binding hook that each runtime can implement.
- Add fixed/generated typed state slots with deterministic exhaustion.
- Add bounded UTF-8 or resource-backed text and formatting.
- Run the same portable thermostat fixture against both host runtimes.

**Progress:** Bounded decimal text and an application-typed thermostat state
model now compile in Embedded Swift. The identical portable thermostat view is
checked against static and dynamic host layout/action semantics. Generalized
fixed/generated `@State` slots remain future state-layer work.

### Stage E — validate Embedded Swift and hardware integration

- Compile the portable core and static runtime with Embedded Swift restrictions.
- Add allocation and section-size checks to the nRF52840 build.
- Connect the bounded renderer, event queue, display, touch, and GPIO adapters.
- Keep flashing an explicit, user-requested operation.

## 5. First-iteration exit criteria

This preparation iteration is complete. It established the following checked
conditions:

- `DynamicRuntime` declares the dynamic profile at compile time;
- `GiftUI` offers a portable identified-action button path;
- `GiftUIDynamicConveniences` is the only public source of closure-backed
  button and unbounded `String` text initializers;
- dynamic examples opt in through package dependencies;
- a test target depending only on `GiftUI` exercises the portable text and
  button surface;
- existing dynamic behavior and framebuffer snapshots remain unchanged;
- the full host test suite passes.

The iteration does **not** claim allocation-free compilation. The remaining
dynamic internals listed in section 1 are the work queue for Stages C and D.
