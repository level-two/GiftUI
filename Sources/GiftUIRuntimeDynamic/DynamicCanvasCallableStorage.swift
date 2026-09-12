import GiftUI
import GiftUIDrawing

private struct DynamicCanvasCallable<Identity> where Identity: Equatable & Sendable {
    let identity: Identity
    var canvas: Canvas?
}

package struct DynamicCanvasCallableStorage<Identity>: CanvasInvocationSource
where Identity: Equatable & Sendable {
    package let capacity: UInt16
    package private(set) var releaseCount: UInt16
    private var callables: [DynamicCanvasCallable<Identity>]

    package init(capacity: UInt16) {
        self.capacity = capacity
        releaseCount = 0
        callables = []
        callables.reserveCapacity(Int(capacity))
    }

    package var canvasOccurrenceCount: UInt16 {
        UInt16(callables.count)
    }

    package mutating func stage(
        identity: consuming Identity,
        canvas: consuming Canvas
    ) -> Bool {
        guard callables.count < Int(capacity),
            !callables.contains(where: { $0.identity == identity })
        else {
            return false
        }
        callables.append(
            DynamicCanvasCallable(identity: consume identity, canvas: consume canvas)
        )
        return true
    }

    package func canvasIdentity(at index: UInt16) -> Identity? {
        guard Int(index) < callables.count else { return nil }
        return callables[Int(index)].identity
    }

    package mutating func invokeCanvas(
        at identity: Identity,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        guard let index = callables.firstIndex(where: { $0.identity == identity }),
            let canvas = callables[index].canvas
        else {
            throw .invariantViolation
        }
        try canvas._giftUIInvokeCanvas(context: &context, size: size)
    }

    package mutating func releaseCanvas(at identity: Identity) {
        guard let index = callables.firstIndex(where: { $0.identity == identity }),
            callables[index].canvas != nil
        else {
            return
        }
        callables[index].canvas = nil
        let next = releaseCount.addingReportingOverflow(1)
        if !next.overflow {
            releaseCount = next.partialValue
        }
    }

    package mutating func discard() {
        for index in callables.indices {
            releaseCanvas(at: callables[index].identity)
        }
        callables.removeAll(keepingCapacity: true)
    }
}
