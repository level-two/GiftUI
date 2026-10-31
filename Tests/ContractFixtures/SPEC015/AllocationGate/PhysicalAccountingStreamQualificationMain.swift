import Darwin
import GiftUI
import GiftUIFailureCore
import GiftUIRuntimeCore
import GiftUISemanticCore
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderLowering
@testable import GiftUIExecution
import GiftUIObservableState
import GiftUIInteraction
import GiftUIDrawing
import GiftUIHostConfiguration
@main
enum VisitorStateQualification {
    static func main() {
        if let mode = CommandLine.arguments.dropFirst().first, mode.hasPrefix("--facts-") { selectedFactsFatal(mode); print("FACTS GUARD ABSENT"); exit(97) }
        if CommandLine.arguments.dropFirst().first == "--missing-row-fatal" {
            p08CounterPhysicalFactsMissingRowsFatal()
            print("MISSING ROW GUARD ABSENT"); exit(97)
        }
        if CommandLine.arguments.contains("--inventory-read-negative") { p08InventoryInvalidIndexQualification(-1, write: false); print("INVALID INVENTORY INDEX ACCEPTED"); exit(97) }
        if CommandLine.arguments.contains("--inventory-read-upper") { p08InventoryInvalidIndexQualification(14, write: false); print("INVALID INVENTORY INDEX ACCEPTED"); exit(97) }
        if CommandLine.arguments.contains("--inventory-write-negative") { p08InventoryInvalidIndexQualification(-1, write: true); print("INVALID INVENTORY INDEX ACCEPTED"); exit(97) }
        if CommandLine.arguments.contains("--inventory-write-upper") { p08InventoryInvalidIndexQualification(14, write: true); print("INVALID INVENTORY INDEX ACCEPTED"); exit(97) }
        let engineFactsChecks = selectedEngineFactsControls()
        let streamChecks = p08CounterAccountingStreamQualification()
        let factoryChecks = p08FactoryDefaultQualification()
        precondition(factoryChecks > 96000)
        precondition(streamChecks > 0)
        precondition(p08PhysicalIDEqualityQualification() == 196)
        precondition(p08InventoryIndexQualification() == 56)
        precondition(p08RuntimeEqualityQualification() == 109)
        let graphChecks = p08CounterGraph()
        precondition(graphChecks == 130)
        let checks = p08CounterPhysicalFactsQualification()
        precondition(checks == 492)
        print(
            "physical facts Static/Dynamic independent rows, five banks, 26 totals, audits, mismatch, refusal, faults, surplus, destruction PASS checks=\(checks) graph=\(graphChecks) engineFacts=\(engineFactsChecks) stream=\(streamChecks) factory=\(factoryChecks)"
        )
    }
}

enum OldGraphValidation {
    static let requiredRoleCount: UInt8 = 18
    private static let validRoleMask: UInt32 = (1 << requiredRoleCount) - 1

    static func validate<Graph>(
        _ graph: borrowing Graph
    ) -> HostConfigurationError?
    where Graph: HostComponentGraphView {
        guard graph.count == requiredRoleCount else {
            return firstMissingRole(in: graph) ?? .invalidGraph
        }

        var seen = HostComponentRoleSet(rawValue: 0)
        for index in UInt8(0) ..< requiredRoleCount {
            guard let expectedRole = HostComponentRole(rawValue: index),
                let record = graph.record(at: index)
            else {
                return .missingRole(HostComponentRole(rawValue: index)!)
            }
            let roleSet = HostComponentRoleSet(record.role)
            if seen.contains(roleSet) {
                return .duplicateRole(record.role)
            }
            guard record.role == expectedRole else { return .invalidGraph }
            guard record.dependencies.rawValue & ~validRoleMask == 0 else {
                return .invalidGraph
            }
            guard !record.dependencies.contains(roleSet) else {
                return .invalidGraph
            }

            let upwardMask = validRoleMask & ~((UInt32(1) << UInt32(index + 1)) - 1)
            guard record.dependencies.rawValue & upwardMask == 0 else {
                return .invalidGraph
            }
            seen.formUnion(roleSet)
        }
        return nil
    }

