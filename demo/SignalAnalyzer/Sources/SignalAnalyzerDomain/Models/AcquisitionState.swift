package enum AcquisitionState: Equatable, Sendable {
    case idle
    case running
    case stopped
    case failed(String)
}
