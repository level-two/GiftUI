// Generated from these checked SPEC-010/SPEC-012 inputs:
// 02831ec5318c786ef899dcae52c0f82910981af79658f4e81bdb45e8645c862b
// fffe5b6f20e9939d6f46809678d0217556c05595003be1089ad7093157497109
// Do not edit independently of the owning generator inputs.

import GiftUI
import GiftUIDrawing
import GiftUIRuntimeCore
import GiftUIRuntimeStatic

enum GeneratedProfileIdentity: UInt8, Equatable, Sendable {
    case primary = 0
    case secondary = 1
}

struct GeneratedObservableSlots: StaticObservableSlotMetadata {
    let slotCount: UInt16 = 2

    func structuralIdentity(for slot: UInt16) -> GeneratedProfileIdentity? {
        switch slot {
        case 0: .primary
        case 1: .secondary
        default: nil
        }
    }
}

enum GeneratedProfileAction: UInt16, GiftUIAction {
    case first = 0
    case second = 1
}

struct GeneratedCanvasCaptureStorage: Equatable, Sendable {
    let color: Color
    let firstScalar: GeometryScalar
    let secondScalar: GeometryScalar
}

struct GeneratedRuntimeCanvasTable: StaticCanvasCallableTable {
    let callableCaseCount: UInt16 = 3
    private(set) var lastInvokedID: UInt16?

    func captureByteCount(for id: UInt16) -> UInt16? {
        switch id {
        case 1: 8
        case 2: 12
        case 3: 0
        default: nil
        }
    }

    mutating func invoke(
        id: UInt16,
        captures: borrowing GeneratedCanvasCaptureStorage,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        switch id {
        case 1:
            _ = captures.color
            _ = captures.firstScalar
        case 2:
            _ = captures.color
            _ = captures.firstScalar
            _ = captures.secondScalar
        case 3:
            _ = size
        default:
            throw .invariantViolation
        }
        lastInvokedID = id
    }
}

struct GeneratedCanvasCoverage: StaticCanvasCoverageMetadata {
    let declaredEntryCount: UInt16 = 3
    let maximumDeclaredID: UInt16 = 3

    func coverageMultiplicity(for id: UInt16) -> UInt8 {
        switch id {
        case 1, 2, 3: 1
        default: 0
        }
    }
}

typealias GeneratedRuntimeMetadata = StaticGeneratedProfileMetadata<
    GeneratedObservableSlots,
    GeneratedProfileAction,
    GeneratedRuntimeCanvasTable,
    GeneratedCanvasCoverage
>

struct GeneratedStaticRegions: StaticProfileStorageRegions, ~Copyable {
    private var semanticCandidate: UInt8 = 0
    private var semanticPublished: UInt8 = 0
    private var layoutCandidate: UInt8 = 0
    private var renderWorkspace: UInt8 = 0
    private var canvasCallable: UInt8 = 0
    private var pathWorkspace: UInt8 = 0
    private var drawingPlan: UInt8 = 0
    private var observableLive: UInt8 = 0
    private var observableCandidate: UInt8 = 0
    private var interactionCandidate: UInt8 = 0
    private var interactionCommitted: UInt8 = 0
    private var admissionQueue: UInt8 = 0
    private var sealedBatch: UInt8 = 0
    private var pointerState: UInt8 = 0
    private var coordinatorState: UInt8 = 0
    private var failureState: UInt8 = 0

    var byteCounts: RuntimeStorageByteCounts {
        RuntimeStorageByteCounts(
            semanticCandidateBytes: UInt32(MemoryLayout.size(ofValue: semanticCandidate)),
            semanticPublishedBytes: UInt32(MemoryLayout.size(ofValue: semanticPublished)),
            layoutCandidateBytes: UInt32(MemoryLayout.size(ofValue: layoutCandidate)),
            renderWorkspaceBytes: UInt32(MemoryLayout.size(ofValue: renderWorkspace)),
            canvasCallableBytes: UInt32(MemoryLayout.size(ofValue: canvasCallable)),
            pathWorkspaceBytes: UInt32(MemoryLayout.size(ofValue: pathWorkspace)),
            drawingPlanBytes: UInt32(MemoryLayout.size(ofValue: drawingPlan)),
            observableLiveBytes: UInt32(MemoryLayout.size(ofValue: observableLive)),
            observableCandidateBytes: UInt32(MemoryLayout.size(ofValue: observableCandidate)),
            interactionCandidateBytes: UInt32(MemoryLayout.size(ofValue: interactionCandidate)),
            interactionCommittedBytes: UInt32(MemoryLayout.size(ofValue: interactionCommitted)),
            admissionQueueBytes: UInt32(MemoryLayout.size(ofValue: admissionQueue)),
            sealedBatchBytes: UInt32(MemoryLayout.size(ofValue: sealedBatch)),
            pointerStateBytes: UInt32(MemoryLayout.size(ofValue: pointerState)),
            coordinatorStateBytes: UInt32(MemoryLayout.size(ofValue: coordinatorState)),
            failureStateBytes: UInt32(MemoryLayout.size(ofValue: failureState))
        )
    }

    mutating func withRegion<Result>(
        _ family: RuntimeStorageFamily,
        _ body: (UnsafeMutableRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        switch family {
        case .semanticCandidate: return try withUnsafeMutableBytes(of: &semanticCandidate, body)
        case .semanticPublished: return try withUnsafeMutableBytes(of: &semanticPublished, body)
        case .layoutCandidate: return try withUnsafeMutableBytes(of: &layoutCandidate, body)
        case .renderWorkspace: return try withUnsafeMutableBytes(of: &renderWorkspace, body)
        case .canvasCallable: return try withUnsafeMutableBytes(of: &canvasCallable, body)
        case .pathWorkspace: return try withUnsafeMutableBytes(of: &pathWorkspace, body)
        case .drawingPlan: return try withUnsafeMutableBytes(of: &drawingPlan, body)
        case .observableLive: return try withUnsafeMutableBytes(of: &observableLive, body)
        case .observableCandidate: return try withUnsafeMutableBytes(of: &observableCandidate, body)
        case .interactionCandidate:
            return try withUnsafeMutableBytes(of: &interactionCandidate, body)
        case .interactionCommitted:
            return try withUnsafeMutableBytes(of: &interactionCommitted, body)
        case .admissionQueue: return try withUnsafeMutableBytes(of: &admissionQueue, body)
        case .sealedBatch: return try withUnsafeMutableBytes(of: &sealedBatch, body)
        case .pointerState: return try withUnsafeMutableBytes(of: &pointerState, body)
        case .coordinatorState: return try withUnsafeMutableBytes(of: &coordinatorState, body)
        case .failureState: return try withUnsafeMutableBytes(of: &failureState, body)
        }
    }

    mutating func withSemanticRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result {
        try withUnsafeMutableBytes(of: &semanticCandidate) { candidate in
            try withUnsafeMutableBytes(of: &semanticPublished) { published in
                try body(candidate, published)
            }
        }
    }

    mutating func resetAttemptRegions() {
        semanticCandidate = 0
        layoutCandidate = 0
        renderWorkspace = 0
        canvasCallable = 0
        pathWorkspace = 0
        drawingPlan = 0
        observableCandidate = 0
        interactionCandidate = 0
    }

    mutating func resetAllRegions() {
        resetAttemptRegions()
        semanticPublished = 0
        observableLive = 0
        interactionCommitted = 0
        admissionQueue = 0
        sealedBatch = 0
        pointerState = 0
        coordinatorState = 0
        failureState = 0
    }
}
