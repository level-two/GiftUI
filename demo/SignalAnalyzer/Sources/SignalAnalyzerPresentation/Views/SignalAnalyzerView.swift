import SignalAnalyzerDomain
import SwiftUI

package struct SignalAnalyzerView: View {
    @State private var viewModel: SignalAnalyzerViewModel

    package init(viewModel: SignalAnalyzerViewModel) {
        _viewModel = State(initialValue: viewModel)
        viewModel.startObserving()
    }

    package var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.043, blue: 0.06)

            VStack(spacing: 18) {
                header
                WaveformView(
                    capture: viewModel.state.capture,
                    visibleRange: viewModel.visibleRange
                )
                controls
                Text(errorText)
                    .foregroundStyle(.red)
            }
            .padding(24)
        }
        .frame(minWidth: 820, minHeight: 570)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DIGITAL SIGNAL ANALYZER")
                    .foregroundStyle(Color(red: 0.42, green: 0.86, blue: 0.77))
                Text("Four-channel acquisition")
            }

            Spacer()

            statusPill
        }
    }

    private var statusPill: some View {
        HStack(spacing: 9) {
            Text("●")
                .foregroundStyle(statusColor)
            Text(statusText.uppercased())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color(red: 0.093, green: 0.100, blue: 0.116))
    }

    private var controls: some View {
        HStack(spacing: 12) {
            controlButton("Start", tint: Color(red: 0.20, green: 0.68, blue: 0.54)) {
                viewModel.startTapped()
            }
            .disabled(statusIsRunning)

            controlButton("Stop", tint: Color(red: 0.82, green: 0.34, blue: 0.37)) {
                viewModel.stopTapped()
            }
            .disabled(!statusIsRunning)

            controlButton("Clear", tint: Color(red: 0.62, green: 0.65, blue: 0.70)) {
                viewModel.clearTapped()
            }

            Spacer()

            Text("WINDOW")
                .foregroundStyle(Color(red: 0.62, green: 0.65, blue: 0.70))

            Button("1 s") {
                viewModel.visibleDurationChanged(.oneSecond)
            }
            .disabled(viewModel.state.visibleWindow == .oneSecond)

            Button("2 s") {
                viewModel.visibleDurationChanged(.twoSeconds)
            }
            .disabled(viewModel.state.visibleWindow == .twoSeconds)

            Button("5 s") {
                viewModel.visibleDurationChanged(.fiveSeconds)
            }
            .disabled(viewModel.state.visibleWindow == .fiveSeconds)
        }
        .padding(14)
        .background(Color(red: 0.078, green: 0.086, blue: 0.102))
    }

    private func controlButton(
        _ title: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .frame(minWidth: 70)
                .foregroundStyle(tint)
        }
    }

    private var errorText: String {
        viewModel.state.errorMessage.map { "Acquisition error: \($0)" } ?? ""
    }

    private var statusIsRunning: Bool {
        viewModel.state.acquisitionState == .running
    }

    private var statusText: String {
        switch viewModel.state.acquisitionState {
        case .idle: "Ready"
        case .running: "Running"
        case .stopped: "Stopped"
        case .failed: "Failed"
        }
    }

    private var statusColor: Color {
        switch viewModel.state.acquisitionState {
        case .idle: Color(red: 0.62, green: 0.65, blue: 0.70)
        case .running: Color(red: 0.25, green: 0.95, blue: 0.66)
        case .stopped: Color(red: 1.0, green: 0.68, blue: 0.25)
        case .failed: .red
        }
    }
}
