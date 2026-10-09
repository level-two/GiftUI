import SignalAnalyzerTargetHost
import Testing

struct SignalAnalyzerSourceScheduleTests {
    @Test func latePollingPreservesThirtySecondTimeline() {
        var schedule = SignalAnalyzerSourceSchedule()
        let result1 = schedule.synchronize(generation: 1, delayMicroseconds: 12_500, now: 0)
        #expect(result1)
        var deliveries = 0
        for now in stride(from: UInt64(250_000), through: 30_000_000, by: 250_000) {
            var batch = 0
            while let deadline = schedule.deadline, deadline <= now {
                #expect(batch < 20)
                deliveries += 1
                #expect(deadline == UInt64(deliveries) * 12_500)
                let result2 = schedule.advance(by: 12_500)
                #expect(result2)
                batch += 1
            }
            #expect(batch == 20)
        }
        #expect(deliveries == 2400)
        #expect(schedule.deadline == 30_012_500)
    }

    @Test func stopRestartAndClearKeepGenerationSemantics() {
        var schedule = SignalAnalyzerSourceSchedule()
        let result3 = schedule.synchronize(generation: nil, delayMicroseconds: nil, now: 0)
        #expect(result3)
        #expect(schedule.deadline == nil)
        let result4 = schedule.synchronize(generation: 1, delayMicroseconds: 10, now: 100)
        #expect(result4)
        // An unchanged generation (including Clear) cannot rebase a pending event.
        let result5 = schedule.synchronize(generation: 1, delayMicroseconds: 10, now: 1000)
        #expect(result5)
        #expect(schedule.deadline == 110)
        let result6 = schedule.advance(by: 0)
        #expect(result6)
        #expect(schedule.deadline == 110)
        // Stop+Start can occur in one opportunity without an idle poll.
        let result7 = schedule.synchronize(generation: 2, delayMicroseconds: 20, now: 1000)
        #expect(result7)
        #expect(schedule.deadline == 1020)
        let result8 = schedule.synchronize(generation: nil, delayMicroseconds: nil, now: 1001)
        #expect(result8)
        #expect(schedule.deadline == nil)
        let result9 = !schedule.advance(by: 1)
        #expect(result9)
    }

    @Test func invalidScheduleCannotPartiallyReplaceAnchor() {
        var schedule = SignalAnalyzerSourceSchedule()
        let result10 = !schedule.synchronize(generation: 1, delayMicroseconds: nil, now: 0)
        #expect(result10)
        #expect(schedule.generation == nil)
        let result11 = schedule.synchronize(generation: 1, delayMicroseconds: 0, now: .max)
        #expect(result11)
        let result12 = !schedule.advance(by: 1)
        #expect(result12)
        #expect(schedule.deadline == .max)
        let result13 = !schedule.synchronize(generation: 2, delayMicroseconds: 1, now: .max)
        #expect(result13)
        #expect(schedule.generation == 1)
    }
}
