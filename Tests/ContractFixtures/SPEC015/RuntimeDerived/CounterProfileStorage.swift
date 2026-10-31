#if !GIFTUI_COUNTER_REPORT_ACCUMULATOR_ORACLE
import P08CounterTable
import P08CounterSchema
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
@testable import GiftUIRuntimeCore
import GiftUISemanticCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif

#endif

// This concrete callback-local value avoids generic captured-box metadata.
// Every indexed total, wrapping addition and sticky overflow bit is unchanged.
struct CounterPhysicalReportAccumulator {
    private var f00: UInt64 = 0
    private var f01: UInt64 = 0
    private var f02: UInt64 = 0
    private var f03: UInt64 = 0
    private var f04: UInt64 = 0
    private var f05: UInt64 = 0
    private var f06: UInt64 = 0
    private var f07: UInt64 = 0
    private var f08: UInt64 = 0
    private var f09: UInt64 = 0
    private var f10: UInt64 = 0
    private var f11: UInt64 = 0
    private var f12: UInt64 = 0
    private var f13: UInt64 = 0
    private var f14: UInt64 = 0
    private var f15: UInt64 = 0
    private var f16: UInt64 = 0
    private var f17: UInt64 = 0
    private var f18: UInt64 = 0
    private var f19: UInt64 = 0
    private var f20: UInt64 = 0
    private var f21: UInt64 = 0
    private var f22: UInt64 = 0
    private var f23: UInt64 = 0
    private var f24: UInt64 = 0
    private var f25: UInt64 = 0
    private(set) var overflow = false

    subscript(_ family: Int) -> UInt64 {
        get {
            switch family {
            case 0: return f00
            case 1: return f01
            case 2: return f02
            case 3: return f03
            case 4: return f04
            case 5: return f05
            case 6: return f06
            case 7: return f07
            case 8: return f08
            case 9: return f09
            case 10: return f10
            case 11: return f11
            case 12: return f12
            case 13: return f13
            case 14: return f14
            case 15: return f15
            case 16: return f16
            case 17: return f17
            case 18: return f18
            case 19: return f19
            case 20: return f20
            case 21: return f21
            case 22: return f22
            case 23: return f23
            case 24: return f24
            case 25: return f25
            default: preconditionFailure("physical report family out of bounds")
            }
        }
        set {
            switch family {
            case 0: f00 = newValue
            case 1: f01 = newValue
            case 2: f02 = newValue
            case 3: f03 = newValue
            case 4: f04 = newValue
            case 5: f05 = newValue
            case 6: f06 = newValue
            case 7: f07 = newValue
            case 8: f08 = newValue
            case 9: f09 = newValue
            case 10: f10 = newValue
            case 11: f11 = newValue
            case 12: f12 = newValue
            case 13: f13 = newValue
            case 14: f14 = newValue
            case 15: f15 = newValue
            case 16: f16 = newValue
            case 17: f17 = newValue
            case 18: f18 = newValue
            case 19: f19 = newValue
            case 20: f20 = newValue
            case 21: f21 = newValue
            case 22: f22 = newValue
            case 23: f23 = newValue
            case 24: f24 = newValue
            case 25: f25 = newValue
            default: preconditionFailure("physical report family out of bounds")
            }
        }
    }

    mutating func record(family: Int, chargedBytes: UInt64, report: (UInt64, Bool) -> Void) {
        precondition((0..<26).contains(family))
        let sum = self[family].addingReportingOverflow(chargedBytes)
        overflow = overflow || sum.overflow
        self[family] = sum.partialValue
        report(self[family], overflow)
    }
}

#if !GIFTUI_COUNTER_REPORT_ACCUMULATOR_ORACLE
#if hasFeature(Embedded)
typealias CounterStaticRootStorage = StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>
#else
/// Concrete Native owning storage. It lends the same contiguous model slots and
/// independently borrowed registration fields to the common checked factories.
struct CounterStaticRootStorage: ~Copyable {
    private var ownership: ObservableModelOwnership
    private var models: InlineArray<2, CounterOwnedModel?> = [nil, nil]
    private var identities: InlineArray<2, SemanticCompleteIdentity?> = [nil, nil]
    private var registration = ObservableStateRootControl()
    private let schema: UInt16
    private let needsCapture: Bool

    init?(identity: ObservableModelOwnerIdentity, schema: UInt16, needsCapture: Bool,
        modelLimit: UInt16 = 2, claimLimit: UInt16 = 4, pinLimit: UInt16 = 2,
        captureLimit: UInt16? = nil) {
        guard let ownership = ObservableModelOwnership(identity: identity, modelLimit: modelLimit,
            claimLimit: claimLimit, pinLimit: pinLimit, captureLimit: captureLimit ?? (needsCapture ? 1 : 0))
        else { return nil }
        self.ownership = consume ownership
        self.schema = schema
        self.needsCapture = needsCapture
    }

    var storageLayout: (owner: ObservableModelOwnerIdentity, models: UInt16, claims: UInt16,
        pins: UInt16, captures: UInt16, metadataBytes: Int, modelBytes: Int, pinBytes: Int,
        liveBytes: Int, candidateBytes: Int) {
        let capacities = ownership.storageCapacities
        let modelBytes = MemoryLayout<InlineArray<2, CounterOwnedModel?>>.size
        let registrationBytes = MemoryLayout<ObservableStateRootControl>.size
            + MemoryLayout<InlineArray<2, SemanticCompleteIdentity?>>.size
        let fields = MemoryLayout<ObservableModelOwnership>.size + modelBytes + registrationBytes
            + MemoryLayout<UInt16>.size + MemoryLayout<Bool>.size
        let metadataBytes = ObservableModelOwnership.metadataStorageBytes
            + MemoryLayout<UInt16>.size + MemoryLayout<Bool>.size + MemoryLayout<Self>.size - fields
        let candidateBytes = ObservableStateRootControl.candidateStorageBytes
        return (ownership.identityForAccounting(), 2, 4, 2, capacities.captures, metadataBytes, modelBytes,
            ObservableModelOwnership.framePinStorageBytes, registrationBytes - candidateBytes,
            candidateBytes)
    }

    mutating func withLifetime<Result>(
        limits: ObservableStateLimits = .init(maximumLocations: 2, maximumRegistrations: 2,
            maximumStagedAssociations: 2)!,
        _ body: (borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
            borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>)
            throws(ObservableStateError) -> Result
    ) throws(ObservableStateError) -> Result {
        try Self.withFields(ownership: &ownership, models: &models, identities: &identities,
            registration: &registration, schema: schema, needsCapture: needsCapture,
            limits: limits, body)
    }

    private static func withFields<Result>(ownership: inout ObservableModelOwnership,
        models: inout InlineArray<2, CounterOwnedModel?>,
        identities: inout InlineArray<2, SemanticCompleteIdentity?>,
        registration: inout ObservableStateRootControl, schema: UInt16, needsCapture: Bool,
        limits: ObservableStateLimits,
        _ body: (borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
            borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>)
            throws(ObservableStateError) -> Result
    ) throws(ObservableStateError) -> Result {
        var span = models.mutableSpan
        return try withObservableModelScope(ownership: &ownership, models: &span,
            schema: schema, needsCapture: needsCapture) { (scope) throws(ObservableStateError) in
            try scope.withRoot(identities: &identities, control: &registration, limits: limits) {
                (root) throws(ObservableStateError) in try body(scope, root)
            }
        }
    }
}
#endif

// These are the actual typed owners, not an audited allocation recipe. An
// activation moves owned workspaces into the scoped pipeline and restores them
// only after the consuming coordinator has quiesced and ended all its borrows.
typealias CounterStaticCandidate = StaticTwoInteractionCandidateStorage<SemanticCompleteIdentity>
typealias CounterStaticCommitted = StaticTwoInteractionCommittedStorage<SemanticCompleteIdentity>
typealias CounterStaticHits = StaticTwoInteractionHitStorage<SemanticCompleteIdentity>
typealias CounterStaticKeys = InteractionOwnedKeyState<CounterStaticCandidate, CounterStaticCommitted, CounterStaticHits>
typealias CounterRootLayout = (owner: ObservableModelOwnerIdentity, models: UInt16, claims: UInt16, pins: UInt16, captures: UInt16, metadataBytes: Int, modelBytes: Int, pinBytes: Int, liveBytes: Int, candidateBytes: Int)
let counterSemanticLimits = SemanticRecordLimits(records: 64, paths: 192, depth: 24, fanout: 5, payloads: 128, textScalars: 64, payloadBytes: 4096)!
let counterCanvasLimits = StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: UInt16(MemoryLayout<CounterValueTable.CaptureStorage>.stride))!
let counterExecutionLimits = ExecutionLimits(maximumInputEvents: 2, maximumStateChangeFacts: 34, maximumCompletionFacts: 1, maximumSemanticActions: 2, maximumActiveInputSources: 1, maximumCommittedActions: 2)!

private func counterInitialSemanticRecords() -> InlineArray<128, SemanticRuntimeRecord> {
    let seed = SemanticRuntimeRecord()
    return [seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed]
}

private func counterInitialSemanticPaths() -> InlineArray<384, SemanticPathEntry> {
    let seed = SemanticPathEntry()
    return [seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed, seed]
}

struct CounterSemanticBacking: ~Copyable {
    var pending = CounterPendingBacking()
    var records: InlineArray<128, SemanticRuntimeRecord> = counterInitialSemanticRecords()
    var paths: InlineArray<384, SemanticPathEntry> = counterInitialSemanticPaths()
    var payloads: InlineArray<256, CounterPayload?> = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    var scalars: InlineArray<128, UInt32> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    static var paddingBytes: Int {
        let fields = MemoryLayout<InlineArray<128, SemanticRuntimeRecord>>.size + MemoryLayout<InlineArray<384, SemanticPathEntry>>.size + MemoryLayout<InlineArray<256, CounterPayload?>>.size + MemoryLayout<InlineArray<128, UInt32>>.size
        precondition(MemoryLayout<Self>.size >= fields)
        return MemoryLayout<Self>.size - fields - MemoryLayout<CounterPendingBacking>.size
    }
}

struct CounterStaticWorkspaceBacking {
    var scopes: InlineArray<1024, UInt8> = .init(repeating: 0)
    var text: InlineArray<1056, UInt8> = .init(repeating: 0)
    var path: InlineArray<20, UInt8> = .init(repeating: 0)
    var plan: InlineArray<112, UInt8> = .init(repeating: 0)
    var measurement: CounterGeometryMeasurement {
        .init(layout: counterLayoutLimits, render: counterRenderLimits, renderWorkspace: counterRenderCapacity, drawing: counterDrawingLimits,
            layoutBytes: UInt64(scopes.count + text.count + MemoryLayout<StaticCounterGeometry>.size - MemoryLayout<QualifiedRender>.size - MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>.size),
            renderBytes: UInt64(MemoryLayout<QualifiedRender>.size), pathBytes: UInt64(path.count),
            planBytes: UInt64(plan.count + MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>.size))
    }
    mutating func withGeometry(_ body: (consuming StaticCounterGeometry) -> Int) -> Int {
        withUnsafeMutableBytes(of: &scopes) { s in
            withUnsafeMutableBytes(of: &text) { t in
                withUnsafeMutableBytes(of: &path) { p in
                    withUnsafeMutableBytes(of: &plan) { d in
                        body(StaticCounterGeometry(scopes: s, text: t, path: p, plan: d))
                    }
                }
            }
        }
    }
}

