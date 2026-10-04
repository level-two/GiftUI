import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerTargetHost

@main
struct RetentionResearch {
    static func main() {
        let bytes = StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
        defer { pointer.deallocate() }
        var regions = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(start: pointer, count: bytes))!
        var portable = SignalCaptureStore()
        var target = StaticSignalAnalyzerNRFCaptureHistory()
        var replay = SignalCaptureRevisionState.initial
        var full: [SignalTransition] = []
        var comparisons = 0
        var windowComparisons = 0
        func compare(_ event: SignalTransition, accepted: Bool = true) {
            let p = portable.receive(event)
            let t = target.receive(event, in: &regions)
            switch (p, t) {
            case (.accepted(let publication), .accepted(let revision, let change)):
                precondition(accepted)
                precondition(publication == .mutation(revision: revision, change: change))
                guard case .applied(let next) = publication.replay(on: replay) else {
                    preconditionFailure("mutation replay failed")
                }
                replay = next
                full.append(event)
            case (.rejected(let p), .rejected(let t)):
                precondition(!accepted && String(describing: p) == String(describing: t))
            default: preconditionFailure("history outcomes differ")
            }
            precondition(replay.capture == portable.capture)
            precondition(target.revision == portable.revision)
            precondition(Int(target.count) == portable.capture.transitions.count)
            precondition(target.duration == portable.capture.duration)
            precondition(target.retainedLowerBound == portable.capture.retainedLowerBound)
            precondition(target.baselineLevels == portable.capture.baselineLevels)
            for index in 0..<Int(target.count) {
                precondition(regions.load(from: .live, at: index)?.transition == portable.capture.transitions[index])
            }
            comparisons += 1
        }
        func event(_ channel: Int, _ ms: Int, _ level: DigitalLevel) -> SignalTransition {
            SignalTransition(channelID: SignalChannelID(rawValue: channel),
                             timestamp: .milliseconds(ms), level: level)
        }
        for channel in 1...4 { compare(event(channel, 0, .low)) }
        for tick in 1...600 {
            for channel in 1...4 {
                compare(event(channel, tick * 50, tick.isMultiple(of: 2) ? .low : .high))
            }
            // Independent full-history level oracle for each visible left edge.
            for window in [1, 2, 5] {
                let cutoff = max(Duration.zero, .milliseconds(tick * 50) - .seconds(window))
                for channel in 1...4 {
                    let id = SignalChannelID(rawValue: channel)
                    var original = DigitalLevel.low
                    for transition in full where transition.channelID == id && transition.timestamp < cutoff {
                        original = transition.level
                    }
                    var retained = portable.capture.baselineLevel(for: id)
                    for transition in portable.capture.transitions where transition.channelID == id && transition.timestamp < cutoff {
                        retained = transition.level
                    }
                    precondition(original == retained)
                    windowComparisons += 1
                }
            }
        }
        precondition(portable.capture.transitions.count == 404)
        precondition(portable.capture.retainedLowerBound == .seconds(25))
        precondition(portable.capture.transitions.first?.timestamp == .seconds(25))
        precondition(portable.revision == 2404)
        let snapshot = target.snapshot(in: &regions)!
        let first = regions.load(from: .admission, at: 0)
        compare(event(3, 25_010, .high)) // retained out-of-order insertion under pressure
        compare(event(1, 24_999, .high), accepted: false)
        compare(event(5, 30_000, .high), accepted: false)
        compare(event(1, -1, .high), accepted: false)
        compare(event(1, 30_000, .high)) // equal-time arrival stays last
        precondition(regions.load(from: .admission, at: 0) == first)
        precondition(snapshot.count == 404)
        let pc = portable.clear()
        let tc = target.clear(in: &regions)
        guard case .accepted(let publication) = pc,
              case .accepted(let revision, let change) = tc,
              case .applied(let next) = publication.replay(on: replay) else {
            preconditionFailure("clear failed")
        }
        precondition(publication == .mutation(revision: revision, change: change))
        replay = next
        precondition(target.baselineLevels == portable.capture.baselineLevels)
        precondition(regions.load(from: .admission, at: 0) == first)
        compare(event(1, 30_050, .low))
        precondition(portable.capture.duration == .milliseconds(50))
        precondition(portable.capture.transitions.count == 1)
        var exhaustedP = SignalCaptureStore(initialRevision: .max)
        var exhaustedT = StaticSignalAnalyzerNRFCaptureHistory(initialRevision: .max)
        guard case .rejected(.revisionExhausted) = exhaustedP.receive(event(1, 0, .low)),
              case .rejected(.revisionExhausted) = exhaustedT.receive(event(1, 0, .low), in: &regions)
        else { preconditionFailure("revision exhaustion differed") }
        print("five-second candidate: \(comparisons) paired history/replay checks; \(windowComparisons) independent left-edge checks; storage=\(bytes); final sustained revision=2404")
    }
}
