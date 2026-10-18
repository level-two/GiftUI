import GiftUI
import SignalAnalyzerDomain

// P02 declaration syntax from SA01/02/14: typed nested state/capture access.
// Full application migration and capture ownership remain P03/P06/P09.
package struct AnalyzerReadProbe: View {
    package let model: SignalAnalyzerViewModel
    @usableFromInline
    package let index: Int
    package init(model: SignalAnalyzerViewModel, index: Int) { self.model = model; self.index = index }
    package var body: some View {
        let state = model.state
        Text(state.acquisitionState == .running ? "RUNNING" : "STOPPED")
        Text(BoundedText(Int32(model.state.capture.count)))
        if model.state.capture.count > 0 {
            Text(BoundedText(Int32(model.state.capture.transition(index).channelID.rawValue)))
        }
    }
}
