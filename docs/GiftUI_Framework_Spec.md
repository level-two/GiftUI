# GiftUI Framework Specification

**Status:** Proof-of-concept specification  
**Primary language:** Swift  
**Target:** Embedded Swift environments, from statically allocated bare-metal systems to allocating embedded Linux/RTOS systems  
**Primary PoC backend:** Framebuffer  
**Document purpose:** Implementation specification suitable for human developers and AI coding agents

---

## 1. Vision

GiftUI is a declarative user-interface framework for embedded systems, inspired by SwiftUI's source-level model:

- views are value types;
- each client-defined view declares a `body`;
- view hierarchies are composed with result-builder syntax;
- state is declared with property wrappers;
- state changes invalidate and re-render the affected interface;
- layout and rendering are separated from the application view declarations;
- the rendering backend is selected independently from the UI declaration.

GiftUI must provide similar ergonomics across two broad embedded profiles:

1. **Dynamic embedded environments**
   - Heap allocation is available.
   - Escaping closures and dynamically sized collections are acceptable.
   - Typical targets include embedded Linux, capable RTOS systems, Qt-based devices, and simulator/desktop hosts.

2. **Static embedded environments**
   - Heap allocation may be forbidden or tightly controlled.
   - Runtime type discovery, unrestricted existentials, and reflection must not be required.
   - Collections, state storage, render commands, and event queues may need fixed capacities.
   - Typical targets include microcontrollers, bare-metal systems, and small RTOS devices.

The same application-facing DSL should be retained wherever practical. Runtime capabilities may differ by selected profile.

---

## 2. PoC Goal

The proof of concept must support the following application code without backend-specific declarations:

```swift
struct ThermostatView: View {
    @State private var target: Int = 21

    var body: some View {
        VStack(spacing: 8) {
            Text("Target")
            Text("\(target)°")

            HStack {
                Button("-") {
                    target -= 1
                }

                Button("+") {
                    target += 1
                }
            }
        }
    }
}
```

The PoC must also support nesting client-defined subviews:

```swift
struct TemperatureValueView: View {
    let value: Int

    var body: some View {
        Text("\(value)°")
    }
}

struct ThermostatView: View {
    @State private var target: Int = 21

    var body: some View {
        VStack(spacing: 8) {
            Text("Target")
            TemperatureValueView(value: target)

            HStack {
                Button("-") {
                    target -= 1
                }

                Button("+") {
                    target += 1
                }
            }
        }
    }
}
```

### Required behavior

- The initial frame displays:
  - `Target`
  - `21°`
  - decrement and increment buttons.
- Activating `-` changes the state to `20`.
- Activating `+` changes the state to `22` from the initial state.
- A state mutation schedules UI invalidation.
- The next render reflects the new value.
- Nested client-defined views are recursively expanded and rendered.
- Application code contains no framebuffer-specific types.
- Switching the backend must not require changing `ThermostatView`.

---

## 3. Design Principles

### 3.1 Compile-time composition first

GiftUI should favor:

- generics;
- protocols with associated types;
- opaque result types;
- result builders;
- concrete sum and product types;
- statically selected backends.

The core must not require:

- reflection;
- Objective-C runtime facilities;
- runtime generic instantiation;
- unrestricted protocol existentials;
- runtime backend discovery.

### 3.2 Separate declaration, runtime, layout, and rendering

A `View` describes UI structure. It must not directly:

- write pixels;
- allocate backend widgets;
- process hardware interrupts;
- own the main event loop;
- know which renderer is active.

### 3.3 Capability-based profiles

The static profile must not be implemented as an afterthought. Code requiring
allocation should be isolated behind modules or compile-time capabilities.

GiftUI defines two language/runtime profiles:

1. **Portable profile**
   - valid for both static and dynamic runtimes;
   - uses bounded or statically known storage;
   - uses typed actions instead of requiring stored escaping closures;
   - has deterministic capacity and failure behavior;
   - is the only profile for which cross-platform source invariance is
     guaranteed.
2. **Dynamic convenience profile**
   - adds heap-backed strings, collections, heterogeneous storage, escaping
     callback closures, and other facilities suitable for capable systems;
   - is opt-in and must not become a dependency of the portable core;
   - is source-compatible only with configurations that declare dynamic
     runtime support.

Static and dynamic describe storage and language/runtime capabilities. They do
not describe a particular operating system. A platform chooses a supported
combination explicitly; it is not required to implement every runtime profile.

The initial supported configuration matrix is:

| Configuration | Runtime profile | Presentation/input |
| --- | --- | --- |
| macOS simulator | Dynamic | AppKit and mouse |
| Raspberry Pi 1 / Linux | Dynamic | Linux framebuffer, evdev, and libgpiod |
| nRF52840-DK / Zephyr | Portable/static | RGB565 SPI display, touch, and GPIO |
| Host static test harness | Portable/static | Recording and bounded test backends |

Adding nRF52840 support does not require a dynamic nRF52840 runtime. Adding the
static runtime does not require shipping it on every Linux or macOS product.

#### 3.3.1 Source-invariance contract

GiftUI invariance applies at three different levels:

- **Semantic invariance:** layout, state mutation, invalidation, rendering
  order, and input dispatch have the same documented behavior in every
  conforming profile.
- **Portable source invariance:** a view written only with portable-profile
  APIs must compile unchanged against every supported runtime and platform.
