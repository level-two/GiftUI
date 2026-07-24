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
