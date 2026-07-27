import Testing
import GiftUI
import GiftUIExampleThermostatPortableView
import GiftUIRuntimeDynamic
import GiftUIRuntimeStatic

@Test
func portableThermostatHasEquivalentPreRenderSemantics() throws {
    var model = ThermostatModel()

    try assertRuntimeParity(for: model)
    let didIncrement = model.dispatch(ThermostatAction.increment)
    #expect(didIncrement)
    #expect(model.target == 22)
    try assertRuntimeParity(for: model)
    let didDecrement = model.dispatch(ThermostatAction.decrement)
    #expect(didDecrement)
    #expect(model.target == 21)
}

@Test(arguments: [0, -1, Int.min, Int.max])
func boundedIntegerTextHasEquivalentIntrinsicWidth(_ value: Int) throws {
    let view = Text(integer: value, suffix: "°")
    let dynamic = DynamicRuntime().layout(
        view,
        in: Size(width: 240, height: 240)
    )
    let fixed = try StaticRuntime().layout(
        view,
        in: Size(width: 240, height: 240)
    )

    #expect(fixed.rootFrame.size == dynamic.frame.size)
}

private func assertRuntimeParity(for model: ThermostatModel) throws {
    let view = ThermostatPortableView(target: model.target)
    let surfaceSize = Size(width: 240, height: 240)
    let dynamic = DynamicRuntime().layoutSnapshot(view, in: surfaceSize)
    let fixed = try StaticRuntime().layout(view, in: surfaceSize)

    #expect(fixed.rootFrame == dynamic.layout.frame)
    #expect(fixed.nodeCount == countNodes(dynamic.layout))
    #expect(fixed.hitRegionCount == dynamic.identifiedHitRegions.count)

    for region in dynamic.identifiedHitRegions {
        #expect(dynamic.action(at: region.bounds.origin) == region.action)
        #expect(fixed.action(at: region.bounds.origin) == region.action)
    }
}

private func countNodes(_ node: LayoutNode) -> Int {
    1 + node.children.reduce(0) { $0 + countNodes($1) }
}