    private static func firstMissingRole<Graph>(
        in graph: borrowing Graph
    ) -> HostConfigurationError?
    where Graph: HostComponentGraphView {
        var seen = HostComponentRoleSet(rawValue: 0)
        for index in UInt8(0) ..< graph.count {
            guard let record = graph.record(at: index) else { continue }
            let roleSet = HostComponentRoleSet(record.role)
            if seen.contains(roleSet) {
                return .duplicateRole(record.role)
            }
            seen.formUnion(roleSet)
        }
        for rawValue in UInt8(0) ..< requiredRoleCount {
            let role = HostComponentRole(rawValue: rawValue)!
            if !seen.contains(HostComponentRoleSet(role)) {
                return .missingRole(role)
            }
        }
        return nil
    }
}


private final class GraphReadTrace {
    let counts: [UInt8]
    var countReads = 0
    var reads: [Int] = []
    init(_ counts: [UInt8]) { self.counts = counts }
    func count() -> UInt8 { reads.append(-1); let i = min(countReads, counts.count - 1); countReads += 1; return counts[i] }
}
private struct ScriptGraph: HostComponentGraphView {
    let trace: GraphReadTrace
    let rows: [HostComponentRecord?]
    var count: UInt8 { trace.count() }
    func record(at index: UInt8) -> HostComponentRecord? { trace.reads.append(Int(index)); return Int(index) < rows.count ? rows[Int(index)] : nil }
}
private func sameRegion(_ a: CounterStorageRegion?, _ b: CounterStorageRegion?) -> Bool {
    switch (a,b) {
    case (.none,.none): return true
    case (.some(let a),.some(let b)): return a.family == b.family && a.kind == b.kind && a.count == b.count && a.size == b.size && a.stride == b.stride && a.alignment == b.alignment && a.chargedBytes == b.chargedBytes
    default: return false
    }
}
@inline(never) private func oldRegionLoad(_ x: borrowing InlineArray<48, CounterStorageRegion?>, _ i: Int) -> CounterStorageRegion? { x[i] }
@inline(never) private func oldRegionStore(_ x: inout InlineArray<48, CounterStorageRegion?>, _ i: Int, _ value: CounterStorageRegion?) { x[i] = value }
private struct OldFactsLayout { var regions: InlineArray<48, CounterStorageRegion?> = .init { _ in nil }; var count = 0 }
private func makeRegion(_ i: Int) -> CounterStorageRegion { .init(family: i % 26, kind: .elements, count: i + 1, size: 1, stride: 1, alignment: 1, chargedBytes: UInt64(i + 1)) }
private func selectedFactsFatal(_ mode: String) {
    var facts = CounterPhysicalGeometryFacts()
    if mode == "--facts-overflow" { for i in 0..<48 { facts.append(makeRegion(i)) }; facts.append(makeRegion(48)); return }
    if mode == "--facts-negative" { _ = facts.regions[-1]; return }
    if mode == "--facts-upper" { _ = facts.regions[48]; return }
    preconditionFailure("unknown facts mode")
}
private func selectedEngineFactsControls() -> Int {
    var checks = 0
    func require(_ value: Bool) { precondition(value); checks += 1 }
    func compare(_ counts: [UInt8], _ rows: [HostComponentRecord?]) {
        let a = GraphReadTrace(counts), b = GraphReadTrace(counts)
        let old = OldGraphValidation.validate(ScriptGraph(trace:a,rows:rows))
        let new = HostComponentGraphValidation.validate(ScriptGraph(trace:b,rows:rows))
        require(old == new); require(a.reads == b.reads); require(a.countReads == b.countReads)
        require(b.countReads == (counts[0] == 18 ? 1 : 2))
    }
    var base: [HostComponentRecord?] = []
    for i in 0..<18 { base.append(.init(role: HostComponentRole(rawValue:UInt8(i))!, dependencies:.init(rawValue:0))) }
    compare([18,255],base)
    for first: UInt8 in [0,1,17,19,255] { for second: UInt8 in [0,1,17,18,19,255] { compare([first,second],base) } }
    for i in 0..<18 {
        var rows = base; rows[i] = nil; compare([18,0],rows); compare([0,18],rows)
        if i > 0 { rows = base; rows[i] = .init(role:.runtimeProfile,dependencies:.init(rawValue:UInt32.max)); compare([18,18],rows); compare([0,18],rows) }
        if i < 17 { rows = base; rows[i] = .init(role:HostComponentRole(rawValue:UInt8(i+1))!,dependencies:.init(rawValue:UInt32.max)); compare([18,18],rows) }
        for bits: UInt32 in [UInt32.max, UInt32(1)<<UInt32(i), i<17 ? UInt32(1)<<UInt32(i+1) : 0] {
            rows=base; rows[i] = .init(role:HostComponentRole(rawValue:UInt8(i))!,dependencies:.init(rawValue:bits));compare([18,18],rows)
        }
    }
    var extended=base; while extended.count<255 { extended.append(nil) };compare([0,255],extended)
    extended[254]=base[0];compare([0,255],extended)
    for value in 0...255 {
        let role=HostComponentRole(rawValue:UInt8(value))
        if value<18 { require(role?.rawValue == UInt8(value)) } else { if case .none=role { require(true) } else { require(false) } }
    }
    require(OldGraphValidation.validate(CounterHostGraph()) == counterValidateHostGraph(CounterHostGraph()))
    for mode: UInt8 in 0...7 { require(OldGraphValidation.validate(CounterInvalidGraph(mode:mode)) == counterValidateHostGraph(CounterInvalidGraph(mode:mode))) }
    var facts=CounterPhysicalGeometryFacts();var old:InlineArray<48,CounterStorageRegion?> = .init { _ in nil }
    require(facts.count==0 && facts.regions.count==48)
    for i in 0..<48 { require(sameRegion(facts.regions[i],oldRegionLoad(old,i))) }
    for i in 0..<48 { let region=makeRegion(i);facts.append(region);oldRegionStore(&old,i,region);require(facts.count==i+1) }
    var visited=0
    facts.visitStorageRegions { row in require(sameRegion(row,oldRegionLoad(old,visited)));visited+=1 }
    require(visited==48)
    var copy=facts;copy.regions[0]=makeRegion(47);require(sameRegion(facts.regions[0],oldRegionLoad(old,0)));require(copy.regions[0]?.count==48)
    require(MemoryLayout<CounterPhysicalRegionBuffer>.size==MemoryLayout<InlineArray<48,CounterStorageRegion?>>.size)
    require(MemoryLayout<CounterPhysicalRegionBuffer>.stride==MemoryLayout<InlineArray<48,CounterStorageRegion?>>.stride)
    require(MemoryLayout<CounterPhysicalRegionBuffer>.alignment==MemoryLayout<InlineArray<48,CounterStorageRegion?>>.alignment)
    require(MemoryLayout<CounterPhysicalGeometryFacts>.size==MemoryLayout<OldFactsLayout>.size)
    require(MemoryLayout<CounterPhysicalGeometryFacts>.stride==MemoryLayout<OldFactsLayout>.stride)
    require(MemoryLayout<CounterPhysicalGeometryFacts>.alignment==MemoryLayout<OldFactsLayout>.alignment)
    return checks
}

