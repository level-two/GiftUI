import Testing
@testable import GiftUI

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
func builderCreatesTupleContent() {
    let content = ViewBuilder.buildBlock(Text("A"), Text("B"))
    #expect(type(of: content) == TupleView<(Text, Text)>.self)
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
