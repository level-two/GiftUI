import SignalAnalyzerDomain
import SwiftUI

struct WaveformView: View {
    private let capture: SignalCapture
    private let visibleRange: Range<Duration>

    private let accents: [Color] = [
        Color(red: 0.27, green: 0.92, blue: 0.73),
        Color(red: 0.35, green: 0.69, blue: 1.0),
        Color(red: 0.77, green: 0.53, blue: 1.0),
        Color(red: 1.0, green: 0.61, blue: 0.31)
    ]

    init(capture: SignalCapture, visibleRange: Range<Duration>) {
        self.capture = capture
        self.visibleRange = visibleRange
    }

    var body: some View {
        VStack(spacing: 0) {
            timeRuler

            channelView(at: 0, accent: accents[0])
            channelView(at: 1, accent: accents[1])
            channelView(at: 2, accent: accents[2])
            channelView(at: 3, accent: accents[3])
        }
        .background(Color(red: 0.055, green: 0.068, blue: 0.09))
    }

    private var timeRuler: some View {
        HStack {
            Text("LOGIC")
                .foregroundStyle(Color(red: 0.62, green: 0.65, blue: 0.70))
                .frame(width: 54, alignment: .leading)

            HStack {
                Text(timeLabel(visibleRange.lowerBound))
                Spacer()
                Text(timeLabel(midpoint))
                Spacer()
                Text(timeLabel(visibleRange.upperBound))
            }
            .foregroundStyle(Color(red: 0.62, green: 0.65, blue: 0.70))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color(red: 0.046, green: 0.057, blue: 0.076))
    }

    private func channelView(at index: Int, accent: Color) -> some View {
        ChannelWaveformView(
            input: ChannelWaveformInput(
                channel: channel(at: index),
                transitions: capture.transitions,
                baselineLevel: baselineLevel(at: index),
                visibleRange: visibleRange
            ),
            accent: accent
        )
        .frame(maxHeight: .infinity)
    }

    private func channel(at index: Int) -> SignalChannel? {
        guard capture.channels.indices.contains(index) else { return nil }
        return capture.channels[index]
    }

    private func baselineLevel(at index: Int) -> DigitalLevel {
        guard let channel = channel(at: index) else { return .low }
        return capture.baselineLevel(for: channel.id)
    }

    private var midpoint: Duration {
        visibleRange.lowerBound + (visibleRange.upperBound - visibleRange.lowerBound) / 2
    }

    private func timeLabel(_ duration: Duration) -> String {
        String(format: "%.2f s", duration.secondsValue)
    }
}
