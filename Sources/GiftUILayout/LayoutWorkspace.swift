import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package struct LayoutMeasurement: Equatable, Sendable {
    package let idealSize: Size
    package let resolvedSize: Size

    package init(idealSize: Size, resolvedSize: Size) {
        self.idealSize = idealSize
        self.resolvedSize = resolvedSize
    }
}

package struct LayoutPlacement: Equatable, Sendable {
    package let bounds: Rect
    package let clip: Rect

    package init(bounds: Rect, clip: Rect) {
        self.bounds = bounds
        self.clip = clip
    }
}

package protocol LayoutWorkspace {
    associatedtype Identity: Equatable, Sendable

    var maximumScopes: UInt16 { get }
    var maximumDepth: UInt16 { get }
    var maximumTextScalars: UInt16 { get }
    var maximumTextLines: UInt16 { get }
    var maximumPositionedGlyphs: UInt16 { get }
    var isLayoutActive: Bool { get }

    mutating func acquireLayout() -> Bool
    mutating func appendScope(
        identity: borrowing Identity,
        measurement: LayoutMeasurement
    ) -> Bool
    func measurement(for identity: borrowing Identity) -> LayoutMeasurement?
    mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing Identity
    ) -> Bool
    func placement(for identity: borrowing Identity) -> LayoutPlacement?
    mutating func pushScope(_ identity: borrowing Identity) -> Bool
    mutating func popScope()
    mutating func resetLayout()
}
