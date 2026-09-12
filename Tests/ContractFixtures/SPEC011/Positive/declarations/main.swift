import GiftUI

enum SignalAnalyzerAction: UInt16, GiftUIAction {
    case start = 0
    case stop = 1
    case clear = 2
    case selectOneSecond = 3
    case selectTwoSeconds = 4
    case selectFiveSeconds = 5
}

struct Controls: View {
    var body: some View {
        VStack {
            VStack {
                Button("Start", action: SignalAnalyzerAction.start)
                Button("Stop", action: SignalAnalyzerAction.stop).disabled(true)
                Button("Clear", action: SignalAnalyzerAction.clear)
            }
            VStack {
                Button("1 s", action: SignalAnalyzerAction.selectOneSecond)
                Button("2 s", action: SignalAnalyzerAction.selectTwoSeconds)
                Button("5 s", action: SignalAnalyzerAction.selectFiveSeconds)
            }
        }
    }
}

func constructControls() -> Controls {
    Controls()
}
