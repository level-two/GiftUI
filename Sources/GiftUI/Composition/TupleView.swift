public struct TupleView<A: View, B: View>: View, PrimitiveView {
    public let value: (A, B)

    package init(_ a: A, _ b: B) {
        value = (a, b)
    }

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitTuple(value.0, value.1)
    }
}

public struct TupleView3<A: View, B: View, C: View>: View, PrimitiveView {
    public let value: (A, B, C)

    package init(_ a: A, _ b: B, _ c: C) {
        value = (a, b, c)
    }

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitTuple(value.0, value.1, value.2)
    }
}

public struct TupleView4<A: View, B: View, C: View, D: View>: View, PrimitiveView {
    public let value: (A, B, C, D)

    package init(_ a: A, _ b: B, _ c: C, _ d: D) {
        value = (a, b, c, d)
    }

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitTuple(value.0, value.1, value.2, value.3)
    }
}

public struct TupleView5<A: View, B: View, C: View, D: View, E: View>: View, PrimitiveView {
    public let value: (A, B, C, D, E)

    package init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) {
        value = (a, b, c, d, e)
    }

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitTuple(value.0, value.1, value.2, value.3, value.4)
    }
}
