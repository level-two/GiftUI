import SignalAnalyzerDomain
import SwiftUI

struct ChannelWaveformInput: Sendable {
    let channel: SignalChannel?
    let transitions: [SignalTransition]
    let visibleRange: Range<Duration>

    init(
        channel: SignalChannel?,
        transitions: [SignalTransition],
        visibleRange: Range<Duration>
    ) {
        self.channel = channel
        self.transitions = transitions
        self.visibleRange = visibleRange
    }
}

struct ChannelWaveformView: View {
    private let input: ChannelWaveformInput
    private let accent: Color

    init(input: ChannelWaveformInput, accent: Color) {
        self.input = input
        self.accent = accent
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(channelName)
                    .foregroundStyle(accent)
                Text(currentLevel == .high ? "HIGH" : "LOW")
                    .foregroundStyle(Color(red: 0.62, green: 0.65, blue: 0.70))
            }
            .frame(width: 54, alignment: .leading)

            Canvas { context, size in
                drawGrid(in: &context, size: size)
                context.stroke(
                    waveformPath(size: size),
                    with: .color(accent),
                    style: StrokeStyle(lineWidth: 2.25, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 11)
        .background(Color(red: 0.079, green: 0.091, blue: 0.113))
    }

    private var channelName: String {
        input.channel?.name ?? "--"
    }

    private var channelTransitions: [SignalTransition] {
        guard let channel = input.channel else { return [] }
        return input.transitions.filter { $0.channelID == channel.id }
    }

    private var currentLevel: DigitalLevel {
        channelTransitions.last?.level ?? .low
    }

    private func waveformPath(size: CGSize) -> Path {
        let lower = input.visibleRange.lowerBound
        let upper = input.visibleRange.upperBound
        let span = max(0.000_001, (upper - lower).secondsValue)
        let inset: CGFloat = 8
        let highY = inset
        let lowY = max(inset, size.height - inset)
        let earlierTransitions = channelTransitions.filter { $0.timestamp <= lower }
        var level = earlierTransitions.last?.level ?? .low
        var path = Path()
        var currentY = level == .high ? highY : lowY
        path.move(to: CGPoint(x: 0, y: currentY))

        for transition in channelTransitions where transition.timestamp > lower && transition.timestamp <= upper {
            let progress = (transition.timestamp - lower).secondsValue / span
            let x = size.width * CGFloat(min(1, max(0, progress)))
            path.addLine(to: CGPoint(x: x, y: currentY))
            level = transition.level
            currentY = level == .high ? highY : lowY
            path.addLine(to: CGPoint(x: x, y: currentY))
        }

        path.addLine(to: CGPoint(x: size.width, y: currentY))
        return path
    }

    private func drawGrid(in context: inout GraphicsContext, size: CGSize) {
        for index in 0...10 {
            let x = size.width * CGFloat(index) / 10
            var line = Path()
            line.move(to: CGPoint(x: x, y: 0))
            line.addLine(to: CGPoint(x: x, y: size.height))
            let color = index % 5 == 0
                ? Color(red: 0.171, green: 0.182, blue: 0.202)
                : Color(red: 0.120, green: 0.132, blue: 0.153)
            context.stroke(line, with: .color(color), lineWidth: 1)
        }

        var center = Path()
        center.move(to: CGPoint(x: 0, y: size.height / 2))
        center.addLine(to: CGPoint(x: size.width, y: size.height / 2))
        context.stroke(
            center,
            with: .color(Color(red: 0.120, green: 0.132, blue: 0.153)),
            lineWidth: 1
        )
    }
}
