# Signal Analyzer

A native SwiftUI macOS demo that simulates a four-channel, low-frequency digital signal analyzer. The implementation follows the supplied GiftUI MVP architecture while using SwiftUI for the current presentation layer.

## Run

Open `Package.swift` in Xcode, select the **SignalAnalyzer** scheme and run it on **My Mac**.

From Terminal:

```sh
swift build
swift run SignalAnalyzer
```

Run the test suite with:

```sh
swift test
```

## Architecture

The package targets enforce dependency direction:

```text
SignalAnalyzerApp (composition root)
      ├── SignalAnalyzerPresentation ──► SignalAnalyzerDomain
      └── SignalAnalyzerData ──────────► SignalAnalyzerDomain
```

- **Domain** contains portable signal models, the repository protocol, and use cases.
- **Data** contains the hardware-like source abstraction, deterministic mock source, and main-actor-isolated bounded repository.
- **Presentation** contains the observable main-actor view model and pure SwiftUI waveform rendering.
- **App** is the only target that constructs concrete dependencies.

Signal events and application-level captures are delivered through synchronous source/sink protocols on the main actor. The pipeline uses no locks or asynchronous streams; only the main-actor-isolated mock generator uses `Task.sleep` to simulate hardware timing. The mock keeps deterministic channel patterns and an idempotent start/stop lifecycle. Capture history is capped at 30 seconds by default.