- **Convenience source invariance:** not guaranteed. A view that selects a
  dynamic-only overload is intentionally restricted to dynamic configurations.

The implementation and storage representation are not invariant. Dynamic and
static runtimes may use completely different state, node, text, action, and
render storage as long as portable semantics and conformance tests agree.

#### 3.3.2 Feature classification

Every public feature must be assigned one of these classes:

| Class | Meaning | Examples | Policy |
| --- | --- | --- | --- |
| Portable | Same source and semantics in both profiles | geometry, stacks, bounded state, typed actions, static/bounded text | Lives in the portable core |
| Dynamic convenience | Requires or permits unbounded allocation/runtime behavior | escaping callback closures, `String` interpolation, dynamic lists, `Any` state | Lives in an opt-in dynamic extension |
| Platform capability | Depends on an OS, RTOS, or device | mouse, evdev, GPIO, BLE, ILI9486, ADS7846 | Lives in a platform/hardware module |
| Unsupported | Cannot meet the selected profile's contract | unbounded list on a heap-free target | Produces a compile-time diagnostic |

When a dynamic convenience represents behavior needed by portable
applications, GiftUI must provide a portable alternative. Examples include:

| Dynamic convenience | Portable alternative |
| --- | --- |
| `Button { capturedState += 1 }` | typed `GiftUIAction` or application action enum |
| `Text("\(value)")` | bounded formatting or a generated/static text value |
| dynamically growing list | fixed-capacity collection with explicit overflow |
| `Any`-backed state | typed/generated state slots |
| retained `DisplayList` array | direct sink or fixed-capacity operation buffer |

#### 3.3.3 Availability and conditional-compilation policy

Profile selection is compile time. GiftUI must not implement profile support as
runtime `if available` checks in view bodies.

- Use separate products/modules or narrowly scoped compile-time capability
  facades for dynamic conveniences and platform integrations.
- Prefer the absence of an unsupported overload plus a clear compiler
  diagnostic over a runtime trap.
- `@available` is reserved for genuine platform or API-version availability;
  it is not the primary mechanism for heap/static capability selection.
- `#if`, `canImport`, and Embedded Swift feature checks may select
  implementations at module boundaries, but must not be scattered through
  client view declarations or core layout semantics.
- Hardware presence may be checked at runtime by the owning platform module.
  For example, a platform may report that touch is disconnected. That is
  distinct from runtime-profile availability.
- A build must declare its runtime profile and platform capabilities so its
  supported surface is inspectable and testable.

The preferred module direction is:

```text
GiftUI dynamic convenience extensions (optional)
                   ↓ depends on
GiftUI portable API and semantic contracts

GiftUIRuntimeStatic      GiftUIRuntimeDynamic
          \                 /
           selected application product
                       ↓
       platform and hardware adapters
```

Dynamic convenience modules may extend portable types with closure- or
heap-backed initializers. The portable core must not import those extensions.

#### 3.3.4 Callback policy

Escaping callback closures are a dynamic convenience, not a universal GiftUI
requirement. The portable action representation is a bounded value or action
identifier dispatched by the application/runtime.

Closure syntax may become portable only if the Embedded Swift implementation
can prove that its capture and lifetime require no forbidden or unbounded
storage. Until that is demonstrated by generated code and allocation tests,
closure-backed `Button` APIs remain dynamic-only.

### 3.4 Predictable memory and execution

GiftUI should allow a target to determine or bound:

- state storage;
- render command capacity;
- event queue capacity;
- tree traversal depth;
- text buffer capacity;
- framebuffer memory;
- per-frame work.

### 3.5 Backend replaceability

A backend implementation must reside outside `GiftUICore`. The PoC framebuffer backend must be independently importable and replaceable.

### 3.6 Cost model and containment

Supporting both runtime profiles has a real engineering cost:

- two storage/runtime implementations and their diagnostics;
- a deliberately smaller portable API surface;
- bounded variants of text, actions, lists, state, and render queues;
- resource accounting and overflow tests that dynamic-only frameworks avoid;
- semantic conformance tests run against both runtimes;
- platform adapters and hardware drivers with their own validation fixtures;
- documentation that classifies each public API by capability.

This is not a duplicate implementation of the entire framework. View
composition, geometry, layout rules, render-operation semantics, and input
semantics remain shared. The principal duplication is storage/execution:
state, nodes, text, actions, queues, invalidation bookkeeping, and render
staging. In practical planning, the first static runtime is a substantial
framework milestone comparable to implementing a second runtime, while each
later platform or hardware target should mostly pay for its adapter/driver and
end-to-end validation rather than another GiftUI core.

This cost must be contained by testing contracts in layers rather than testing
the full Cartesian product of every runtime, backend, platform, and device:

1. run shared semantic suites against dynamic and static host runtimes;
2. run renderer contracts once per backend;
3. run event-loop/input contracts once per platform adapter;
4. run driver tests once per hardware controller;
5. run end-to-end tests only for configurations declared supported in the
   configuration matrix.

Each new feature pays the two-profile cost only if it is classified portable.
A dynamic convenience needs dynamic tests and a documented portable
alternative when equivalent behavior is required. A platform or hardware
feature remains below the core and does not multiply the runtime API surface.

Review of a public API addition must answer:

- Which feature class does it belong to?
- What storage and execution bounds does it impose?
- What is its portable alternative, if one is needed?
- Which contract suites and supported configurations must exercise it?
- Does it introduce conditional compilation outside an approved boundary?

