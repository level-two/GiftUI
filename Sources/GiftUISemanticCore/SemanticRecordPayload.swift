import GiftUI

/// The canonical consumer vocabulary contains no owned declaration or Canvas
/// capture. Concrete Canvas values remain in the attempt's typed pending pool
/// until transfer; consumers see only this marker in the same payload ordinal.
@usableFromInline
package enum SemanticRecordPayload: Equatable, Sendable {
    case standard(SemanticStandardPayload)
    case canvas
}

extension SemanticRecordPayload {
    package var layoutPrimitive: SemanticLayoutPrimitive? {
        switch self {
        case .standard(let value): value.layoutPrimitive
        case .canvas: .canvas
        }
    }

    package var layoutModifier: SemanticLayoutModifier? {
        switch self {
        case .standard(let value): value.layoutModifier
        case .canvas: nil
        }
    }

    package var renderScope: SemanticRenderScope {
        switch self {
        case .standard(let value): value.renderScope
        case .canvas: .canvas
        }
    }
}
