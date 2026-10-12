import GiftUI

package protocol StaticCanvasCallableTable {
    associatedtype Domain: _GiftUIReadDomain
    associatedtype CaptureStorage

    var callableCaseCount: UInt16 { get }
    func captureByteCount(for id: UInt16) -> UInt16?
    mutating func invoke(
        id: UInt16,
        captures: borrowing CaptureStorage,
        context: inout GraphicsContext,
        size: Size,
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(DrawingError)
}