---

## 4. Scope

## 4.1 PoC scope

The PoC includes:

- `View`;
- `ViewBuilder`;
- client-defined composite views;
- `EmptyView`;
- tuple/group composition for the arity needed by the example;
- conditional content if inexpensive to include;
- `Text`;
- `Button`;
- `VStack`;
- `HStack`;
- spacing;
- minimal intrinsic measurement;
- minimal horizontal and vertical layout;
- `@State`;
- state persistence across body recomputation;
- invalidation and complete-root re-rendering;
- button hit testing;
- pointer/touch-like press input;
- abstract rendering backend;
- separate framebuffer backend;
- host-side simulator or test harness;
- deterministic tests.

## 4.2 Explicit PoC non-goals

The first PoC does not need:

- diffing of arbitrary retained view trees;
- partial subtree reconciliation;
- animations;
- transitions;
- scroll views;
- text wrapping;
- font fallback;
- accessibility;
- localization framework;
- environment values;
- preference keys;
- bindings beyond what is necessary for internal state;
- navigation;
- dynamic lists;
- asynchronous tasks;
- production-quality Unicode shaping;
- GPU acceleration;
- multiple simultaneous windows;
- public ABI stability.

---

## 5. Proposed Package and Module Structure

```text
GiftUI/
├── Package.swift
├── Sources/
│   ├── GiftUICore/
│   │   ├── View/
│   │   ├── Builder/
│   │   ├── PrimitiveViews/
│   │   ├── Containers/
│   │   ├── State/
│   │   ├── Layout/
│   │   ├── Input/
│   │   ├── Rendering/
│   │   └── Geometry/
│   │
│   ├── GiftUIRuntimeDynamic/
│   │   ├── DynamicStateStorage/
│   │   ├── DynamicEventQueue/
│   │   └── DynamicRenderStorage/
│   │
│   ├── GiftUIRuntimeStatic/
│   │   ├── FixedStateArena/
│   │   ├── FixedEventQueue/
│   │   └── FixedRenderStorage/
│   │
│   ├── GiftUIBackendFramebuffer/
│   │   ├── FramebufferBackend/
│   │   ├── PixelFormat/
│   │   ├── Rasterizer/
│   │   ├── BitmapFont/
│   │   └── FramebufferSurface/
│   │
│   ├── GiftUISimulator/
│   │   ├── HostWindow/
│   │   ├── InputAdapter/
│   │   └── FramebufferPresenter/
│   │
│   └── GiftUIExampleThermostat/
│       ├── ThermostatView.swift
│       └── Main.swift
│
└── Tests/
    ├── GiftUICoreTests/
    ├── GiftUIRuntimeDynamicTests/
    ├── GiftUIRuntimeStaticTests/
    ├── GiftUIBackendFramebufferTests/
    └── GiftUIIntegrationTests/
```

### Module rules

#### `GiftUICore`

Must contain only backend-independent concepts:

- view declarations;
- builders;
- geometry;
- layout contracts;
- state contracts;
- render operations or backend protocol;
- input events;
- tree traversal.

It must not import the framebuffer backend.

#### `GiftUIRuntimeDynamic`

May use:

- heap allocation;
- arrays and dictionaries;
- reference types;
- escaping closures;
- dynamically growing storage.

#### Dynamic convenience extensions

Dynamic-only public conveniences must be isolated from the portable core,
whether implemented as a separate `GiftUIDynamicConveniences` module or as a
narrowly scoped product facade. They may add:

- closure-backed control initializers;
- unbounded `String` formatting;
- dynamically growing collection views;
- other APIs whose contract permits heap growth.

Importing a dynamic runtime must not make the portable core depend on these
extensions. A portable application should be able to compile without them.

#### `GiftUIRuntimeStatic`

Must support:

- fixed-capacity storage;
- explicit overflow handling;
- no mandatory heap allocation;
- no mandatory dynamically growing collections;
- no runtime reflection.

#### `GiftUIBackendFramebuffer`

Implements the abstract backend using a pixel buffer. It must not be required by `GiftUICore`.

#### `GiftUISimulator`

Provides a desktop development loop by displaying framebuffer output and translating mouse/keyboard input into GiftUI input events.

---

## 6. Core View Model

## 6.1 `View`

The public protocol should resemble:

```swift
public protocol View {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }
}
```

Primitive views cannot recursively define meaningful bodies. The implementation may use one of these strategies:

### Strategy A: marker protocol

```swift
public protocol PrimitiveView: View {}

public struct NoBody: View {
    public var body: NoBody {
        fatalError("NoBody must never be evaluated")
    }
}
```

Primitive rendering is detected through an internal overload or visitor.

### Strategy B: separate internal render conformance

```swift
public protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

package protocol _PrimitiveView {
    func _makeNode(in context: inout BuildContext) -> Node
}
```

Strategy B is preferred if it avoids exposing an artificial `Never` or `NoBody` model in the public API.

## 6.2 Composite client views

Any non-primitive `View` is expanded by evaluating its body and recursively processing the returned concrete view type.

Requirements:

- nested client views work at arbitrary practical depth;
- the client view type does not need registration;
- no global type map is required;
- generic specialization should resolve body types at compile time.

---

## 7. Result Builder

A minimal builder:

