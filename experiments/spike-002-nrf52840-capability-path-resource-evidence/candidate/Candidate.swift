// Disposable SPIKE-002 vocabulary. These layouts and names are evidence, not
// candidates for a production GiftUICapabilities API or Specification.

@_silgen_name("spike002_store_result")
func storeResult(
    _ available: UInt32, _ reason: UInt32, _ width: UInt32, _ height: UInt32,
    _ tileBytes: UInt32, _ stagingBytes: UInt32, _ trace: UInt32, _ counters: UInt32
)

@_silgen_name("spike002_read_snapshot")
func readSnapshot() -> UInt32

@_silgen_name("spike002_store_path0") func storePath0(_ trace: UInt32, _ counters: UInt32)
@_silgen_name("spike002_store_path1") func storePath1(_ trace: UInt32, _ counters: UInt32)
@_silgen_name("spike002_store_path2") func storePath2(_ trace: UInt32, _ counters: UInt32)
@_silgen_name("spike002_store_path3") func storePath3(_ trace: UInt32, _ counters: UInt32)
@_silgen_name("spike002_store_path4") func storePath4(_ trace: UInt32, _ counters: UInt32)
@_silgen_name("spike002_store_path5") func storePath5(_ trace: UInt32, _ counters: UInt32)
@_silgen_name("spike002_store_path6") func storePath6(_ trace: UInt32, _ counters: UInt32)

struct EncodingSet {
    var bits: UInt8
    static let rgb565: UInt8 = 1
    static let xrgb8888: UInt8 = 2
}

struct Requirements {
    var operationSet: UInt8
    var delivery: UInt8
    var width: UInt16
    var height: UInt16
}

struct ProducerContribution {
    var operationSet: UInt8
    var delivery: UInt8
    var encodings: EncodingSet
    var producedLifetime: UInt8
    var maxWidth: UInt16
    var maxHeight: UInt16
    var tileBytes: UInt16
}

struct DisplayContribution {
    var encodings: EncodingSet
    var acceptedLifetime: UInt8
    var handoff: UInt8
    var maxInFlight: UInt8
    var width: UInt16
    var height: UInt16
}

struct ResourcePolicy {
    var rasterBytes: UInt16
    var stagingBytes: UInt16
    var maxInFlight: UInt8
}

struct Contributions {
    var requirements: Requirements
    var producer: ProducerContribution
    var display: DisplayContribution
    var policy: ResourcePolicy
    var duplicateProducer: Bool
}

struct WorkCounters {
    var contributionsVisited: UInt8 = 0
    var compatibilityComparisons: UInt8 = 0
    var checkedOperations: UInt8 = 0
    var validationRecords: UInt8 = 0
    var resolverInvocations: UInt8 = 0

    func packed() -> UInt32 {
        UInt32(contributionsVisited)
            | (UInt32(compatibilityComparisons) << 5)
            | (UInt32(checkedOperations) << 11)
            | (UInt32(validationRecords) << 17)
            | (UInt32(resolverInvocations) << 21)
    }
}

struct EffectiveSnapshot {
    var available: Bool = false
    var reason: UInt8 = 0
    var encoding: UInt8 = 0
    var width: UInt16 = 0
    var height: UInt16 = 0
    var tileBytes: UInt16 = 0
    var stagingBytes: UInt16 = 0
    var maxInFlight: UInt8 = 0
}

struct Resolution {
    var snapshot: EffectiveSnapshot
    var counters: WorkCounters
}

let malformedInput: UInt8 = 1
let duplicateOwner: UInt8 = 2
let incompatiblePixelEncoding: UInt8 = 3
let incompatibleSubmissionLifetime: UInt8 = 4
let unsatisfiedResourceBounds: UInt8 = 5

@inline(never)
func unavailable(_ reason: UInt8, _ counters: WorkCounters) -> Resolution {
    var finished = counters
    finished.validationRecords &+= 1
    return Resolution(
        snapshot: EffectiveSnapshot(available: false, reason: reason),
        counters: finished
    )
}

