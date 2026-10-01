import GiftUI

/// Finite maxima pass the surface budget through stacks whose main-axis
/// proposal is absent. All origins and final bounds remain owned by Layout.
package struct SignalAnalyzerLayoutConstraints: Equatable, Sendable {
    package let labelWidth: GeometryScalar
    package let gridWidth: GeometryScalar
    package let gridHeight: GeometryScalar
    package let traceWidth: GeometryScalar
    package let traceHeight: GeometryScalar

    package static let reference = Self(width: 320, height: 240, lineHeight: 20)

    package init(width: GeometryScalar, height: GeometryScalar, lineHeight: GeometryScalar) {
        // Reserve root/panel padding, header, controls, ruler and one diagnostic
        // line. Reserve two label columns so LOW/HIGH cannot move the traces.
        labelWidth = 2 * lineHeight
        traceWidth = max(1, width - 8 - 2 * labelWidth - 4)
        gridWidth = traceWidth
        traceHeight = max(4, (height - 7 * lineHeight - 20) / 4)
        gridHeight = lineHeight + 4 * traceHeight
    }
}
