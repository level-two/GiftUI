/// One typed, address-stable target model location. A copied handle refers to
/// this location and its current generation; no model object is allocated.
package struct StaticSignalAnalyzerNRFModelLocation {
    private var nextGeneration: UInt32? = 0
    package private(set) var activeGeneration: UInt32?
    package private(set) var visibleWindowRawValue: UInt8 = 1
    package private(set) var isDirty = false

    package init() {}

    package mutating func activate() -> UInt32? {
        guard activeGeneration == nil, let generation = nextGeneration else {
            return nil
        }
        activeGeneration = generation
        nextGeneration = generation == .max ? nil : generation + 1
        visibleWindowRawValue = 1
        isDirty = true
        return generation
    }

    package mutating func retire() {
        activeGeneration = nil
        isDirty = false
    }

    package mutating func clearDirtyAfterPublication() {
        isDirty = false
    }

    fileprivate mutating func selectWindow(_ rawValue: UInt8) -> Bool {
        guard activeGeneration != nil, rawValue <= 2 else { return false }
        if visibleWindowRawValue != rawValue {
            visibleWindowRawValue = rawValue
            isDirty = true
        }
        return true
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
        guard location.pointee.activeGeneration == generation else { return nil }
        switch actionRawValue {
        case 0: return .start
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