```swift
@resultBuilder
public enum ViewBuilder {
    public static func buildBlock() -> EmptyView

    public static func buildBlock<Content: View>(
        _ content: Content
    ) -> Content

    public static func buildBlock<A: View, B: View>(
        _ a: A,
        _ b: B
    ) -> TupleView<(A, B)>

    public static func buildBlock<A: View, B: View, C: View>(
        _ a: A,
        _ b: B,
        _ c: C
    ) -> TupleView<(A, B, C)>

    public static func buildEither<First: View, Second: View>(
        first: First
    ) -> ConditionalContent<First, Second>

    public static func buildEither<First: View, Second: View>(
        second: Second
    ) -> ConditionalContent<First, Second>

    public static func buildOptional<Content: View>(
        _ content: Content?
    ) -> OptionalContent<Content>
}
```

The PoC needs enough `buildBlock` overloads for its acceptance example. Future versions should investigate parameter packs to avoid manual arity overloads.

The builder must not erase children to `[any View]`.

---

## 8. Primitive and Container Views

## 8.1 `Text`

Proposed API:

```swift
public struct Text: View {
    public init(_ content: String)
}
```

PoC responsibilities:

- store or reference textual content;
- report intrinsic size using the selected font metrics;
- emit a text draw operation;
- support interpolation through normal Swift string interpolation.

Static-profile consideration:

- production static targets may require bounded strings or static string storage;
- the PoC may initially use `String` on the host/dynamic profile;
- the text abstraction must leave room for:
  - `StaticString`;
  - fixed-capacity UTF-8 storage;
  - string table identifiers;
  - externally supplied buffers.

Profile rule:

- static strings and explicitly bounded text/formatting belong to the portable
  profile;
- unbounded `String` construction and interpolation belong to the dynamic
  convenience profile until their storage can be bounded and verified;
- both paths must produce equivalent glyph/layout semantics for text that fits
  within the portable representation.

## 8.2 `Button`

PoC API:

```swift
public struct Button<Label: View>: View {
    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    )
}

public extension Button where Label == Text {
    init(_ title: String, action: @escaping () -> Void)
}
```

Dynamic runtime:

- may store an escaping closure.

Portable/static API:

```swift
public struct Button<Label: View, Action: GiftUIAction>: View {
    public init(
        action: Action,
        @ViewBuilder label: () -> Label
    )
}
```

or:

```swift
Button("-", action: AppAction.decrement)
```

The PoC may implement closure-based actions first, but the core architecture must not make closures the only possible event representation.

The closure-backed initializers are dynamic conveniences. They may remain
available to current macOS and Linux clients through the dynamic facade, but a
portable view must use a typed action unless allocation-free closure lowering
has been proven for the selected Embedded Swift toolchain. This distinction is
compile-time API selection, not a runtime `if available` branch.

Button responsibilities:

- measure its label plus internal padding;
- arrange its label;
- emit background/border/text operations as needed;
- register a hit region and action token;
- invoke the matching action on pointer release or click.

## 8.3 `VStack`

```swift
public struct VStack<Content: View>: View {
    public init(
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    )
}
```

PoC behavior:

- children are arranged from top to bottom;
- the gap between adjacent children equals `spacing`;
- width equals the maximum child width;
- height equals the sum of child heights plus gaps;
- children may be horizontally centered by default.

## 8.4 `HStack`

```swift
public struct HStack<Content: View>: View {
    public init(
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    )
}
```

PoC behavior:

- children are arranged from left to right;
- the gap between adjacent children equals `spacing`;
- width equals the sum of child widths plus gaps;
- height equals the maximum child height;
- children may be vertically centered by default.

---

## 9. State System

## 9.1 Required semantics

`@State` must:

- preserve its value across repeated evaluations of a view's `body`;
- expose ordinary read/write syntax;
- invalidate the UI after mutation;
- associate storage with a stable structural identity;
- support multiple state properties in one view;
- support state inside nested client-defined views.

This is not sufficient:

```swift
@propertyWrapper
struct State<Value> {
    var wrappedValue: Value
}
```

A client `View` value may be recreated on each render, so state must live outside the transient view value.

## 9.2 Proposed identity model for PoC

Use **structural path identity**.

Each view encountered during traversal receives a path such as:

```text
root
root.body.child[0]
root.body.child[1]
root.body.child[2].child[0]
```

Each state property receives an additional slot index:

```text
root/state[0]
root.body.child[2]/state[0]
```

A state key consists of:

```swift
struct StateKey: Hashable {
    let viewPath: ViewPath
    let slotIndex: Int
}
```

The traversal context assigns state slots deterministically in declaration/access order.

### PoC limitations

Structural identity assumes stable topology. Inserting or removing siblings may shift identities. This is acceptable for the PoC and must be documented.

Future versions should support explicit identity:

```swift
view.id(deviceID)
```

and reconciliation rules similar to retained declarative UI systems.

## 9.3 Proposed wrapper shape

Conceptual API:

```swift
@propertyWrapper
public struct State<Value> {
    private let initialValue: Value
    private var location: StateLocation<Value>?

    public init(wrappedValue: Value)

    public var wrappedValue: Value {
        get
        nonmutating set
    }
}
```

During body evaluation, the runtime binds each state wrapper to external storage.

Possible implementation approaches:

1. Compiler-visible enclosing-instance mechanisms, if suitable.
2. A runtime task/thread-local build context in dynamic environments.
3. Explicit internal binding during view traversal.
4. Generated or synthesized state descriptors in a later implementation.

