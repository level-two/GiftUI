import GiftUITextResources
import GiftUI
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUISemanticCore

// Bounded observations copied from actual traversal, never fed back as topology.
struct CounterSemanticSnapshot: Equatable {
    var scalars: InlineArray<22, UInt32> = .init(repeating: 0)
    var scalarCount: UInt16 = 0
    var textLengths: InlineArray<4, UInt16> = .init(repeating: 0)
    var texts: UInt16 = 0
    var disabledMask: UInt8 = 0
    var disabledCount: UInt8 = 0
    var canvasOrigin = Point(x: 0, y: 0)
    static func == (left: Self, right: Self) -> Bool {
        guard left.scalarCount == right.scalarCount && left.texts == right.texts && left.disabledMask == right.disabledMask && left.disabledCount == right.disabledCount && left.canvasOrigin == right.canvasOrigin else { return false }
        for index in 0..<22 { if left.scalars[index] != right.scalars[index] { return false } }
        for index in 0..<4 { if left.textLengths[index] != right.textLengths[index] { return false } }
        return true
    }
    init() {}
    init(_ bank: borrowing SemanticRecordView<CounterPayload>) {
        for index: UInt16 in 0..<bank.recordCount {
            let record = bank.record(bank.reference(at: index)!)!
            guard let payload = bank.payload(at: record.payload) else { continue }
            switch payload {
            case .standard(.text):
                counterCorpusExpect(texts < 4 && scalarCount + record.textScalarCount <= 22)
                textLengths[Int(texts)] = record.textScalarCount; texts += 1
                for offset: UInt16 in 0..<record.textScalarCount {
                    scalars[Int(scalarCount)] = bank.scalar(at: record.firstTextScalar + offset)!
                    scalarCount += 1
                }
            case .standard(.disabled(let disabled)):
                counterCorpusExpect(disabledCount < 2)
                if disabled { disabledMask |= 1 << disabledCount }
                disabledCount += 1
            default: break
            }
        }
    }
}

func counterCheckHostFrame(_ control: borrowing CounterControl, value: UInt8) -> Int {
    let snapshot = control.semanticSnapshot
    let frame = control.lastFrame
    let frameActive = control.frameActive
    let sealActive = control.runtime.admission.sealActive
    let pointerCount = control.runtime.admission.pointerCount
    let finalized = !frameActive && !sealActive && pointerCount == 0
    counterCorpusExpect(snapshot.texts == 4 && snapshot.scalarCount == 22 && snapshot.disabledCount == 2)
    let lengths: InlineArray<4, UInt16> = [7, 1, 9, 5]
    let expected: InlineArray<22, UInt32> = [67,111,117,110,116,101,114,UInt32(48 + value),73,110,99,114,101,109,101,110,116,82,101,115,101,116]
    for i in 0..<4 { counterCorpusExpect(snapshot.textLengths[i] == lengths[i]) }
    for i in 0..<22 { counterCorpusExpect(snapshot.scalars[i] == expected[i]) }
    // Catalogue advances give widths60/10/74/41. VStack centers them in74,
    // with20px lines and4px gaps: baselines16/40/64/88, Canvas origin13/96.
    let glyphIDs: InlineArray<22, UInt16> = [3, 43, 49, 42, 48, 31, 46, 56, 9, 42, 29, 46, 31, 41, 31, 42, 48, 18, 31, 47, 31, 48]
    let digits: InlineArray<10, UInt16> = [56, 57, 58, 59, 60, 61, 62, 63, 64, 65]
    let advances: InlineArray<22, GeometryScalar> = [12, 10, 9, 9, 5, 9, 6, 10, 4, 9, 9, 6, 9, 14, 9, 9, 5, 10, 9, 8, 9, 5]
    var ordinal = 0
    let digitAdvance: GeometryScalar = value == 1 ? 7 : value == 7 ? 9 : 10
    let starts: InlineArray<4, GeometryScalar> = [7, (74 - digitAdvance) / 2, 0, 16]
    for line in 0..<4 {
        var x = starts[line]
        for _ in 0..<Int(lengths[line]) {
            let glyph = frame.glyphRecords[ordinal]!
            counterCorpusExpect(glyph.glyph.rawValue == (ordinal == 7 ? digits[Int(value)] : glyphIDs[ordinal]))
            counterCorpusExpect(glyph.baseline == Point(x: x, y: 16 + GeometryScalar(line) * 24))
            x += ordinal == 7 ? digitAdvance : advances[ordinal]; ordinal += 1
        }
    }
    counterCorpusExpect(snapshot.disabledMask == (value == 0 ? 2 : value == 9 ? 1 : 0))
    counterCorpusExpect(frame.glyphs == 22 && frame.finishes == 1 && frame.discards == 0)
    counterCorpusExpect(frame.strokes == (value == 0 ? 0 : 1))
    if value > 0 {
        counterCorpusExpect(frame.firstPoint == Point(x: 17, y: 104))
        counterCorpusExpect(frame.secondPoint == Point(x: 17 + 4 * GeometryScalar(value), y: 104))
    }
    counterCorpusExpect(finalized)
    var checks = 76 + (value > 0 ? 2 : 0)
    #if !hasFeature(Embedded)
    checks += counterCheckPixels(control, value: value)
    #endif
    return checks
}

