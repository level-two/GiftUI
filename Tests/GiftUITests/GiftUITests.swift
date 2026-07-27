import Testing
@testable import GiftUI

@Test
func runtimeProfilesHaveDistinctCompileTimeIdentities() {
    #expect(PortableRuntimeProfile.self != DynamicRuntimeProfile.self)
    #expect(PortableRuntimeProfile.name.description == "portable")
    #expect(DynamicRuntimeProfile.name.description == "dynamic")
}

@Test
func integerGeometryRetainsValues() {
    let rect = Rect(
        origin: Point(x: 4, y: 8),
        size: Size(width: 240, height: 240)
    )

    #expect(rect.origin.x == 4)
    #expect(rect.origin.y == 8)
    #expect(rect.size == Size(width: 240, height: 240))
}

@Test
func layoutArithmeticReportsOverflowDeterministically() {
    #expect(throws: LayoutArithmeticError.overflow) {
        try LayoutArithmetic.add(Int.max, 1)
    }
    #expect(throws: LayoutArithmeticError.overflow) {
        try LayoutArithmetic.subtract(Int.min, 1)
    }
    #expect(throws: LayoutArithmeticError.overflow) {
        try LayoutArithmetic.multiply(Int.max, 2)
    }
}

@Test
func rectangleContainmentAvoidsCoordinateOverflow() {
    let nearMaximum = Rect(
        origin: Point(x: Int.max - 1, y: Int.max - 1),
        size: Size(width: 1, height: 1)
    )
    let extremeSpan = Rect(
        origin: Point(x: Int.min, y: Int.min),
        size: Size(width: Int.max, height: Int.max)
    )

    #expect(nearMaximum.contains(Point(x: Int.max - 1, y: Int.max - 1)))
    #expect(!nearMaximum.contains(Point(x: Int.max, y: Int.max)))
    #expect(!extremeSpan.contains(Point(x: Int.max, y: Int.max)))
}

@Test
func builderCreatesTupleContent() {
    let content = ViewBuilder.buildBlock(Text("A"), Text("B"))
    #expect(type(of: content) == TupleView<(Text, Text)>.self)
}

@Test
func builderSupportsArbitrarySiblingCounts() {
    struct FiveSiblings: View {
        var body: some View {
            HStack(spacing: 1) {
                Text("A")
                Text("B")
                Text("C")
                Text("D")
                Text("E")
            }
        }
    }

    let layout = LayoutEngine.layout(
        FiveSiblings(),
        in: Size(width: 80, height: 40)
    )

    #expect(layout.frame.size == Size(width: 44, height: 12))
    #expect(layout.children.count == 5)
}

@Test
func conditionalBranchesHaveDistinctStructuralPaths() {
    struct FirstBranch: View {
        @State var value = 1

        var body: some View {
            Text("\(value)")
        }
    }

    struct SecondBranch: View {
        @State var value = "B"

        var body: some View {
            Text(value)
        }
    }

    struct ConditionalState: View {
        let showFirst: Bool

        @ViewBuilder
        var body: some View {
            if showFirst {
                FirstBranch()
            } else {
                SecondBranch()
            }
        }
    }

    let storage = RecordingStateStorage()
    _ = ViewGraph.layout(
        ConditionalState(showFirst: true),
        in: Size(width: 40, height: 40),
        stateStorage: storage
    )
    _ = ViewGraph.layout(
        ConditionalState(showFirst: false),
        in: Size(width: 40, height: 40),
        stateStorage: storage
    )

    #expect(storage.keys.count == 2)
    #expect(storage.keys[0].path.contains(".first."))
    #expect(storage.keys[1].path.contains(".second."))
    #expect(storage.keys[0] != storage.keys[1])
}

@Test
func nestedStacksMeasureSpaceAlignAndCenterChildren() {
    struct NestedView: View {
        var body: some View {
            VStack(spacing: 4) {
                Text("AB")
                HStack(spacing: 2) {
                    Text("C")
                    Text("DE")
                }
            }
        }
    }

    let layout = LayoutEngine.layout(
        NestedView(),
        in: Size(width: 100, height: 80)
    )

    #expect(layout.frame == Rect(
        origin: Point(x: 37, y: 26),
        size: Size(width: 26, height: 28)
    ))
    #expect(layout.children[0].frame.origin == Point(x: 42, y: 26))
    #expect(layout.children[1].frame == Rect(
        origin: Point(x: 37, y: 42),
        size: Size(width: 26, height: 12)
    ))
}

@Test
func intrinsicContentIsDeterministicallyCenteredInConstrainedSurfaces() {
    let constrained = LayoutEngine.layout(
        Text("AB"),
        in: Size(width: 8, height: 6)
    )
    let zero = LayoutEngine.layout(
        Text("A"),
        in: Size(width: 0, height: 0)
    )

    #expect(constrained.frame == Rect(
        origin: Point(x: -4, y: -3),
        size: Size(width: 16, height: 12)
    ))
    #expect(zero.frame == Rect(
        origin: Point(x: -4, y: -6),
        size: Size(width: 8, height: 12)
    ))
}

@Test
func conditionalAndOptionalContentExpandWithoutRegistration() {
    struct ConditionalView: View {
        let showDetail: Bool

        var body: some View {
            VStack(spacing: 3) {
                Text("A")
                if showDetail {
                    Text("BC")
                }
                if false {
                    Text("hidden")
                }
            }
        }
    }

    let shown = LayoutEngine.layout(
        ConditionalView(showDetail: true),
        in: Size(width: 40, height: 40)
    )
    let hidden = LayoutEngine.layout(
        ConditionalView(showDetail: false),
        in: Size(width: 40, height: 40)
    )

    #expect(shown.frame.size == Size(width: 16, height: 27))
    #expect(hidden.frame.size == Size(width: 8, height: 12))
}

