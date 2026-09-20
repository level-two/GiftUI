package enum PiScreenConsoleMode: Int32, Equatable, Sendable {
    case text = 0
    case graphics = 1
}

package protocol PiScreenConsoleModeTransport {
    mutating func readMode() -> PiScreenConsoleMode?
    mutating func writeMode(_ mode: PiScreenConsoleMode) -> Bool
    mutating func close()
}

package enum PiScreenConsoleOwnershipFailure: UInt8, Error, Equatable, Sendable {
    case invalidLifecycle = 0
    case modeReadFailed = 1
    case graphicsModeFailed = 2
    case restoreModeFailed = 3
}

package enum PiScreenConsoleAcquisition: Equatable, Sendable {
    case acquired(previousMode: PiScreenConsoleMode, changedMode: Bool)
    case failure(PiScreenConsoleOwnershipFailure)
}

package enum PiScreenConsoleRestoration: Equatable, Sendable {
    case restored(changedMode: Bool)
    case failure(PiScreenConsoleOwnershipFailure)
}

package struct PiScreenConsoleModeOwner<Transport: PiScreenConsoleModeTransport> {
    private enum State: UInt8 {
        case ready = 0
        case acquired = 1
        case released = 2
    }

    private var transport: Transport
    private var state: State = .ready
    private var previousMode: PiScreenConsoleMode?

    package init(transport: Transport) {
        self.transport = transport
    }

    package mutating func acquire() -> PiScreenConsoleAcquisition {
        guard state == .ready else { return .failure(.invalidLifecycle) }
        guard let mode = transport.readMode() else {
            releaseTransport()
            return .failure(.modeReadFailed)
        }
        previousMode = mode
        let changedMode = mode != .graphics
        guard !changedMode || transport.writeMode(.graphics) else {
            releaseTransport()
            return .failure(.graphicsModeFailed)
        }
        state = .acquired
        return .acquired(previousMode: mode, changedMode: changedMode)
    }

    package mutating func restore() -> PiScreenConsoleRestoration {
        if state == .released { return .restored(changedMode: false) }
        guard state == .acquired, let previousMode else {
            return .failure(.invalidLifecycle)
        }
        let changedMode = previousMode != .graphics
        let restored = !changedMode || transport.writeMode(previousMode)
        releaseTransport()
        guard restored else { return .failure(.restoreModeFailed) }
        return .restored(changedMode: changedMode)
    }

    private mutating func releaseTransport() {
        transport.close()
        previousMode = nil
        state = .released
    }
}
