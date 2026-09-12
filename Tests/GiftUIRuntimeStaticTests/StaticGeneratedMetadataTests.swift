import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIRuntimeStatic
import Testing

@Test
func generatedStaticMetadataBindsDenseSlotsActionsAndCanvasCoverage() {
    let metadata = GeneratedRuntimeMetadata(
        observableSlots: GeneratedObservableSlots(),
        action: GeneratedProfileAction.self,
        canvasTable: GeneratedRuntimeCanvasTable(),
        canvasCoverage: GeneratedCanvasCoverage()
    )

    #expect(metadata?.observableSlots.slotCount == 2)
    #expect(metadata?.observableSlots.structuralIdentity(for: 0) == .primary)
    #expect(metadata?.observableSlots.structuralIdentity(for: 1) == .secondary)
    #expect(metadata?.observableSlots.structuralIdentity(for: 2) == nil)
    #expect(
        metadata?.actionSpecialization.decode(BoundedApplicationAction(code: 1)) == .second
    )
    #expect(metadata?.actionSpecialization.decode(BoundedApplicationAction(code: 2)) == nil)
    #expect(metadata?.callableCaseCount == 3)
    #expect(metadata?.declaredEntryCount == 3)
    #expect(metadata?.maximumDeclaredID == 3)
    #expect(metadata?.coverageMultiplicity(for: 0) == 0)
    #expect(metadata?.coverageMultiplicity(for: 1) == 1)
    #expect(metadata?.coverageMultiplicity(for: 2) == 1)
    #expect(metadata?.coverageMultiplicity(for: 3) == 1)
    #expect(metadata?.coverageMultiplicity(for: 4) == 0)
    #expect(metadata?.captureByteCount(for: 1) == 8)
    #expect(metadata?.captureByteCount(for: 2) == 12)
    #expect(metadata?.captureByteCount(for: 3) == 0)
}

@Test
func generatedStaticCanvasSwitchCoversEveryDeclaredID() throws {
    var table = GeneratedRuntimeCanvasTable()
    let captures = GeneratedCanvasCaptureStorage(
        color: .white,
        firstScalar: 1,
        secondScalar: 2
    )
    let size = Size(width: 3, height: 5)!

    for id: UInt16 in 1 ... 3 {
        try withGeneratedCanvasContext { context in
            try table.invoke(id: id, captures: captures, context: &context, size: size)
        }
        #expect(table.lastInvokedID == id)
    }
    #expect(throws: DrawingError.invariantViolation) {
        try withGeneratedCanvasContext { context in
            try table.invoke(id: 0, captures: captures, context: &context, size: size)
        }
    }
}

private struct GeneratedCanvasContextStorage {}

private let generatedCanvasOperations = _GiftUIDrawingOperations(
    beginPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
    endPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
    movePath: { _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue },
    addLineToPath: { _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue },
    strokePath: { _, _, _, _, _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue }
)

private func withGeneratedCanvasContext<Result>(
    _ body: (inout GraphicsContext) throws -> Result
) throws -> Result {
    var contextStorage = GeneratedCanvasContextStorage()
    return try withUnsafeMutablePointer(to: &contextStorage) { pointer in
        var context = GraphicsContext(
            storage: UnsafeMutableRawPointer(pointer),
            generation: 1,
            operations: generatedCanvasOperations
        )
        return try body(&context)
    }
}
