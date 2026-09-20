import GiftUI
import SignalAnalyzerDomain

@ObservableStateHost
package struct SignalAnalyzerView: View {
    @State private var viewModel: SignalAnalyzerViewModel

    package init(viewModel: SignalAnalyzerViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    package var body: some View {
        VStack(spacing: 4) {
            SignalAnalyzerHeaderView(acquisitionState: viewModel.state.acquisitionState)
            SignalAnalyzerWaveformView(
                capture: viewModel.state.capture,
                visibleRange: viewModel.visibleRange
            )
            SignalAnalyzerControlsView(
                acquisitionState: viewModel.state.acquisitionState,
                selectedWindow: viewModel.state.visibleWindow
            )
            if let errorMessage = viewModel.state.errorMessage {
                Text(errorMessage.boundedText)
                    .foregroundStyle(.red)
            }
        }
        .padding(4)
        .background(.black)
    }
}

package struct SignalAnalyzerHeaderView: View {
    package let acquisitionState: AcquisitionState

    package var body: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DIGITAL SIGNAL ANALYZER")
                    .foregroundStyle(.white)
                Text("Four-channel acquisition")
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text(acquisitionState.statusText)
                .foregroundStyle(acquisitionState.statusColor)
                .padding(2)
                .background(SignalAnalyzerSurfaceColor.statusBackground)
        }
    }
}

package struct SignalAnalyzerWaveformView: View {
    package let capture: SignalCapture
    package let visibleRange: Range<Duration>

    package var body: some View {
        ZStack {
            SignalAnalyzerGridView()
                .frame(width: 200, height: 100)
            VStack(spacing: 2) {
                SignalAnalyzerTimeRulerView(visibleRange: visibleRange)
                SignalAnalyzerChannelWaveformView(
                    channelID: SignalChannelID(rawValue: 1),
                    name: BoundedText("CH1")!,
                    capture: capture,
                    visibleRange: visibleRange
                )
                SignalAnalyzerChannelWaveformView(
                    channelID: SignalChannelID(rawValue: 2),
                    name: BoundedText("CH2")!,
                    capture: capture,
                    visibleRange: visibleRange
                )
                SignalAnalyzerChannelWaveformView(
                    channelID: SignalChannelID(rawValue: 3),
                    name: BoundedText("CH3")!,
                    capture: capture,
                    visibleRange: visibleRange
                )
                SignalAnalyzerChannelWaveformView(
                    channelID: SignalChannelID(rawValue: 4),
                    name: BoundedText("CH4")!,
                    capture: capture,
                    visibleRange: visibleRange
                )
            }
        }
        .frame(minHeight: 80, maxHeight: .infinity)
        .padding(2)
        .background(SignalAnalyzerSurfaceColor.waveformBackground)
    }
}

package struct SignalAnalyzerTimeRulerView: View {
    package let visibleRange: Range<Duration>

    package var body: some View {
        let labels = SignalAnalyzerRulerLabels(visibleRange: visibleRange)
        HStack(spacing: 2) {
            Text(labels.lowerBound)
                .foregroundStyle(.gray)
            Spacer()
            Text(labels.midpoint)
                .foregroundStyle(.gray)
            Spacer()
            Text(labels.upperBound)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 2)
        .background(SignalAnalyzerSurfaceColor.rulerBackground)
    }
}

package struct SignalAnalyzerChannelWaveformView: View {
    package let channelID: SignalChannelID
    package let name: BoundedText
    package let capture: SignalCapture
    package let visibleRange: Range<Duration>

    package var body: some View {
        let level = capture.currentLevel(for: channelID)
        HStack(spacing: 2) {
            Text(name)
                .foregroundStyle(.white)
            SignalAnalyzerTraceView(
                channelID: channelID,
                capture: capture,
                visibleRange: visibleRange
            )
            .frame(width: 120, height: 16)
            Text(level.label)
                .foregroundStyle(level.foregroundColor)
        }
        .padding(.vertical, 1)
        .background(SignalAnalyzerSurfaceColor.channelRowBackground)
    }
}

package struct SignalAnalyzerGridView: View {
    package var body: some View {
        makeSignalAnalyzerGridCanvas()
    }
}

package struct SignalAnalyzerTraceView: View {
    package let channelID: SignalChannelID
    package let capture: SignalCapture
    package let visibleRange: Range<Duration>

    package var body: some View {
        makeSignalAnalyzerTraceCanvas(
            channelID: channelID,
            capture: capture,
            visibleRange: visibleRange
        )
    }
}

package func makeSignalAnalyzerGridCanvas() -> Canvas {
    Canvas { (context, size) throws(DrawingError) in
        try drawSignalAnalyzerGrid(context: &context, size: size)
    }
}

package func makeSignalAnalyzerTraceCanvas(
    channelID: SignalChannelID,
    capture: SignalCapture,
    visibleRange: Range<Duration>
) -> Canvas {
    Canvas { (context, size) throws(DrawingError) in
        try drawSignalAnalyzerTrace(
            context: &context,
            size: size,
            channelID: channelID,
            capture: capture,
            visibleRange: visibleRange
        )
    }
}

package func drawSignalAnalyzerGrid(
    context: inout GraphicsContext,
    size: Size
) throws(DrawingError) {
    guard size.width > 0, size.height > 0 else { throw .invalidValue }
    try context.withPath { (context, path) throws(DrawingError) in
        for index in 0 ... 10 {
            let x = GeometryScalar(Int64(size.width) * Int64(index) / 10)
            try path.move(to: Point(x: x, y: 0))
            try path.addLine(to: Point(x: x, y: size.height))
        }
        let centerY = size.height / 2
        try path.move(to: Point(x: 0, y: centerY))
        try path.addLine(to: Point(x: size.width, y: centerY))
        try context.stroke(path, with: .color(.gray), lineWidth: 1)
    }
}

