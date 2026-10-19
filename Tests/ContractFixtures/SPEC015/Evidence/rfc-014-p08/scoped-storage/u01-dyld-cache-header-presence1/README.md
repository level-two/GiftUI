# U01 dyld cache format header presence check

Status: **STOP — all three authorized candidates are absent.** This is a
bounded filesystem presence result only. Header applicability remains unproved.

## Candidates

The exact candidate paths were taken from the named Xcode layout in the
81a85ee6 review request:

| Candidate | Result |
| --- | --- |
| `/usr/include/mach-o/dyld_cache_format.h` | absent |
| `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/mach-o/dyld_cache_format.h` | absent |
| `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk/usr/include/mach-o/dyld_cache_format.h` | absent |

## Method and limits

Used Python standard-library `os.path.isfile` checks against only the three
literal paths above. The check completed in under one second. No candidate
file was opened or read; consequently there are no file sizes, SHA-256 values,
or file version data. No search, substitute candidate, header parsing,
compiler, build, test, runtime, controller, decoder, or acquisition was used.

Because every candidate is absent, investigation stops here. This result does
not establish whether another header exists or whether any header applies to
the relevant runtime/cache. R01–R04 and all previously recorded identity gaps
remain open and unchanged.

## Preservation and navigation

This packet is the minimal navigation target for this presence check. The three
existing markers, five pre-existing modified files, and untracked
`scripts/contracts/__pycache__/` were preserved without inspection or change.
The five modified paths observed before the check were:

- `Sources/SignalAnalyzerTargetHost/SignalAnalyzerCycleFailureNormalizer.swift`
- `Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInteractionTargetProjection.swift`
- `firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt`
- `scripts/nrf52840/build.sh`
- `scripts/raspberry-pi/build.sh`