The PoC implementation may use a controlled global/current-render context on a single-threaded host, but this must remain internal and replaceable.

## 9.4 Dynamic state storage

Possible implementation:

```swift
final class DynamicStateStore {
    private var values: [StateKey: AnyStateBox]
}
```

Requirements:

- type mismatch for an existing key is treated as a programmer/runtime error;
- value updates set `needsRender = true`;
- action processing and rendering occur serially.

## 9.5 Static state storage

Static runtime should use a fixed arena:

```swift
struct StaticStateArena<Storage> {
    // Fixed-size byte storage or generated typed slots.
}
```

Possible strategies:

- fixed byte arena with alignment-aware typed slots;
- compile-time-generated application state layout;
- fixed-capacity heterogeneous slot table;
- explicit client-owned state model passed into views;
- enum-tagged state slots for known value types.

Required behavior:

- capacity is known or bounded;
- exhaustion returns a deterministic error;
- no silent allocation fallback;
- state access does not require reflection.

---

## 10. Update and Rendering Cycle

The PoC may re-render the entire root after each state change.

```text
Input event
    ↓
Hit test
    ↓
Invoke action
    ↓
State mutation
    ↓
Mark root invalid
    ↓
Evaluate root body
    ↓
Measure
    ↓
Arrange
    ↓
Emit backend operations
    ↓
Present frame
```

Suggested runtime API:

```swift
public struct GiftUIApplication<Root: View, Backend: GiftUIBackend> {
    public init(root: Root, backend: Backend)

    public mutating func renderIfNeeded()
    public mutating func send(_ event: InputEvent)
}
```

Requirements:

- initial render occurs before input;
- multiple state mutations during one action may coalesce into one frame;
- rendering is non-reentrant;
- action execution is serialized;
- state mutation during rendering should either be rejected or deferred.

---

## 11. Layout Architecture

## 11.1 PoC layout phases

Use two explicit phases.

### Measure

```swift
func measure(
    proposal: ProposedSize,
    context: inout LayoutContext
) -> Size
```

### Arrange/render

```swift
func place(
    in bounds: Rect,
    context: inout LayoutContext
)
```

Alternative: arrange into a lightweight layout tree, then render it. This may simplify hit testing.

## 11.2 Geometry types

```swift
public struct Size {
    public var width: Int
    public var height: Int
}

public struct Point {
    public var x: Int
    public var y: Int
}

public struct Rect {
    public var origin: Point
    public var size: Size
}

public struct ProposedSize {
    public var width: Int?
    public var height: Int?
}
```

For the PoC, integer coordinates are preferred because they map directly to framebuffer pixels and avoid mandatory floating-point support.

## 11.3 Minimal intrinsic sizes

- `Text`: bitmap-font glyph width × character count, plus font-specific spacing.
- `Button`: label size plus fixed horizontal and vertical padding.
- `VStack`: aggregate child sizes vertically.
- `HStack`: aggregate child sizes horizontally.

## 11.4 Root layout

The root receives the framebuffer dimensions as its proposal.

The PoC may center the root content within the framebuffer.

---

## 12. Abstract Backend

## 12.1 Backend responsibilities

The backend must:

- expose the render surface size;
- begin and end a frame;
- clear or initialize the frame;
- draw primitive geometry;
- draw text through a defined font abstraction;
- present or flush the completed frame;
- remain independent of client view types.

The backend must not:

- evaluate `body`;
- own `@State`;
- make layout decisions;
- know about `VStack` or `HStack`;
- invoke client actions;
- perform structural view reconciliation.

## 12.2 Proposed backend protocol

```swift
public protocol GiftUIBackend {
    associatedtype Color
    associatedtype Font

    var surfaceSize: Size { get }

    mutating func beginFrame()
    mutating func clear(_ color: Color)

    mutating func fill(
        _ rect: Rect,
        color: Color
    )

    mutating func stroke(
        _ rect: Rect,
        color: Color,
        lineWidth: Int
    )

    mutating func drawText(
        _ text: TextStorage,
        at origin: Point,
        font: Font,
        color: Color
    )

    mutating func endFrame()
    mutating func present()
}
```

The exact associated types may be replaced with backend-independent core types when that produces simpler application-independent rendering.

## 12.3 Preferred render boundary

GiftUICore should lower views into a compact set of primitive render operations:

```swift
enum RenderOperation {
    case fillRect(Rect, Color)
    case strokeRect(Rect, Color, lineWidth: Int)
    case text(TextRun)
}
```

Dynamic runtime may store these in an array.

Static runtime may emit them directly or store them in a fixed-capacity buffer.

The design should support both modes:

```swift
renderer.render(root, directlyInto: &backend)
```

and:

```swift
let displayList = renderer.makeDisplayList(root)
backend.execute(displayList)
```

Direct emission is preferred for the smallest static targets.

---

## 13. Framebuffer Backend Module

`GiftUIBackendFramebuffer` is the PoC backend and must remain a separate module.

## 13.1 Responsibilities

- own or reference a framebuffer surface;
- map backend-independent colors to pixel values;
- rasterize rectangles;
- rasterize button borders/backgrounds;
- render text using a bitmap font;
- support at least one pixel format;
- expose output for tests and host simulation;
- flush changed or complete buffers to the device adapter.

## 13.2 Surface abstraction

```swift
public protocol FramebufferSurface {
    var width: Int { get }
    var height: Int { get }
    var bytesPerRow: Int { get }

    mutating func withMutableBytes<R>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R

    mutating func present()
}
```