struct CounterCanvasAudit: RuntimeStaticCanvasAuditMetadata {
    let table = CounterValueTable()
    var callableCaseCount: UInt16 { table.callableCaseCount }
    var declaredEntryCount: UInt16 { table.callableCaseCount }
    var maximumDeclaredID: UInt16 { table.callableCaseCount }
    func coverageMultiplicity(for id: UInt16) -> UInt8 {
        if case .none = table.captureByteCount(for: id) { return 0 }; return 1
    }
    func captureByteCount(for id: UInt16) -> UInt16? { table.captureByteCount(for: id) }
}



func counterSemanticConfiguration(_ limits: RuntimeProfileLimits) -> SemanticRecordLimits {
    SemanticRecordLimits(records: limits.maximumSemanticStructuralOccurrences, paths: limits.records.maximumPathEntries, depth: limits.records.maximumPathDepth, fanout: limits.records.maximumPathChildFanout, payloads: counterSemanticLimits.payloads, textScalars: counterSemanticLimits.textScalars, payloadBytes: limits.records.maximumPayloadBytesPerBank)!
}

// A report is a value, never RuntimeProfileStorage. Each typed physical region
// contributes to exactly one family, with complete identities partitioned out
// of Interaction records by counterMeasureInteraction.
struct CounterSemanticMeasurement {
    let limits: SemanticRecordLimits
    let records: CounterExtent
    let paths: CounterExtent
    let payloads: CounterExtent
    let scalars: CounterExtent
    let controlBytes: Int
}

func counterValidateBacking<G, C, R, H, GR: CounterStorageRegionSource>(profile: RuntimeProfileKind, limits: RuntimeProfileLimits,
    root: CounterRootLayout, rootMetadataRegion: CounterStorageRegion, semantic: CounterSemanticMeasurement, geometry: CounterGeometryMeasurement,
    interaction: borrowing InteractionOwnedKeyState<C, R, H>, geometryType: G.Type,
    canvasCount: Int, canvasCapacity: UInt16, canvasControlBytes: Int,
    factoryRegion: CounterStorageRegion,
    factoryDescriptorRegion: CounterStorageRegion? = nil,
    geometryRegions: borrowing GR,
    report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult
where G: CounterGeometry, C: CounterCandidateBacking & InteractionOwnedBankMeasurementSource, R: CounterCommittedBacking & InteractionOwnedBankMeasurementSource, H: CounterHitBacking & InteractionOwnedBankMeasurementSource,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    let facts = interaction.ownedStorageMeasurement()
    let metadata = MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - MemoryLayout<C>.size - 2 * MemoryLayout<R>.size - 2 * MemoryLayout<H>.size
    func physical<Record>(_ bank: InteractionOwnedBankMeasurement, record: Record.Type) -> CounterPhysicalBankFacts {
        .init(bank: bank, recordSize: bank.retainedPayloadBytes == 0 ? MemoryLayout<Record?>.size : MemoryLayout<Record>.size, recordStride: bank.retainedPayloadBytes == 0 ? MemoryLayout<Record?>.stride : MemoryLayout<Record>.stride, recordAlignment: bank.retainedPayloadBytes == 0 ? MemoryLayout<Record?>.alignment : MemoryLayout<Record>.alignment,
            optionalRecords: bank.retainedPayloadBytes == 0, retainedBytes: bank.inlineSize + bank.retainedPayloadBytes)
    }
    let rows = CounterPhysicalInteractionFacts(
        candidate: physical(facts.candidate, record: InteractionCandidateRecord<SemanticCompleteIdentity>.self),
        candidateHits: physical(facts.candidateHits, record: InteractionHitRegion<SemanticCompleteIdentity>.self),
        prepared: physical(facts.prepared, record: BoundActionRecord<SemanticCompleteIdentity>.self),
        committed: physical(facts.committed, record: BoundActionRecord<SemanticCompleteIdentity>.self),
        committedHits: physical(facts.committedHits, record: InteractionHitRegion<SemanticCompleteIdentity>.self), stateMetadataBytes: metadata)
    return counterValidatePhysicalBacking(profile: profile, limits: limits, root: root, rootMetadataRegion: rootMetadataRegion,
        semantic: semantic, geometry: geometry, interactionFacts: rows, identityCapacities: interaction.identityCapacities,
        geometryType: geometryType, candidateType: C.self, committedType: R.self, hitType: H.self,
        canvasCount: canvasCount, canvasCapacity: canvasCapacity, canvasControlBytes: canvasControlBytes,
        factoryRegion: factoryRegion, factoryDescriptorRegion: factoryDescriptorRegion, geometryRegions: geometryRegions, report: report)
}

