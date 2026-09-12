// Generated from these checked SPEC-010/SPEC-012 inputs:
// 02831ec5318c786ef899dcae52c0f82910981af79658f4e81bdb45e8645c862b
// fffe5b6f20e9939d6f46809678d0217556c05595003be1089ad7093157497109
// Do not edit independently of the owning generator inputs.

import GiftUI
import GiftUIDrawing
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
