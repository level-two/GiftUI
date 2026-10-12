import GiftUI
import GiftUIRenderLowering
import GiftUISemanticCore

package struct DynamicRenderWorkspace: RenderProductionWorkspace {
    package typealias Identity = SemanticRecordReference

    package let capacity: RenderLimits
    package let structuralCapacity: RenderWorkspaceCapacity
    package private(set) var isActive = false

    private var semanticVisits: [Bool]
    private var layoutVisits: [Bool]
    private var foregrounds: [Color] = []

    package init(
        capacity: RenderLimits,
        structuralCapacity: RenderWorkspaceCapacity
    ) {
        self.capacity = capacity
        self.structuralCapacity = structuralCapacity
        semanticVisits = Array(
            repeating: false,
            count: Int(structuralCapacity.maximumSemanticScopes)
        )
        layoutVisits = Array(
            repeating: false,
            count: Int(structuralCapacity.maximumLayoutScopes)
        )
        foregrounds.reserveCapacity(
            Int(structuralCapacity.maximumTraversalDepth)
        )
    }

    /// Retained element extents; the owning value's inline layout is separate.
    /// Reports the actual retained typed buffers; live occupancy is not capacity.
    package borrowing func visitRetainedPayloadExtents(_ visit: (Int, Int, Int, Int) -> Void) {
        visit(
            semanticVisits.capacity, MemoryLayout<Bool>.size, MemoryLayout<Bool>.stride,
            MemoryLayout<Bool>.alignment)
        visit(
            layoutVisits.capacity, MemoryLayout<Bool>.size, MemoryLayout<Bool>.stride,
            MemoryLayout<Bool>.alignment)
        visit(
            foregrounds.capacity, MemoryLayout<Color>.size, MemoryLayout<Color>.stride,
            MemoryLayout<Color>.alignment)
    }

    package var reservedPayloadBytes: Int {
        semanticVisits.capacity * MemoryLayout<Bool>.stride
            + layoutVisits.capacity * MemoryLayout<Bool>.stride
            + foregrounds.capacity * MemoryLayout<Color>.stride
    }

    package var currentForeground: Color? {
        guard isActive else { return nil }
        return foregrounds.last
    }

    package mutating func acquire() -> Bool {
        guard !isActive else { return false }
        isActive = true
        return true
    }

    package mutating func visitSemanticScope(
        at ordinal: UInt16
    ) -> RenderWorkspaceVisit {
        guard isActive else { return .invalid }
        return Self.visit(ordinal: ordinal, in: &semanticVisits)
    }

    package mutating func visitLayoutScope(
        at ordinal: UInt16
    ) -> RenderWorkspaceVisit {
        guard isActive else { return .invalid }
        return Self.visit(ordinal: ordinal, in: &layoutVisits)
    }

    package mutating func pushForeground(_ color: Color) -> Bool {
        guard isActive,
            foregrounds.count
                < Int(structuralCapacity.maximumTraversalDepth)
        else { return false }
        foregrounds.append(color)
        return true
    }

    package mutating func popForeground() -> Bool {
        guard isActive, !foregrounds.isEmpty else { return false }
        foregrounds.removeLast()
        return true
    }

    package mutating func reset() {
        for index in semanticVisits.indices { semanticVisits[index] = false }
        for index in layoutVisits.indices { layoutVisits[index] = false }
        foregrounds.removeAll(keepingCapacity: true)
        isActive = false
    }

    private static func visit(
        ordinal: UInt16,
        in visits: inout [Bool]
    ) -> RenderWorkspaceVisit {
        guard Int(ordinal) < visits.count else { return .invalid }
        let index = Int(ordinal)
        guard !visits[index] else { return .repeated }
        visits[index] = true
        return .first
    }
}
