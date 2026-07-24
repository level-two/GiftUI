import GiftUI
import GiftUIBackendFramebuffer
import GiftUIRuntimeDynamic
import Testing

@Test
func modulesComposeWithoutPlatformDependencies() {
    #expect(GiftUIRuntimeDynamicModule.name.hasPrefix(GiftUIModule.name))
    #expect(GiftUIBackendFramebufferModule.name.hasPrefix(GiftUIModule.name))
}

@Test
func applicationRendersAndDispatchesThermostatButtons() {
    struct Thermostat: View {
        @State var target = 21

        var body: some View {
            VStack(spacing: 8) {
                Text("Target")
                Text("\(target)°")
                HStack(spacing: 8) {
                    Button("-") { target -= 1 }
                    Button("+") { target += 1 }
                }
            }
        }
    }

    var backend = RecordingBackend(
        surfaceSize: Size(width: 240, height: 240)
    )
    let application = GiftUIApplication(root: Thermostat())

    #expect(application.renderIfNeeded(into: &backend))
    #expect(backend.texts.map(\.0) == ["Target", "21°", "-", "+"])
    #expect(application.hitRegions.count == 2)
    #expect(application.hitRegions[0].bounds == Rect(
        origin: Point(x: 92, y: 128),
        size: Size(width: 24, height: 24)
    ))
    #expect(application.hitRegions[1].bounds == Rect(
        origin: Point(x: 124, y: 128),
        size: Size(width: 24, height: 24)
    ))
    #expect(!application.runtime.isInvalid)

    let increment = application.hitRegions[1].bounds
    let point = Point(
        x: increment.origin.x + increment.size.width / 2,
        y: increment.origin.y + increment.size.height / 2
    )
    #expect(!application.send(.pointerDown(point)))
    #expect(application.send(.pointerUp(point)))
    #expect(application.runtime.isInvalid)

    backend.texts.removeAll()
    #expect(application.renderIfNeeded(into: &backend))
    #expect(backend.texts.map(\.0) == ["Target", "22°", "-", "+"])
    #expect(!application.renderIfNeeded(into: &backend))
}

@Test
func nestedViewStatePersistsAcrossFullRootRebuilds() {
    struct NestedCounter: View {
        @State var count = 0

        var body: some View {
            VStack(spacing: 2) {
                Text("\(count)")
                Button("+") { count += 1 }
            }
        }
    }

    struct Root: View {
        var body: some View {
            NestedCounter()
        }
    }

    var backend = RecordingBackend(
        surfaceSize: Size(width: 80, height: 80)
    )
    let application = GiftUIApplication(root: Root())
    application.renderIfNeeded(into: &backend)

    let button = application.hitRegions[0].bounds
    let point = Point(x: button.origin.x + 1, y: button.origin.y + 1)
    application.send(.pointerDown(point))
    #expect(application.send(.pointerUp(point)))

    backend.texts.removeAll()
    application.renderIfNeeded(into: &backend)
    #expect(backend.texts.map(\.0) == ["1", "+"])
}

@Test
func draggingOutsideButtonCancelsAction() {
    var activations = 0
    var backend = RecordingBackend(
        surfaceSize: Size(width: 80, height: 80)
    )
    let application = GiftUIApplication(
        root: Button("Tap") { activations += 1 }
    )
    application.renderIfNeeded(into: &backend)

    let button = application.hitRegions[0].bounds
    let inside = Point(x: button.origin.x + 1, y: button.origin.y + 1)
    let outside = Point(x: 0, y: 0)
    application.send(.pointerDown(inside))
    application.send(.pointerMove(outside))
    #expect(!application.send(.pointerUp(inside)))
    #expect(activations == 0)
}

@Test
func thermostatFramebufferHasDeterministicInitialSnapshot() {
    struct Thermostat: View {
        var body: some View {
            VStack(spacing: 8) {
                Text("Target")
                Text("21°")
                HStack(spacing: 8) {
                    Button("-") {}
                    Button("+") {}
                }
            }
        }
    }

    var backend = FramebufferBackend(
        surface: MemoryFramebufferSurface(width: 240, height: 240)
    )
    let application = GiftUIApplication(root: Thermostat())
    application.renderIfNeeded(into: &backend)

    #expect(framebufferHash(backend.surface) == 5_328_133_023_529_522_418)
}

private struct RecordingBackend: RenderBackend {
    let surfaceSize: Size
    var texts: [(String, Point)] = []

    mutating func beginFrame() {}
    mutating func clear(_ color: Color) {}
    mutating func fill(_ rect: Rect, color: Color) {}
    mutating func stroke(_ rect: Rect, color: Color, lineWidth: Int) {}

    mutating func drawText(_ text: TextRun, at origin: Point) {
        texts.append((text.content, origin))
    }

    mutating func endFrame() {}
    mutating func present() {}
}

private func framebufferHash(
    _ surface: MemoryFramebufferSurface
) -> UInt64 {
    surface.withUnsafeBytes { bytes in
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in bytes {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return hash
    }
}
