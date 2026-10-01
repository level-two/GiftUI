import GiftUI
import SignalAnalyzerDomain

@ObservableStateHost
package struct SignalAnalyzerView: View {
    @State private var viewModel: SignalAnalyzerViewModel
    private let layout: SignalAnalyzerLayoutConstraints

    package init(
        viewModel: SignalAnalyzerViewModel,
        layout: SignalAnalyzerLayoutConstraints = .reference
    ) {
        self.layout = layout
        _viewModel = State(wrappedValue: viewModel)
    }

    package var body: some View {
        VStack(spacing: 0) {
            SignalAnalyzerHeaderView(
                acquisitionState: viewModel.state.acquisitionState,
                errorMessage: viewModel.state.errorMessage, layout: layout)
            SignalAnalyzerWaveformView(
                capture: viewModel.state.capture,
                visibleRange: viewModel.visibleRange,
                selectedWindow: viewModel.state.visibleWindow,
                layout: layout
            )
        }
        .foregroundStyle(.white)
        .padding(2)
        .background(.black)
    }
}

package struct SignalAnalyzerHeaderView: View {
    package let acquisitionState: AcquisitionState
    package let errorMessage: SignalAnalyzerDiagnostic?
    package let layout: SignalAnalyzerLayoutConstraints

    package var body: some View {
        let controls = SignalAnalyzerControlState(
            acquisitionState: acquisitionState, selectedWindow: .twoSeconds)
        HStack(alignment: .top, spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DIGITAL SIGNAL ANALYZER")
                Text("Four-channel acquisition")
                    .foregroundStyle(.gray)
                Text(errorMessage?.boundedText ?? BoundedText("")!)
                    .foregroundStyle(.red)
                    .frame(height: layout.errorLineHeight, alignment: .leading)
            }
            .frame(width: layout.headerTextWidth, alignment: .leading)
            SignalAnalyzerSquareButton(
                label: controls.recordingLabel, action: controls.recordingAction,
                color: controls.recordingColor, fill: controls.recordingFill,
                size: layout.buttonSize
            )
        }
        .frame(
            height: layout.headerHeight, alignment: Alignment(horizontal: .leading, vertical: .top))
    }
}

package struct SignalAnalyzerWaveformView: View {
    package let layout: SignalAnalyzerLayoutConstraints

    package init(
        capture: SignalCapture, visibleRange: Range<Duration>,
        selectedWindow: VisibleTimeWindow = .twoSeconds,
        layout: SignalAnalyzerLayoutConstraints = .reference
    ) {
        self.capture = capture
        self.visibleRange = visibleRange
        self.selectedWindow = selectedWindow
        self.layout = layout
    }
    package let capture: SignalCapture
    package let visibleRange: Range<Duration>
    package let selectedWindow: VisibleTimeWindow

    package var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            SignalAnalyzerGridView()
                .frame(maxWidth: .points(layout.gridWidth), maxHeight: .points(layout.gridHeight))
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 2) {
                    SignalAnalyzerSquareButton(
                        label: BoundedText("-")!, action: selectedWindow.shorterAction,
                        color: selectedWindow == .oneSecond ? .gray : .white,
                        fill: selectedWindow == .oneSecond
                            ? Color(red: 24, green: 24, blue: 24)
                            : Color(red: 64, green: 64, blue: 64),
                        size: layout.buttonSize, isDisabled: selectedWindow == .oneSecond
                    )
                    SignalAnalyzerTimeRulerView(
                        visibleRange: visibleRange, labelWidth: layout.rulerLabelWidth
                    )
                    .frame(width: layout.traceWidth)
                    SignalAnalyzerSquareButton(
                        label: BoundedText("+")!, action: selectedWindow.longerAction,
                        color: selectedWindow == .fiveSeconds ? .gray : .white,
                        fill: selectedWindow == .fiveSeconds
                            ? Color(red: 24, green: 24, blue: 24)
                            : Color(red: 64, green: 64, blue: 64),
                        size: layout.buttonSize, isDisabled: selectedWindow == .fiveSeconds
                    )
                }
                SignalAnalyzerChannelWaveformView(
                    layout: layout,
                    channelID: SignalChannelID(rawValue: 1),
                    name: BoundedText("CH1")!,
                    capture: capture,
                    visibleRange: visibleRange
                )
                SignalAnalyzerChannelWaveformView(
                    layout: layout,
                    channelID: SignalChannelID(rawValue: 2),
                    name: BoundedText("CH2")!,
                    capture: capture,
                    visibleRange: visibleRange
                )
                SignalAnalyzerChannelWaveformView(
                    layout: layout,
                    channelID: SignalChannelID(rawValue: 3),
                    name: BoundedText("CH3")!,
                    capture: capture,
                    visibleRange: visibleRange
                )
                SignalAnalyzerChannelWaveformView(
                    layout: layout,
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
    package var labelWidth: GeometryScalar = 72

    package var body: some View {
        let labels = SignalAnalyzerRulerLabels(visibleRange: visibleRange)
        HStack(spacing: 2) {
            Text(labels.lowerBound)
                .frame(width: labelWidth)
                .foregroundStyle(.gray)
            Spacer()
            Text(labels.midpoint)
                .frame(width: labelWidth)
                .foregroundStyle(.gray)
            Spacer()
            Text(labels.upperBound)
                .frame(width: labelWidth)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 2)
        .background(SignalAnalyzerSurfaceColor.rulerBackground)
    }
}

package struct SignalAnalyzerChannelWaveformView: View {
    package var layout: SignalAnalyzerLayoutConstraints = .reference
    package let channelID: SignalChannelID
    package let name: BoundedText
    package let capture: SignalCapture
    package let visibleRange: Range<Duration>

    package var body: some View {
        let level = capture.currentLevel(for: channelID)
        HStack(spacing: 2) {
            Text(name)
                .frame(width: layout.labelWidth, alignment: .leading)
            SignalAnalyzerTraceView(
                channelID: channelID,
                capture: capture,
                visibleRange: visibleRange
            )
            .frame(maxWidth: .points(layout.traceWidth), maxHeight: .points(layout.traceHeight))
            Text(level.label)
                .foregroundStyle(level.foregroundColor)
        }

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

package struct SignalAnalyzerSquareButton: View {
    package let label: BoundedText
    package let action: SignalAnalyzerAction
    package let color: Color
    package let fill: Color
    package let size: GeometryScalar
    package var isDisabled = false

    package var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                Text(label)
                    .frame(width: size - 4, height: size - 4)
                    .background(fill)
                    .padding(2)
                    .background(color)
                    .foregroundStyle(color)
            }
            .disabled(isDisabled)
        }
    }

}

package struct SignalAnalyzerControlState: Equatable, Sendable {
    package let recordingLabel: BoundedText
    package let recordingAction: SignalAnalyzerAction
    package let recordingColor: Color
    package let recordingFill: Color
    package let statusText: BoundedText
    package let startDisabled: Bool
    package let stopDisabled: Bool
    package let oneSecondDisabled: Bool
    package let twoSecondsDisabled: Bool
    package let fiveSecondsDisabled: Bool

    package init(acquisitionState: AcquisitionState, selectedWindow: VisibleTimeWindow) {
        let isRecording: Bool
        if case .running = acquisitionState { isRecording = true } else { isRecording = false }
        recordingLabel = BoundedText(isRecording ? "R" : "S")!
        recordingAction = isRecording ? .stop : .start
        recordingColor = isRecording ? .green : Color(red: 255, green: 96, blue: 128)
        recordingFill =
            isRecording ? Color(red: 0, green: 48, blue: 16) : Color(red: 56, green: 16, blue: 32)
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
