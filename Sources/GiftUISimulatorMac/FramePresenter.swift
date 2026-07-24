import CoreGraphics
import Foundation
import GiftUIBackendFramebuffer

enum FramePresenter {
    static func makeImage(
        from surface: MemoryFramebufferSurface
    ) -> CGImage? {
        let data = surface.withUnsafeBytes { Data($0) }
        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
        }

        return CGImage(
            width: surface.width,
            height: surface.height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: surface.bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(
                rawValue: CGImageAlphaInfo.last.rawValue
            ),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }
}
