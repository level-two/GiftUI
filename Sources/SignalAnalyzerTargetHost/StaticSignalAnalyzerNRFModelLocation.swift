import SignalAnalyzerDomain

/// One typed, address-stable target model location. A copied handle refers to
/// this location and its current generation; no model object is allocated.
package struct StaticSignalAnalyzerNRFModelLocation {
    package let structuralIdentity = StaticSignalAnalyzerNRFModelDescriptor.structuralIdentity
    package let declarationOrdinal = StaticSignalAnalyzerNRFModelDescriptor.declarationOrdinal
    private var nextGeneration: UInt32? = 0
    package private(set) var activeGeneration: UInt32?
    package private(set) var visibleWindowRawValue: UInt8 = 1
    package private(set) var isDirty = false
    package private(set) var isMutating = false
    package private(set) var errorMessage: SignalAnalyzerDiagnostic?

    package init() {}

    package mutating func activate() -> UInt32? {
        guard activeGeneration == nil, let generation = nextGeneration else {
            return nil
        }
        activeGeneration = generation
        nextGeneration = generation == .max ? nil : generation + 1
        visibleWindowRawValue = 1
        isDirty = true
        isMutating = false
        errorMessage = nil
        return generation
    }

    package mutating func retire() {
        activeGeneration = nil
        isDirty = false
        isMutating = false
    }

    package mutating func beginMutation() -> Bool {
        guard activeGeneration != nil, !isMutating else { return false }
        isMutating = true
        return true
    }

    package mutating func endMutation() -> Bool {
        guard isMutating else { return false }
        isMutating = false
        return true
    }

    package mutating func clearDirtyAfterPublication() {
        isDirty = false
    }

    package mutating func setDiagnostic(_ diagnostic: SignalAnalyzerDiagnostic?) -> Bool {
        guard let generation = activeGeneration, isMutating else { return false }
        guard errorMessage != diagnostic else { return true }
        let previous = errorMessage
        errorMessage = diagnostic
        let token = StaticSignalAnalyzerNRFRegistrationToken(slot: 0, generation: generation)
        guard reportChange(token: token) == .accepted else {
            errorMessage = previous
            return false
        }
        return true
    }

    package mutating func reportChange(
        token: StaticSignalAnalyzerNRFRegistrationToken
    ) -> StaticSignalAnalyzerNRFChangeReportOutcome {
        guard token.slot == 0, activeGeneration == token.generation else {
            return .staleRegistration
        }
        guard isMutating else { return .phaseViolation }
        isDirty = true
        return .accepted
    }

    fileprivate mutating func selectWindow(_ rawValue: UInt8) -> Bool {
        guard let generation = activeGeneration, isMutating, rawValue <= 2 else {
            return false
        }
        if visibleWindowRawValue != rawValue {
            let previous = visibleWindowRawValue
            visibleWindowRawValue = rawValue
            let token = StaticSignalAnalyzerNRFRegistrationToken(
                slot: 0, generation: generation
            )
            guard reportChange(token: token) == .accepted else {
                visibleWindowRawValue = previous
                return false
            }
        }
        return true
    }
}

package struct StaticSignalAnalyzerNRFRegistrationToken: Equatable, Sendable {
    package let slot: UInt16
    package let generation: UInt32

    package init(slot: UInt16, generation: UInt32) {
        self.slot = slot
        self.generation = generation
    }
}

package enum StaticSignalAnalyzerNRFChangeReportOutcome: UInt8, Equatable {
    case accepted = 0
    case staleRegistration = 1
    case phaseViolation = 2
}

/// One bounded direct endpoint; copies still report against the same location.
package struct StaticSignalAnalyzerNRFChangeRegistration {
    private let location: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>
    package let token: StaticSignalAnalyzerNRFRegistrationToken

    package init?(
        location: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>,
        token: StaticSignalAnalyzerNRFRegistrationToken
    ) {
        guard token.slot == 0,
            location.pointee.activeGeneration == token.generation
        else { return nil }
        self.location = location
        self.token = token
    }

    package func reportChange() -> StaticSignalAnalyzerNRFChangeReportOutcome {
        location.pointee.reportChange(token: token)
    }
}

package enum StaticSignalAnalyzerNRFModelIntent: UInt8, Equatable {
    case start = 0
    case stop = 1
    case clear = 2
    case visibleWindowChanged = 3
}

/// The handle never owns the model location. Its caller must end this lifetime
/// before the enclosing address-stable storage scope returns.
package struct StaticSignalAnalyzerNRFModelHandle {
    private let location: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>
    private let generation: UInt32

    package init?(
        location: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>,
        generation: UInt32
    ) {
        guard location.pointee.activeGeneration == generation else { return nil }
        self.location = location
        self.generation = generation
    }

    package func dispatch(actionRawValue: UInt16) -> StaticSignalAnalyzerNRFModelIntent? {
        guard location.pointee.activeGeneration == generation,
            location.pointee.isMutating
        else { return nil }
        switch actionRawValue {
        case 0:
            return location.pointee.setDiagnostic(nil) ? .start : nil
        case 1: return .stop
        case 2: return .clear
        case 3: return selectWindow(0)
        case 4: return selectWindow(1)
        case 5: return selectWindow(2)
        default: return nil
        }
    }

    private func selectWindow(_ rawValue: UInt8) -> StaticSignalAnalyzerNRFModelIntent? {
        location.pointee.selectWindow(rawValue) ? .visibleWindowChanged : nil
    }
}
