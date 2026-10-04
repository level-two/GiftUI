# Step 15 — Specific conditional-removal candidates

The guard review now has an actual isolated source-selection experiment,
rather than a request to investigate arbitrary directives.

## Primary bounded candidate: 15 whole-file Embedded guards

The following files are selected by nRF CMake and currently wrapped in a
single outer `#if GIFTUI_NRF_EMBEDDED`. The prototype unwraps exactly that
outer guard in copied files and leaves every nested/interior guard intact:

- `StaticSignalAnalyzerNRFCommonLayoutPass.swift`
- `StaticSignalAnalyzerNRFCommonLayoutWorkspace.swift`
- `StaticSignalAnalyzerNRFEmbeddedActionDispatcher.swift`
- `StaticSignalAnalyzerNRFEmbeddedCanvasPayload.swift`
- `StaticSignalAnalyzerNRFEmbeddedCanvasSource.swift`
- `StaticSignalAnalyzerNRFEmbeddedCountingSink.swift`
- `StaticSignalAnalyzerNRFEmbeddedGestureSession.swift`
- `StaticSignalAnalyzerNRFEmbeddedInputHandler.swift`
- `StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences.swift`
- `StaticSignalAnalyzerNRFEmbeddedInteractionOwner.swift`
- `StaticSignalAnalyzerNRFEmbeddedLayoutAdapters.swift`
- `StaticSignalAnalyzerNRFEmbeddedRasterSink.swift`
- `StaticSignalAnalyzerNRFEmbeddedRenderPreflight.swift`
- `StaticSignalAnalyzerNRFEmbeddedRenderSemanticAdapter.swift`
- `StaticSignalAnalyzerNRFEmbeddedTileRuns.swift`

[Preparation/native runner](check-file-selection-candidate.py) checks that
every candidate belongs to the actual CMake closure and replaces its exact
fragment in the native source. The full production native layout/Drawing
harness passes. The nRF candidate compiles and links at exactly the same
275,600 flash / 191,104 RAM bytes as production. Both images pass ARMv7E-M,
VFP argument and disabled-heap checks; configured stack sizes are identical.
[Native/source evidence](evidence/15-file-selection-candidate.json),
[ELF comparison](evidence/15-file-selection-elf.json).

This proves that the guards add no behavior inside the selected Embedded
closure. It does **not** prove that deleting them without changing SwiftPM
selection is safe. Current SwiftPM compiles these files without the Embedded
flag, yielding no declarations. Production removal must put these exact
Embedded-only files in an explicit SwiftPM exclusion/selection list while
preserving nRF CMake and native rehearsal selection. Review tools that compile
selected files directly must consume the same list or check its consistency.
Validate native module interfaces/source manifests and all affected builds.
No new target or owner is required merely to move file selection.

`StaticSignalAnalyzerNRFEmbeddedFontRaster.swift` contains only a guarded
comment, already saying shared resources own the adapter. It is a separate
empty-file removal candidate (update the selection list with deletion).

## Secondary candidates, not yet selected

| Candidate | Required companion change / risk |
| --- | --- |
| LinuxPiScreenDevices.swift and LinuxPiScreenExercise.swift | Conditional Package source exclusion on non-Linux; keep Pi module APIs and hardware-free rehearsal coverage |
| LinuxSignalAnalyzerPiInputPump.swift and LinuxSignalAnalyzerPiProcessLoop.swift | OS source selection in Package plus explicit main/composition call routing; preserve ARMv6 compile and native rehearsal |
| PiHostNativeRehearsal.swift | Collect macOS rehearsal-only declarations into selected files; file presently interleaves multiple guards, so deleting all guards is unsafe |
| Interior Embedded branches in DisplayTarget, ResolvedLayoutView and RenderWorkspace | Split realizations only after dependency/API and resource equivalence checks; this experiment did not remove them |

## Explicit residual guard policy

Retain the existing Dynamic Canvas declaration exclusions, Embedded raster
arithmetic realization, bitmap/outline payload exclusions and conflict errors,
bounded diagnostic storage/capacity selections, instrumentation omissions,
native collection helper exclusions and Zephyr watchdog/Devicetree options.
Those guards enforce supported profile behavior or resource/capability
configuration. Removing them needs evidence of an equivalent selection
mechanism; minimizing their count is not itself a correctness requirement.
The full residual inventory remains [Step 09](evidence/09-source-guards.tsv).

For IT-AC-004, propose the named 15-file source-selection cleanup plus empty
compatibility-file removal, with justified residual guards. A requirement to
remove every directive would change profile/resource contracts and is not
supported by this review. FW-029 remains captured, without inferred approval.

## Reproduction

Run `python3 docs/iterations/iteration-002-review/check-file-selection-candidate.py`,
then `bash docs/iterations/iteration-002-review/build-research-firmware.sh iteration-002-file-selection`
and `measure-research-elf.py` with production/candidate build directories.
Generated copies/artifacts stay under `.build/nrf52840/`; production is untouched.