#if GIFTUI_PHYSICAL_FACTS_QUALIFICATION
func p08OriginalCounterValidatePhysicalBacking<G, C, R, H, GR: CounterStorageRegionSource>(profile: RuntimeProfileKind, limits: RuntimeProfileLimits,
    root: CounterRootLayout, rootMetadataRegion: CounterStorageRegion, semantic: CounterSemanticMeasurement, geometry: CounterGeometryMeasurement,
    interactionFacts: CounterPhysicalInteractionFacts, identityCapacities: (perKey: UInt16, perBank: UInt32),
    descriptorBytes: Int = 0, geometryType: G.Type, candidateType: C.Type, committedType: R.Type, hitType: H.Type,
    canvasCount: Int, canvasCapacity: UInt16, canvasControlBytes: Int,
    factoryRegion: CounterStorageRegion,
    factoryDescriptorRegion: CounterStorageRegion? = nil,
    geometryRegions: borrowing GR,
    report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult
where G: CounterGeometry & ~Copyable & ~Escapable, C: CounterCandidateBacking & ~Copyable & ~Escapable, R: CounterCommittedBacking & ~Copyable & ~Escapable, H: CounterHitBacking & ~Copyable & ~Escapable,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    // The concrete scoped render adapter exports exactly the configured view;
    // inaccessible physical headroom remains measured in the backing regions.
    guard counterRenderWorkspaceCovers(geometry.renderWorkspace, limits.renderWorkspace) else { return .invalid(.insufficientStorage) }
    let keys = interactionFacts.measurement
    let keyLimits = identityCapacities
    let semanticLimits = semantic.limits
    guard let recordBytes = semantic.records.bytes, let pathBytes = semantic.paths.bytes,
        let payloadBytes = semantic.payloads.bytes, let scalarBytes = semantic.scalars.bytes,
        let canvasBytes = CounterExtent.elements(count: canvasCount, stride: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.stride, alignment: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.alignment).bytes else { return .invalid(.arithmeticOverflow) }
    let interactionMetadata = interactionFacts.stateMetadataBytes
    let pending = MemoryLayout<InlineArray<2, NormalizedPointerEvent?>>.size + MemoryLayout<InlineArray<34, UInt8>>.size + MemoryLayout<UInt16>.size + MemoryLayout<UInt16?>.size
    let sealed = MemoryLayout<CounterAdmissionBacking>.size - pending
    let result = MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.size
    typealias Admission = CounterAdmission
    typealias Owner = CounterPipelineOwner<G, C, R, H>
    typealias Coordinator = StaticRuntimeExecutionCoordinator<CounterExecutionBinding, Admission, Owner>
    var concreteCoordinatorBytes = MemoryLayout<Coordinator>.size
    #if !hasFeature(Embedded)
        if case .dynamic = profile {
            concreteCoordinatorBytes = MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, Admission, Owner>>.size
    }
    #endif
    // Endpoint/sink data now resides in Control but still belongs to the backend
    // accounting owner. Subtract it once from the combined coordinator/control.
    // Physical backend arrays in CounterControl remain fully charged below.
    let coordinator = concreteCoordinatorBytes - MemoryLayout<G>.size
        - MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - MemoryLayout<CounterEndpoint>.size
        + MemoryLayout<CounterControl>.size - Admission.pointerStateStorageBytes
        - MemoryLayout<CounterAdmissionBacking>.size - MemoryLayout<CounterPointerState>.size - result
        + descriptorBytes + Int(factoryRegion.chargedBytes) + Int(factoryDescriptorRegion?.chargedBytes ?? 0)
    // Bank zero occupies exactly the configured whole-element prefix. Bank one
    // owns the second configured slice plus any retained allocator tail; never
    // divide a typed element when Array capacity rounds to an odd count.
    let firstRecords = CounterExtent.elements(count: Int(semanticLimits.records), stride: MemoryLayout<SemanticRuntimeRecord>.stride, alignment: MemoryLayout<SemanticRuntimeRecord>.alignment).bytes!
    let firstPaths = CounterExtent.elements(count: Int(semanticLimits.paths), stride: MemoryLayout<SemanticPathEntry>.stride, alignment: MemoryLayout<SemanticPathEntry>.alignment).bytes!
    let firstPayloads = CounterExtent.elements(count: Int(semanticLimits.payloads), stride: MemoryLayout<CounterPayload?>.stride, alignment: MemoryLayout<CounterPayload?>.alignment).bytes!
    let firstScalars = CounterExtent.elements(count: Int(semanticLimits.textScalars), stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment).bytes!
    guard semantic.records.count >= Int(semanticLimits.records) * 2,
        semantic.paths.count >= Int(semanticLimits.paths) * 2,
        semantic.payloads.count >= Int(semanticLimits.payloads) * 2,
        semantic.scalars.count >= Int(semanticLimits.textScalars) * 2 else { return .invalid(.insufficientStorage) }
    let candidatePayload = firstPayloads + firstScalars
    let publishedPayload = payloadBytes - firstPayloads + scalarBytes - firstScalars
    let firstMatch = UInt64(semanticLimits.paths) * UInt64(MemoryLayout<UInt16>.size)
    let allMatch = UInt64(semantic.paths.count) * UInt64(MemoryLayout<UInt16>.size)
    let matchControl = 4 * MemoryLayout<UInt32>.size
    guard firstPaths >= firstMatch, pathBytes >= allMatch,
        semantic.controlBytes >= matchControl, coordinator >= 0,
        interactionMetadata >= 0 else { return .invalid(.invariantViolation) }
    let values: InlineArray<26, UInt64> = [firstPaths - firstMatch, pathBytes - firstPaths - (allMatch - firstMatch), candidatePayload, publishedPayload,
        allMatch + UInt64(matchControl), keys.candidateIdentityBytes, keys.committedIdentityBytes,
        UInt64(root.metadataBytes), UInt64(root.modelBytes), UInt64(root.pinBytes),
        firstRecords + UInt64(semantic.controlBytes - matchControl), recordBytes - firstRecords,
        geometry.layoutBytes, geometry.renderBytes, canvasBytes + UInt64(canvasControlBytes), geometry.pathBytes, geometry.planBytes,
        UInt64(root.liveBytes), UInt64(root.candidateBytes), keys.candidateBytes + UInt64(interactionMetadata), keys.committedBytes,
        UInt64(pending), UInt64(sealed), UInt64(Admission.pointerStateStorageBytes + MemoryLayout<CounterPointerState>.size), UInt64(coordinator), UInt64(result)]
    let preflightLimit = values.count
    precondition(preflightLimit >= 0)
    var preflightIndex = 0
    while preflightIndex < preflightLimit {
        if case .none = UInt32(exactly: CounterFamilyValueIndexAccess.get(values, at: preflightIndex)) { return .invalid(.arithmeticOverflow) }

        preflightIndex += 1
    }
    var reported = CounterPhysicalReportAccumulator()
    func emitRegions(_ reported: inout CounterPhysicalReportAccumulator) {
        func record(_ region: CounterStorageRegion) {
            reported.record(family: region.family, chargedBytes: region.chargedBytes) { _, _ in
                report(region)
            }
        }
        record(.elements(count: Int(semanticLimits.paths), family: 0, chargedBytes: CounterFamilyValueIndexAccess.get(values, at: 0), size: MemoryLayout<SemanticPathEntry>.size, stride: MemoryLayout<SemanticPathEntry>.stride, alignment: MemoryLayout<SemanticPathEntry>.alignment))
        record(.elements(count: semantic.paths.count - Int(semanticLimits.paths), family: 1, chargedBytes: CounterFamilyValueIndexAccess.get(values, at: 1), size: MemoryLayout<SemanticPathEntry>.size, stride: MemoryLayout<SemanticPathEntry>.stride, alignment: MemoryLayout<SemanticPathEntry>.alignment))
        record(.elements(count: Int(semanticLimits.payloads), family: 2, size: MemoryLayout<CounterPayload?>.size, stride: MemoryLayout<CounterPayload?>.stride, alignment: MemoryLayout<CounterPayload?>.alignment))
        record(.elements(count: Int(semanticLimits.textScalars), family: 2, size: MemoryLayout<UInt32>.size, stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment))
        record(.elements(count: semantic.payloads.count - Int(semanticLimits.payloads), family: 3, size: MemoryLayout<CounterPayload?>.size, stride: MemoryLayout<CounterPayload?>.stride, alignment: MemoryLayout<CounterPayload?>.alignment))
        record(.elements(count: semantic.scalars.count - Int(semanticLimits.textScalars), family: 3, size: MemoryLayout<UInt32>.size, stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment))
        // Repeated embedded fields, not a contiguous allocation or another bank.
        record(.elements(count: semantic.paths.count, family: 4, size: MemoryLayout<UInt16>.size, stride: MemoryLayout<UInt16>.stride, alignment: MemoryLayout<UInt16>.alignment))
        record(.elements(count: 4, family: 4, size: MemoryLayout<UInt32>.size, stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment))
        record(rootMetadataRegion)
        record(.elements(count: Int(root.models), family: 8, size: MemoryLayout<CounterOwnedModel?>.size, stride: MemoryLayout<CounterOwnedModel?>.stride, alignment: MemoryLayout<CounterOwnedModel?>.alignment))
        record(.elements(count: Int(root.pins), family: 9, size: MemoryLayout<Bool>.size, stride: MemoryLayout<Bool>.stride, alignment: MemoryLayout<Bool>.alignment))
        record(.elements(count: Int(semanticLimits.records), family: 10, size: MemoryLayout<SemanticRuntimeRecord>.size, stride: MemoryLayout<SemanticRuntimeRecord>.stride, alignment: MemoryLayout<SemanticRuntimeRecord>.alignment))
        if case .static = profile {
            record(.inline(family: 10, chargedBytes: CounterSemanticBacking.paddingBytes, kind: .metadataPadding, size: MemoryLayout<CounterSemanticBacking>.size, stride: MemoryLayout<CounterSemanticBacking>.stride, alignment: MemoryLayout<CounterSemanticBacking>.alignment))
            record(.inline(family: 10, chargedBytes: MemoryLayout<StaticSemanticRecordStorage>.size - matchControl, kind: .partition, size: MemoryLayout<StaticSemanticRecordStorage>.size, stride: MemoryLayout<StaticSemanticRecordStorage>.stride, alignment: MemoryLayout<StaticSemanticRecordStorage>.alignment))
        }
        #if !hasFeature(Embedded)
            if case .dynamic = profile {
                record(.inline(family: 7, size: MemoryLayout<UInt16>.size, stride: MemoryLayout<UInt16>.stride, alignment: MemoryLayout<UInt16>.alignment))
            record(.elements(count: 2, family: 7, size: MemoryLayout<Bool>.size, stride: MemoryLayout<Bool>.stride, alignment: MemoryLayout<Bool>.alignment))
            record(.inline(family: 7, size: MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.size, stride: MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.stride, alignment: MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.alignment))
            record(.inline(family: 10, chargedBytes: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.size - matchControl, kind: .partition, size: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.size, stride: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.stride, alignment: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.alignment))
            record(.inline(family: 10, size: MemoryLayout<[SemanticRuntimeRecord]>.size, stride: MemoryLayout<[SemanticRuntimeRecord]>.stride, alignment: MemoryLayout<[SemanticRuntimeRecord]>.alignment))
            record(.inline(family: 10, size: MemoryLayout<[SemanticPathEntry]>.size, stride: MemoryLayout<[SemanticPathEntry]>.stride, alignment: MemoryLayout<[SemanticPathEntry]>.alignment))
            record(.inline(family: 10, size: MemoryLayout<[CounterPayload?]>.size, stride: MemoryLayout<[CounterPayload?]>.stride, alignment: MemoryLayout<[CounterPayload?]>.alignment))
            record(.inline(family: 10, size: MemoryLayout<[UInt32]>.size, stride: MemoryLayout<[UInt32]>.stride, alignment: MemoryLayout<[UInt32]>.alignment))
            record(.inline(family: 10, size: MemoryLayout<SemanticRecordLimits>.size, stride: MemoryLayout<SemanticRecordLimits>.stride, alignment: MemoryLayout<SemanticRecordLimits>.alignment))
            record(.inline(family: 10, size: MemoryLayout<SemanticRecordOwnerIdentity>.size, stride: MemoryLayout<SemanticRecordOwnerIdentity>.stride, alignment: MemoryLayout<SemanticRecordOwnerIdentity>.alignment))
            record(.inline(family: 10, size: MemoryLayout<Bool>.size, stride: MemoryLayout<Bool>.stride, alignment: MemoryLayout<Bool>.alignment))
        }
        #endif
        record(.elements(count: semantic.records.count - Int(semanticLimits.records), family: 11, size: MemoryLayout<SemanticRuntimeRecord>.size, stride: MemoryLayout<SemanticRuntimeRecord>.stride, alignment: MemoryLayout<SemanticRuntimeRecord>.alignment))
        geometryRegions.visitStorageRegions(record)
        record(.elements(count: canvasCount, family: 14, size: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.size, stride: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.stride, alignment: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.alignment))
        record(.elements(count: Int(CounterPendingBacking.capacity), family: 14, size: MemoryLayout<CounterValueTable.CaptureStorage?>.size, stride: MemoryLayout<CounterValueTable.CaptureStorage?>.stride, alignment: MemoryLayout<CounterValueTable.CaptureStorage?>.alignment))
        record(.elements(count: Int(CounterPendingBacking.capacity), family: 14, size: MemoryLayout<UInt16>.size, stride: MemoryLayout<UInt16>.stride, alignment: MemoryLayout<UInt16>.alignment))
        record(.inline(family: 14, size: MemoryLayout<CanvasPendingMetadata>.size, stride: MemoryLayout<CanvasPendingMetadata>.stride, alignment: MemoryLayout<CanvasPendingMetadata>.alignment))
        record(.inline(family: 14, chargedBytes: CounterPendingBacking.paddingBytes, kind: .metadataPadding, size: MemoryLayout<CounterPendingBacking>.size, stride: MemoryLayout<CounterPendingBacking>.stride, alignment: MemoryLayout<CounterPendingBacking>.alignment))
        if case .static = profile { record(.inline(family: 14, size: MemoryLayout<StaticCanvasValueStorage>.size, stride: MemoryLayout<StaticCanvasValueStorage>.stride, alignment: MemoryLayout<StaticCanvasValueStorage>.alignment)) }
        #if !hasFeature(Embedded)
            if case .dynamic = profile {
                record(
                    .inline(family: 14, size: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size, stride: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.stride, alignment: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.alignment))
            }
        #endif
        record(.inline(family: 17, chargedBytes: root.liveBytes, kind: .partition, size: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.size, stride: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.stride, alignment: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.alignment))
        record(.inline(family: 18, chargedBytes: root.candidateBytes, kind: .partition, size: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.size, stride: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.stride, alignment: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.alignment))
        interactionFacts.visitStorageRegions(record)
        record(.elements(count: 2, family: 21, size: MemoryLayout<NormalizedPointerEvent?>.size, stride: MemoryLayout<NormalizedPointerEvent?>.stride, alignment: MemoryLayout<NormalizedPointerEvent?>.alignment))
        record(.inline(family: 21, size: MemoryLayout<InlineArray<34, UInt8>>.size, stride: MemoryLayout<InlineArray<34, UInt8>>.stride, alignment: MemoryLayout<InlineArray<34, UInt8>>.alignment))
        record(.inline(family: 21, size: MemoryLayout<UInt16>.size, stride: MemoryLayout<UInt16>.stride, alignment: MemoryLayout<UInt16>.alignment))
        record(.inline(family: 21, size: MemoryLayout<UInt16?>.size, stride: MemoryLayout<UInt16?>.stride, alignment: MemoryLayout<UInt16?>.alignment))
        record(.inline(family: 22, chargedBytes: sealed, kind: .partition, size: MemoryLayout<CounterAdmissionBacking>.size, stride: MemoryLayout<CounterAdmissionBacking>.stride, alignment: MemoryLayout<CounterAdmissionBacking>.alignment))
        record(.inline(family: 23, chargedBytes: Admission.pointerStateStorageBytes, kind: .partition, size: MemoryLayout<Admission.Controller?>.size, stride: MemoryLayout<Admission.Controller?>.stride, alignment: MemoryLayout<Admission.Controller?>.alignment))
        record(.inline(family: 23, size: MemoryLayout<CounterPointerState>.size, stride: MemoryLayout<CounterPointerState>.stride, alignment: MemoryLayout<CounterPointerState>.alignment))
        let coordinatorFields = concreteCoordinatorBytes - MemoryLayout<G>.size - MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size
        if case .static = profile {
            record(
                .inline(family: 24, chargedBytes: coordinatorFields + descriptorBytes,
                    kind: .metadataPadding, size: MemoryLayout<Coordinator>.size, stride: MemoryLayout<Coordinator>.stride, alignment: MemoryLayout<Coordinator>.alignment))
        }
        #if !hasFeature(Embedded)
            if case .dynamic = profile {
                record(
                    .inline(family: 24, chargedBytes: coordinatorFields + descriptorBytes,
                        kind: .metadataPadding, size: MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, Admission, Owner>
                            >.size, stride: MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, Admission, Owner>
                            >.stride, alignment: MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, Admission, Owner>
                            >.alignment))
            }
        #endif
        // All outer controls, observations, optional controller metadata and padding
        // remain physically live and are charged here exactly once.
        record(.inline(family: 24, chargedBytes: MemoryLayout<CounterControl>.size - MemoryLayout<CounterEndpoint>.size - Admission.pointerStateStorageBytes - MemoryLayout<CounterAdmissionBacking>.size - MemoryLayout<CounterPointerState>.size - result, kind: .metadataPadding, size: MemoryLayout<CounterControl>.size, stride: MemoryLayout<CounterControl>.stride, alignment: MemoryLayout<CounterControl>.alignment))
        record(factoryRegion)
        if let factoryDescriptorRegion { record(factoryDescriptorRegion) }
        record(.inline(family: 25, size: MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.size, stride: MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.stride, alignment: MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.alignment))
    }
    emitRegions(&reported)
    guard !reported.overflow else { return .invalid(.arithmeticOverflow) }
    var comparisonIndex = 0
    while comparisonIndex < 26 { precondition(reported[comparisonIndex] == CounterFamilyValueIndexAccess.get(values, at: comparisonIndex), "physical region audit mismatch")
        comparisonIndex += 1
    }
    let bytes = RuntimeStorageByteCounts(semanticCandidatePathBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 0)), semanticPublishedPathBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 1)), semanticCandidatePayloadBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 2)), semanticPublishedPayloadBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 3)), identityMatchWorkspaceBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 4)), interactionCandidateIdentityBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 5)), interactionCommittedIdentityBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 6)), modelMetadataBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 7)), modelOwnerBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 8)), framePinBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 9)), semanticCandidateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 10)), semanticPublishedBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 11)), layoutCandidateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 12)), renderWorkspaceBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 13)), canvasCallableBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 14)), pathWorkspaceBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 15)), drawingPlanBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 16)), observableLiveBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 17)), observableCandidateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 18)), interactionCandidateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 19)), interactionCommittedBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 20)), admissionQueueBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 21)), sealedBatchBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 22)), pointerStateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 23)), coordinatorStateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 24)), failureStateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 25)))
    let records = RuntimeRecordLimits(maximumPathEntries: semanticLimits.paths, maximumPathDepth: semanticLimits.depth, maximumPathChildFanout: semanticLimits.fanout, maximumPayloadBytesPerBank: semanticLimits.payloadBytes, maximumIdentityComponentsPerKey: keyLimits.perKey, maximumInteractionIdentityComponents: keyLimits.perBank)
    let inputs = RuntimeProfileLimitInputs(records: limits.records, models: limits.models, semantic: limits.semantic, maximumSemanticStructuralOccurrences: limits.maximumSemanticStructuralOccurrences, layout: limits.layout, render: limits.render, renderWorkspace: limits.renderWorkspace, renderSink: limits.renderSink, maximumOrdinaryRenderOperations: limits.maximumOrdinaryRenderOperations, execution: limits.execution, observableState: limits.observableState, interaction: limits.interaction, drawing: limits.drawing, staticCanvas: limits.staticCanvas, profile: profile)
    let rootCapacity = ObservableStateRootControl.storageCapacities()
    let capacities = RuntimeStorageCapacities(candidateRecords: records, publishedRecords: records,
        models: .init(maximumModelSlots: root.models, maximumOwningTickets: root.claims, maximumFramePins: root.pins, maximumModelCaptureBanks: root.captures),
        semanticCandidate: .init(maximumDepth: semanticLimits.depth, maximumSemanticNodes: semanticLimits.records, maximumBodyEvaluations: semanticLimits.records, maximumModifierApplications: semanticLimits.records, maximumActionOccurrences: semanticLimits.records),
        semanticPublished: .init(maximumDepth: semanticLimits.depth, maximumSemanticNodes: semanticLimits.records, maximumBodyEvaluations: semanticLimits.records, maximumModifierApplications: semanticLimits.records, maximumActionOccurrences: semanticLimits.records),
        semanticCandidateStructuralOccurrences: semanticLimits.records, semanticPublishedStructuralOccurrences: semanticLimits.records,
        layoutCandidate: geometry.layout, render: geometry.render, renderWorkspace: limits.renderWorkspace,
        canvasCallableOccurrences: canvasCapacity, staticCanvasCaptureBytes: UInt16(MemoryLayout<CounterValueTable.CaptureStorage>.stride),
        pathPoints: geometry.drawing.maximumLivePathPoints, pathSubpaths: geometry.drawing.maximumLivePathSubpaths,
        drawingPlanStrokes: geometry.drawing.maximumPlanStrokes, drawingPlanPoints: geometry.drawing.maximumPlanPoints, drawingPlanSubpaths: geometry.drawing.maximumPlanSubpaths, normalizedStrokeOperations: geometry.drawing.maximumNormalizedStrokeOperations,
        observableLiveLocations: rootCapacity.locations, observableLiveRegistrations: rootCapacity.registrations, observableCandidateAssociations: rootCapacity.associations,
        interactionCandidateActions: keys.candidateRecords, interactionCandidateHitRegions: keys.candidateHits, interactionCommittedActions: keys.committedRecords, interactionCommittedHitRegions: keys.committedHits,
        admissionQueue: counterExecutionLimits, sealedBatch: counterExecutionLimits, pointerStates: 1,
        coordinatorStatePresent: concreteCoordinatorBytes > 0, failureStatePresent: result > 0, byteCounts: bytes)
    if case .static = profile {
        return RuntimeProfileValidator.validateStatic(
            inputs: inputs, capacities: capacities, metadata: CounterCanvasAudit())
    }
    return RuntimeProfileValidator.validateDynamic(inputs: inputs, capacities: capacities)
}
#endif
struct CounterPhysicalTypeLayout {
    let size: Int
    let stride: Int
    let alignment: Int
}
struct CounterPhysicalAccountingInput {
    let profile: RuntimeProfileKind
    let limits: RuntimeProfileLimits
    let root: CounterRootLayout
    let rootMetadataRegion: CounterStorageRegion
    let semantic: CounterSemanticMeasurement
    let geometry: CounterGeometryMeasurement
    let interactionFacts: CounterPhysicalInteractionFacts
    let identityCapacities: (perKey: UInt16, perBank: UInt32)
    let descriptorBytes: Int
    let canvasCount: Int
    let canvasCapacity: UInt16
    let canvasControlBytes: Int
    let factoryRegion: CounterStorageRegion
    let factoryDescriptorRegion: CounterStorageRegion?
}
struct CounterPhysicalAccountingEngine {
    enum Request {
        case staticCoordinatorSize, dynamicCoordinatorSize, geometrySize, keyStateSize
        case staticCoordinatorLayout, dynamicCoordinatorLayout
        case region(CounterStorageRegion), visitGeometry, visitInteraction
        case done(RuntimeProfileValidationResult)
    }
    typealias Admission = CounterAdmission
    private let input: CounterPhysicalAccountingInput
    private var recordBytes: UInt64 = 0
    private var pathBytes: UInt64 = 0
    private var payloadBytes: UInt64 = 0
    private var scalarBytes: UInt64 = 0
    private var canvasBytes: UInt64 = 0
    private var firstRecords: UInt64 = 0
    private var firstPaths: UInt64 = 0
    private var firstPayloads: UInt64 = 0
    private var firstScalars: UInt64 = 0
    private var candidatePayload: UInt64 = 0
    private var publishedPayload: UInt64 = 0
    private var firstMatch: UInt64 = 0
    private var allMatch: UInt64 = 0
    private var interactionMetadata: Int = 0
    private var pending: Int = 0
    private var sealed: Int = 0
    private var result: Int = 0
    private var concreteCoordinatorBytes: Int = 0
    private var geometrySize: Int = 0
    private var keyStateSize: Int = 0
    private var coordinator: Int = 0
    private var matchControl: Int = 0
    private var descriptorGeometry: Int = 0
    private var coordinatorFields: Int = 0
    private var descriptorCharge: Int = 0
    private var keys = CounterInteractionMeasurement(candidateRecords: 0, candidateHits: 0, committedRecords: 0, committedHits: 0, candidateIdentityBytes: 0, committedIdentityBytes: 0, candidateBytes: 0, committedBytes: 0)
    private var values: InlineArray<26, UInt64> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    private var reported = CounterPhysicalReportAccumulator()
    private var phase = 0
    private var resumePhase = 0
    private var selectedLayout = CounterPhysicalTypeLayout(size: 0, stride: 0, alignment: 1)
    private var terminal: RuntimeProfileValidationResult? = nil