package func drawSignalAnalyzerTrace(
    context: inout GraphicsContext,
    size: Size,
    channelID: SignalChannelID,
    capture: SignalCapture,
    visibleRange: Range<Duration>
) throws(DrawingError) {
    guard size.width > 0, size.height >= 4 else { throw .invalidValue }
    var level = SignalAnalyzerWaveformGeometry.startingLevel(
        capture: capture,
        channelID: channelID,
        visibleLowerBound: visibleRange.lowerBound
    )
    try context.withPath { (context, path) throws(DrawingError) in
        try path.move(
            to: Point(
                x: 0,
                y: SignalAnalyzerWaveformGeometry.y(for: level, height: size.height)
            )
        )
        for transition in capture.transitions
        where transition.channelID == channelID
            && transition.timestamp > visibleRange.lowerBound
            && transition.timestamp <= visibleRange.upperBound
        {
            let x = SignalAnalyzerWaveformGeometry.x(
                for: transition.timestamp,
                visibleRange: visibleRange,
                width: size.width
            )
            try path.addLine(
                to: Point(
                    x: x,
                    y: SignalAnalyzerWaveformGeometry.y(for: level, height: size.height)
                )
            )
            level = transition.level
            try path.addLine(
                to: Point(
                    x: x,
                    y: SignalAnalyzerWaveformGeometry.y(for: level, height: size.height)
                )
            )
        }
        try path.addLine(
            to: Point(
                x: size.width,
                y: SignalAnalyzerWaveformGeometry.y(for: level, height: size.height)
            )
        )
        try context.stroke(path, with: .color(.green), lineWidth: 1)
    }
}

package struct SignalAnalyzerControlsView: View {
    package let acquisitionState: AcquisitionState
    package let selectedWindow: VisibleTimeWindow

    package var body: some View {
        let controlState = SignalAnalyzerControlState(
            acquisitionState: acquisitionState,
            selectedWindow: selectedWindow
        )
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Button("Start", action: SignalAnalyzerAction.start)
                    .foregroundStyle(.white)
                    .disabled(controlState.startDisabled)
                Button("Stop", action: SignalAnalyzerAction.stop)
                    .foregroundStyle(.white)
                    .disabled(controlState.stopDisabled)
                Button("Clear", action: SignalAnalyzerAction.clear)
                    .foregroundStyle(.white)
            }
            HStack(spacing: 4) {
                Button("1 s", action: SignalAnalyzerAction.selectOneSecond)
                    .foregroundStyle(.white)
                    .disabled(controlState.oneSecondDisabled)
                Button("2 s", action: SignalAnalyzerAction.selectTwoSeconds)
                    .foregroundStyle(.white)
                    .disabled(controlState.twoSecondsDisabled)
                Button("5 s", action: SignalAnalyzerAction.selectFiveSeconds)
                    .foregroundStyle(.white)
                    .disabled(controlState.fiveSecondsDisabled)
            }
        }
        .padding(2)
        .background(SignalAnalyzerSurfaceColor.controlsBackground)
    }
}

package struct SignalAnalyzerControlState: Equatable, Sendable {
    package let statusText: BoundedText
    package let startDisabled: Bool
    package let stopDisabled: Bool
    package let oneSecondDisabled: Bool
    package let twoSecondsDisabled: Bool
    package let fiveSecondsDisabled: Bool

    package init(acquisitionState: AcquisitionState, selectedWindow: VisibleTimeWindow) {
        switch acquisitionState {
        case .idle:
            statusText = BoundedText("READY")!
            startDisabled = false
            stopDisabled = true
        case .running:
            statusText = BoundedText("RUNNING")!
            startDisabled = true
            stopDisabled = false
        case .stopped:
            statusText = BoundedText("STOPPED")!
            startDisabled = false
            stopDisabled = true
        case .failed:
            statusText = BoundedText("FAILED")!
            startDisabled = false
            stopDisabled = true
        }
        oneSecondDisabled = selectedWindow == .oneSecond
        twoSecondsDisabled = selectedWindow == .twoSeconds
        fiveSecondsDisabled = selectedWindow == .fiveSeconds
    }
}

private extension AcquisitionState {
    var statusText: BoundedText {
        switch self {
        case .idle: BoundedText("READY")!
        case .running: BoundedText("RUNNING")!
        case .stopped: BoundedText("STOPPED")!
        case .failed: BoundedText("FAILED")!
        }
    }

    var statusColor: Color {
        switch self {
        case .failed: .red
        case .running: .green
        case .idle, .stopped: .white
        }
    }
}

private extension DigitalLevel {
    var label: BoundedText {
        switch self {
        case .low: BoundedText("LOW")!
        case .high: BoundedText("HIGH")!
        }
    }

    var foregroundColor: Color {
        switch self {
        case .low: SignalAnalyzerSurfaceColor.channelLow
        case .high: .green
        }
    }
}

private enum SignalAnalyzerSurfaceColor {
    static let channelLow = Color(red: 0, green: 128, blue: 255)
    static let waveformBackground = Color(red: 16, green: 16, blue: 16)
    static let statusBackground = Color(red: 32, green: 32, blue: 32)
    static let controlsBackground = Color(red: 48, green: 48, blue: 48)
    static let rulerBackground = Color(red: 24, green: 24, blue: 24)
    static let channelRowBackground = Color(red: 8, green: 8, blue: 8)
}

package extension SignalCapture {
    func currentLevel(for channelID: SignalChannelID) -> DigitalLevel {
        var result = baselineLevel(for: channelID)
        for transition in transitions where transition.channelID == channelID {
            result = transition.level
        }
        return result
    }
}