// Valid deliberately slack inputs let every one of52storedleaves differindependently.
private func p08RuntimeEqualityValue(changed: Int? = nil, canvas: Bool = true) -> RuntimeProfileLimits {
    func u16(_ index: Int, _ value: UInt16) -> UInt16 { value + (changed == index ? 1 : 0) }
    func u32(_ index: Int, _ value: UInt32) -> UInt32 { value + (changed == index ? 1 : 0) }
    func i32(_ index: Int, _ value: Int32) -> Int32 { value + (changed == index ? 1 : 0) }
    let records = RuntimeRecordLimits(maximumPathEntries: u16(0, 32), maximumPathDepth: u16(1, 4), maximumPathChildFanout: u16(2, 4), maximumPayloadBytesPerBank: u32(3, 1024), maximumIdentityComponentsPerKey: u16(4, 8), maximumInteractionIdentityComponents: u32(5, 1024))
    let models = RuntimeModelLimits(maximumModelSlots: u16(6, 8), maximumOwningTickets: u16(7, 8), maximumFramePins: u16(8, 8), maximumModelCaptureBanks: u16(9, 0))
    let semantic = SemanticExpansionLimits(maximumDepth: u16(10, 4), maximumSemanticNodes: u16(11, 16), maximumBodyEvaluations: u16(12, 16), maximumModifierApplications: u16(13, 8), maximumActionOccurrences: u16(14, 3))!
    let layout = LayoutLimits(maximumScopes: u16(16, 8), maximumDepth: u16(17, 4), maximumTextScalars: u16(18, 64), maximumTextLines: u16(19, 8), maximumPositionedGlyphs: u16(20, 8))!
    let render = RenderLimits(maximumOperations: u16(21, 128), maximumPositionedGlyphs: u16(22, 16), maximumClipDepth: u16(23, 8))!
    let renderWorkspace = RenderWorkspaceCapacity(maximumSemanticScopes: u16(24, 16), maximumLayoutScopes: u16(25, 16), maximumTraversalDepth: u16(26, 8), maximumTextLines: u16(27, 16))!
    let renderSink = RenderSinkCapacity(maximumOperations: u16(28, 128), maximumPositionedGlyphs: u16(29, 16))
    let execution = ExecutionLimits(maximumInputEvents: u16(31, 16), maximumStateChangeFacts: u16(32, 16), maximumCompletionFacts: u16(33, 4), maximumSemanticActions: u16(34, 8), maximumActiveInputSources: u16(35, 2), maximumCommittedActions: u16(36, 8))!
    let observableState = ObservableStateLimits(maximumLocations: u16(37, 8), maximumRegistrations: u16(38, 16), maximumStagedAssociations: u16(39, 16))!
    let interaction = InteractionLimits(maximumActions: u16(40, 4), maximumHitRegions: u16(41, 2))!
    let drawing = DrawingLimits(maximumLineWidth: i32(42, 2), maximumCanvasOccurrences: u16(43, 4), maximumLivePathPoints: u16(44, 32), maximumLivePathSubpaths: u16(45, 4), maximumPlanStrokes: u16(46, 8), maximumPlanPoints: u16(47, 32), maximumPlanSubpaths: u16(48, 4), maximumNormalizedStrokeOperations: u16(49, 16))!
    let staticCanvas: StaticCanvasLimits? = canvas ? StaticCanvasLimits(maximumStaticCallableCases: u16(50, 4), maximumStaticCaptureBytes: u16(51, 64))! : nil
    guard let result = RuntimeProfileLimits(records: records, models: models, semantic: semantic, maximumSemanticStructuralOccurrences: u16(15, 32), layout: layout, render: render, renderWorkspace: renderWorkspace, renderSink: renderSink, maximumOrdinaryRenderOperations: u16(30, 32), execution: execution, observableState: observableState, interaction: interaction, drawing: drawing, staticCanvas: staticCanvas, profile: canvas ? .static : .dynamic) else { preconditionFailure("equality input rejected leaf \(String(describing: changed))") }
    return result
}
private func p08RuntimeEqualityQualification() -> Int {
    let base = p08RuntimeEqualityValue()
    precondition(base.matchesForHostStartup(base) == (base == base))
    var checks = 1
    for leaf in 0..<52 {
        let changed = p08RuntimeEqualityValue(changed: leaf)
        precondition(changed != base)
        checks += 1
        precondition(base.matchesForHostStartup(changed) == (base == changed))
        checks += 1
    }
    for left in [false, true] {
        for right in [false, true] {
            let lhs = p08RuntimeEqualityValue(canvas: left)
            let rhs = p08RuntimeEqualityValue(canvas: right)
            precondition(lhs.matchesForHostStartup(rhs) == (lhs == rhs))
            checks += 1
        }
    }
    return checks
}

