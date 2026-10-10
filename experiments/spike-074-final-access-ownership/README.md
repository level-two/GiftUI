# Final access/ownership validation

Disposable, bounded evidence for [SPIKE-074](../../docs/spikes/spike-074-final-access-ownership.md).
The registration defines the fixed cases, budget and terminal verdict. No
production source is modified. This is the last investigation round, not an
implementation authorization or a complete application feasibility claim.

Exact reproduction and terminal results are recorded here after execution.

## Reproduction and evidence

The completed workflow was:

```sh
python3 experiments/spike-074-final-access-ownership/run.py positive
python3 experiments/spike-074-final-access-ownership/run.py negative
python3 experiments/spike-074-final-access-ownership/run.py inspect
# Recorded repair: move the reserved-bank test before A's first population.
python3 experiments/spike-074-final-access-ownership/run.py positive
```

These are historical commands, not authorization to rerun or remove the terminal
marker. [The exact ledger](evidence/ledger.json) records every invocation, source
snapshot, compiler/module hash, diagnostic and output hash. The final verdict,
limits and assertion map are in [result.md](evidence/result.md). Native binaries
and target objects remain under the registered `.build` roots. No global tools
or target hardware were changed.

Actual production inputs are compiled directly, unmodified: the analyzer's
SignalPrimitiveValues, SignalAnalyzerDiagnostic, AcquisitionState, and the target
host's StaticSignalAnalyzerNRFCaptureStorage. Their exact bytes are retained in
the source snapshots. Core/schema/presentation/bridge/driver are hand-written
candidate forms, not production module source replacements or a frontend.

Target inspection uses the project-local readelf/size/llvm-nm binaries. Exact
commands and diagnostic log hashes are in [inspection.json](evidence/inspection.json).
Layout constants were emitted by compiler invocations 37–40, and extracted from
HostBridge.ll / Driver.ll under the registered build roots. The only subsequent
source repair changes test ordering; layout functions and represented types do
not change. The root objects and native runs use the final Driver source.
