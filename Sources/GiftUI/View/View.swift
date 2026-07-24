public protocol View {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }
}

extension Never: View {
    public var body: Never {
        fatalError("Never cannot produce a GiftUI view body")
    }
}
