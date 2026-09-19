import GiftUIFailureCore

public struct GiftUICorrelatedFailure<Context> {
    public let fact: GiftUIFailureFact
    public let context: Context
    public let annotations: GiftUIFailureAnnotations

    public init(
        fact: GiftUIFailureFact,
        context: Context,
        annotations: GiftUIFailureAnnotations = .init()
    ) {
        self.fact = fact
        self.context = context
        self.annotations = annotations
    }
}

extension GiftUICorrelatedFailure: Sendable where Context: Sendable {}
extension GiftUICorrelatedFailure: Equatable where Context: Equatable {}
