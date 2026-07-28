import Testing
import GiftUI
@testable import GiftUIRuntimeStatic

@Test
func staticRuntimeDeclaresPortableProfileAtCompileTime() {
    func requirePortableProfile<Runtime: GiftUIRuntime>(
        _ runtime: Runtime
    ) where Runtime.Profile == PortableRuntimeProfile {}

    requirePortableProfile(StaticRuntime())
}

@Test
func staticRuntimeBuildsBoundedStackLayout() throws {
    let decrement = ActionID(rawValue: 1)
    let increment = ActionID(rawValue: 2)
    let content = VStack(spacing: 8) {
        Text("Target")
        Text("21°")
        HStack(spacing: 8) {
            Button("-", action: decrement)
            Button("+", action: increment)
        }
    }

    let layout = try StaticRuntime().layout(
        content,
        in: Size(width: 240, height: 240)
    )

    #expect(layout.rootFrame.size == Size(width: 56, height: 64))
    #expect(layout.nodeCount == 8)
    #expect(layout.hitRegionCount == 2)
    #expect(layout.action(at: Point(x: 101, y: 151)) == decrement)
    #expect(layout.action(at: Point(x: 133, y: 151)) == increment)
}

@Test
func staticRuntimeReportsNodeCapacityExhaustion() {
    #expect(throws: StaticRuntimeError.nodeCapacityExceeded(capacity: 64)) {
        _ = try StaticRuntime().layout(
            VStack { TooManyTextChildren() },
            in: Size(width: 240, height: 240)
        )
    }
}

@Test
func staticRuntimeReportsTraversalDepthExhaustion() {
    #expect(throws: StaticRuntimeError.traversalDepthExceeded(capacity: 16)) {
        _ = try StaticRuntime().layout(
            RecursivelyNestedStack(),
            in: Size(width: 240, height: 240)
        )
    }
}

@Test
func staticRuntimeReportsHitRegionCapacityExhaustion() {
    #expect(throws: StaticRuntimeError.hitRegionCapacityExceeded(capacity: 16)) {
        _ = try StaticRuntime().layout(
            VStack { TooManyButtons() },
            in: Size(width: 240, height: 1_000)
        )
    }
}

@Test
func staticRuntimeEmitsPortableRenderOperationsWithoutDisplayList() throws {
    struct RecordingSink: RenderOperationSink {
        var operations: [RenderOperation] = []

        mutating func append(_ operation: RenderOperation) {
            operations.append(operation)
        }
    }

    let content = VStack(spacing: 4) {
        Text("Target")
        Text(integer: -21, suffix: "°")
        Button("+", action: ActionID(rawValue: 1))
    }
    let layout = try StaticRuntime().layout(
        content,
        in: Size(width: 120, height: 120)
    )
    var sink = RecordingSink()

    layout.appendRenderOperations(to: &sink)

    #expect(sink.operations.count == 5)
    #expect(sink.operations[0] == .text(
        TextRun("Target"),
        at: Point(x: 36, y: 32)
    ))
    #expect(sink.operations[1] == .text(
        TextRun(integer: -21, suffix: "°"),
        at: Point(x: 44, y: 48)
    ))
}

@Test
func staticRenderEmissionPropagatesSinkCapacityFailure() throws {
    enum CapacityError: Error {
        case exhausted
    }

    struct BoundedSink: RenderOperationSink {
        typealias Failure = CapacityError

        var remainingCapacity: Int

        mutating func append(
            _ operation: RenderOperation
        ) throws(CapacityError) {
            guard remainingCapacity > 0 else {
                throw .exhausted
            }
            remainingCapacity -= 1
        }
    }

    let layout = try StaticRuntime().layout(
        Button("+", action: ActionID(rawValue: 1)),
        in: Size(width: 40, height: 40)
    )
    var sink = BoundedSink(remainingCapacity: 2)

    #expect(throws: CapacityError.exhausted) {
        try layout.appendRenderOperations(to: &sink)
    }
}

private struct TooManyTextChildren: View {
    var body: Never {
        fatalError("Custom traversal does not evaluate a body")
    }

    func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        var count = 0
        while count < 65 {
            Text("X")._visit(&visitor)
            count += 1
        }
    }
}

private struct RecursivelyNestedStack: View {
    var body: Never {
        fatalError("Custom traversal does not evaluate a body")
    }

    func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitVStack(spacing: 0, content: self)
    }
}

private struct TooManyButtons: View {
    var body: Never {
        fatalError("Custom traversal does not evaluate a body")
    }

    func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        var count = 0
        while count < 17 {
            Button("X", action: ActionID(rawValue: count))._visit(&visitor)
            count += 1
        }
    }
}
