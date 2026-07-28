import GiftUI
import GiftUIDynamicConveniences
import Testing

@Test
func dynamicTextAcceptsRuntimeStrings() {
    let runtimeText = ["Dynamic", " text"].joined()

    let layout = LayoutEngine.layout(
        Text(runtimeText),
        in: Size(width: 120, height: 40)
    )

    #expect(layout.frame.size == Size(width: 96, height: 12))
}

@Test
func dynamicTextRunAcceptsRuntimeStrings() {
    let content = String(repeating: "A", count: 3)

    #expect(TextRun(content).content == "AAA")
}

@Test
func dynamicButtonAcceptsEscapingCallbacks() {
    var activations = 0
    let graph = ViewGraph.layout(
        Button("Tap") { activations += 1 },
        in: Size(width: 80, height: 40)
    )
    let snapshot = graph.makeInteractionSnapshot()
    let action = snapshot.hitTestMap.regions[0].action

    #expect(snapshot.perform(action))
    #expect(activations == 1)
}