    private var profile: RuntimeProfileKind { input.profile }
    private var limits: RuntimeProfileLimits { input.limits }
    private var root: CounterRootLayout { input.root }
    private var rootMetadataRegion: CounterStorageRegion { input.rootMetadataRegion }
    private var semantic: CounterSemanticMeasurement { input.semantic }
    private var geometry: CounterGeometryMeasurement { input.geometry }
    private var interactionFacts: CounterPhysicalInteractionFacts { input.interactionFacts }
    private var identityCapacities: (perKey: UInt16, perBank: UInt32) { input.identityCapacities }
    private var descriptorBytes: Int { input.descriptorBytes }
    private var canvasCount: Int { input.canvasCount }
    private var canvasCapacity: UInt16 { input.canvasCapacity }
    private var canvasControlBytes: Int { input.canvasControlBytes }
    private var factoryRegion: CounterStorageRegion { input.factoryRegion }
    private var factoryDescriptorRegion: CounterStorageRegion? { input.factoryDescriptorRegion }
    private var semanticLimits: SemanticRecordLimits { semantic.limits }
    private var keyLimits: (perKey: UInt16, perBank: UInt32) { identityCapacities }

    #if GIFTUI_COUNTER_FAMILY_EFFECT_PROOF
        @_noAllocation
    #endif
    init(_ input: CounterPhysicalAccountingInput) { self.input = input }
    #if GIFTUI_COUNTER_FAMILY_EFFECT_PROOF
        @_noAllocation
    #endif
    mutating func record(_ region: CounterStorageRegion) {
        reported.record(family: region.family, chargedBytes: region.chargedBytes) { _, _ in }
    }
    #if GIFTUI_COUNTER_FAMILY_EFFECT_PROOF
        @_noAllocation
    #endif
    mutating func acceptSize(_ size: Int) {
        switch phase {
        case 1:
            concreteCoordinatorBytes = size
            phase = 3
            #if !hasFeature(Embedded)
                if case .dynamic = profile { phase = 2 }
            #endif
        case 2: concreteCoordinatorBytes = size; phase = 3
        case 3: geometrySize = size; phase = 4
        case 4: keyStateSize = size; phase = 5
        case 10: descriptorGeometry = size; phase = 11
        case 11:
            coordinatorFields = concreteCoordinatorBytes - descriptorGeometry - size
            descriptorCharge = coordinatorFields + descriptorBytes
            phase = 12
        default: preconditionFailure("unexpected accounting size")
        }
    }
    #if GIFTUI_COUNTER_FAMILY_EFFECT_PROOF
        @_noAllocation
    #endif
    mutating func acceptLayout(_ layout: CounterPhysicalTypeLayout) {
        precondition(phase == 12)
        selectedLayout = layout
        phase = 13
    }
    #if GIFTUI_COUNTER_FAMILY_EFFECT_PROOF
        @_noAllocation
    #endif
    mutating func next() -> Request {
        while true {
            switch phase {
            case 0:
                if let error = prepareInitial() { terminal = .invalid(error); phase = 999; continue }
                phase = 1
            case 1: return .staticCoordinatorSize
            case 2: return .dynamicCoordinatorSize
            case 3, 10: return .geometrySize
            case 4, 11: return .keyStateSize
            case 5:
                if let error = prepareValues() { terminal = .invalid(error); phase = 999; continue }
                phase = 100
            case 12:
                if case .static = profile { return .staticCoordinatorLayout }
                #if !hasFeature(Embedded)
                    if case .dynamic = profile { return .dynamicCoordinatorLayout }
                #endif
                phase = resumePhase
            case 13:
                phase = resumePhase
                return .region(.inline(family: 24, chargedBytes: descriptorCharge, kind: .metadataPadding, size: selectedLayout.size, stride: selectedLayout.stride, alignment: selectedLayout.alignment))
            case 999: return .done(terminal!)
            default: return nextRegion()
            }
        }
    }
    private mutating func prepareInitial() -> RuntimeProfileValidationError? {

    // The concrete scoped render adapter exports exactly the configured view;
    // inaccessible physical headroom remains measured in the backing regions.
    guard counterRenderWorkspaceCovers(geometry.renderWorkspace, limits.renderWorkspace) else { return .insufficientStorage }
    let keys = interactionFacts.measurement
    let keyLimits = identityCapacities
    let semanticLimits = semantic.limits
    guard let recordBytes = semantic.records.bytes, let pathBytes = semantic.paths.bytes,
        let payloadBytes = semantic.payloads.bytes, let scalarBytes = semantic.scalars.bytes,
        let canvasBytes = CounterExtent.elements(count: canvasCount, stride: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.stride, alignment: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.alignment).bytes else { return .arithmeticOverflow }
    let interactionMetadata = interactionFacts.stateMetadataBytes
    let pending = MemoryLayout<InlineArray<2, NormalizedPointerEvent?>>.size + MemoryLayout<InlineArray<34, UInt8>>.size + MemoryLayout<UInt16>.size + MemoryLayout<UInt16?>.size
    let sealed = MemoryLayout<CounterAdmissionBacking>.size - pending
    let result = MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.size

        self.keys = keys
        self.recordBytes = recordBytes
        self.pathBytes = pathBytes
        self.payloadBytes = payloadBytes
        self.scalarBytes = scalarBytes
        self.canvasBytes = canvasBytes
        self.interactionMetadata = interactionMetadata
        self.pending = pending
        self.sealed = sealed
        self.result = result
        return nil
    }
    private mutating func prepareValues() -> RuntimeProfileValidationError? {
    // Endpoint/sink data now resides in Control but still belongs to the backend
    // accounting owner. Subtract it once from the combined coordinator/control.
    // Physical backend arrays in CounterControl remain fully charged below.
    let coordinator = concreteCoordinatorBytes - geometrySize
        - keyStateSize - MemoryLayout<CounterEndpoint>.size
        + MemoryLayout<CounterControl>.size - Admission.pointerStateStorageBytes
        - MemoryLayout<CounterAdmissionBacking>.size - MemoryLayout<CounterPointerState>.size - result
        + descriptorBytes + Int(factoryRegion.chargedBytes) + Int(factoryDescriptorRegion?.chargedBytes ?? 0)
    // Bank zero occupies exactly the configured whole-element prefix. Bank one
    // owns the second configured slice plus any retained allocator tail; never
    // divide a typed element when Array capacity rounds to an odd count.
    let firstRecords = CounterExtent.elements(count: Int(semanticLimits.records), stride: MemoryLayout<SemanticRuntimeRecord>.stride, alignment: MemoryLayout<SemanticRuntimeRecord>.alignment).bytes!
    let firstPaths = CounterExtent.elements(count: Int(semanticLimits.paths), stride: MemoryLayout<SemanticPathEntry>.stride, alignment: MemoryLayout<SemanticPathEntry>.alignment).bytes!
    let firstPayloads = CounterExtent.elements(count: Int(semanticLimits.payloads), stride: MemoryLayout<CounterPayload?>.stride, alignment: MemoryLayout<CounterPayload?>.alignment).bytes!
    let firstScalars = CounterExtent.elements(count: Int(semanticLimits.textScalars), stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment).bytes!
    guard semantic.records.count >= Int(semanticLimits.records) * 2,
        semantic.paths.count >= Int(semanticLimits.paths) * 2,
        semantic.payloads.count >= Int(semanticLimits.payloads) * 2,
        semantic.scalars.count >= Int(semanticLimits.textScalars) * 2 else { return .insufficientStorage }
    let candidatePayload = firstPayloads + firstScalars
    let publishedPayload = payloadBytes - firstPayloads + scalarBytes - firstScalars
    let firstMatch = UInt64(semanticLimits.paths) * UInt64(MemoryLayout<UInt16>.size)
    let allMatch = UInt64(semantic.paths.count) * UInt64(MemoryLayout<UInt16>.size)
    let matchControl = 4 * MemoryLayout<UInt32>.size
    guard firstPaths >= firstMatch, pathBytes >= allMatch,
        semantic.controlBytes >= matchControl, coordinator >= 0,
        interactionMetadata >= 0 else { return .invariantViolation }
    let values: InlineArray<26, UInt64> = [firstPaths - firstMatch, pathBytes - firstPaths - (allMatch - firstMatch), candidatePayload, publishedPayload,
        allMatch + UInt64(matchControl), keys.candidateIdentityBytes, keys.committedIdentityBytes,
        UInt64(root.metadataBytes), UInt64(root.modelBytes), UInt64(root.pinBytes),
        firstRecords + UInt64(semantic.controlBytes - matchControl), recordBytes - firstRecords,
        geometry.layoutBytes, geometry.renderBytes, canvasBytes + UInt64(canvasControlBytes), geometry.pathBytes, geometry.planBytes,
        UInt64(root.liveBytes), UInt64(root.candidateBytes), keys.candidateBytes + UInt64(interactionMetadata), keys.committedBytes,
        UInt64(pending), UInt64(sealed), UInt64(Admission.pointerStateStorageBytes + MemoryLayout<CounterPointerState>.size), UInt64(coordinator), UInt64(result)]
    let preflightLimit = values.count
    precondition(preflightLimit >= 0)
    var preflightIndex = 0
    while preflightIndex < preflightLimit {
        if case .none = UInt32(exactly: CounterFamilyValueIndexAccess.get(values, at: preflightIndex)) { return .arithmeticOverflow }

        preflightIndex += 1
    }

        self.coordinator = coordinator
        self.firstRecords = firstRecords
        self.firstPaths = firstPaths
        self.firstPayloads = firstPayloads
        self.firstScalars = firstScalars
        self.candidatePayload = candidatePayload
        self.publishedPayload = publishedPayload
        self.firstMatch = firstMatch
        self.allMatch = allMatch
        self.matchControl = matchControl
        self.values = values
        return nil
    }
    private mutating func nextRegion() -> Request {
        while true {
            switch phase {
        case 100:
            phase = 101
            return .region(.elements(count: Int(semanticLimits.paths), family: 0, chargedBytes: CounterFamilyValueIndexAccess.get(values, at: 0), size: MemoryLayout<SemanticPathEntry>.size, stride: MemoryLayout<SemanticPathEntry>.stride, alignment: MemoryLayout<SemanticPathEntry>.alignment))
        case 101:
            phase = 102
            return .region(.elements(count: semantic.paths.count - Int(semanticLimits.paths), family: 1, chargedBytes: CounterFamilyValueIndexAccess.get(values, at: 1), size: MemoryLayout<SemanticPathEntry>.size, stride: MemoryLayout<SemanticPathEntry>.stride, alignment: MemoryLayout<SemanticPathEntry>.alignment))
        case 102:
            phase = 103
            return .region(.elements(count: Int(semanticLimits.payloads), family: 2, size: MemoryLayout<CounterPayload?>.size, stride: MemoryLayout<CounterPayload?>.stride, alignment: MemoryLayout<CounterPayload?>.alignment))
        case 103:
            phase = 104
            return .region(.elements(count: Int(semanticLimits.textScalars), family: 2, size: MemoryLayout<UInt32>.size, stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment))
        case 104:
            phase = 105
            return .region(.elements(count: semantic.payloads.count - Int(semanticLimits.payloads), family: 3, size: MemoryLayout<CounterPayload?>.size, stride: MemoryLayout<CounterPayload?>.stride, alignment: MemoryLayout<CounterPayload?>.alignment))
        case 105:
            phase = 106
            return .region(.elements(count: semantic.scalars.count - Int(semanticLimits.textScalars), family: 3, size: MemoryLayout<UInt32>.size, stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment))
        case 106:
            phase = 107
            return .region(.elements(count: semantic.paths.count, family: 4, size: MemoryLayout<UInt16>.size, stride: MemoryLayout<UInt16>.stride, alignment: MemoryLayout<UInt16>.alignment))
        case 107:
            phase = 108
            return .region(.elements(count: 4, family: 4, size: MemoryLayout<UInt32>.size, stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment))
        case 108:
            phase = 109
            return .region(rootMetadataRegion)
        case 109:
            phase = 110
            return .region(.elements(count: Int(root.models), family: 8, size: MemoryLayout<CounterOwnedModel?>.size, stride: MemoryLayout<CounterOwnedModel?>.stride, alignment: MemoryLayout<CounterOwnedModel?>.alignment))
        case 110:
            phase = 111
            return .region(.elements(count: Int(root.pins), family: 9, size: MemoryLayout<Bool>.size, stride: MemoryLayout<Bool>.stride, alignment: MemoryLayout<Bool>.alignment))
        case 111:
            phase = 112
            return .region(.elements(count: Int(semanticLimits.records), family: 10, size: MemoryLayout<SemanticRuntimeRecord>.size, stride: MemoryLayout<SemanticRuntimeRecord>.stride, alignment: MemoryLayout<SemanticRuntimeRecord>.alignment))
        case 112:
            phase = 113
            if case .static = profile { return .region(.inline(family: 10, chargedBytes: CounterSemanticBacking.paddingBytes, kind: .metadataPadding, size: MemoryLayout<CounterSemanticBacking>.size, stride: MemoryLayout<CounterSemanticBacking>.stride, alignment: MemoryLayout<CounterSemanticBacking>.alignment)) }
            continue
        case 113:
            phase = 114
            if case .static = profile { return .region(.inline(family: 10, chargedBytes: MemoryLayout<StaticSemanticRecordStorage>.size - matchControl, kind: .partition, size: MemoryLayout<StaticSemanticRecordStorage>.size, stride: MemoryLayout<StaticSemanticRecordStorage>.stride, alignment: MemoryLayout<StaticSemanticRecordStorage>.alignment)) }
            continue
        case 114:
            phase = 115
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 7, size: MemoryLayout<UInt16>.size, stride: MemoryLayout<UInt16>.stride, alignment: MemoryLayout<UInt16>.alignment)) }
            #endif
            continue
        case 115:
            phase = 116
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.elements(count: 2, family: 7, size: MemoryLayout<Bool>.size, stride: MemoryLayout<Bool>.stride, alignment: MemoryLayout<Bool>.alignment)) }
            #endif
            continue
        case 116:
            phase = 117
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 7, size: MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.size, stride: MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.stride, alignment: MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.alignment)) }
            #endif
            continue
        case 117:
            phase = 118
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 10, chargedBytes: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.size - matchControl, kind: .partition, size: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.size, stride: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.stride, alignment: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.alignment)) }
            #endif
            continue
        case 118:
            phase = 119
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 10, size: MemoryLayout<[SemanticRuntimeRecord]>.size, stride: MemoryLayout<[SemanticRuntimeRecord]>.stride, alignment: MemoryLayout<[SemanticRuntimeRecord]>.alignment)) }
            #endif
            continue
        case 119:
            phase = 120
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 10, size: MemoryLayout<[SemanticPathEntry]>.size, stride: MemoryLayout<[SemanticPathEntry]>.stride, alignment: MemoryLayout<[SemanticPathEntry]>.alignment)) }
            #endif
            continue
        case 120:
            phase = 121
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 10, size: MemoryLayout<[CounterPayload?]>.size, stride: MemoryLayout<[CounterPayload?]>.stride, alignment: MemoryLayout<[CounterPayload?]>.alignment)) }
            #endif
            continue
        case 121:
            phase = 122
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 10, size: MemoryLayout<[UInt32]>.size, stride: MemoryLayout<[UInt32]>.stride, alignment: MemoryLayout<[UInt32]>.alignment)) }
            #endif
            continue
        case 122:
            phase = 123
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 10, size: MemoryLayout<SemanticRecordLimits>.size, stride: MemoryLayout<SemanticRecordLimits>.stride, alignment: MemoryLayout<SemanticRecordLimits>.alignment)) }
            #endif
            continue
        case 123:
            phase = 124
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 10, size: MemoryLayout<SemanticRecordOwnerIdentity>.size, stride: MemoryLayout<SemanticRecordOwnerIdentity>.stride, alignment: MemoryLayout<SemanticRecordOwnerIdentity>.alignment)) }
            #endif
            continue
        case 124:
            phase = 125
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(.inline(family: 10, size: MemoryLayout<Bool>.size, stride: MemoryLayout<Bool>.stride, alignment: MemoryLayout<Bool>.alignment)) }
            #endif
            continue
        case 125:
            phase = 126
            return .region(.elements(count: semantic.records.count - Int(semanticLimits.records), family: 11, size: MemoryLayout<SemanticRuntimeRecord>.size, stride: MemoryLayout<SemanticRuntimeRecord>.stride, alignment: MemoryLayout<SemanticRuntimeRecord>.alignment))
        case 126: phase = 127; return .visitGeometry
        case 127:
            phase = 128
            return .region(.elements(count: canvasCount, family: 14, size: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.size, stride: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.stride, alignment: MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>.alignment))
        case 128:
            phase = 129
            return .region(.elements(count: Int(CounterPendingBacking.capacity), family: 14, size: MemoryLayout<CounterValueTable.CaptureStorage?>.size, stride: MemoryLayout<CounterValueTable.CaptureStorage?>.stride, alignment: MemoryLayout<CounterValueTable.CaptureStorage?>.alignment))
        case 129:
            phase = 130
            return .region(.elements(count: Int(CounterPendingBacking.capacity), family: 14, size: MemoryLayout<UInt16>.size, stride: MemoryLayout<UInt16>.stride, alignment: MemoryLayout<UInt16>.alignment))
        case 130:
            phase = 131
            return .region(.inline(family: 14, size: MemoryLayout<CanvasPendingMetadata>.size, stride: MemoryLayout<CanvasPendingMetadata>.stride, alignment: MemoryLayout<CanvasPendingMetadata>.alignment))
        case 131:
            phase = 132
            return .region(.inline(family: 14, chargedBytes: CounterPendingBacking.paddingBytes, kind: .metadataPadding, size: MemoryLayout<CounterPendingBacking>.size, stride: MemoryLayout<CounterPendingBacking>.stride, alignment: MemoryLayout<CounterPendingBacking>.alignment))
        case 132:
            phase = 133
            if case .static = profile { return .region(.inline(family: 14, size: MemoryLayout<StaticCanvasValueStorage>.size, stride: MemoryLayout<StaticCanvasValueStorage>.stride, alignment: MemoryLayout<StaticCanvasValueStorage>.alignment)) }
            continue
        case 133:
            phase = 134
            #if !hasFeature(Embedded)
            if case .dynamic = profile { return .region(
                    .inline(family: 14, size: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size, stride: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.stride, alignment: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.alignment)) }
            #endif
            continue
        case 134:
            phase = 135
            return .region(.inline(family: 17, chargedBytes: root.liveBytes, kind: .partition, size: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.size, stride: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.stride, alignment: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.alignment))
        case 135:
            phase = 136
            return .region(.inline(family: 18, chargedBytes: root.candidateBytes, kind: .partition, size: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.size, stride: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.stride, alignment: MemoryLayout<ObservableStateRootStorage<SemanticCompleteIdentity>>.alignment))
        case 136: phase = 137; return .visitInteraction
        case 137:
            phase = 138
            return .region(.elements(count: 2, family: 21, size: MemoryLayout<NormalizedPointerEvent?>.size, stride: MemoryLayout<NormalizedPointerEvent?>.stride, alignment: MemoryLayout<NormalizedPointerEvent?>.alignment))
        case 138:
            phase = 139
            return .region(.inline(family: 21, size: MemoryLayout<InlineArray<34, UInt8>>.size, stride: MemoryLayout<InlineArray<34, UInt8>>.stride, alignment: MemoryLayout<InlineArray<34, UInt8>>.alignment))
        case 139:
            phase = 140
            return .region(.inline(family: 21, size: MemoryLayout<UInt16>.size, stride: MemoryLayout<UInt16>.stride, alignment: MemoryLayout<UInt16>.alignment))
        case 140:
            phase = 141
            return .region(.inline(family: 21, size: MemoryLayout<UInt16?>.size, stride: MemoryLayout<UInt16?>.stride, alignment: MemoryLayout<UInt16?>.alignment))
        case 141:
            phase = 142
            return .region(.inline(family: 22, chargedBytes: sealed, kind: .partition, size: MemoryLayout<CounterAdmissionBacking>.size, stride: MemoryLayout<CounterAdmissionBacking>.stride, alignment: MemoryLayout<CounterAdmissionBacking>.alignment))
        case 142:
            phase = 143
            return .region(.inline(family: 23, chargedBytes: Admission.pointerStateStorageBytes, kind: .partition, size: MemoryLayout<Admission.Controller?>.size, stride: MemoryLayout<Admission.Controller?>.stride, alignment: MemoryLayout<Admission.Controller?>.alignment))
        case 143:
            phase = 144
            return .region(.inline(family: 23, size: MemoryLayout<CounterPointerState>.size, stride: MemoryLayout<CounterPointerState>.stride, alignment: MemoryLayout<CounterPointerState>.alignment))
        case 144: resumePhase = 145; phase = 10; return .geometrySize
        case 145:
            phase = 146
            return .region(.inline(family: 24, chargedBytes: MemoryLayout<CounterControl>.size - MemoryLayout<CounterEndpoint>.size - Admission.pointerStateStorageBytes - MemoryLayout<CounterAdmissionBacking>.size - MemoryLayout<CounterPointerState>.size - result, kind: .metadataPadding, size: MemoryLayout<CounterControl>.size, stride: MemoryLayout<CounterControl>.stride, alignment: MemoryLayout<CounterControl>.alignment))
        case 146:
            phase = 147
            return .region(factoryRegion)
        case 147:
            phase = 148
            if let factoryDescriptorRegion { return .region(factoryDescriptorRegion) }
            continue
        case 148:
            phase = 149
            return .region(.inline(family: 25, size: MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.size, stride: MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.stride, alignment: MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.alignment))
        case 149:
            terminal = finish()
            phase = 999
            return .done(terminal!)
        default: preconditionFailure("unexpected accounting stage")
            }
        }
    }
    private func finish() -> RuntimeProfileValidationResult {
    guard !reported.overflow else { return .invalid(.arithmeticOverflow) }
    var comparisonIndex = 0
    while comparisonIndex < 26 { precondition(reported[comparisonIndex] == CounterFamilyValueIndexAccess.get(values, at: comparisonIndex), "physical region audit mismatch")
        comparisonIndex += 1
    }
    let bytes = RuntimeStorageByteCounts(semanticCandidatePathBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 0)), semanticPublishedPathBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 1)), semanticCandidatePayloadBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 2)), semanticPublishedPayloadBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 3)), identityMatchWorkspaceBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 4)), interactionCandidateIdentityBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 5)), interactionCommittedIdentityBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 6)), modelMetadataBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 7)), modelOwnerBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 8)), framePinBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 9)), semanticCandidateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 10)), semanticPublishedBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 11)), layoutCandidateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 12)), renderWorkspaceBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 13)), canvasCallableBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 14)), pathWorkspaceBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 15)), drawingPlanBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 16)), observableLiveBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 17)), observableCandidateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 18)), interactionCandidateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 19)), interactionCommittedBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 20)), admissionQueueBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 21)), sealedBatchBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 22)), pointerStateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 23)), coordinatorStateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 24)), failureStateBytes: UInt32(CounterFamilyValueIndexAccess.get(values, at: 25)))
    let records = RuntimeRecordLimits(maximumPathEntries: semanticLimits.paths, maximumPathDepth: semanticLimits.depth, maximumPathChildFanout: semanticLimits.fanout, maximumPayloadBytesPerBank: semanticLimits.payloadBytes, maximumIdentityComponentsPerKey: keyLimits.perKey, maximumInteractionIdentityComponents: keyLimits.perBank)
    let inputs = RuntimeProfileLimitInputs(records: limits.records, models: limits.models, semantic: limits.semantic, maximumSemanticStructuralOccurrences: limits.maximumSemanticStructuralOccurrences, layout: limits.layout, render: limits.render, renderWorkspace: limits.renderWorkspace, renderSink: limits.renderSink, maximumOrdinaryRenderOperations: limits.maximumOrdinaryRenderOperations, execution: limits.execution, observableState: limits.observableState, interaction: limits.interaction, drawing: limits.drawing, staticCanvas: limits.staticCanvas, profile: profile)
    let rootCapacity = ObservableStateRootControl.storageCapacities()
    let capacities = RuntimeStorageCapacities(candidateRecords: records, publishedRecords: records,
        models: .init(maximumModelSlots: root.models, maximumOwningTickets: root.claims, maximumFramePins: root.pins, maximumModelCaptureBanks: root.captures),
        semanticCandidate: .init(maximumDepth: semanticLimits.depth, maximumSemanticNodes: semanticLimits.records, maximumBodyEvaluations: semanticLimits.records, maximumModifierApplications: semanticLimits.records, maximumActionOccurrences: semanticLimits.records),
        semanticPublished: .init(maximumDepth: semanticLimits.depth, maximumSemanticNodes: semanticLimits.records, maximumBodyEvaluations: semanticLimits.records, maximumModifierApplications: semanticLimits.records, maximumActionOccurrences: semanticLimits.records),
        semanticCandidateStructuralOccurrences: semanticLimits.records, semanticPublishedStructuralOccurrences: semanticLimits.records,
        layoutCandidate: geometry.layout, render: geometry.render, renderWorkspace: limits.renderWorkspace,
        canvasCallableOccurrences: canvasCapacity, staticCanvasCaptureBytes: UInt16(MemoryLayout<CounterValueTable.CaptureStorage>.stride),
        pathPoints: geometry.drawing.maximumLivePathPoints, pathSubpaths: geometry.drawing.maximumLivePathSubpaths,
        drawingPlanStrokes: geometry.drawing.maximumPlanStrokes, drawingPlanPoints: geometry.drawing.maximumPlanPoints, drawingPlanSubpaths: geometry.drawing.maximumPlanSubpaths, normalizedStrokeOperations: geometry.drawing.maximumNormalizedStrokeOperations,
        observableLiveLocations: rootCapacity.locations, observableLiveRegistrations: rootCapacity.registrations, observableCandidateAssociations: rootCapacity.associations,
        interactionCandidateActions: keys.candidateRecords, interactionCandidateHitRegions: keys.candidateHits, interactionCommittedActions: keys.committedRecords, interactionCommittedHitRegions: keys.committedHits,
        admissionQueue: counterExecutionLimits, sealedBatch: counterExecutionLimits, pointerStates: 1,
        coordinatorStatePresent: concreteCoordinatorBytes > 0, failureStatePresent: result > 0, byteCounts: bytes)
    if case .static = profile {
        return RuntimeProfileValidator.validateStatic(
            inputs: inputs, capacities: capacities, metadata: CounterCanvasAudit())
    }
    return RuntimeProfileValidator.validateDynamic(inputs: inputs, capacities: capacities)
    }
}
func counterRecordAccountingRegion(_ region: CounterStorageRegion, engine: inout CounterPhysicalAccountingEngine, report: (CounterStorageRegion) -> Void) {
    engine.record(region)
    report(region)
}
func counterVisitAccountingRegions<GR: CounterStorageRegionSource>(_ request: CounterPhysicalAccountingEngine.Request, engine: inout CounterPhysicalAccountingEngine, geometry: borrowing GR, interaction: borrowing CounterPhysicalInteractionFacts, report: (CounterStorageRegion) -> Void) {
    func record(_ region: CounterStorageRegion) { counterRecordAccountingRegion(region, engine: &engine, report: report) }
    switch request {
    case .visitGeometry: geometry.visitStorageRegions(record)
    case .visitInteraction: interaction.visitStorageRegions(record)
    default: preconditionFailure("unexpected accounting visitor")
    }
}
func counterVisitConcreteAccountingRegions(_ request: CounterPhysicalAccountingEngine.Request, engine: inout CounterPhysicalAccountingEngine, geometry: borrowing CounterPhysicalGeometryFacts, interaction: borrowing CounterPhysicalInteractionFacts, report: (CounterStorageRegion) -> Void) {
    func record(_ region: CounterStorageRegion) { counterRecordAccountingRegion(region, engine: &engine, report: report) }
    switch request {
    case .visitGeometry: geometry.visitStorageRegions(record)
    case .visitInteraction: interaction.visitStorageRegions(record)
    default: preconditionFailure("unexpected accounting visitor")
    }
}

