import GiftUI
import GiftUIBackendFramebuffer
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
func framebufferDisplayRejectsNonPositiveLogicalDimensions() {
    #expect(throws: LinuxPlatformError.self) {
        _ = try LinuxFramebufferDisplaySurface(
            devicePath: "/dev/fb1",
            logicalSize: Size(width: 0, height: 240)
        )
    }
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
