public protocol View {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }

    func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor)
}

extension View {
    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitBody { body }
    }
}

extension Never: View {
    public var body: Never {
        fatalError("Never cannot produce a GiftUI view body")
    }

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        fatalError("Never cannot be traversed as GiftUI content")
    }
}