// Selected scoped and ordinary owned hosts share this exact independent oracle.
// Source/input callback delivery uses the coordinator's same admission owner.
// The callback owns no model alias/ticket, performs no body read or mutation.
func counterHostCorpus<H: MVPHostInstance & ~Copyable & ~Escapable>(host: inout H, control: UnsafeMutablePointer<CounterControl>) -> Int where H.OwnerFailure == RuntimeOwnerFailure {
    var checks = counterCheckHostFrame(control.pointee, value: 0)
    var admission = CounterAdmission(borrowing: control)
    var sequence: UInt32 = 0
    var timestamp = control.pointee.wakeClockMicroseconds
    let wakeControl = CounterHostControl(pointer: control)
    // Rejected physical input must never reach the coordinator's admission queue.
    let firstRevision = control.pointee.runtime.committedPresentation!
    counterCorpusExpect(control.pointee.inputGate.inputIsEligible)
    for (source, revision, malformed, reason) in [
        (InputSourceID(rawValue: 1), Optional(firstRevision), false, HostNormalizedInputRejection.unknownSource),
        (InputSourceID(rawValue: 0), nil, false, .stalePresentation),
        (InputSourceID(rawValue: 0), Optional(firstRevision), true, .malformed),
    ] {
        let rejected = control.pointee.inputGate.submit(phase: .down, position: .init(x: 0, y: 0), source: source, observedPresentationRevision: revision, isMalformed: malformed, priorPhysicalSequenceIsComplete: true, to: &admission)
        counterCorpusExpect(rejected == .dropped(reason))
        counterCorpusExpect(control.pointee.runtime.admission.pointerCount == 0)
        checks += 2
    }
    checks += 1
    func click(_ code: Int, expected: UInt8, changed: Bool) {
        let revision = control.pointee.runtime.committedPresentation!
        let applied = control.pointee.applied
        let point = control.pointee.actionPoints[code]
        let down = control.pointee.inputGate.submit(phase: .down, position: point, source: .init(rawValue: 0), observedPresentationRevision: revision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
        let up = control.pointee.inputGate.submit(phase: .up, position: point, source: .init(rawValue: 0), observedPresentationRevision: revision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
        guard case .queued(let downEvent) = down, case .queued(let upEvent) = up else { preconditionFailure("counter physical input gate") }
        counterCorpusExpect(downEvent.sequence.rawValue == sequence && downEvent.ordinal.rawValue == 0 && downEvent.presentationRevision == revision)
        counterCorpusExpect(upEvent.sequence == downEvent.sequence && upEvent.ordinal.rawValue == 1 && upEvent.presentationRevision == revision)
        timestamp += 250000
        guard case .cycle(.admittedWork, .cycle(.success(let summary))) = counterServiceHost(at: timestamp, host: &host, control: wakeControl) else { preconditionFailure("counter actual paced host typed action") }
        counterCorpusExpect(summary.admission.inputEventCount == 2 && summary.admission.semanticActionCount == (changed ? 1 : 0))
        counterCorpusExpect(control.pointee.applied == applied + (changed ? 1 : 0))
        counterCorpusExpect(control.pointee.runtime.pointer.capture.current == nil)
        checks += 5 + counterCheckHostFrame(control.pointee, value: expected)
        sequence += 1
    }
    click(1, expected: 0, changed: false)
    for value: UInt8 in 1...9 { click(0, expected: value, changed: true) }
    click(0, expected: 9, changed: false)
    click(1, expected: 0, changed: true)
    click(1, expected: 0, changed: false)
    return checks + counterWakeControls(host: &host, control: control)
}

private func counterCorpusExpect(_ condition: Bool, file: StaticString = #fileID, line: UInt = #line) {
    if !condition {
    #if !hasFeature(Embedded)
    print("counter host corpus assertion", file, line)
    #endif
    preconditionFailure("counter corpus") }
}
