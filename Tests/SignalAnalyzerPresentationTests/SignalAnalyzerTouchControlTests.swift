import GiftUI
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Test func recordingToggleReflectsAcquisitionAndSelectsItsNextAction() {
    for (state, label, action) in [
        (AcquisitionState.idle, "S", SignalAnalyzerAction.start),
        (.running, "R", .stop),
        (.stopped, "S", .start),
    ] {
        let controls = SignalAnalyzerControlState(
            acquisitionState: state, selectedWindow: .twoSeconds)
        #expect(controls.recordingLabel == BoundedText(utf8: Array(label.utf8))!)
        #expect(controls.recordingAction == action)
    }
}

@Test func windowSteppersSelectAdjacentDurations() {
    #expect(VisibleTimeWindow.oneSecond.shorterAction == .selectOneSecond)
    #expect(VisibleTimeWindow.oneSecond.longerAction == .selectTwoSeconds)
    #expect(VisibleTimeWindow.twoSeconds.shorterAction == .selectOneSecond)
    #expect(VisibleTimeWindow.twoSeconds.longerAction == .selectFiveSeconds)
    #expect(VisibleTimeWindow.fiveSeconds.shorterAction == .selectTwoSeconds)
    #expect(VisibleTimeWindow.fiveSeconds.longerAction == .selectFiveSeconds)
}

@Test func analyzerReservesFingerSizedSquareControls() {
    for width: GeometryScalar in [240, 320, 480] {
        let layout = SignalAnalyzerLayoutConstraints(width: width, height: 240, lineHeight: 20)
        #expect(layout.buttonSize == 44)
        #expect(layout.labelWidth == layout.buttonSize)
        #expect(layout.headerTextWidth + layout.buttonSize + 8 == width)
        #expect(layout.traceWidth + 2 * layout.buttonSize + 12 == width)
    }
}
