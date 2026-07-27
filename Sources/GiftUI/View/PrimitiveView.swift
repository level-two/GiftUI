package protocol PrimitiveView: View where Body == Never {}

extension PrimitiveView {
    public var body: Never {
        fatalError("Primitive GiftUI views do not have a body")
    }

}
