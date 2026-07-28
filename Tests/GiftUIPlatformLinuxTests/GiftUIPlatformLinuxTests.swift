import GiftUI
import GiftUIBackendFramebuffer
import GiftUIBackendRGB565
import GiftUIDynamicConveniences
import GiftUIPlatformLinux
import GiftUIRuntimeDynamic
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
func linuxApplicationUsesBoundedRGB565TilesAndDirtyUpdates() throws {
    struct Counter: View {
        @State var value = 0

        var body: some View {
            VStack {
                Text("\(value)")
                Button("+") { value += 1 }
            }
        }
    }

    let display = RecordingRGB565TileDisplaySurface(
        logicalSize: Size(width: 80, height: 80),
        tileHeight: 4
    )
    let application = GiftUILinuxApplication(
        root: Counter(),
        display: display,
        logger: { _ in }
    )

    #expect(application.usesRGB565TileRenderer)
    #expect(application.pixelBufferByteCapacity == 80 * 4 * 2)
    #expect(try application.runCycle())
    #expect(display.fullRefreshes == [true])
    #expect(display.fallbackPresentationCount == 0)
    #expect(display.tiles.count == 20)
    #expect(display.presentedByteCounts.reduce(0, +) == 80 * 80 * 2)
    let initialPixels = display.pixels

    let button = application.hitRegions[0].bounds
    let point = Point(
        x: button.origin.x + button.size.width / 2,
        y: button.origin.y + button.size.height / 2
    )
    application.send(.pointerDown(point))
    #expect(application.send(.pointerUp(point)))
    #expect(try application.runCycle())

    #expect(display.fullRefreshes == [true, false])
    let updateStart = display.frameTileStarts[1]
    let updateByteCount = display.presentedByteCounts[updateStart...].reduce(0, +)
    #expect(updateByteCount < 80 * 80 * 2)
    #expect(display.tiles[updateStart...].allSatisfy { $0.width < 80 })
    #expect(display.pixels != initialPixels)
    #expect(display.fallbackPresentationCount == 0)
}

@Test
func linuxApplicationFallsBackWhenTileDimensionsExceedCapacity() {
    let display = RecordingRGB565TileDisplaySurface(
        logicalSize: Size(width: 481, height: 1),
        tileHeight: 1
    )
    let application = GiftUILinuxApplication(
        root: Text("fallback"),
        display: display,
        logger: { _ in }
    )

    #expect(display.rgb565RendererConfiguration == nil)
    #expect(!application.usesRGB565TileRenderer)
    #expect(application.pixelBufferByteCapacity == 481 * 4)
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

private final class RecordingRGB565TileDisplaySurface: RGB565TileDisplaySurface {
    let logicalSize: Size
    let rgb565RendererConfiguration: RGB565RendererConfiguration?
    private(set) var fullRefreshes: [Bool] = []
    private(set) var frameTileStarts: [Int] = []
    private(set) var tiles: [RGB565Tile] = []
    private(set) var presentedByteCounts: [Int] = []
    private(set) var fallbackPresentationCount = 0
    private(set) var pixels: [UInt16]

    init(logicalSize: Size, tileHeight: Int) {
        self.logicalSize = logicalSize
        rgb565RendererConfiguration = try? RGB565RendererConfiguration(
            physicalWidth: logicalSize.width,
            physicalHeight: logicalSize.height,
            tileHeight: tileHeight,
            byteOrder: .mostSignificantByteFirst
        )
        pixels = Array(
            repeating: 0,
            count: logicalSize.width * logicalSize.height
        )
    }

    func prepareRGB565Frame(isFullRefresh: Bool) {
        fullRefreshes.append(isFullRefresh)
        frameTileStarts.append(tiles.count)
        if isFullRefresh {
            pixels = Array(repeating: 0, count: pixels.count)
        }
    }

    func present(tile: RGB565Tile, bytes: UnsafeRawBufferPointer) {
        tiles.append(tile)
        presentedByteCounts.append(bytes.count)
        for y in 0..<tile.height {
            for x in 0..<tile.width {
                let sourceOffset = y * tile.bytesPerRow + x * 2
                let pixel = UInt16(bytes[sourceOffset]) << 8
                    | UInt16(bytes[sourceOffset + 1])
                let destinationOffset = (tile.physicalY + y) * logicalSize.width
                    + tile.physicalX + x
                pixels[destinationOffset] = pixel
            }
        }
    }

    func present(framebuffer: MemoryFramebufferSurface) {
        fallbackPresentationCount += 1
    }
}

private final class RecordingNavigationInputSource: LinuxNavigationInputSource {
    var pending: [NavigationInput] = []

    func pollNavigation() -> [NavigationInput] {
        defer { pending.removeAll(keepingCapacity: true) }
        return pending
    }
}