func counterValidatePhysicalBacking<G, C, R, H, GR: CounterStorageRegionSource>(profile: RuntimeProfileKind, limits: RuntimeProfileLimits,
    root: CounterRootLayout, rootMetadataRegion: CounterStorageRegion, semantic: CounterSemanticMeasurement, geometry: CounterGeometryMeasurement,
    interactionFacts: CounterPhysicalInteractionFacts, identityCapacities: (perKey: UInt16, perBank: UInt32),
    descriptorBytes: Int = 0, geometryType: G.Type, candidateType: C.Type, committedType: R.Type, hitType: H.Type,
    canvasCount: Int, canvasCapacity: UInt16, canvasControlBytes: Int,
    factoryRegion: CounterStorageRegion,
    factoryDescriptorRegion: CounterStorageRegion? = nil,
    geometryRegions: borrowing GR,
    report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult
where G: CounterGeometry & ~Copyable & ~Escapable, C: CounterCandidateBacking & ~Copyable & ~Escapable, R: CounterCommittedBacking & ~Copyable & ~Escapable, H: CounterHitBacking & ~Copyable & ~Escapable,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    typealias Owner = CounterPipelineOwner<G, C, R, H>
    var engine = CounterPhysicalAccountingEngine(CounterPhysicalAccountingInput(profile: profile, limits: limits, root: root, rootMetadataRegion: rootMetadataRegion, semantic: semantic, geometry: geometry, interactionFacts: interactionFacts, identityCapacities: identityCapacities, descriptorBytes: descriptorBytes, canvasCount: canvasCount, canvasCapacity: canvasCapacity, canvasControlBytes: canvasControlBytes, factoryRegion: factoryRegion, factoryDescriptorRegion: factoryDescriptorRegion))
    while true {
        let request = engine.next()
        switch request {
        case .staticCoordinatorSize: engine.acceptSize(MemoryLayout<StaticRuntimeExecutionCoordinator<CounterExecutionBinding, CounterAdmission, Owner>>.size)
        case .dynamicCoordinatorSize:
            #if !hasFeature(Embedded)
                engine.acceptSize(MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, CounterAdmission, Owner>>.size)
            #else
                preconditionFailure("unexpected Dynamic accounting")
            #endif
        case .geometrySize: engine.acceptSize(MemoryLayout<G>.size)
        case .keyStateSize: engine.acceptSize(MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size)
        case .staticCoordinatorLayout: engine.acceptLayout(.init(size: MemoryLayout<StaticRuntimeExecutionCoordinator<CounterExecutionBinding, CounterAdmission, Owner>>.size, stride: MemoryLayout<StaticRuntimeExecutionCoordinator<CounterExecutionBinding, CounterAdmission, Owner>>.stride, alignment: MemoryLayout<StaticRuntimeExecutionCoordinator<CounterExecutionBinding, CounterAdmission, Owner>>.alignment))
        case .dynamicCoordinatorLayout:
            #if !hasFeature(Embedded)
                engine.acceptLayout(.init(size: MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, CounterAdmission, Owner>>.size, stride: MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, CounterAdmission, Owner>>.stride, alignment: MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, CounterAdmission, Owner>>.alignment))
            #else
                preconditionFailure("unexpected Dynamic accounting")
            #endif
        case .region(let region): counterRecordAccountingRegion(region, engine: &engine, report: report)
        case .visitGeometry, .visitInteraction:
            counterVisitAccountingRegions(request, engine: &engine, geometry: geometryRegions, interaction: interactionFacts, report: report)
        case .done(let result): return result
        }
    }
}


