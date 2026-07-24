# GiftUI PoC A — macOS Simulator Specification

**Status:** Implementation specification  
**Target:** macOS simulator application  
**Primary client-facing framework:** `GiftUI`  
**Language:** Swift  
**Purpose:** Prove the GiftUI declarative API, state system, layout engine, framebuffer renderer, input routing, and backend isolation before targeting embedded Linux or microcontrollers.

---

## 1. Goal

Build a fully operable macOS proof of concept for GiftUI that supports the following client code:

```swift
import GiftUI

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

The PoC must render this interface into an in-memory framebuffer, display it in a macOS window, accept mouse input, update `@State`, and redraw the UI.

The same `ThermostatView` source must remain reusable with future Linux, SPI framebuffer, Qt, LVGL, or direct embedded backends.

---

## 2. Scope

### Included

- SwiftUI-like declarative syntax.
- `View` protocol with `body`.
- `some View`.
- `@ViewBuilder`.
- `@State`.
- Client-defined nested views.
- `VStack`.
- `HStack`.
- `Text`.
- `Button`.
- Stack spacing.
- Intrinsic measurement.
- Basic layout.
- In-memory framebuffer.
- Bitmap-font rendering.
- Rectangle and border rasterization.
- Mouse-driven hit testing.
- State invalidation.
- Full-root redraw.
- macOS simulator window.
- Snapshot and unit tests.
- Modular backend-independent architecture.

### Excluded

- SwiftUI as the GiftUI runtime.
- AppKit views for each GiftUI view.
- Diffing or partial reconciliation.
- Animations.
- Scroll views.
- Dynamic collections such as `ForEach`.
- Advanced modifiers.
- Accessibility.
- Localization infrastructure.
- Production typography.
- GPU rendering.
- Embedded or allocation-free runtime.
- Raspberry Pi or MCU support.

AppKit may be used only by the simulator shell to create a window and present the framebuffer.

---

## 3. Development Environment

### 3.1 Required platform

- macOS 15 or newer.
- Apple Silicon preferred.
- Intel support is optional for the PoC.

### 3.2 Toolchain

- Xcode 16.3 or newer.
- Swift 6 language mode.
- Swift Package Manager.
- macOS command-line tools installed.

Verify:

```bash
xcode-select -p
swift --version
swift package --version
```

### 3.3 Recommended project form

Use a single Swift package containing reusable libraries, the simulator, the example application, and tests.

No `.xcodeproj` is required for the first implementation.

```bash
open Package.swift
```

### 3.4 Compiler settings

Recommended:

```swift
swiftLanguageModes: [.v6]
```

Suggested platform declaration:

```swift
platforms: [
    .macOS(.v15)
]
```

The first runtime should be main-thread-confined and single-threaded even if strict concurrency checking is enabled.

---

## 4. Dependency Policy

The PoC should minimize external dependencies.

### Required dependencies

- Swift standard library.
- Foundation.
- AppKit, only in the simulator module.
- CoreGraphics, only in the simulator presentation layer if needed.
- XCTest or Swift Testing.

### External dependencies

None are required.

SDL2 may be introduced later as an alternative presentation layer, but the initial PoC should prefer AppKit because it is already available on macOS.

### Forbidden dependencies in `GiftUI`

The client-facing `GiftUI` framework must not depend on:

- AppKit;
- SwiftUI;
- CoreGraphics;
- Metal;
- SDL;
- platform-specific event APIs;
- framebuffer device APIs;
- Raspberry Pi libraries;
- MCU SDKs.

---

## 5. Package Structure

```text
GiftUI/
├── Package.swift
├── README.md
├── Sources/
│   ├── GiftUI/
│   │   ├── View/
│   │   │   ├── View.swift
│   │   │   ├── PrimitiveView.swift
│   │   │   └── ViewBuilder.swift
│   │   ├── Composition/
│   │   │   ├── EmptyView.swift
│   │   │   ├── TupleView.swift
│   │   │   ├── ConditionalContent.swift
│   │   │   └── OptionalContent.swift
│   │   ├── PrimitiveViews/
│   │   │   ├── Text.swift
│   │   │   └── Button.swift
│   │   ├── Containers/
│   │   │   ├── VStack.swift
│   │   │   └── HStack.swift
│   │   ├── State/
│   │   │   ├── State.swift
│   │   │   ├── StateKey.swift
│   │   │   └── StateStorage.swift
│   │   ├── Geometry/
│   │   │   ├── Point.swift
│   │   │   ├── Size.swift
│   │   │   ├── Rect.swift
│   │   │   └── ProposedSize.swift
│   │   ├── Layout/
│   │   │   ├── LayoutNode.swift
│   │   │   ├── LayoutContext.swift
│   │   │   ├── Measure.swift
│   │   │   └── Placement.swift
│   │   ├── Rendering/
│   │   │   ├── RenderBackend.swift
│   │   │   ├── RenderOperation.swift
│   │   │   ├── Color.swift
│   │   │   └── TextRun.swift
│   │   ├── Input/
│   │   │   ├── InputEvent.swift
│   │   │   ├── HitRegion.swift
│   │   │   └── ActionID.swift
│   │   └── Runtime/
│   │       ├── GiftUIApplication.swift
│   │       ├── Invalidation.swift
│   │       └── TreeTraversal.swift
│   │
│   ├── GiftUIRuntimeDynamic/
│   │   ├── DynamicStateStore.swift
│   │   ├── DynamicActionStore.swift
│   │   ├── DynamicHitRegionStore.swift
│   │   └── DynamicRuntime.swift
│   │
│   ├── GiftUIBackendFramebuffer/
│   │   ├── FramebufferBackend.swift
│   │   ├── FramebufferSurface.swift
│   │   ├── MemoryFramebufferSurface.swift
│   │   ├── PixelFormat.swift
│   │   ├── PixelBuffer.swift
│   │   ├── Rasterizer.swift
│   │   ├── BitmapFont.swift
│   │   └── BuiltinFont8x12.swift
│   │
│   ├── GiftUISimulatorMac/
│   │   ├── SimulatorApplication.swift
│   │   ├── SimulatorWindow.swift
│   │   ├── FramebufferView.swift
│   │   ├── MouseInputAdapter.swift
│   │   └── FramePresenter.swift
│   │
│   └── GiftUIExampleThermostat/
│       ├── ThermostatView.swift
│       ├── TemperatureValueView.swift
│       └── main.swift
│
└── Tests/
    ├── GiftUITests/
    ├── GiftUIRuntimeDynamicTests/
    ├── GiftUIBackendFramebufferTests/
    └── GiftUIIntegrationTests/
