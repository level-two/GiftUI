import GiftUI
import GiftUIBackendFramebuffer
import GiftUIBackendRGB565

public protocol DisplaySurface: AnyObject {
    var logicalSize: Size { get }

    func present(framebuffer: MemoryFramebufferSurface) throws
}

/// A retained display that accepts bounded RGB565 source tiles.
///
/// The display owns the full-frame backing store. GiftUI only keeps the tile
/// allocation described by `rgb565RendererConfiguration`.
public protocol RGB565TileDisplaySurface: DisplaySurface {
    var rgb565RendererConfiguration: RGB565RendererConfiguration? { get }

    func prepareRGB565Frame(isFullRefresh: Bool) throws

    func present(
        tile: RGB565Tile,
        bytes: UnsafeRawBufferPointer
    ) throws
}

public enum DisplayRotation: Int, CaseIterable, Sendable {
    case degrees0 = 0
    case degrees90 = 90
    case degrees180 = 180
    case degrees270 = 270
}
