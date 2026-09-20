# SPEC-015 Milestone 6 — macOS Dynamic and Static Presets

Evidence kind: `host-execution`

The two executable products consume the checked-in generated presets, validate
the complete 18-role graph, run the exact profile storage audit, resolve the
four capability contributions exactly once, check the endpoint projection, and
exercise the common 20-fact semantic script through the production Dynamic and
Static admission owners.

Reproduce from the repository root:

```sh
swift build --disable-sandbox --product SignalAnalyzerMacOSDynamic
swift build --disable-sandbox --product SignalAnalyzerMacOSStatic
.build/debug/SignalAnalyzerMacOSDynamic
.build/debug/SignalAnalyzerMacOSStatic
swift test --disable-sandbox --filter macOSHardwareFreePresets
```

The immutable reports are bound to repository revision
`4035e46ed44e36fccf0fa160185f28a442257826` and run
`4035e46ed44e36fccf0fa160185f28a442257826-e5b156c796a8714d`.
The normalized reports agree on semantic checksum `360515885`, extent
`320x240`, six actions, 32 compact-fact slots, five Canvas occurrences, 202
live points, and 832 plan points. The permitted profile-storage difference is
41,376 bytes Dynamic versus 36,368 bytes Static. Each report records one
startup resolver call; the execution phase performs no further resolution.

Changing the immutable extent requires selecting and validating a fresh preset;
the runner exposes no live reconfiguration path.