#if !hasFeature(Embedded)
typealias CounterDynamicCandidate = DynamicInteractionCandidateStorage<SemanticCompleteIdentity>
typealias CounterDynamicCommitted = DynamicInteractionCommittedStorage<SemanticCompleteIdentity>
typealias CounterDynamicHits = DynamicInteractionHitStorage<SemanticCompleteIdentity>
typealias CounterDynamicKeys = InteractionOwnedKeyState<CounterDynamicCandidate, CounterDynamicCommitted, CounterDynamicHits>
struct DynamicCounterProfileStorage: ~Copyable, RuntimeProfileStorage {
    typealias StructuralIdentity = SemanticCompleteIdentity
    static var profile: RuntimeProfileKind { .dynamic }
    let limits: RuntimeProfileLimits
    var root: DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>
    var semantic: DynamicSemanticRecordStorage
    var pending = CounterPendingBacking()
    var canvas = DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>(capacity: 1)
    var geometry: DynamicCounterGeometry? = DynamicCounterGeometry()
    var interaction: CounterDynamicKeys?
    var control = CounterControl()
    var used = false
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity, limits: RuntimeProfileLimits = counterActualLimits(.dynamic)) {
        self.limits = limits
        root = DynamicObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!
        semantic = DynamicSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner)
        interaction = CounterDynamicKeys(state: InteractionState(candidateRecords: CounterDynamicCandidate(capacity: 2), candidateHitRegions: CounterDynamicHits(capacity: 2), candidateCommittedRecords: CounterDynamicCommitted(capacity: 2), committedRecords: CounterDynamicCommitted(capacity: 2), committedHitRegions: CounterDynamicHits(capacity: 2)), maximumComponentsPerKey: 24, maximumComponents: 48)!
    }
    borrowing func audit() -> RuntimeProfileValidationResult { audit(report: { _ in }) }
    borrowing func audit(report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult {
        guard let geometry, let interaction else { return .invalid(.missingStorage) }
        let extent = semantic.retainedExtents
        return counterValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout, rootMetadataRegion: .inline(family: 7, chargedBytes: root.storageLayout.metadataBytes - MemoryLayout<UInt16>.size - 2 * MemoryLayout<Bool>.size - MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.size, kind: .partition, size: MemoryLayout<ObservableModelOwnership>.size, stride: MemoryLayout<ObservableModelOwnership>.stride, alignment: MemoryLayout<ObservableModelOwnership>.alignment),
            semantic: .init(limits: semantic.storageLimits, records: .elements(count: extent.records, stride: MemoryLayout<SemanticRuntimeRecord>.stride, alignment: MemoryLayout<SemanticRuntimeRecord>.alignment), paths: .elements(count: extent.paths, stride: MemoryLayout<SemanticPathEntry>.stride, alignment: MemoryLayout<SemanticPathEntry>.alignment), payloads: .elements(count: extent.payloads, stride: MemoryLayout<CounterPayload?>.stride, alignment: MemoryLayout<CounterPayload?>.alignment), scalars: .elements(count: extent.scalars, stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment), controlBytes: extent.controlBytes),
            geometry: geometry.storageMeasurement(), interaction: interaction, geometryType: DynamicCounterGeometry.self,
            canvasCount: canvas.retainedElementCapacity, canvasCapacity: canvas.capacity,
            canvasControlBytes: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size + MemoryLayout<CounterPendingBacking>.size,
            factoryRegion: .inline(family: 24, chargedBytes: MemoryLayout<Self>.size - MemoryLayout<CounterPendingBacking>.size - MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size - MemoryLayout<DynamicCounterGeometry>.size - MemoryLayout<CounterDynamicKeys>.size - MemoryLayout<CounterControl>.size, kind: .metadataPadding, size: MemoryLayout<Self>.size, stride: MemoryLayout<Self>.stride, alignment: MemoryLayout<Self>.alignment),
            geometryRegions: geometry, report: report)
    }
    mutating func resetAttemptStorage() {
            let p08Presence65: Bool;
            if case .some = geometry {
                if case .some = interaction { p08Presence65 = true } else { p08Presence65 = false }
            } else {
                p08Presence65 = false
            }; precondition(p08Presence65)
            geometry!.reset()
            interaction!.resolveCandidate(.discard)
        control.admission.finishAttempt()
    }
    mutating func resetAllStorage() {
        control.requireVacantRuntimeSlot()
        precondition(!used || control.unavailable)
        resetAttemptStorage()
        interaction!.resetAllStorage()
        control.admission.resetAll()
    }

    mutating func run() -> Int {
        guard !used, case .valid(let audited) = audit() else { return 0 }
        used = true
        precondition(interaction!.configureIdentityLimits(perKey: limits.records.maximumIdentityComponentsPerKey, perBank: limits.records.maximumInteractionIdentityComponents))
        var movedGeometry = geometry.take()
        var movedInteraction = interaction.take()
        var returned: CounterReturnedWorkspaces<DynamicCounterGeometry, CounterDynamicCandidate, CounterDynamicCommitted, CounterDynamicHits>?
        do throws(ObservableStateError) {
            try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    try semantic.withLifetime(configuredLimits: counterSemanticConfiguration(limits)) { (semantic) throws(SemanticExpansionError) in
return try pending.withLifetime { semanticCodec in
                        do throws(DrawingError) {
                            try canvas.withLifetime(table: CounterValueTable(), limits: limits.staticCanvas ?? counterCanvasLimits, configuredCapacity: limits.drawing.maximumCanvasOccurrences) { values in
                                returned = exerciseCounterCoordinator(models: models, root: root, semantic: semantic, semanticCodec: copy semanticCodec, values: values, dynamic: true, geometry: movedGeometry.take()!, interaction: movedInteraction.take()!, audit: audited, control: &control)
                            }
                        } catch { preconditionFailure("factory Canvas") }

}
}
                } catch { preconditionFailure("factory semantic") }
            }
        } catch { preconditionFailure("factory model") }
        let workspaces = returned.take()!
        let checks = workspaces.checks
        geometry = workspaces.geometry; interaction = workspaces.interaction
        precondition(audit() == .valid(audited))
        resetAllStorage()
        precondition(audit() == .valid(audited))
        return checks + 6
    }
}
#endif

