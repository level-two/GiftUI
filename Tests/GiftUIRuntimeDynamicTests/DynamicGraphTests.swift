import Testing
@testable import GiftUI
@testable import GiftUIRuntimeDynamic

@Test
func builderSupportsFiveSiblingAcceptanceArity() {
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
            let _ = value
            Text("First")
        }
    }

    struct SecondBranch: View {
        @State var value = "B"

        var body: some View {
            let _ = value
            Text("Second")
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
        Button("+", action: ActionID(rawValue: 0)),
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
        Button("+", action: ActionID(rawValue: 0)),
        in: Size(width: 40, height: 40)
    )
    var sink = BoundedSink(capacity: 3)

    try graph.appendRenderOperations(to: &sink)

    #expect(sink.operations == [
        .fillRect(
            Rect(
                origin: Point(x: 8, y: 8),
                size: Size(width: 24, height: 24)
            ),
            Color(red: 62, green: 68, blue: 82)
        ),
        .strokeRect(
            Rect(
                origin: Point(x: 8, y: 8),
                size: Size(width: 24, height: 24)
            ),
            Color(red: 116, green: 130, blue: 160),
            lineWidth: 1
        ),
        .text(TextRun("+"), at: Point(x: 16, y: 14)),
    ])
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
        Button("+", action: ActionID(rawValue: 0)),
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
func nestedPortableButtonsBuildAConsistentInteractionSnapshot() {
    let outerAction = ActionID(rawValue: 40)
    let innerAction = ActionID(rawValue: 41)
    let graph = ViewGraph.layout(
        Button(action: outerAction) {
            Button("Inner", action: innerAction)
        },
        in: Size(width: 80, height: 80)
    )
    let snapshot = graph.makeInteractionSnapshot()
    let point = snapshot.hitTestMap.regions[1].bounds.origin
    var dispatchedActions: [ActionID] = []

    let action = snapshot.action(at: point)

    #expect(snapshot.hitTestMap.regions.count == 2)
    #expect(action == ActionID(rawValue: 1))
    #expect(action.map {
        snapshot.perform(
            $0,
            identifiedActionHandler: { dispatchedActions.append($0) }
        )
    } == true)
    #expect(dispatchedActions == [innerAction])
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