```

---

## 6. Products and Dependency Graph

Recommended products:

```swift
products: [
    .library(name: "GiftUI", targets: ["GiftUI"]),
    .library(name: "GiftUIRuntimeDynamic", targets: ["GiftUIRuntimeDynamic"]),
    .library(name: "GiftUIBackendFramebuffer", targets: ["GiftUIBackendFramebuffer"]),
    .library(name: "GiftUISimulatorMac", targets: ["GiftUISimulatorMac"]),
    .executable(name: "GiftUIExampleThermostat", targets: ["GiftUIExampleThermostat"])
]
```

Dependency graph:

```text
GiftUI
    └── no platform-specific dependencies

GiftUIRuntimeDynamic
    └── GiftUI

GiftUIBackendFramebuffer
    └── GiftUI

GiftUISimulatorMac
    ├── GiftUI
    ├── GiftUIBackendFramebuffer
    ├── AppKit
    └── CoreGraphics

GiftUIExampleThermostat
    ├── GiftUI
    ├── GiftUIRuntimeDynamic
    ├── GiftUIBackendFramebuffer
    └── GiftUISimulatorMac
```

No dependency may point from `GiftUI` toward simulator, framebuffer, or dynamic-runtime modules.

---

## 7. Client-Facing Framework: `GiftUI`

`GiftUI` is the only framework application view declarations should import:

```swift
import GiftUI
```

It exposes:

- `View`;
- `ViewBuilder`;
- `State`;
- `Text`;
- `Button`;
- `VStack`;
- `HStack`;
- client-relevant geometry and styling types.

It does not expose:

- AppKit types;
- framebuffer memory;
- window management;
- action dictionaries;
- state boxes;
- simulator internals;
- backend-specific pixel formats unless promoted to a backend-neutral type.

---

## 8. Core API

### 8.1 `View`

```swift
public protocol View {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }
}
```

Composite views are expanded recursively by evaluating `body`.

Primitive views terminate expansion through an internal/package protocol:

```swift
package protocol _PrimitiveView {
    func _makeLayoutNode(
        context: inout BuildContext
    ) -> LayoutNode
}
```

Client-defined views must not need to conform to `_PrimitiveView`.

### 8.2 `ViewBuilder`

Minimum forms:

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

    public static func buildEither<A: View, B: View>(
        first: A
    ) -> ConditionalContent<A, B>

    public static func buildEither<A: View, B: View>(
        second: B
    ) -> ConditionalContent<A, B>

    public static func buildOptional<Content: View>(
        _ content: Content?
    ) -> OptionalContent<Content>
}
```