@inline(never)
func resolve(_ input: Contributions) -> Resolution {
    var counters = WorkCounters()
    counters.resolverInvocations = 1
    counters.contributionsVisited = 4

    counters.checkedOperations &+= 1
    if input.requirements.width == 0 || input.requirements.height == 0
        || input.producer.tileBytes == 0 || input.display.width == 0
        || input.display.height == 0 || input.policy.stagingBytes == 0 {
        return unavailable(malformedInput, counters)
    }
    if input.duplicateProducer {
        return unavailable(duplicateOwner, counters)
    }

    counters.compatibilityComparisons &+= 1
    if input.requirements.operationSet != input.producer.operationSet
        || input.requirements.delivery != input.producer.delivery {
        return unavailable(malformedInput, counters)
    }

    counters.compatibilityComparisons &+= 1
    let commonEncodings = input.producer.encodings.bits & input.display.encodings.bits
    if commonEncodings == 0 {
        return unavailable(incompatiblePixelEncoding, counters)
    }

    counters.compatibilityComparisons &+= 1
    let lifetimeCompatible = input.display.acceptedLifetime == 1
        && input.display.handoff == 1 && input.producer.producedLifetime == 1
    if !lifetimeCompatible {
        return unavailable(incompatibleSubmissionLifetime, counters)
    }

    counters.checkedOperations &+= 4
    if input.requirements.width > input.producer.maxWidth
        || input.requirements.height > input.producer.maxHeight
        || input.requirements.width != input.display.width
        || input.requirements.height != input.display.height
        || input.producer.tileBytes > input.policy.rasterBytes
        || input.producer.tileBytes > input.policy.stagingBytes
        || input.display.maxInFlight > input.policy.maxInFlight {
        return unavailable(unsatisfiedResourceBounds, counters)
    }

    counters.validationRecords &+= 1
    return Resolution(
        snapshot: EffectiveSnapshot(
            available: true,
            reason: 0,
            encoding: (commonEncodings & EncodingSet.rgb565) != 0 ? 1 : 2,
            width: input.requirements.width,
            height: input.requirements.height,
            tileBytes: input.producer.tileBytes,
            stagingBytes: input.policy.stagingBytes,
            maxInFlight: input.display.maxInFlight
        ),
        counters: counters
    )
}

@inline(never)
func fixedContributions(_ seed: UInt32) -> Contributions {
    // The volatile C caller's seed prevents the entire path becoming a
    // compile-time constant while preserving the same valid fixture values.
    let width = UInt16(480 &+ (seed & 0))
    return Contributions(
        requirements: Requirements(operationSet: 1, delivery: 1, width: width, height: 320),
        producer: ProducerContribution(
            operationSet: 1, delivery: 1, encodings: EncodingSet(bits: EncodingSet.rgb565),
            producedLifetime: 1, maxWidth: 480, maxHeight: 320, tileBytes: 3_840
        ),
        display: DisplayContribution(
            encodings: EncodingSet(bits: EncodingSet.rgb565), acceptedLifetime: 1,
            handoff: 1, maxInFlight: 1, width: 480, height: 320
        ),
        policy: ResourcePolicy(rasterBytes: 3_840, stagingBytes: 3_840, maxInFlight: 1),
        duplicateProducer: false
    )
}

@_cdecl("spike002_swift_run")
public func spike002CandidateRun(_ seed: UInt32) -> UInt64 {
    var trace: UInt32 = 0
    var digest: UInt32 = seed

    let input = fixedContributions(seed)
    trace |= 1 << 0 // contribution construction
    let success = resolve(input)
    trace |= 1 << 1 // initialization resolution
    trace |= 1 << 2 // validation construction
    let immutableSnapshot = success.snapshot
    storeResult(
        immutableSnapshot.available ? 1 : 0,
        UInt32(immutableSnapshot.reason), UInt32(immutableSnapshot.width),
        UInt32(immutableSnapshot.height), UInt32(immutableSnapshot.tileBytes),
        UInt32(immutableSnapshot.stagingBytes), trace | (1 << 3),
        success.counters.packed()
    )
    trace |= 1 << 3 // effective storage
    digest ^= readSnapshot()
    trace |= 1 << 4 // steady-state read, no resolve call
    storePath0(trace, success.counters.packed())

    var malformed = input
    malformed.requirements.width = 0
    let malformedResult = resolve(malformed)
    storePath1(trace | (1 << 5), malformedResult.counters.packed())
    digest ^= UInt32(malformedResult.snapshot.reason) << 1

    var duplicate = input
    duplicate.duplicateProducer = true
    let duplicateResult = resolve(duplicate)
    storePath2(trace | (1 << 6), duplicateResult.counters.packed())
    digest ^= UInt32(duplicateResult.snapshot.reason) << 3

    var encoding = input
    encoding.display.encodings = EncodingSet(bits: EncodingSet.xrgb8888)
    let encodingResult = resolve(encoding)
    storePath3(trace | (1 << 7), encodingResult.counters.packed())
    digest ^= UInt32(encodingResult.snapshot.reason) << 5

    var lifetime = input
    lifetime.display.acceptedLifetime = 2
    let lifetimeResult = resolve(lifetime)
    storePath4(trace | (1 << 8), lifetimeResult.counters.packed())
    digest ^= UInt32(lifetimeResult.snapshot.reason) << 7

    var bounds = input
    bounds.policy.stagingBytes = 3_839
    let boundsResult = resolve(bounds)
    storePath5(trace | (1 << 9), boundsResult.counters.packed())
    digest ^= UInt32(boundsResult.snapshot.reason) << 9

    // A second success proves validation-result construction is stable and
    // gives the sixth required negative/control slot a positive control.
    let control = resolve(input)
    storePath6(trace | (1 << 10), control.counters.packed())
    digest ^= UInt32(control.snapshot.width) ^ UInt32(control.snapshot.height)
    return (UInt64(trace) << 32) | UInt64(digest)
}
