// The target amalgamation compiles the common Layout algorithm without the
// host-only semantic and text-resource modules. These value-only interfaces
// mirror exactly the portions those modules provide to Layout.
#if GIFTUI_NRF_EMBEDDED
    package enum SemanticLayoutPrimitive: Equatable, Sendable {
        case proxy
        case vStack(alignment: HorizontalAlignment, spacing: GeometryScalar)
        case hStack(alignment: VerticalAlignment, spacing: GeometryScalar)
        case zStack(alignment: Alignment)
        case spacer(minLength: GeometryScalar)
        case text
        case canvas
    }

    package enum SemanticLayoutModifier: Equatable, Sendable {
        case passthrough
        case padding(edges: EdgeSet, length: GeometryScalar)
        case paddingInsets(EdgeInsets)
        case fixedFrame(
            width: GeometryScalar?, height: GeometryScalar?, alignment: Alignment
        )
        case flexibleFrame(
            minWidth: GeometryScalar?, maxWidth: FrameLimit?,
            minHeight: GeometryScalar?, maxHeight: FrameLimit?,
            alignment: Alignment
        )
    }

    package protocol SemanticLayoutView {
        associatedtype Identity: Equatable, Sendable
        var rootIdentity: Identity { get }
        var scopeCount: UInt16 { get }
        func primitive(at identity: Identity) -> SemanticLayoutPrimitive?
        func childCount(of identity: Identity) -> UInt16?
        func child(of identity: Identity, at index: UInt16) -> Identity?
        func modifierCount(of identity: Identity) -> UInt16?
        func modifierScope(of identity: Identity, at index: UInt16) -> Identity?
        func modifier(of identity: Identity, at index: UInt16) -> SemanticLayoutModifier?
        func textScalarCount(of identity: Identity) -> UInt16?
        func textScalar(of identity: Identity, at index: UInt16) -> UInt32?
    }

    package struct FontInstanceID: Equatable, Sendable {
        package let rawValue: UInt8
    }

    package struct GlyphID: Equatable, Sendable {
        package let rawValue: UInt16
    }

    package enum GlyphMapping: Equatable, Sendable {
        case exact(GlyphID)
        case replacement(GlyphID)
    }

    package struct FontLineMetrics: Equatable, Sendable {
        package let ascent: GeometryScalar
        package let descent: GeometryScalar
        package let lineGap: GeometryScalar
    }

    package struct GlyphMetrics: Equatable, Sendable {
        package let advanceX: GeometryScalar
        package let offsetX: GeometryScalar
        package let offsetY: GeometryScalar
        package let inkSize: Size
    }

    package struct FontInstanceDescriptor: Equatable, Sendable {
        package let id: FontInstanceID
        package let lineMetrics: FontLineMetrics
        package let replacementGlyph: GlyphID
    }

    package struct TextResourceDescriptor: Equatable, Sendable {
        package let instanceCount: UInt16
    }

    package protocol CanonicalTextMetricsView {
        var descriptor: TextResourceDescriptor { get }
        func instance(at index: UInt16) -> FontInstanceDescriptor?
        func mapScalar(_ scalar: UInt32, in instance: FontInstanceID) -> GlyphMapping?
        func metrics(for glyph: GlyphID, in instance: FontInstanceID) -> GlyphMetrics?
    }
#endif
