import GiftUI
import Testing

@testable import GiftUILayout

@Test
func proposalCapsAxesIndependently() {
    let measurement = LayoutGeometry.cap(
        ideal: Size(width: 40, height: 30)!,
        to: ProposedSize(width: 20)!
    )

    #expect(measurement.idealSize == Size(width: 40, height: 30)!)
    #expect(measurement.resolvedSize == Size(width: 20, height: 30)!)
}

@Test
func insetProposalFloorsUnderflowAtZeroAndPreservesAbsentAxes() {
    #expect(
        LayoutGeometry.insetProposal(
            ProposedSize(width: 3)!,
            horizontal: 5,
            vertical: 7
        ) == ProposedSize(width: 0)!
    )
}

@Test
func checkedGeometryRejectsEveryRepresentableOverflowShape() {
    #expect(
        LayoutGeometry.adding(
            width: 1,
            height: 0,
            to: Size(width: .max, height: 0)!
        ) == nil
    )
    #expect(
        LayoutGeometry.translated(Point(x: .max, y: 0), x: 1, y: 0) == nil
    )
    #expect(LayoutGeometry.spacingTotal(spacing: .max, childCount: 3) == nil)
    #expect(
        LayoutGeometry.offset(
            container: .max,
            child: .min,
            alignment: HorizontalAlignment.center
        ) == nil
    )
}

@Test
func alignmentUsesLowCenteredAndHighOffsetsWithoutClampingOverflow() {
    #expect(
        LayoutGeometry.offset(
            container: 5,
            child: 8,
            alignment: HorizontalAlignment.center
        ) == -1
    )
    #expect(
        LayoutGeometry.offset(
            container: 5,
            child: 8,
            alignment: VerticalAlignment.bottom
        ) == -3
    )
}

@Test
func disjointIntersectionIsEmptyAtTheGreaterMinimumEdges() {
    let lhs = Rect(
        origin: Point(x: 0, y: 20),
        size: Size(width: 5, height: 5)!
    )!
    let rhs = Rect(
        origin: Point(x: 10, y: 0),
        size: Size(width: 4, height: 4)!
    )!

    #expect(
        LayoutGeometry.intersection(lhs, rhs)
            == Rect(
                origin: Point(x: 10, y: 20),
                size: Size(width: 0, height: 0)!
            )!
    )
}

@Test
func overlappingIntersectionUsesGreaterMinimumAndLesserMaximum() {
    let lhs = Rect(
        origin: Point(x: 1, y: 2),
        size: Size(width: 8, height: 7)!
    )!
    let rhs = Rect(
        origin: Point(x: 4, y: 0),
        size: Size(width: 8, height: 6)!
    )!

    #expect(
        LayoutGeometry.intersection(lhs, rhs)
            == Rect(
                origin: Point(x: 4, y: 2),
                size: Size(width: 5, height: 4)!
            )!
    )
}
