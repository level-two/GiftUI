import GiftUI
import GiftUIBackendFramebuffer
import GiftUIDynamicConveniences
import GiftUIPlatformLinux
import Testing

@Test
func linuxApplicationPresentsInitialFrameAndStateUpdate() throws {
    struct Counter: View {
        @State var value = 0

        var body: some View {
            VStack {
                Text("\(value)")
                Button("+") { value += 1 }
            }
        }
    }

    let display = RecordingDisplaySurface(
        logicalSize: Size(width: 80, height: 80)
    )
    let application = GiftUILinuxApplication(
        root: Counter(),
        display: display,
        logger: { _ in }
    )

    #expect(try application.runCycle())
    #expect(application.frameCount == 1)
    #expect(display.frames.count == 1)
    #expect(application.hitRegions.count == 1)

    let button = application.hitRegions[0].bounds
    let point = Point(
        x: button.origin.x + button.size.width / 2,
        y: button.origin.y + button.size.height / 2
    )
    #expect(!application.send(.pointerDown(point)))
    #expect(application.send(.pointerUp(point)))
    #expect(try application.runCycle())

    #expect(application.frameCount == 2)
    #expect(display.frames.count == 2)
    #expect(display.frames[0] != display.frames[1])
    #expect(try !application.runCycle())
}

@Test
func linuxApplicationDispatchesPortableActionIdentifiers() throws {
    let expectedAction = ActionID(rawValue: 42)
    var receivedActions: [ActionID] = []
    let display = RecordingDisplaySurface(
        logicalSize: Size(width: 80, height: 80)
    )
    let application = GiftUILinuxApplication(
        root: Button("Portable", action: expectedAction),
        display: display,
        identifiedActionHandler: { receivedActions.append($0) },
        logger: { _ in }
    )

    #expect(try application.runCycle())
    let button = application.hitRegions[0].bounds
    let point = Point(x: button.origin.x + 1, y: button.origin.y + 1)
    application.send(.pointerDown(point))

    #expect(application.send(.pointerUp(point)))
    #expect(receivedActions == [expectedAction])
}

@Test
func framebufferDisplayRejectsNonPositiveLogicalDimensions() {
    #expect(throws: LinuxPlatformError.self) {
        _ = try LinuxFramebufferDisplaySurface(
            devicePath: "/dev/fb1",
            logicalSize: Size(width: 0, height: 240)
        )
    }
}

@Test
func focusInputWrapsAndActivatesFocusedHitRegion() {
    let regions = [
        HitRegion(
            bounds: Rect(
                origin: Point(x: 10, y: 20),
                size: Size(width: 20, height: 10)
            ),
            action: ActionID(rawValue: 1)
        ),
        HitRegion(
            bounds: Rect(
                origin: Point(x: 40, y: 50),
                size: Size(width: 10, height: 20)
            ),
            action: ActionID(rawValue: 2)
        ),
    ]
    var adapter = FocusInputAdapter()

    adapter.synchronize(with: regions)
    #expect(adapter.focusedIndex == 0)
    let previousEvents = adapter.events(for: .previous, hitRegions: regions)
    #expect(previousEvents.isEmpty)
    #expect(adapter.focusedIndex == 1)
    let nextEvents = adapter.events(for: .next, hitRegions: regions)
    #expect(nextEvents.isEmpty)
    #expect(adapter.focusedIndex == 0)
    let activationEvents = adapter.events(for: .activate, hitRegions: regions)
    #expect(activationEvents == [
        .pointerDown(Point(x: 20, y: 25)),
        .pointerUp(Point(x: 20, y: 25)),
    ])
}

@Test
func linuxApplicationDispatchesNavigationInput() throws {
    struct Counter: View {
        @State var value = 0

        var body: some View {
            VStack {
                Text("\(value)")
                HStack {
                    Button("-") { value -= 1 }
                    Button("+") { value += 1 }
                }
            }
        }
    }

    let display = RecordingDisplaySurface(
        logicalSize: Size(width: 80, height: 80)
    )
    let navigation = RecordingNavigationInputSource()
    let application = GiftUILinuxApplication(
        root: Counter(),
        display: display,
        navigationInputSources: [navigation],
        logger: { _ in }
    )

    #expect(try application.runCycle())
    #expect(application.focusedHitRegionIndex == 0)

    navigation.pending = [.next]
    #expect(try application.runCycle())
    #expect(application.focusedHitRegionIndex == 1)
    #expect(application.frameCount == 2)
    #expect(display.frames[0] != display.frames[1])

    navigation.pending = [.activate]
    #expect(try application.runCycle())
    #expect(application.focusedHitRegionIndex == 1)
    #expect(application.frameCount == 3)
    #expect(display.frames[1] != display.frames[2])
}

private final class RecordingDisplaySurface: DisplaySurface {
    let logicalSize: Size
    private(set) var frames: [[UInt8]] = []

    init(logicalSize: Size) {
        self.logicalSize = logicalSize
    }

    func present(framebuffer: MemoryFramebufferSurface) {
        frames.append(framebuffer.withUnsafeBytes { Array($0) })
    }
}

private final class RecordingNavigationInputSource: LinuxNavigationInputSource {
    var pending: [NavigationInput] = []

    func pollNavigation() -> [NavigationInput] {
        defer { pending.removeAll(keepingCapacity: true) }
        return pending
    }
}
