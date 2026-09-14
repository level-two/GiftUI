package enum RuntimeProfileTimingProbe {
    @inline(never)
    package static func measureNanoseconds(_ operation: () -> Void) -> UInt64 {
        let clock = ContinuousClock()
        let start = clock.now
        operation()
        let components = start.duration(to: clock.now).components
        let seconds = UInt64(components.seconds)
        let attoseconds = UInt64(components.attoseconds)
        let (secondNanoseconds, secondOverflow) = seconds.multipliedReportingOverflow(by: 1_000_000_000)
        let fractionalNanoseconds = attoseconds / 1_000_000_000
        let (total, additionOverflow) = secondNanoseconds.addingReportingOverflow(fractionalNanoseconds)
        return secondOverflow || additionOverflow ? .max : total
    }
}
