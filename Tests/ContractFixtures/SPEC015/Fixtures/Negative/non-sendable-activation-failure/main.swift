import GiftUIHostConfiguration

final class NonSendableFailure: Equatable {
    static func == (lhs: NonSendableFailure, rhs: NonSendableFailure) -> Bool {
        lhs === rhs
    }
}

let result: HostActivationResult<NonSendableFailure>? = nil
_ = result
