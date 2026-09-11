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

package struct RenderWorkspaceCapacity: Equatable, Sendable {
    package let maximumSemanticScopes: UInt16
    package let maximumLayoutScopes: UInt16
    package let maximumTraversalDepth: UInt16
    package let maximumTextLines: UInt16

    package init?(
        maximumSemanticScopes: UInt16,
        maximumLayoutScopes: UInt16,
        maximumTraversalDepth: UInt16,
        maximumTextLines: UInt16
    ) {
        guard maximumSemanticScopes > 0,
            maximumLayoutScopes > 0,
            maximumTraversalDepth > 0,
            maximumTextLines > 0
        else {
            return nil
        }
        self.maximumSemanticScopes = maximumSemanticScopes
        self.maximumLayoutScopes = maximumLayoutScopes
        self.maximumTraversalDepth = maximumTraversalDepth
        self.maximumTextLines = maximumTextLines
    }
}

package enum RenderProductionResult: Equatable, Sendable {
    case success(RenderPlanHeader)
    case failure(RenderProductionError)
}

package enum RenderWorkspaceVisit: UInt8, Equatable, Sendable {
    case first = 0
    case repeated = 1
    case invalid = 2
}

package protocol RenderProductionWorkspace {
    associatedtype Identity: Equatable, Sendable

    var capacity: RenderLimits { get }
    var structuralCapacity: RenderWorkspaceCapacity { get }
    var isActive: Bool { get }
    mutating func acquire() -> Bool
    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit
    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit
    mutating func reset()
}
