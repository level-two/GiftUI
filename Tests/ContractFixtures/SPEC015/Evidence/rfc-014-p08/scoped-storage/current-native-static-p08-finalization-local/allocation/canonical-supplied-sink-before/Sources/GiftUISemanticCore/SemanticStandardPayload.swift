import GiftUI

/// Owned finite values only. Text scalars reside in the separately bounded pool;
/// no case retains a declaration, model, handler, reference or drawing closure.
@usableFromInline
package enum SemanticStandardPayload: Equatable, Sendable {
    case vStack(_GiftUIVStackPayload)
    case hStack(_GiftUIHStackPayload)
    case zStack(_GiftUIZStackPayload)
    case spacer(_GiftUISpacerPayload)
    case text
    case padding(_GiftUIPaddingPayload)
    case insets(_GiftUIPaddingInsetsPayload)
    case fixedFrame(_GiftUIFixedFramePayload)
    case flexibleFrame(_GiftUIFlexibleFramePayload)
    case foreground(Color)
    case background(Color)
    case disabled(Bool)
    case action(role: UInt16, code: UInt16)
}

@usableFromInline
package struct SemanticStandardPayloadCodec<Roles: SemanticDeclarationRoles>:
    SemanticRecordPayloadCodec
{
    @usableFromInline
    package typealias Payload = SemanticStandardPayload
    @inlinable
    package init() {}

    /// Exact generic type equality precedes rebinding; no runtime reflection or
    /// existential cast is used. The known finite value is copied while borrowed.
    @inlinable
    internal static func project<Value, Expected>(_ value: borrowing Value, as type: Expected.Type)
        -> Expected
    {
        precondition(Value.self == Expected.self)
        return withUnsafePointer(to: value) { source in
            source.withMemoryRebound(to: Expected.self, capacity: 1) { $0.pointee }
        }
    }
    @inlinable
    package borrowing func primitive<Value: _GiftUISemanticPrimitivePayload>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError? {
        primitive(value, writer: writer, wrapping: { .standard($0) })
    }
    @inlinable
    package borrowing func primitive<Value: _GiftUISemanticPrimitivePayload>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter,
        wrapping wrap: (Payload) -> SemanticRecordPayload
    ) -> SemanticExpansionError? {
        if Value.self == _GiftUIVStackPayload.self {
            return writer.store(
                wrap(.vStack(Self.project(value, as: _GiftUIVStackPayload.self))), kind: .primitive)
        }
        if Value.self == _GiftUIHStackPayload.self {
            return writer.store(
                wrap(.hStack(Self.project(value, as: _GiftUIHStackPayload.self))), kind: .primitive)
        }
        if Value.self == _GiftUIZStackPayload.self {
            return writer.store(
                wrap(.zStack(Self.project(value, as: _GiftUIZStackPayload.self))), kind: .primitive)
        }
        if Value.self == _GiftUISpacerPayload.self {
            return writer.store(
                wrap(.spacer(Self.project(value, as: _GiftUISpacerPayload.self))), kind: .primitive)
        }
        if Value.self == _GiftUITextPayload.self {
            let text = Self.project(value, as: _GiftUITextPayload.self)
            var scalars: InlineArray<96, UInt32> = .init(repeating: 0)
            var count = 0
            switch text.content {
            case .invalidDeclaration:
                scalars[0] = 0xD800
                count = 1
            case .admitted(let text):
                // BoundedText has already checked UTF-8. Decode into bounded
                // owned scalar scratch, then atomically preflight/copy the pool.
                text.withUTF8 { bytes in
                    var index = 0
                    while index < bytes.count {
                        let lead = bytes[index]
                        index += 1
                        var value: UInt32
                        var remaining: Int
                        if lead < 0x80 {
                            value = UInt32(lead)
                            remaining = 0
                        } else if lead < 0xE0 {
                            value = UInt32(lead & 0x1F)
                            remaining = 1
                        } else if lead < 0xF0 {
                            value = UInt32(lead & 0x0F)
                            remaining = 2
                        } else {
                            value = UInt32(lead & 0x07)
                            remaining = 3
                        }
                        for _ in 0 ..< remaining {
                            value = (value << 6) | UInt32(bytes[index] & 0x3F)
                            index += 1
                        }
                        scalars[count] = value
                        count += 1
                    }
                }
            }
            return scalars.span.withUnsafeBufferPointer { values in
                let admitted = UnsafeBufferPointer(start: values.baseAddress, count: count)
                let span = Span(_unsafeElements: admitted)
                return writer.store(wrap(.text), kind: .primitive, text: span)
            }
        }
        // Unknown finite payloads fail closed; Canvas uses its dedicated wrapper codec.
        return .invariantViolation
    }
    @inlinable
    package borrowing func modifier<Value: _GiftUISemanticModifierPayload>(
        _ value: borrowing Value, chainIndex: UInt16,
        writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError? {
        modifier(value, chainIndex: chainIndex, writer: writer, wrapping: { .standard($0) })
    }
    @inlinable
    package borrowing func modifier<Value: _GiftUISemanticModifierPayload>(
        _ value: borrowing Value, chainIndex: UInt16,
        writer: borrowing SemanticPayloadWriter,
        wrapping wrap: (Payload) -> SemanticRecordPayload
    ) -> SemanticExpansionError? {
        let owned: Payload
        if Value.self == _GiftUIPaddingPayload.self {
            owned = .padding(Self.project(value, as: _GiftUIPaddingPayload.self))
        } else if Value.self == _GiftUIPaddingInsetsPayload.self {
            owned = .insets(Self.project(value, as: _GiftUIPaddingInsetsPayload.self))
        } else if Value.self == _GiftUIFixedFramePayload.self {
            owned = .fixedFrame(Self.project(value, as: _GiftUIFixedFramePayload.self))
        } else if Value.self == _GiftUIFlexibleFramePayload.self {
            owned = .flexibleFrame(Self.project(value, as: _GiftUIFlexibleFramePayload.self))
        } else if Value.self == _GiftUIForegroundStylePayload.self {
            owned = .foreground(Self.project(value, as: _GiftUIForegroundStylePayload.self).color)
        } else if Value.self == _GiftUIBackgroundPayload.self {
            owned = .background(Self.project(value, as: _GiftUIBackgroundPayload.self).color)
        } else if Value.self == DisabledSemanticPayload.self {
            owned = .disabled(Self.project(value, as: DisabledSemanticPayload.self).isDisabled)
        } else {
            return .invariantViolation
        }
        return writer.store(wrap(owned), kind: .modifier, chainIndex: chainIndex)
    }
    @inlinable
    package borrowing func action<Value: GiftUIAction>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError? {
        action(value, writer: writer, wrapping: { .standard($0) })
    }
    @inlinable
    package borrowing func action<Value: GiftUIAction>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter,
        wrapping wrap: (Payload) -> SemanticRecordPayload
    ) -> SemanticExpansionError? {
        guard let role = Roles.role(of: Value.self), role.rawValue != 0 else {
            return .invalidIdentity
        }
        return writer.store(wrap(.action(role: role.rawValue, code: value.rawValue)), kind: .action)
    }
}
