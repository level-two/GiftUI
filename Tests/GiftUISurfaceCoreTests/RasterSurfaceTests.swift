import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import Testing

@testable import GiftUISurfaceCore

private let surfaceBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 2, height: 2)!
)!
private let onePixelDamage = Rect(
    origin: Point(x: 1, y: 0),
    size: Size(width: 1, height: 1)!
)!
private let surfaceDescriptor = RasterSurfaceDescriptor(
    bounds: surfaceBounds,
    encoding: .rgba8888,
    bytesPerRow: 8,
    realization: .fullSurface,
    regionWidth: 2,
    regionHeight: 2
)!

private func header(
    surface: Rect = surfaceBounds,
    damage: Rect = onePixelDamage
) -> RenderPlanHeader {
    RenderPlanHeader(
        surfaceBounds: surface,
        damageBounds: damage,
        operationCount: 1,
        positionedGlyphCount: 0,
        maximumObservedClipDepth: 1
    )
}

@Test
func recordingSurfaceFinishesOneValidBoundedAttemptAndResets() {
    var surface = RecordingRasterSurface(
        descriptor: surfaceDescriptor,
        writableCapacityBytes: 16
    )
    let pixel = CanonicalEncodedPixel(color: .red, encoding: .rgba8888)

    let began = surface.beginFrame(header())
    let duplicateBegin = surface.beginFrame(header())
    let replaced = surface.replacePixel(at: Point(x: 1, y: 0), with: pixel)
    #expect(began)
    #expect(!duplicateBegin)
    #expect(replaced)
    #expect(
        surface.replacements == [
            RecordedPixelReplacement(point: Point(x: 1, y: 0), pixel: pixel)
        ]
    )
    let finished = surface.finishFrame()
    let duplicateFinish = surface.finishFrame()
    #expect(finished)
    #expect(!duplicateFinish)
    #expect(surface.beginCount == 1)
    #expect(surface.finishCount == 1)
    #expect(surface.discardCount == 0)
    #expect(!surface.presentationResponsibilityAccepted)
    let beganAfterReset = surface.beginFrame(header())
    #expect(beganAfterReset)
}

@Test
func recordingSurfaceRejectsInvalidBeginAndPreTransferReplacement() {
    var undersized = RecordingRasterSurface(
        descriptor: surfaceDescriptor,
        writableCapacityBytes: 15
    )
    var surface = RecordingRasterSurface(
        descriptor: surfaceDescriptor,
        writableCapacityBytes: 16
    )
    let outsideSurface = Rect(
        origin: Point(x: 1, y: 1),
        size: Size(width: 2, height: 1)!
    )!

    let undersizedBegin = undersized.beginFrame(header())
    let outsideBegin = surface.beginFrame(header(damage: outsideSurface))
    let began = surface.beginFrame(header())
    let outsideReplacement = surface.replacePixel(
        at: Point(x: 0, y: 0),
        with: CanonicalEncodedPixel(color: .red, encoding: .rgba8888)
    )
    let wrongEncoding = surface.replacePixel(
        at: Point(x: 1, y: 0),
        with: CanonicalEncodedPixel(color: .red, encoding: .rgb565BigEndian)
    )
    #expect(!undersizedBegin)
    #expect(!outsideBegin)
    #expect(began)
    #expect(!outsideReplacement)
    #expect(!wrongEncoding)
    surface.discardFrame()
    surface.discardFrame()
    #expect(surface.discardCount == 1)
    #expect(surface.replacements.isEmpty)
    let beganAfterDiscard = surface.beginFrame(header())
    #expect(beganAfterDiscard)
}

@Test
func recordingSurfaceResponsibilityIsStickyAndDrainsAfterFault() {
    var surface = RecordingRasterSurface(
        descriptor: surfaceDescriptor,
        writableCapacityBytes: 16
    )

    let acceptedWhileIdle = surface.acceptPresentationResponsibility()
    let began = surface.beginFrame(header())
    let accepted = surface.acceptPresentationResponsibility()
    #expect(!acceptedWhileIdle)
    #expect(began)
    #expect(accepted)
    #expect(surface.presentationResponsibilityAccepted)
    let drainedReplacement = surface.replacePixel(
        at: Point(x: 0, y: 0),
        with: CanonicalEncodedPixel(color: .red, encoding: .rgb565BigEndian)
    )
    #expect(drainedReplacement)
    #expect(surface.drainedValidationFailure)
    #expect(surface.replacements.isEmpty)
    #expect(surface.presentationResponsibilityAccepted)
    let finished = surface.finishFrame()
    #expect(finished)
    #expect(!surface.presentationResponsibilityAccepted)
    #expect(surface.finishCount == 1)
    #expect(surface.discardCount == 0)
}
