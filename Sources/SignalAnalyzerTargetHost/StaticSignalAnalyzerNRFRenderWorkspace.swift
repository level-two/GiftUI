import GiftUI
import GiftUIRenderLowering

/// Render traversal scratch within the unused tail of the audited 4,704-byte
/// attempt-local region. The layout records and publication marker stay intact.
package struct StaticSignalAnalyzerNRFRenderWorkspace: RenderProductionWorkspace {
    package typealias Identity = UInt16

    package let capacity: RenderLimits
    package let structuralCapacity: RenderWorkspaceCapacity
    package private(set) var isActive = false

    private let region: UnsafeMutableRawBufferPointer
    private var foregroundDepth: UInt16 = 0

    #if GIFTUI_NRF_EMBEDDED
        private static let scratchOffset =
            StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset
    #else
        private static let scratchOffset = StaticSignalAnalyzerNRFLayoutTextCodec.scratchOffset
    #endif
    private static let semanticOffset = scratchOffset + 32
    private static let layoutOffset = semanticOffset + 98
    private static let foregroundOffset = layoutOffset + 98
    private static let maximumScratchEnd = foregroundOffset + 13 * 3

    package init?(
        region: UnsafeMutableRawBufferPointer,
        capacity: RenderLimits,
        structuralCapacity: RenderWorkspaceCapacity
    ) {
        guard region.count == 4_704,
            structuralCapacity.maximumSemanticScopes <= 98,
            structuralCapacity.maximumLayoutScopes <= 98,
            structuralCapacity.maximumTraversalDepth <= 13,
            Self.maximumScratchEnd <= region.count
        else { return nil }
        self.region = region
        self.capacity = capacity
        self.structuralCapacity = structuralCapacity
    }

    package var currentForeground: Color? {
        guard isActive, foregroundDepth > 0 else { return nil }
        let offset = Self.foregroundOffset + Int(foregroundDepth - 1) * 3
        return Color(
            red: region[offset], green: region[offset + 1],
            blue: region[offset + 2])
    }

    package mutating func acquire() -> Bool {
        guard !isActive else { return false }
        clearScratch()
        isActive = true
        return true
    }

    package mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        visit(
            ordinal, capacity: structuralCapacity.maximumSemanticScopes,
            baseOffset: Self.semanticOffset)
    }

    package mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        visit(
            ordinal, capacity: structuralCapacity.maximumLayoutScopes,
            baseOffset: Self.layoutOffset)
    }

    package mutating func pushForeground(_ color: Color) -> Bool {
        guard isActive, foregroundDepth < structuralCapacity.maximumTraversalDepth
        else { return false }
        let offset = Self.foregroundOffset + Int(foregroundDepth) * 3
        region[offset] = color.red
        region[offset + 1] = color.green
        region[offset + 2] = color.blue
        foregroundDepth += 1
        return true
    }

    package mutating func popForeground() -> Bool {
        guard isActive, foregroundDepth > 0 else { return false }
        foregroundDepth -= 1
        let offset = Self.foregroundOffset + Int(foregroundDepth) * 3
        region[offset] = 0
        region[offset + 1] = 0
        region[offset + 2] = 0
        return true
    }

    package mutating func reset() {
        clearScratch()
        foregroundDepth = 0
        isActive = false
    }

    private mutating func visit(
        _ ordinal: UInt16, capacity: UInt16, baseOffset: Int
    ) -> RenderWorkspaceVisit {
        guard isActive, ordinal < capacity else { return .invalid }
        let offset = baseOffset + Int(ordinal)
        guard region[offset] == 0 else { return .repeated }
        region[offset] = 1
        return .first
    }

    private func clearScratch() {
        region[Self.semanticOffset ..< Self.maximumScratchEnd]
            .initializeMemory(as: UInt8.self, repeating: 0)
    }
}
