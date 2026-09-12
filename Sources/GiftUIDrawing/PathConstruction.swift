import GiftUI
import GiftUIRenderCore

package protocol LivePathStorage {
    var maximumPointCount: UInt16 { get }
    var maximumSubpathCount: UInt16 { get }
    var pointCount: UInt16 { get }
    var subpathCount: UInt16 { get }

    func point(at index: UInt16) -> Point?
    func subpath(at index: UInt16) -> SubpathRange?

    mutating func startFirstSubpath(at point: Point) -> Bool
    mutating func replaceCurrentSubpathStart(with point: Point) -> Bool
    mutating func startNextSubpath(at point: Point) -> Bool
    mutating func appendLine(to point: Point) -> Bool
    mutating func reset()
}

package struct LivePathBuilder<Storage> where Storage: LivePathStorage {
    package private(set) var storage: Storage
    package private(set) var isActive: Bool

    package init(storage: Storage) {
        self.storage = storage
        isActive = true
    }

    package mutating func move(to point: Point) throws(DrawingError) {
        guard isActive else { throw DrawingError.invalidScope }
        if storage.subpathCount == 0 {
            guard storage.pointCount == 0 else {
                throw DrawingError.invariantViolation
            }
            try requireCapacity(
                pointDemand: 1,
                subpathDemand: 1
            )
            guard storage.startFirstSubpath(at: point) else {
                throw DrawingError.invariantViolation
            }
            return
        }

        guard let current = storage.subpath(at: storage.subpathCount - 1),
            current.pointCount > 0
        else { throw DrawingError.invariantViolation }
        let currentEnd = current.firstPoint.addingReportingOverflow(current.pointCount)
        guard !currentEnd.overflow, currentEnd.partialValue == storage.pointCount else {
            throw DrawingError.invariantViolation
        }

        if current.pointCount == 1 {
            guard storage.replaceCurrentSubpathStart(with: point) else {
                throw DrawingError.invariantViolation
            }
            return
        }

        try requireCapacity(pointDemand: 1, subpathDemand: 1)
        guard storage.startNextSubpath(at: point) else {
            throw DrawingError.invariantViolation
        }
    }

    package mutating func addLine(to point: Point) throws(DrawingError) {
        guard isActive else { throw DrawingError.invalidScope }
        guard storage.subpathCount > 0 else {
            throw DrawingError.invalidPathState
        }
        guard let current = storage.subpath(at: storage.subpathCount - 1),
            current.pointCount > 0
        else { throw DrawingError.invariantViolation }
        let currentEnd = current.firstPoint.addingReportingOverflow(current.pointCount)
        guard !currentEnd.overflow, currentEnd.partialValue == storage.pointCount else {
            throw DrawingError.invariantViolation
        }

        try requireCapacity(pointDemand: 1, subpathDemand: 0)
        guard storage.appendLine(to: point) else {
            throw DrawingError.invariantViolation
        }
    }

    package mutating func reset() {
        storage.reset()
        isActive = false
    }

    private func requireCapacity(
        pointDemand: UInt16,
        subpathDemand: UInt16
    ) throws(DrawingError) {
        let nextPoints = storage.pointCount.addingReportingOverflow(pointDemand)
        let nextSubpaths = storage.subpathCount.addingReportingOverflow(subpathDemand)
        guard !nextPoints.overflow, !nextSubpaths.overflow else {
            throw DrawingError.arithmeticOverflow
        }
        guard nextPoints.partialValue <= storage.maximumPointCount,
            nextSubpaths.partialValue <= storage.maximumSubpathCount
        else { throw DrawingError.capacityExhausted }
    }
}