@Test
func buttonUsesFixedPaddingAndCentersItsLabel() {
    let layout = LayoutEngine.layout(
        Button("+") {},
        in: Size(width: 40, height: 40)
    )

    #expect(layout.frame == Rect(
        origin: Point(x: 8, y: 8),
        size: Size(width: 24, height: 24)
    ))
    #expect(layout.children[0].frame == Rect(
        origin: Point(x: 16, y: 14),
        size: Size(width: 8, height: 12)
    ))
}

@Test
func displayListReplaysBackendIndependentOperationsInOrder() {
    let fillRect = Rect(
        origin: Point(x: 1, y: 2),
        size: Size(width: 3, height: 4)
    )
    let strokeRect = Rect(
        origin: Point(x: 5, y: 6),
        size: Size(width: 7, height: 8)
    )
    let text = TextRun("GiftUI", color: .white)
    let textOrigin = Point(x: 9, y: 10)
    let displayList = DisplayList(operations: [
        .fillRect(fillRect, .black),
        .strokeRect(strokeRect, .white, lineWidth: 2),
        .text(text, at: textOrigin),
    ])
    var backend = OperationRecordingBackend()

    backend.execute(displayList)

    #expect(backend.operations == displayList.operations)
}

@Test
func viewGraphCanEmitIntoBoundedRenderStorage() throws {
    enum CapacityError: Error {
        case exhausted
    }

    struct BoundedSink: RenderOperationSink {
        typealias Failure = CapacityError

        let capacity: Int
        var operations: [RenderOperation] = []

        mutating func append(
            _ operation: RenderOperation
        ) throws(CapacityError) {
            guard operations.count < capacity else {
                throw CapacityError.exhausted
            }
            operations.append(operation)
        }
    }

    let graph = ViewGraph.layout(
        Button("+") {},
        in: Size(width: 40, height: 40)
    )
    var sink = BoundedSink(capacity: 3)

    try graph.appendRenderOperations(to: &sink)

    #expect(sink.operations == graph.makeDisplayList().operations)
}

@Test
func boundedRenderStorageReportsCapacityExhaustion() {
    enum CapacityError: Error {
        case exhausted
    }

    struct BoundedSink: RenderOperationSink {
        typealias Failure = CapacityError

        let capacity: Int
        var count = 0

        mutating func append(
            _ operation: RenderOperation
        ) throws(CapacityError) {
            guard count < capacity else {
                throw CapacityError.exhausted
            }
            count += 1
        }
    }

    let graph = ViewGraph.layout(
        Button("+") {},
        in: Size(width: 40, height: 40)
    )
    var sink = BoundedSink(capacity: 2)

    #expect(throws: CapacityError.exhausted) {
        try graph.appendRenderOperations(to: &sink)
    }
}

@Test
func hitTestingPrefersTheLastOverlappingRegion() {
    let bounds = Rect(
        origin: Point(x: 4, y: 6),
        size: Size(width: 20, height: 12)
    )
    let map = HitTestMap(regions: [
        HitRegion(bounds: bounds, action: ActionID(rawValue: 0)),
        HitRegion(bounds: bounds, action: ActionID(rawValue: 1)),
    ])

    #expect(map.action(at: Point(x: 10, y: 10)) == ActionID(rawValue: 1))
    #expect(map.action(at: Point(x: 24, y: 10)) == nil)
}

@Test
func nestedButtonsBuildAConsistentCoreInteractionSnapshot() {
    var outerActivations = 0
    var innerActivations = 0
    let graph = ViewGraph.layout(
        Button(action: { outerActivations += 1 }) {
            Button("Inner") { innerActivations += 1 }
        },
        in: Size(width: 80, height: 80)
    )
    let snapshot = graph.makeInteractionSnapshot()
    let point = snapshot.hitTestMap.regions[1].bounds.origin

    let action = snapshot.action(at: point)

    #expect(snapshot.hitTestMap.regions.count == 2)
    #expect(action == ActionID(rawValue: 1))
    #expect(action.map { snapshot.perform($0) } == true)
    #expect(outerActivations == 0)
    #expect(innerActivations == 1)
}

private final class RecordingStateStorage: StateStorage {
    var keys: [StateKey] = []
    private var values: [StateKey: Any] = [:]

    func read<Value>(
        key: StateKey,
        initialValue: @autoclosure () -> Value
    ) -> Value {
        keys.append(key)
        if let value = values[key] as? Value {
            return value
        }
        let value = initialValue()
        values[key] = value
        return value
    }

    func write<Value>(_ value: Value, key: StateKey) {
        values[key] = value
    }
}

private struct OperationRecordingBackend: RenderBackend {
    let surfaceSize = Size(width: 20, height: 20)
    var operations: [RenderOperation] = []

    mutating func beginFrame() {}
    mutating func clear(_ color: Color) {}

    mutating func fill(_ rect: Rect, color: Color) {
        operations.append(.fillRect(rect, color))
    }

    mutating func stroke(
        _ rect: Rect,
        color: Color,
        lineWidth: Int
    ) {
        operations.append(
            .strokeRect(rect, color, lineWidth: lineWidth)
        )
    }

    mutating func drawText(_ text: TextRun, at origin: Point) {
        operations.append(.text(text, at: origin))
    }

    mutating func endFrame() {}
    mutating func present() {}
}
