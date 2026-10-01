import GiftUI

/// Finite maxima pass the surface budget through stacks whose main-axis
/// proposal is absent. All origins and final bounds remain owned by Layout.
package struct SignalAnalyzerLayoutConstraints: Equatable, Sendable {
    package let buttonSize: GeometryScalar
    package let headerTextWidth: GeometryScalar
    package let headerHeight: GeometryScalar
    package let errorLineHeight: GeometryScalar
    package let rulerLabelWidth: GeometryScalar
    package let labelWidth: GeometryScalar
    package let gridWidth: GeometryScalar
    package let gridHeight: GeometryScalar
    package let traceWidth: GeometryScalar
    package let traceHeight: GeometryScalar

    package static let reference = Self(width: 320, height: 240, lineHeight: 20)

    package init(width: GeometryScalar, height: GeometryScalar, lineHeight: GeometryScalar) {
        buttonSize = max(44, 2 * lineHeight + 4)
        headerTextWidth = max(1, width - buttonSize - 8)
        headerHeight = 4 * lineHeight + 4
        errorLineHeight = lineHeight
        labelWidth = buttonSize
        traceWidth = max(1, width - 8 - 2 * labelWidth - 4)
        gridWidth = traceWidth
        rulerLabelWidth = max(1, (traceWidth - 8) / 3)
        traceHeight = max(lineHeight, (height - headerHeight - buttonSize - lineHeight - 8) / 4)
        gridHeight = 4 * traceHeight
    }
}
