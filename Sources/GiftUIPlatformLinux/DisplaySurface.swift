import GiftUI
import GiftUIBackendFramebuffer

public protocol DisplaySurface: AnyObject {
    var logicalSize: Size { get }

    func present(framebuffer: MemoryFramebufferSurface) throws
}

public enum DisplayRotation: Int, CaseIterable, Sendable {
    case degrees0 = 0
    case degrees90 = 90
    case degrees180 = 180
    case degrees270 = 270
}
