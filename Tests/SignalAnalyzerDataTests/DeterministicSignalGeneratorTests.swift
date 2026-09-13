import SignalAnalyzerData
import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer deterministic generator")
struct DeterministicSignalGeneratorTests {
    @Test("CH1 CH2 and CH3 follow exact interval patterns")
    func fixedPatterns() {
        var generator = DeterministicSignalGenerator(seed: 1_234)
        var timestamps = [Int: [Duration]]()
        while timestamps.values.map(\.count).min() ?? 0 < 8 {
            let transition = generator.nextTransition()
            timestamps[transition.channelID.rawValue, default: []].append(transition.timestamp)
        }

        #expect(
            Array(timestamps[1]!.prefix(4)) == [
                .milliseconds(250), .milliseconds(500), .milliseconds(750), .seconds(1),
            ])
        #expect(
            Array(timestamps[2]!.prefix(4)) == [
                .milliseconds(400), .milliseconds(800), .milliseconds(1_200), .milliseconds(1_600),
            ])
        #expect(
            Array(timestamps[3]!.prefix(8)) == [
                .milliseconds(80), .milliseconds(160), .milliseconds(240), .milliseconds(1_440),
                .milliseconds(1_515), .milliseconds(1_590), .milliseconds(2_490),
                .milliseconds(2_570),
            ])
    }

    @Test("CH4 seed 1234 matches the normative golden vector")
    func seed1234() {
        #expect(ch4Timestamps(seed: 1_234) == [0, 251, 791, 1_380, 1_674, 2_069, 2_477, 2_946])
    }

    @Test("CH4 default live seed matches the normative golden vector")
    func defaultSeed() {
        #expect(ch4Timestamps(seed: 0x5EED) == [0, 438, 909, 1_189, 1_370, 1_964, 2_555, 2_815])
    }

    private func ch4Timestamps(seed: UInt64) -> [Int] {
        var generator = DeterministicSignalGenerator(seed: seed)
        var result = [0]
        while result.count < 8 {
            let transition = generator.nextTransition()
            if transition.channelID.rawValue == 4 {
                let components = transition.timestamp.components
                result.append(
                    Int(components.seconds * 1_000 + components.attoseconds / 1_000_000_000_000_000)
                )
            }
        }
        return result
    }
}
