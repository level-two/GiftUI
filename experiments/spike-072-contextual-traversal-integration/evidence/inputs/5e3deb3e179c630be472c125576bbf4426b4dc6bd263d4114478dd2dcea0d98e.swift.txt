// Candidate portable SPI; fixture's finite schema is two UInt32 properties.
public enum AccessFailure: UInt8, Error, Equatable, Sendable {
    case invalidField, staleFrame, invalidPhase, capacity, staleKey
}
public struct ModelKey: Equatable, Sendable {
    public let index: UInt16
    public let epoch: UInt32
    public init(index: UInt16, epoch: UInt32) { self.index=index; self.epoch=epoch }
}
public protocol FrozenAccess: ~Escapable {
    func scalar(_ key: ModelKey, field: UInt16) throws(AccessFailure) -> UInt32
}
public protocol EvaluationSession: ~Copyable {
    mutating func bind(location: UInt64, ordinal: UInt16, seed: UInt32) throws(AccessFailure) -> ModelKey
    borrowing func evaluate<D: View>(_ declaration: borrowing D) throws(AccessFailure) -> D.Body
}
public protocol _GiftUIObservableStateHost {
    mutating func _bind<S: EvaluationSession & ~Copyable>(location: UInt64, session: inout S) throws(AccessFailure)
}
public protocol Canvas: _GiftUILeaf, _GiftUISemanticPrimitivePayload where Body == Never {
    func draw<R: FrozenAccess & ~Escapable>(in bounds: Rect, context: inout GraphicsContext, read: borrowing R) throws(DrawingError)
}
extension Canvas {
    public func _giftUITraverse<V: _GiftUISemanticTraversalVisitor, S: EvaluationSession & ~Copyable>(_ visitor: inout V, session: inout S) {
        visitor.visitPrimitive(self, session: &session)
    }
}
extension FrozenAccess where Self: ~Escapable {
    public func drawScalar(_ key: ModelKey, field: UInt16) throws(DrawingError) -> UInt32 {
        do { return try scalar(key,field:field) } catch { throw .invalidScope }
    }
}
