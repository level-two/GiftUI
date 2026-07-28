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
func builderCreatesPortableTupleContent() {
    let content = ViewBuilder.buildBlock(Text("A"), Text("B"))

    #expect(type(of: content) == TupleView<Text, Text>.self)
}

@Test(arguments: [Int.min, -21, 0, 21, Int.max])
func boundedIntegerRenderTextEmitsUTF8WithoutDynamicStorage(_ value: Int) {
    let run = TextRun(integer: value, suffix: "°")
    var bytes: [UInt8] = []

    run.forEachUTF8CodeUnit { bytes.append($0) }

    #expect(bytes == Array("\(value)°".utf8))
}
