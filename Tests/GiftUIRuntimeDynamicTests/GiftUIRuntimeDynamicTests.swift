import Testing
import GiftUI
import GiftUIDynamicConveniences
@testable import GiftUIRuntimeDynamic

@MainActor
@Test
func statePersistsAndInvalidates() {
    let runtime = DynamicRuntime()
    let key = StateKey(path: "root", slot: 0)

    #expect(runtime.state.read(key: key, initialValue: 21) == 21)
    runtime.markRendered()
    runtime.state.write(22, key: key)

    #expect(runtime.state.read(key: key, initialValue: 0) == 22)
    #expect(runtime.isInvalid)
}

@Test
func dynamicRuntimeDeclaresItsProfileAtCompileTime() {
    func requireDynamicProfile<Runtime: GiftUIRuntime>(
        _ runtime: Runtime
    ) where Runtime.Profile == DynamicRuntimeProfile {}

    requireDynamicProfile(DynamicRuntime())
}

@Test
func stateWrapperBindsToRuntimeStorageAndSurvivesReevaluation() {
    struct CounterView: View {
        @State var count = 1

        var body: some View {
            Text(String(repeating: "X", count: count))
        }

        func increment() {
            count += 1
        }
    }

    let runtime = DynamicRuntime()
    let root = CounterView()

    let initial = runtime.layout(root, in: Size(width: 80, height: 40))
    #expect(initial.frame.size == Size(width: 8, height: 12))
    #expect(!runtime.isInvalid)

    root.increment()
    #expect(runtime.isInvalid)

    let updated = runtime.layout(root, in: Size(width: 80, height: 40))
    #expect(updated.frame.size == Size(width: 16, height: 12))
    #expect(!runtime.isInvalid)
}

@Test
func multipleStatePropertiesUseIndependentStructuralSlots() {
    struct TwoValuesView: View {
        @State var first = 1
        @State var second = 2

        var body: some View {
            Text(String(repeating: "X", count: first + second))
        }

        func update() {
            first = 2
            second = 4
        }
    }

    let runtime = DynamicRuntime()
    let root = TwoValuesView()

    #expect(
        runtime.layout(root, in: Size(width: 100, height: 40)).frame.size.width
            == 24
    )
    root.update()
    #expect(runtime.isInvalid)
    #expect(
        runtime.layout(root, in: Size(width: 100, height: 40)).frame.size.width
            == 48
    )
}

@Test
func separateRootInstancesKeepIndependentState() {
    struct CounterView: View {
        @State var count = 0

        var body: some View {
            Text("\(count)")
        }

        func increment() {
            count += 1
        }
    }

    let firstRoot = CounterView()
    let secondRoot = CounterView()
    let firstRuntime = DynamicRuntime()
    let secondRuntime = DynamicRuntime()

    _ = firstRuntime.layout(
        firstRoot,
        in: Size(width: 40, height: 40)
    )
    _ = secondRuntime.layout(
        secondRoot,
        in: Size(width: 40, height: 40)
    )
    firstRoot.increment()

    #expect(
        firstRuntime.layout(
            firstRoot,
            in: Size(width: 40, height: 40)
        ).frame.size.width == 8
    )
    #expect(firstRoot.count == 1)
    #expect(!secondRuntime.isInvalid)
    #expect(secondRoot.count == 0)
}

@Test
func dynamicDisplayListReplaysBackendIndependentOperationsInOrder() {
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
