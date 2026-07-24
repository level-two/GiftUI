import Testing
import GiftUI
@testable import GiftUIBackendFramebuffer

@Test
func clearWritesRGBABytes() {
    let surface = MemoryFramebufferSurface(width: 2, height: 1)
    var backend = FramebufferBackend(surface: surface)

    backend.clear(Color(red: 10, green: 20, blue: 30, alpha: 40))

    let pixels = backend.surface.withUnsafeBytes { Array($0) }
    #expect(pixels == [10, 20, 30, 40, 10, 20, 30, 40])
}