For strict static targets, a concrete surface may wrap statically allocated memory.

## 13.3 Initial pixel format

Use one simple format for the PoC:

- `ARGB8888`, `RGBA8888`, or
- monochrome 1-bit if the first target requires it.

A host simulator is easiest with 32-bit pixels. The implementation should isolate encoding so future formats can be added:

- RGB565;
- grayscale 8-bit;
- monochrome 1-bit;
- e-paper packed formats.

## 13.4 Bitmap font

The PoC font should:

- use fixed-size glyphs;
- support the characters needed by the example:
  - digits;
  - uppercase/lowercase Latin characters;
  - `+`;
  - `-`;
  - degree symbol, or a documented fallback;
- provide deterministic glyph metrics;
- avoid external font-system dependencies in the backend core.

```swift
public protocol BitmapFont {
    var glyphSize: Size { get }
    func glyph(for scalar: Unicode.Scalar) -> GlyphBitmap?
}
```

## 13.5 Device adaptation

Hardware-specific display transport must be below the framebuffer backend:

```text
GiftUICore
    ↓
GiftUIBackendFramebuffer
    ↓
FramebufferSurface
    ↓
SPI LCD / memory-mapped LCD / e-paper / simulator window
```

GiftUI must not contain SPI, DMA, display-controller, or OS windowing code.

---

## 14. Input and Hit Testing

## 14.1 Input events

Minimal input model:

```swift
public enum InputEvent {
    case pointerDown(Point)
    case pointerUp(Point)
    case pointerMove(Point)
}
```

Optional host shortcut:

```swift
case click(Point)
```

## 14.2 Hit regions

During layout, interactive views register:

```swift
struct HitRegion {
    let bounds: Rect
    let actionID: ActionID
}
```

Requirements:

- later/deeper regions win when overlap exists;
- `Button` fires only according to a documented gesture rule;
- the action table is rebuilt per frame or kept consistent with the frame;
- static runtime uses fixed-capacity hit-region storage.

---

## 15. Dynamic Runtime Profile

The dynamic runtime is the first recommended implementation target.

### Allowed facilities

- `Array`;
- `Dictionary`;
- classes;
- escaping closures;
- heap-backed strings;
- boxed heterogeneous state;
- dynamic render-command lists.

### Proposed initial implementation

- root-wide re-render;
- dictionary-backed state;
- array-backed layout nodes;
- array-backed hit regions;
- closure-backed button actions;
- framebuffer display list;
- single-threaded run loop.

### Benefits

- fastest route to validating the API;
- easiest simulator implementation;
- simplest diagnostics;
- suitable as the foundation for Qt and desktop-host backends.

Dynamic convenience conformance does not expand the portable contract. A
dynamic runtime must run portable views with the same semantics as the static
runtime, then may additionally accept dynamic-only APIs.

---

## 16. Static Runtime Profile

The static profile must implement the portable declarative API while replacing
runtime storage. It is not required to accept APIs classified as dynamic
conveniences.

### Constraints

- no mandatory heap;
- no unbounded arrays;
- no heterogeneous `Any` dictionary;
- no mandatory escaping closure storage;
- bounded recursion or documented stack requirements;
- deterministic failure on capacity exhaustion.

### Required abstractions

```swift
public protocol StateStorage {
    mutating func access<Value>(
        key: StateKey,
        initialValue: @autoclosure () -> Value
    ) -> StateReference<Value>
}

public protocol ActionStorage {
    mutating func register<Action: GiftUIAction>(
        _ action: Action,
        bounds: Rect
    ) -> ActionID
}

public protocol RenderStorage {
    mutating func append(_ operation: RenderOperation) throws
}
```

Concrete static implementations may be generated for an application or configured with capacities.

### Static action model

Preferred direction:

```swift
protocol GiftUIAction {
    mutating func perform(in context: inout ApplicationContext)
}
```

or application action enums:

```swift
enum ThermostatAction {
    case decrement
    case increment
}
```

The root runtime dispatches actions without heap-allocated closures.

Selecting the static profile must make dynamic-only overloads unavailable at
compile time. The static runtime must not retain placeholder implementations
that trap when invoked.

### Static text model

Future static-safe text options:

```swift
Text(StaticString)
Text(resource: StringResourceID)
Text(buffer: FixedString<32>)
```

The PoC may defer these variants while preserving extension points.

---

## 17. Diagnostics and Failure Policy

GiftUI must avoid silent undefined behavior.

Recommended runtime errors:

- state storage exhausted;
- state key reused with an incompatible type;
- render-command storage exhausted;
- hit-region storage exhausted;
- layout arithmetic overflow;
- unsupported glyph;
- invalid framebuffer dimensions;
- reentrant render;
- state mutation during forbidden phase.

Dynamic host builds should provide descriptive assertions.

Static release builds should expose configurable policies:

```swift
enum GiftUIFailurePolicy {
    case trap
    case returnError
    case invokeHandler
}
```

---

## 18. PoC Acceptance Criteria

The PoC is complete when all criteria below pass.

### 18.1 Compilation and API

- The exact `ThermostatView` example compiles with no backend types in the view.
- `body` uses `some View`.
- `VStack` and `HStack` use result-builder trailing closures.
- `@State private var target` compiles and behaves correctly.
- A nested client-defined view compiles and renders.

