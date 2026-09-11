import GiftUIRenderCore

package struct RenderLimits: Equatable, Sendable {
    package let maximumOperations: UInt16
    package let maximumPositionedGlyphs: UInt16
    package let maximumClipDepth: UInt16

    package init?(
        maximumOperations: UInt16,
        maximumPositionedGlyphs: UInt16,
        maximumClipDepth: UInt16
    ) {
        guard maximumOperations > 0,
            maximumPositionedGlyphs > 0,
            maximumClipDepth > 0
        else {
            return nil
        }
        self.maximumOperations = maximumOperations
        self.maximumPositionedGlyphs = maximumPositionedGlyphs
        self.maximumClipDepth = maximumClipDepth
    }
}

package enum RenderProductionResult: Equatable, Sendable {
    case success(RenderPlanHeader)
    case failure(RenderProductionError)
}

package protocol RenderProductionWorkspace {
    associatedtype Identity: Equatable, Sendable

    var capacity: RenderLimits { get }
    var isActive: Bool { get }
    mutating func acquire() -> Bool
    mutating func reset()
}
