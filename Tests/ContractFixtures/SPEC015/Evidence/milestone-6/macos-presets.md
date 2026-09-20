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
`b85007d4176f2152f52c29b21e252fda0e72fc7a` and run
`b85007d4176f2152f52c29b21e252fda0e72fc7a-451f863b0bdd06df`.
The normalized reports agree on semantic checksum `360515885`, extent
`320x240`, six actions, 32 compact-fact slots, five Canvas occurrences, 202
live points, and 832 plan points. The permitted profile-storage difference is
33,816 bytes Dynamic versus 30,608 bytes Static. Each report records one
startup resolver call; the execution phase performs no further resolution.

Changing the immutable extent requires selecting and validating a fresh preset;
the runner exposes no live reconfiguration path.