The PoC must not erase children to `[any View]`.

### 8.3 `Text`

```swift
public struct Text: View {
    public init(_ content: String)
}
```

Behavior:

- single-line text;
- fixed bitmap font;
- no wrapping;
- unsupported glyphs replaced by a fallback glyph;
- intrinsic size determined by glyph metrics.

### 8.4 `Button`

```swift
public struct Button<Label: View>: View {
    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    )
}

public extension Button where Label == Text {
    init(
        _ title: String,
        action: @escaping () -> Void
    )
}
```

Behavior:

- fixed internal padding;
- visible background or border;
- pointer hit region;
- action invoked after a valid click;
- redraw requested when action mutates state.

### 8.5 `VStack`

```swift
public struct VStack<Content: View>: View {
    public init(
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    )
}
```

Behavior:

- vertical arrangement;
- exact spacing between adjacent children;
- width equals maximum child width;
- height equals sum of child heights plus spacing;
- horizontal centering.

### 8.6 `HStack`

```swift
public struct HStack<Content: View>: View {
    public init(
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    )
}
```

Behavior:

- horizontal arrangement;
- exact spacing between adjacent children;
- width equals sum of child widths plus spacing;
- height equals maximum child height;
- vertical centering.

---

## 9. State Architecture

### 9.1 Required semantics

`@State` must:

- preserve values across body reevaluation;
- support ordinary property syntax;
- invalidate the application after mutation;
- work in nested client-defined views;
- keep separate state for separate structural positions.

### 9.2 External state storage

View values are transient. State must live in runtime-owned storage.

```swift
public protocol StateStorage {
    func read<Value>(
        key: StateKey,
        initialValue: @autoclosure () -> Value
    ) -> Value

    func write<Value>(
        _ value: Value,
        key: StateKey
    )
}
```

The final implementation may use typed references or boxes to avoid repeated lookup.

### 9.3 Structural identity

The PoC should use structural traversal paths:

```text
root
root.body.0
root.body.1
root.body.2
root.body.2.body.0
```

State properties receive slot indices:

```text
root/state/0
root.body.2/state/0
```

Known limitation: changing sibling order or conditionally inserting siblings may shift state identity.

### 9.4 Dynamic implementation

`GiftUIRuntimeDynamic` may use:

```swift
final class DynamicStateStore {
    private var storage: [StateKey: AnyStateBox]
}
```

Requirements:

- a type mismatch produces an assertion or explicit error;
- writes mark the root invalid;
- rendering and action processing occur on the main thread.

---

## 10. Runtime and Update Loop

Suggested host-facing API:

```swift
public final class GiftUIApplication<Root: View> {
    public init(
        root: Root,
        runtime: DynamicRuntime
    )

    public func render<Backend: RenderBackend>(
        into backend: inout Backend
    )

    public func send(_ event: InputEvent)
}
```

Alternative APIs are acceptable if backend independence is preserved.

Event flow:

```text
window mouse event
    ↓
GiftUI InputEvent
    ↓
hit test current layout
    ↓
invoke action
    ↓
state mutation
    ↓
mark invalid
    ↓
rebuild body
    ↓
measure
    ↓
place
    ↓
rasterize
    ↓
present framebuffer
```

Requirements:

- initial render occurs before input;
- rendering is non-reentrant;
- full-root redraw is acceptable;
- multiple mutations in one action should coalesce into one redraw where practical.

---

## 11. Layout

### 11.1 Geometry

Use integer geometry:

```swift
public struct Point {
    public var x: Int
    public var y: Int
}

public struct Size {
    public var width: Int
    public var height: Int
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

### 11.2 Phases

Measure:

```swift
func measure(
    proposal: ProposedSize,
    context: inout LayoutContext
) -> Size
```

Place:

```swift
func place(
    in bounds: Rect,
    context: inout LayoutContext
)
```

Render placed nodes into backend-independent drawing operations.

### 11.3 Root behavior

Default logical surface:

```text
240 × 240 pixels
```

The root view should be centered within the surface.

The simulator may scale each logical pixel by an integer factor without changing GiftUI layout coordinates.

---

## 12. Rendering Abstraction

### 12.1 Backend protocol

`GiftUI` defines the backend contract:

```swift
public protocol RenderBackend {
    var surfaceSize: Size { get }