### 18.2 Rendering

- The framebuffer is cleared and redrawn.
- `Target`, the temperature, and two buttons appear.
- Stack spacing is visible and deterministic.
- Text and button bounds do not overlap.
- Output is testable as raw pixels or a deterministic image fixture.

### 18.3 Interaction

- Hit testing identifies both buttons.
- Pressing decrement updates `21°` to `20°`.
- Pressing increment updates `21°` to `22°`.
- Repeated presses continue updating state.
- A press outside button bounds performs no action.

### 18.4 State

- State survives body recomputation.
- State does not reset to `21` after each frame.
- Separate instances of `ThermostatView` have separate state.
- State inside a nested client view can be added and preserved.

### 18.5 Modularity

- `GiftUICore` builds without importing `GiftUIBackendFramebuffer`.
- The example selects the framebuffer backend in the application entry point.
- A test backend can replace the framebuffer backend without modifying the view declarations.

### 18.6 Static-profile readiness

The first implementation does not need to be allocation-free, but it must document every dynamic dependency and place it behind replaceable runtime storage abstractions.

---

## 19. Testing Strategy

## 19.1 Builder tests

- empty block;
- one child;
- two children;
- three children;
- nested blocks;
- optional child;
- conditional child.

## 19.2 Layout tests

- intrinsic text size;
- button padding;
- horizontal aggregation;
- vertical aggregation;
- spacing;
- centering;
- nested stacks;
- zero-size surface;
- constrained surface.

## 19.3 State tests

- initial value;
- mutation;
- invalidation;
- persistence;
- multiple slots;
- nested state;
- separate root instances;
- type mismatch detection.

## 19.4 Backend tests

- clear;
- fill rectangle;
- stroke rectangle;
- glyph rasterization;
- clipping;
- pixel-format encoding;
- framebuffer bounds safety.

## 19.5 Integration snapshot tests

Render the thermostat interface into an in-memory framebuffer and compare against a committed fixture or deterministic pixel hash.

---

## 20. Suggested Implementation Sequence

### Milestone 1: Static view composition

Implement:

- `View`;
- `ViewBuilder`;
- `TupleView`;
- `EmptyView`;
- composite view expansion;
- `Text`;
- `VStack`;
- `HStack`.

Validate nested client views without state or interaction.

### Milestone 2: Layout

Implement:

- geometry;
- measurement;
- placement;
- stack spacing;
- deterministic root positioning.

Validate layout through a recording backend.

### Milestone 3: Abstract backend

Implement:

- backend protocol;
- render operations;
- recording/test backend.

Keep framebuffer work out of `GiftUICore`.

### Milestone 4: Framebuffer backend

Implement:

- framebuffer surface;
- rectangle rasterization;
- bitmap font;
- host-presentable output.

### Milestone 5: State

Implement:

- state store;
- structural identity;
- `@State`;
- invalidation;
- root re-render.

### Milestone 6: Button and input

Implement:

- button measurement and rendering;
- hit-region registration;
- input dispatch;
- action execution;
- state-driven updates.

### Milestone 7: Runtime abstraction

Extract dynamic storage behind protocols needed by the static runtime.

### Milestone 8: Static runtime experiment

Build one allocation-bounded thermostat variant with:

- fixed state capacity;
- fixed hit-region capacity;
- direct framebuffer emission;
- enum or typed actions.

---

## 21. Future Directions

## 21.1 Robust layout system

The PoC stack layout should evolve into a general proposal-based layout system supporting:

- minimum, ideal, and maximum sizes;
- alignment guides;
- flexible and fixed sizing;
- padding;
- frames and constraints;
- spacers;
- overlays and backgrounds;
- grids;
- wrapping stacks;
- safe-area or display-inset concepts;
- baseline alignment;
- layout priority;
- custom client layouts;
- clipping;
- coordinate spaces;
- scrolling;
- right-to-left layout;
- fractional or fixed-point geometry where needed.

The layout engine should remain independent of every backend.

Potential API direction:

```swift
public protocol Layout {
    associatedtype Cache

    func makeCache(
        subviews: LayoutSubviews
    ) -> Cache

    func sizeThatFits(
        proposal: ProposedSize,
        subviews: LayoutSubviews,
        cache: inout Cache
    ) -> Size

    func placeSubviews(
        in bounds: Rect,
        proposal: ProposedSize,
        subviews: LayoutSubviews,
        cache: inout Cache
    )
}
```

For static targets, subview and cache storage must support fixed-capacity alternatives.

## 21.2 View modifiers without uncontrolled generic type growth

A naïve SwiftUI-like modifier model creates deeply nested types:

```text
Frame<
    Background<
        Padding<
            Text
        >
    >
>
```

This may increase:

- specialization count;
- compiler work;
- symbol count;
- code size;
- debug-type size.

GiftUI should investigate a normalized modifier architecture.

Possible approaches:

### Consolidated layout/style properties

Common modifiers update a compact property set:

```swift
struct ViewAttributes {
    var padding: EdgeInsets
    var frame: FrameConstraint
    var foreground: Color?
    var background: BackgroundStyle?
    var visibility: Visibility
}
```

Several source-level modifiers can still return one stable wrapper type:

```swift
ModifiedView<Content>
```

rather than one generic wrapper per modifier kind.

### Modifier list with fixed or dynamic storage

```swift
struct ModifiedView<Content: View, Storage: ModifierStorage>: View {
    let content: Content
    let modifiers: Storage
}
```

