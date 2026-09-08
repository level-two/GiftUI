import GiftUI
import Testing

@testable import GiftUIExecution

private struct CaptureIdentity: Equatable, Sendable {
    let rawValue: UInt16
}

private struct CaptureActionView: ExecutionActionView {
    let hitIdentity: CaptureIdentity?
    let registeredIdentity: CaptureIdentity?
    let generation: ActionGeneration?
    let enabled: Bool?

    func generation(for identity: CaptureIdentity) -> ActionGeneration? {
        identity == registeredIdentity ? generation : nil
    }

    func isEnabled(_ identity: CaptureIdentity) -> Bool? {
        identity == registeredIdentity ? enabled : nil
    }

    func hit(at point: Point) -> CaptureIdentity? {
        point == Point(x: 4, y: 7) ? hitIdentity : nil
    }
}

private let capturePoint = Point(x: 4, y: 7)
private let firstIdentity = CaptureIdentity(rawValue: 1)
private let otherIdentity = CaptureIdentity(rawValue: 2)
private let firstGeneration = ActionGeneration(rawValue: 3)
private let laterGeneration = ActionGeneration(rawValue: 4)

private func view(
    hit: CaptureIdentity? = firstIdentity,
    registered: CaptureIdentity? = firstIdentity,
    generation: ActionGeneration? = firstGeneration,
    enabled: Bool? = true
) -> CaptureActionView {
    CaptureActionView(
        hitIdentity: hit,
        registeredIdentity: registered,
        generation: generation,
        enabled: enabled
    )
}

@Test
func downCapturesOnlyExactCurrentEnabledRecord() {
    var capture = PointerActionCapture<CaptureIdentity>()
    let captured = capture.captureDown(at: capturePoint, actionView: view())
    #expect(captured)
    #expect(
        capture.captured
            == CapturedAction(
                identity: firstIdentity,
                generation: firstGeneration
            )
    )

    let rejectedViews = [
        view(hit: nil),
        view(registered: otherIdentity),
        view(generation: nil),
        view(enabled: false),
        view(enabled: nil),
    ]
    for rejected in rejectedViews {
        let accepted = capture.captureDown(
            at: capturePoint,
            actionView: rejected
        )
        #expect(!accepted)
        #expect(capture.captured == nil)
    }
}

@Test
func movementCancellationClearsCaptureWithoutCandidate() {
    var capture = PointerActionCapture<CaptureIdentity>()
    let captured = capture.captureDown(at: capturePoint, actionView: view())
    #expect(captured)
    capture.cancelForMovement()
    #expect(capture.captured == nil)
    let candidate = capture.release(
        at: capturePoint,
        provenanceValid: true,
        generationUnambiguous: true,
        actionView: view()
    )
    #expect(candidate == nil)
}

@Test
func releaseFormsCandidateOnlyAfterCompleteRevalidation() {
    var capture = PointerActionCapture<CaptureIdentity>()
    let captured = capture.captureDown(at: capturePoint, actionView: view())
    #expect(captured)
    let candidate = capture.release(
        at: capturePoint,
        provenanceValid: true,
        generationUnambiguous: true,
        actionView: view()
    )
    #expect(
        candidate
            == CapturedAction(
                identity: firstIdentity,
                generation: firstGeneration
            )
    )
    #expect(capture.captured == nil)
}

@Test
func unrelatedCommitPreservesStableIdentityGenerationCapture() {
    var capture = PointerActionCapture<CaptureIdentity>()
    let captured = capture.captureDown(at: capturePoint, actionView: view())
    #expect(captured)

    let unrelatedCommitView = view()
    let candidate = capture.release(
        at: capturePoint,
        provenanceValid: true,
        generationUnambiguous: true,
        actionView: unrelatedCommitView
    )
    #expect(candidate != nil)
}

@Test
func everyReleaseInvalidationCancelsWithoutRetargeting() {
    let invalidCases: [(Bool, Bool, CaptureActionView)] = [
        (false, true, view()),
        (true, false, view()),
        (true, true, view(hit: nil)),
        (true, true, view(hit: otherIdentity, registered: otherIdentity)),
        (true, true, view(generation: laterGeneration)),
        (true, true, view(generation: nil)),
        (true, true, view(enabled: false)),
        (true, true, view(enabled: nil)),
    ]

    for (provenance, unambiguous, currentView) in invalidCases {
        var capture = PointerActionCapture<CaptureIdentity>()
        let captured = capture.captureDown(
            at: capturePoint,
            actionView: view()
        )
        #expect(captured)
        let candidate = capture.release(
            at: capturePoint,
            provenanceValid: provenance,
            generationUnambiguous: unambiguous,
            actionView: currentView
        )
        #expect(candidate == nil)
        #expect(capture.captured == nil)
    }
}

@Test
func aNewDownClearsOlderCaptureBeforeHitResolution() {
    var capture = PointerActionCapture<CaptureIdentity>()
    let firstCapture = capture.captureDown(
        at: capturePoint,
        actionView: view()
    )
    let secondCapture = capture.captureDown(
        at: Point(x: 0, y: 0),
        actionView: view()
    )
    #expect(firstCapture)
    #expect(!secondCapture)
    #expect(capture.captured == nil)
}