    mutating func beginFrame()
    mutating func clear(_ color: Color)
    mutating func fill(_ rect: Rect, color: Color)
    mutating func stroke(
        _ rect: Rect,
        color: Color,
        lineWidth: Int
    )
    mutating func drawText(
        _ text: TextRun,
        at origin: Point
    )
    mutating func endFrame()
    mutating func present()
}
```

It must remain independent of AppKit and concrete framebuffer storage.

### 12.2 Render operations

The core may produce:

```swift
public enum RenderOperation {
    case fillRect(Rect, Color)
    case strokeRect(Rect, Color, lineWidth: Int)
    case text(TextRun)
}
```

The dynamic PoC may hold operations in an array. Direct backend emission is also acceptable.

---

## 13. Framebuffer Backend

Module:

```text
GiftUIBackendFramebuffer
```

### 13.1 Responsibilities

- allocate or receive pixel memory;
- clear the framebuffer;
- clip drawing operations;
- rasterize filled and stroked rectangles;
- rasterize bitmap-font glyphs;
- expose completed pixels to the simulator;
- remain independent of AppKit.

### 13.2 Initial pixel format

Use:

```text
RGBA8888
```

Reasons:

- straightforward memory layout;
- simple conversion to `CGImage`;
- easy snapshot export;
- no conversion needed for macOS presentation.

Future embedded formats may include RGB565, grayscale, monochrome, and packed e-paper formats.

### 13.3 Surface API

```swift
public protocol FramebufferSurface {
    var width: Int { get }
    var height: Int { get }
    var bytesPerRow: Int { get }

    func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R

    mutating func withUnsafeMutableBytes<R>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R
}
```

### 13.4 In-memory implementation

```swift
public struct MemoryFramebufferSurface: FramebufferSurface {
    public init(
        width: Int,
        height: Int,
        pixelFormat: PixelFormat
    )
}
```

Contiguous `[UInt8]` storage is acceptable for the PoC.

---

## 14. Bitmap Font

Use a compiled fixed-size bitmap font.

Recommended metrics:

```text
8 × 12 or 8 × 16 pixels per glyph
```

Required glyphs:

- ASCII letters;
- digits;
- space;
- `+`;
- `-`;
- common punctuation;
- degree symbol.

Unsupported glyphs should use a deterministic fallback.

Font data must not depend on AppKit font rendering.

---

## 15. macOS Simulator Module

Module:

```text
GiftUISimulatorMac
```

This is the only module that imports AppKit.

### 15.1 Responsibilities

- create `NSApplication`;
- create a window;
- display framebuffer pixels;
- map mouse events to GiftUI coordinates;
- trigger presentation after rendering;
- optionally map keyboard shortcuts;
- expose a simple simulator launcher API.

### 15.2 Window

Recommended configuration:

- title: `GiftUI Simulator`;
- logical surface: 240 × 240;
- scale: 3× or 4×;
- non-resizable initially;
- nearest-neighbor scaling;
- dark outer background.

### 15.3 Framebuffer presentation

Preferred path:

```text
RGBA framebuffer
    ↓
CGDataProvider
    ↓
CGImage
    ↓
NSView.draw(_:)
```

Recreating the image each frame is acceptable for the PoC.

Disable smoothing:

```swift
context.interpolationQuality = .none
```

### 15.4 Input mapping

Convert scaled AppKit coordinates to logical GiftUI pixels:

```swift
logicalX = Int(mouseX / scale)
logicalY = Int(mouseY / scale)
```

Account for AppKit's bottom-left origin.

```text
mouseDown    → pointerDown
mouseDragged → pointerMove
mouseUp      → pointerUp
```

---

## 16. Example Executable

Target:

```text
GiftUIExampleThermostat
```

Bootstrap example:

```swift
import GiftUI
import GiftUIRuntimeDynamic
import GiftUIBackendFramebuffer
import GiftUISimulatorMac

let simulator = GiftUISimulator(
    root: ThermostatView(),
    logicalSize: Size(width: 240, height: 240),
    scale: 3
)

simulator.run()
```

Application view declarations must not reference AppKit or framebuffer internals.

---

## 17. Nested Client Views

The PoC must support:

```swift
import GiftUI

struct TemperatureValueView: View {
    let value: Int

    var body: some View {
        Text("\(value)°")
    }
}

struct ControlsView: View {
    let decrement: () -> Void
    let increment: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button("-", action: decrement)
            Button("+", action: increment)
        }
    }
}

struct ThermostatView: View {
    @State private var target = 21

