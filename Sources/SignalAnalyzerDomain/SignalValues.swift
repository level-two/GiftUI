package struct SignalChannelID: Hashable, Sendable {
    package let rawValue: Int

    package init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package var isStandard: Bool {
        rawValue >= 1 && rawValue <= 4
    }
}

package struct SignalChannel: Identifiable, Equatable, Sendable {
    package let id: SignalChannelID
    package let name: String

    package init(id: SignalChannelID, name: String) {
        self.id = id
        self.name = name
    }

    package static let standard = SignalChannelCollection(
        SignalChannel(id: SignalChannelID(rawValue: 1), name: "CH1"),
        SignalChannel(id: SignalChannelID(rawValue: 2), name: "CH2"),
        SignalChannel(id: SignalChannelID(rawValue: 3), name: "CH3"),
        SignalChannel(id: SignalChannelID(rawValue: 4), name: "CH4")
    )
}

package struct SignalChannelCollection: RandomAccessCollection, Equatable, Sendable {
    package typealias Index = Int
    package typealias Element = SignalChannel

    private let values: (SignalChannel, SignalChannel, SignalChannel, SignalChannel)

    package init(
        _ first: SignalChannel,
        _ second: SignalChannel,
        _ third: SignalChannel,
        _ fourth: SignalChannel
    ) {
        values = (first, second, third, fourth)
    }

    package var startIndex: Int { 0 }
    package var endIndex: Int { 4 }

    package subscript(position: Int) -> SignalChannel {
        switch position {
        case 0: values.0
        case 1: values.1
        case 2: values.2
        case 3: values.3
        default: preconditionFailure("Signal channel index is out of bounds")
        }
    }

    package static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.elementsEqual(rhs)
    }
}

package enum DigitalLevel: Equatable, Sendable {
    case low
    case high
}

package struct SignalTransition: Equatable, Sendable {
    package let channelID: SignalChannelID
    package let timestamp: Duration
    package let level: DigitalLevel

    package init(
        channelID: SignalChannelID,
        timestamp: Duration,
        level: DigitalLevel
    ) {
        self.channelID = channelID
        self.timestamp = timestamp
        self.level = level
    }
}

package struct SignalChannelLevels: Equatable, Sendable {
    package let ch1: DigitalLevel
    package let ch2: DigitalLevel
    package let ch3: DigitalLevel
    package let ch4: DigitalLevel

    package init(
        ch1: DigitalLevel,
        ch2: DigitalLevel,
        ch3: DigitalLevel,
        ch4: DigitalLevel
    ) {
        self.ch1 = ch1
        self.ch2 = ch2
        self.ch3 = ch3
        self.ch4 = ch4
    }

    package static let allLow = SignalChannelLevels(
        ch1: .low,
        ch2: .low,
        ch3: .low,
        ch4: .low
    )

    package subscript(channelID: SignalChannelID) -> DigitalLevel? {
        switch channelID.rawValue {
        case 1: ch1
        case 2: ch2
        case 3: ch3
        case 4: ch4
        default: nil
        }
    }
}

package struct SignalTransitionCollection: RandomAccessCollection, Equatable, Sendable {
    package typealias Index = Int
    package typealias Element = SignalTransition

    private let values: [SignalTransition]

    package init<S: Sequence>(_ source: S) where S.Element == SignalTransition {
        values = Array(source)
    }

    package var startIndex: Int { values.startIndex }
    package var endIndex: Int { values.endIndex }
    package var count: Int { values.count }

    package subscript(position: Int) -> SignalTransition {
        values[position]
    }

    package func element(at position: UInt16) -> SignalTransition? {
        let index = Int(position)
        guard index < values.count else { return nil }
        return values[index]
    }
}

package struct SignalCapture: Equatable, Sendable {
    package static let maximumTransitionCount = 2_404

    package let channels: SignalChannelCollection
    package let transitions: SignalTransitionCollection
    package let duration: Duration
    package let retainedLowerBound: Duration
    package let baselineLevels: SignalChannelLevels

    package init?<S: Collection>(
        transitions source: S,
        duration: Duration,
        retainedLowerBound: Duration = .zero,
        baselineLevels: SignalChannelLevels = .allLow
    ) where S.Element == SignalTransition {
        guard
            Self.validate(
                source,
                duration: duration,
                retainedLowerBound: retainedLowerBound
            )
        else {
            return nil
        }

        channels = SignalChannel.standard
        transitions = SignalTransitionCollection(source)
        self.duration = duration
        self.retainedLowerBound = retainedLowerBound
        self.baselineLevels = baselineLevels
    }

    package static func empty() -> SignalCapture {
        SignalCapture(
            transitions: [SignalTransition](),
            duration: .zero
        )!
    }

    package func baselineLevel(for channelID: SignalChannelID) -> DigitalLevel {
        baselineLevels[channelID] ?? .low
    }

    fileprivate static func validate<S: Collection>(
        _ source: S,
        duration: Duration,
        retainedLowerBound: Duration
    ) -> Bool where S.Element == SignalTransition {
        guard source.count <= maximumTransitionCount,
            retainedLowerBound >= .zero,
            retainedLowerBound <= duration
        else {
            return false
        }

        var previousTimestamp = retainedLowerBound
        for transition in source {
            guard transition.channelID.isStandard,
                transition.timestamp >= retainedLowerBound,
                transition.timestamp <= duration,
                transition.timestamp >= previousTimestamp
            else {
                return false
            }
            previousTimestamp = transition.timestamp
        }
        return true
    }
}

/// Caller-owned bounded storage for allocation-free static-profile capture construction.
/// The caller retains responsibility for the backing buffer's lifetime.
package struct SignalCaptureStaticStorage: ~Copyable {
    package static let requiredCapacity = SignalCapture.maximumTransitionCount

    private var buffer: UnsafeMutableBufferPointer<SignalTransition?>
    package private(set) var count: UInt16
    package let duration: Duration
    package let retainedLowerBound: Duration
    package let baselineLevels: SignalChannelLevels

    package init?<S: Collection>(
        buffer: UnsafeMutableBufferPointer<SignalTransition?>,
        transitions source: S,
        duration: Duration,
        retainedLowerBound: Duration = .zero,
        baselineLevels: SignalChannelLevels = .allLow
    ) where S.Element == SignalTransition {
        guard buffer.count >= Self.requiredCapacity,
            SignalCapture.validate(
                source,
                duration: duration,
                retainedLowerBound: retainedLowerBound
            )
        else {
            return nil
        }

        self.buffer = buffer
        count = 0
        self.duration = duration
        self.retainedLowerBound = retainedLowerBound
        self.baselineLevels = baselineLevels

        for transition in source {
            self.buffer[Int(count)] = transition
            count += 1
        }
    }

    package func element(at position: UInt16) -> SignalTransition? {
        guard position < count else { return nil }
        return buffer[Int(position)]
    }

    package func baselineLevel(for channelID: SignalChannelID) -> DigitalLevel {
        baselineLevels[channelID] ?? .low
    }
}

package enum AcquisitionState: Equatable, Sendable {
    case idle
    case running
    case stopped
    case failed(SignalAnalyzerDiagnostic)
}