- dynamic profile: small-vector or array-backed storage;
- static profile: fixed-capacity inline storage;
- renderer normalizes modifiers before layout.

### Compile-time modifier fusion

Builder/helper functions may fuse adjacent modifiers into a single descriptor where specialization allows it.

### Split semantic modifiers from render styles

Structural modifiers that truly change the tree may remain generic. Common styling modifiers should collapse into data.

The public syntax should still allow:

```swift
Text("Target")
    .padding(4)
    .background(.gray)
    .frame(minWidth: 40)
```

The implementation must measure binary-size effects before committing to a model.

## 21.3 Retained rendering and reconciliation

For capable systems:

- retain backend nodes;
- diff structural trees;
- update only changed properties;
- preserve explicit identities;
- support lifecycle callbacks;
- coalesce updates;
- skip unaffected subtrees.

Immediate full-tree rendering should remain available for small displays.

## 21.4 Backend integrations

### Qt backend

A separate `GiftUIBackendQt` module may:

- map GiftUI primitives to Qt widgets or QML scene items;
- use C++ interoperability;
- support allocating embedded Linux environments;
- run within the Qt event loop;
- retain native controls where appropriate.

GiftUI application views must not import Qt.

### LVGL backend

A separate `GiftUIBackendLVGL` module may:

- map view primitives to LVGL objects;
- bridge through C interoperability;
- support common MCU display/input drivers;
- optionally use LVGL's retained object tree and layout;
- translate LVGL events into GiftUI actions.

The integration must clearly decide whether GiftUI or LVGL owns layout for each rendering mode.

### SDL or desktop backend

Useful for:

- fast host simulation;
- CI rendering;
- keyboard/mouse input;
- profiling;
- screenshot tests.

### Direct hardware renderers

Potential modules:

- monochrome OLED;
- RGB565 SPI LCD;
- e-paper;
- memory-mapped display controller;
- terminal/text-mode display.

The concrete migration plan for an allocation-bounded RGB565 renderer on the
Nordic nRF52840-DK, including ILI9486 display and ADS7846 touch integration, is
defined in
[`GiftUI_nRF52840_DK_Platform_Spec.md`](GiftUI_nRF52840_DK_Platform_Spec.md).

### RTOS integration

Adapters may integrate GiftUI's update loop with:

- Zephyr;
- FreeRTOS;
- ThreadX;
- custom cooperative schedulers.

The core must not depend on a particular scheduler.

## 21.5 Input integrations

Future input types:

- rotary encoder;
- directional buttons;
- keypad;
- capacitive touch;
- mouse;
- keyboard;
- hardware soft keys;
- accessibility switches.

All should lower into backend-neutral semantic events.

## 21.6 State and data flow

Potential additions:

- `Binding`;
- observable models;
- environment values;
- dependency injection;
- derived state;
- explicit transactions;
- asynchronous event sources;
- task cancellation;
- actor-aware dynamic runtime;
- generated state layouts for static builds.

## 21.7 Tooling

Potential tooling:

- layout debugger;
- view-tree dump;
- state-slot inspector;
- framebuffer snapshot exporter;
- binary-size report by view specialization;
- compile-time generated resource tables;
- bitmap-font converter;
- image asset packer;
- static-capacity estimator;
- simulator hot reload where supported.

---

## 22. Architectural Decisions to Preserve

Implementations may change, but these constraints should remain stable:

1. Client view declarations are backend-independent.
2. The framebuffer backend is a separate module.
3. Composite views are generic and compile-time composable.
4. The core does not require reflection or unrestricted existential storage.
5. State lives outside transient view values.
6. Static and dynamic storage are replaceable runtime strategies.
7. The first renderer may redraw the whole root.
8. Layout belongs to GiftUICore, not to the framebuffer backend.
9. Hardware display transport is below the framebuffer surface abstraction.
10. Dynamic conveniences must not prevent a later allocation-bounded runtime.
11. Cross-platform source invariance is guaranteed for the portable profile,
    not for every dynamic convenience.
12. Runtime-profile selection is compile time; hardware presence belongs to
    the owning platform module at runtime.
13. Conditional compilation is confined to capability/module boundaries and
    must not spread through portable view declarations or layout semantics.
14. Supported configurations are explicit; GiftUI does not promise every
    runtime × backend × platform × hardware combination.

---

## 23. Definition of Done

The PoC is done when a host executable imports:

```swift
import GiftUICore
import GiftUIRuntimeDynamic
import GiftUIBackendFramebuffer
```

creates a framebuffer-backed application, renders `ThermostatView`, accepts
simulated button presses, and produces correctly updated pixels while the
`ThermostatView` source remains identical regardless of the selected backend.
This source-invariance requirement applies across runtime profiles only when
the view uses the portable API. A dynamic-only convenience may require a
portable typed or bounded alternative before the view can target a static
runtime.

The architecture must also demonstrate a credible replacement path for:

```text
GiftUIRuntimeDynamic → GiftUIRuntimeStatic
GiftUIBackendFramebuffer → GiftUIBackendQt / GiftUIBackendLVGL / another backend
```

without rewriting the application's declarative view hierarchy.

The static-runtime milestone must also demonstrate that unsupported dynamic
conveniences fail at compile time, that portable alternatives exist for the
thermostat's text and actions, and that the same portable thermostat source
runs under both static and dynamic host conformance tests.