struct StaticCounterProfileStorage: ~Copyable, RuntimeProfileStorage {
    typealias StructuralIdentity = SemanticCompleteIdentity
    static var profile: RuntimeProfileKind { .static }
    let limits: RuntimeProfileLimits
    var root: CounterStaticRootStorage
    var semantic: StaticSemanticRecordStorage
    var semanticBacking = CounterSemanticBacking()
    var canvas = StaticCanvasValueStorage()
    var canvasBacking: InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?> = .init(repeating: nil)
    var workspace = CounterStaticWorkspaceBacking()
    var interaction: CounterStaticKeys?
    var control = CounterControl()
    var used = false
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity, limits: RuntimeProfileLimits = counterActualLimits(.static)) {
        self.limits = limits
        root = CounterStaticRootStorage(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!
        semantic = StaticSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner)
        interaction = CounterStaticKeys(state: InteractionState(candidateRecords: CounterStaticCandidate(capacity: 2)!, candidateHitRegions: CounterStaticHits(capacity: 2)!, candidateCommittedRecords: CounterStaticCommitted(capacity: 2)!, committedRecords: CounterStaticCommitted(capacity: 2)!, committedHitRegions: CounterStaticHits(capacity: 2)!), maximumComponentsPerKey: 24, maximumComponents: 48)!
    }
    borrowing func audit() -> RuntimeProfileValidationResult { audit(report: { _ in }) }
    borrowing func audit(report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult {
        guard let interaction else { return .invalid(.missingStorage) }
        return counterValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout, rootMetadataRegion: .inline(family: 7, chargedBytes: root.storageLayout.metadataBytes, kind: .metadataPadding, size: MemoryLayout<CounterStaticRootStorage>.size, stride: MemoryLayout<CounterStaticRootStorage>.stride, alignment: MemoryLayout<CounterStaticRootStorage>.alignment),
            semantic: .init(limits: semantic.storageLimits, records: .elements(count: semanticBacking.records.count, stride: MemoryLayout<SemanticRuntimeRecord>.stride, alignment: MemoryLayout<SemanticRuntimeRecord>.alignment), paths: .elements(count: semanticBacking.paths.count, stride: MemoryLayout<SemanticPathEntry>.stride, alignment: MemoryLayout<SemanticPathEntry>.alignment), payloads: .elements(count: semanticBacking.payloads.count, stride: MemoryLayout<CounterPayload?>.stride, alignment: MemoryLayout<CounterPayload?>.alignment), scalars: .elements(count: semanticBacking.scalars.count, stride: MemoryLayout<UInt32>.stride, alignment: MemoryLayout<UInt32>.alignment), controlBytes: MemoryLayout<StaticSemanticRecordStorage>.size + CounterSemanticBacking.paddingBytes),
            geometry: workspace.measurement, interaction: interaction, geometryType: StaticCounterGeometry.self,
            canvasCount: canvasBacking.count, canvasCapacity: UInt16(canvasBacking.count),
            canvasControlBytes: MemoryLayout<StaticCanvasValueStorage>.size + MemoryLayout<CounterPendingBacking>.size,
            factoryRegion: .inline(family: 24, chargedBytes: MemoryLayout<Self>.size - MemoryLayout<CounterStaticRootStorage>.size - MemoryLayout<StaticSemanticRecordStorage>.size - MemoryLayout<CounterSemanticBacking>.size - MemoryLayout<StaticCanvasValueStorage>.size - MemoryLayout<InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>>.size - MemoryLayout<CounterStaticWorkspaceBacking>.size - MemoryLayout<CounterStaticKeys>.size - MemoryLayout<CounterControl>.size, kind: .metadataPadding, size: MemoryLayout<Self>.size, stride: MemoryLayout<Self>.stride, alignment: MemoryLayout<Self>.alignment),
            geometryRegions: workspace, report: report)
    }
    mutating func resetAttemptStorage() {
        let p08Presence66: Bool;
        if case .some = interaction { p08Presence66 = true } else { p08Presence66 = false };
        precondition(p08Presence66)
        _ = workspace.withGeometry { geometry in
            var geometry = consume geometry
            geometry.reset()
            return 0
        }
        interaction!.resolveCandidate(.discard)
        control.admission.finishAttempt()
    }
    mutating func resetAllStorage() {
        control.requireVacantRuntimeSlot()
        precondition(!used || control.unavailable)
        resetAttemptStorage()
        interaction!.resetAllStorage()
        control.admission.resetAll()
    }

    mutating func run() -> Int {
        guard !used, case .valid(let audited) = audit() else { return 0 }
        used = true
        precondition(interaction!.configureIdentityLimits(perKey: limits.records.maximumIdentityComponentsPerKey, perBank: limits.records.maximumInteractionIdentityComponents))
        var movedInteraction = interaction.take()
        var checks = 0
        do throws(ObservableStateError) {
            try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    var records = semanticBacking.records.mutableSpan
                    var paths = semanticBacking.paths.mutableSpan
                    var payloads = semanticBacking.payloads.mutableSpan
                    var scalars = semanticBacking.scalars.mutableSpan
                    try semantic.withLifetime(configuredLimits: counterSemanticConfiguration(limits), records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
return try semanticBacking.pending.withLifetime { semanticCodec in
                        do throws(DrawingError) {
                            var entries = canvasBacking.mutableSpan
                            try canvas.withLifetime(entries: &entries, table: CounterValueTable(), capacity: limits.drawing.maximumCanvasOccurrences, limits: limits.staticCanvas ?? counterCanvasLimits) { values in
                                checks = workspace.withGeometry { geometry in
                                    let measured = geometry.storageMeasurement()
                                    var returned = exerciseCounterCoordinator(models: models, root: root, semantic: semantic, semanticCodec: copy semanticCodec, values: values, dynamic: false, geometry: geometry, interaction: movedInteraction.take()!, audit: audited, control: &control)
                                    precondition(returned.geometry.storageMeasurement() == measured)
                                    // The returned raw descriptors are consumed here, while all
                                    // four physical arrays are still borrowed and immovable.
                                    returned.geometry.reset()
                                    movedInteraction = returned.interaction
                                    return returned.checks + 1
                                }
                            }
                        } catch { preconditionFailure("factory Canvas") }

}
}
                } catch { preconditionFailure("factory semantic") }
            }
        } catch { preconditionFailure("factory model") }
        interaction = movedInteraction.take()
        precondition(audit() == .valid(audited))
        resetAllStorage()
        precondition(audit() == .valid(audited))
        return checks + 6
    }
}