    var body: some View {
        VStack(spacing: 8) {
            Text("Target")
            TemperatureValueView(value: target)
            ControlsView(
                decrement: { target -= 1 },
                increment: { target += 1 }
            )
        }
    }
}
```

Requirements:

- subviews need no registration;
- nested bodies expand recursively;
- state remains owned by `ThermostatView`;
- actions passed through child views mutate the correct state.

---

## 18. Testing

### `GiftUITests`

Test:

- builder arities;
- nested client views;
- optional and conditional content;
- stack child extraction;
- geometry types.

### `GiftUIRuntimeDynamicTests`

Test:

- initial state;
- read/write;
- invalidation;
- persistence;
- multiple slots;
- nested state;
- independent root instances;
- incompatible state-type detection.

### `GiftUIBackendFramebufferTests`

Test:

- clear;
- clipping;
- filled rectangle;
- stroked rectangle;
- glyph rasterization;
- unsupported glyph fallback;
- pixel bounds safety.

### Layout tests

Test:

- text intrinsic size;
- button padding;
- stack spacing;
- stack aggregation;
- alignment;
- nested stacks;
- root centering.

### Integration tests

Render the thermostat into a 240 × 240 memory surface and verify:

- initial snapshot;
- hit-region positions;
- decrement click;
- increment click;
- resulting snapshots;
- state persistence after redraw.

Fixtures may use raw RGBA, PNG generated by a test helper, or deterministic hashes plus pixel assertions.

---

## 19. Build and Run

Build:

```bash
swift build
```

Test:

```bash
swift test
```

Run:

```bash
swift run GiftUIExampleThermostat
```

Release build:

```bash
swift build -c release
swift run -c release GiftUIExampleThermostat
```

---

## 20. Implementation Order

### Milestone 1 — Core composition

Implement `View`, primitive/composite distinction, `ViewBuilder`, tuple composition, empty content, and nested body expansion.

Validate with tree-dump tests.

### Milestone 2 — Geometry and layout

Implement geometry, text measurement, stacks, spacing, and root centering.

Validate through a recording layout backend.

### Milestone 3 — Framebuffer renderer

Implement RGBA storage, rectangle rasterization, bitmap font, clipping, and render operations.

### Milestone 4 — Simulator

Implement AppKit window creation, nearest-neighbor presentation, and mouse-coordinate conversion.

Render a static thermostat view.

### Milestone 5 — State

Implement dynamic state storage, structural keys, `@State`, invalidation, and full-root rebuild.

### Milestone 6 — Interaction

Implement button hit regions, mouse events, action dispatch, and redraw after state mutation.

### Milestone 7 — Hardening

Add diagnostics, snapshot tests, nested-view acceptance tests, documentation, and module dependency checks.

---

## 21. Acceptance Criteria

PoC A is complete when:

1. `swift build` succeeds on macOS.
2. `swift test` succeeds.
3. `swift run GiftUIExampleThermostat` opens a window.
4. The window displays the thermostat interface.
5. The logical rendering surface is 240 × 240 pixels.
6. The framebuffer is scaled without smoothing.
7. Clicking `-` decrements the displayed value.
8. Clicking `+` increments the displayed value.
9. State survives repeated body reevaluation.
10. Client-defined nested views render correctly.
11. Client view files import only `GiftUI`.
12. `GiftUI` imports neither AppKit nor SwiftUI.
13. The framebuffer backend is replaceable.
14. The simulator shell is replaceable.
15. Dynamic assumptions are documented for later static-runtime replacement.

---

## 22. Dynamic Assumptions to Track

PoC A may deliberately use:

- heap allocation;
- `Array`;
- `Dictionary`;
- `String`;
- `Any`-backed state boxes;
- escaping closures;
- AppKit event loop;
- full framebuffer;
- full-root redraw.

Each use should remain isolated so later work can replace it with:

- fixed-capacity arrays;
- generated state layouts;
- bounded strings;
- typed action enums;
- direct SPI framebuffer surfaces;
- tiled rendering;
- allocation-bounded runtime storage.

---

## 23. Future Platform Compatibility

The architecture must allow this progression:

```text
GiftUISimulatorMac
        ↓
GiftUIPlatformLinux
        ↓
GiftUIPlatformESP32 / GiftUIPlatformRP2040
```

And independently:

```text
GiftUIBackendFramebuffer
        ↓
GiftUIBackendQt
GiftUIBackendLVGL
GiftUIBackendMetal
another custom backend
```

Application-facing view code must continue to import only:

```swift
import GiftUI
```

---

## 24. Definition of Done

GiftUI PoC A is successful when the exact declarative thermostat UI runs as a native macOS executable, draws through GiftUI's own layout and framebuffer renderer, accepts mouse interaction, preserves `@State`, supports nested client-defined views, and keeps all AppKit-specific code outside the `GiftUI` framework.
