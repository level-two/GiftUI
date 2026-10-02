# T9.3 carrier resources — 2026-10-02

`python3 scripts/contracts/check-spec-013-amended-carriers.py` checks actual
canonical owner declarations and the production SignalAnalyzerCycleOwnerFailure
sum. The production rejection enum moved mechanically to a separate file in
its existing Presentation owner; the compiler consumes that file, not a
lookalike. The nRF definition now exposes the existing canonical
ActionModelTargetAccess protocol required by Runtime Core. The remaining
fixed OwnerFailure restriction on GiftUIRuntimeProfileCoordinator was removed
to match the approved declaration. No module edge was added.

Apple Swift 6.3.3/macOS and pinned Swift 6.3.2 ARMv6/Embedded compilers agree:
framework and composed owner strides 1, failure strides 2, cycle result
strides 64 bytes. Ceilings remain 2/4/8/72. Mutation result is 4 bytes, returned
pipeline result 24 bytes; framework and composed first-failure storage both
28 bytes (zero specialization delta). The existing generated failure-state
reservations remain Dynamic128/Static96 bytes; no increased audit budget is
needed for this declaration repair. The actual retained layout/packing must
be checked again after production joining.

The Embedded object includes standard-library allocator support symbols;
absence of those symbols is not claimed for this probe. Its IR call graph
from carrier_mutation_probe (the shared runner's exact application rejection
with a runtime-selected mutation bit) has no allocating or indirect calls.
The generated entry returns 1 without applied mutation and 3 with mutation,
retains the exact application case and finalizes once. This proves zero heap
on the exercised carrier/partial-mutation runner path, not the entire firmware.

`carrier-layouts.tsv`, `carrier-source-hashes.tsv` and the compressed compiler
evidence preserve measurements, source identity, IR, raw compiler logs,
undefined symbols and reachable Embedded symbols. The check is explicitly
registered in the SPEC-013 owner driver, selected by its profile.
Formatter passed; 8 focused boundary/progress/host/owner-policy tests pass.
The first declaration attempt exposed desktop Domain existential use and the
hidden Interaction protocol. Selection now includes the actual finite
Presentation declaration and all required canonical Runtime Core owners.

Full assembled Pi/nRF binaries, ABI, RAM/flash/stack and zero-heap obligations
remain T10.5/T10.6; no connected hardware or relaxed ceiling is claimed.