#endif

enum CounterFamilyValueIndexAccess {
    #if GIFTUI_COUNTER_FAMILY_EFFECT_PROOF
        @_noAllocation
    #endif
    static func get(_ values: borrowing InlineArray<26, UInt64>, at index: Int) -> UInt64 {
        switch index {
        case 0: values[0]
        case 1: values[1]
        case 2: values[2]
        case 3: values[3]
        case 4: values[4]
        case 5: values[5]
        case 6: values[6]
        case 7: values[7]
        case 8: values[8]
        case 9: values[9]
        case 10: values[10]
        case 11: values[11]
        case 12: values[12]
        case 13: values[13]
        case 14: values[14]
        case 15: values[15]
        case 16: values[16]
        case 17: values[17]
        case 18: values[18]
        case 19: values[19]
        case 20: values[20]
        case 21: values[21]
        case 22: values[22]
        case 23: values[23]
        case 24: values[24]
        case 25: values[25]
        default: preconditionFailure("physical family index out of bounds")
        }
    }
    #if GIFTUI_COUNTER_FAMILY_EFFECT_PROOF
        @_noAllocation
    #endif
    static func set(_ values: inout InlineArray<26, UInt64>, at index: Int, to value: UInt64) {
        switch index {
        case 0: values[0] = value
        case 1: values[1] = value
        case 2: values[2] = value
        case 3: values[3] = value
        case 4: values[4] = value
        case 5: values[5] = value
        case 6: values[6] = value
        case 7: values[7] = value
        case 8: values[8] = value
        case 9: values[9] = value
        case 10: values[10] = value
        case 11: values[11] = value
        case 12: values[12] = value
        case 13: values[13] = value
        case 14: values[14] = value
        case 15: values[15] = value
        case 16: values[16] = value
        case 17: values[17] = value
        case 18: values[18] = value
        case 19: values[19] = value
        case 20: values[20] = value
        case 21: values[21] = value
        case 22: values[22] = value
        case 23: values[23] = value
        case 24: values[24] = value
        case 25: values[25] = value
        default: preconditionFailure("physical family index out of bounds")
        }
    }
}