// Independent original Native construction, retained only for this value/layout oracle.
private struct P08OriginalNativeFactoryStorage {
    var surface: InlineArray<48000, UInt8> = .init(repeating: 0)
    var payload: InlineArray<48000, UInt8> = .init(repeating: 0xA5)
    var health = GiftUIOperationalHealth()
    var endpointHealthObservation = GiftUIOperationalHealth()
    var constructedProjection: HostEndpointConfiguration?
    var constructedEndpoints = 0
    var projectionControls = 0
    var envelopeRejections = 0
    var reservations = 0
    var submissions = 0
    var finishes = 0
    var cancellations = 0
    var active = false
    var submittedBytes: UInt32 = 0
    var submittedRows: UInt16 = 0
    init() { for index in 0..<12000 { surface[index * 4 + 3] = 255 } }
}
@inline(never)
private func p08FactoryDefaultQualification() -> Int {
    var checks = 0
    func require(_ value: Bool) { precondition(value); checks += 1 }
    var actual = CounterNativeBackendStorage()
    let original = P08OriginalNativeFactoryStorage()
    for i in 0..<48000 {
        require(actual.surface[i] == original.surface[i])
        require(actual.payload[i] == original.payload[i])
    }
    require(MemoryLayout<CounterNativeBackendStorage>.size == MemoryLayout<P08OriginalNativeFactoryStorage>.size)
    require(MemoryLayout<CounterNativeBackendStorage>.stride == MemoryLayout<P08OriginalNativeFactoryStorage>.stride)
    require(MemoryLayout<CounterNativeBackendStorage>.alignment == MemoryLayout<P08OriginalNativeFactoryStorage>.alignment)
    require(actual.health == original.health && actual.endpointHealthObservation == original.endpointHealthObservation)
    let copy = actual
    actual.surface[0] = 37; actual.payload[0] = 19
    require(copy.surface[0] == original.surface[0] && copy.payload[0] == original.payload[0])
    let admission = CounterAdmissionBacking()
    for i in 0..<2 { require(admission.pendingPointers[i] == nil && admission.sealedPointers[i] == nil) }
    for i in 0..<34 { require(admission.pendingStates[i] == 0 && admission.sealedStates[i] == 0) }
    let snapshot = CounterSemanticSnapshot()
    for i in 0..<22 { require(snapshot.scalars[i] == 0) }
    for i in 0..<4 { require(snapshot.textLengths[i] == 0) }
    let sink = CounterRenderSink()
    for i in 0..<64 { require(sink.glyphRecords[i] == nil) }
    let control = CounterControl()
    for i in 0..<2 { require(control.actionPoints[i] == Point(x: 0, y: 0)) }
    for i in 0..<9 { require(control.cleanupOrder[i] == 255) }
    require(control.lastTakenWakeReasons.rawValue == 0)
    for raw in 0...255 { require(ExecutionWakeReasons(rawValue: UInt8(raw)).rawValue == UInt8(raw) & 7) }
    let sequence = InputSourceSequenceState()
    require(sequence.mode == .synchronized && sequence.sequence == nil && sequence.ordinal == nil)
    let explicit = InputSourceSequenceState(mode: .active, sequence: nil, ordinal: nil)
    require(explicit.mode == .active && explicit.sequence == nil && explicit.ordinal == nil)
    let context = ExecutionContext(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    require(context.cycle == nil && context.semanticRevision == nil && context.candidateFrame == nil && context.phase == .idle)
    return checks
}
