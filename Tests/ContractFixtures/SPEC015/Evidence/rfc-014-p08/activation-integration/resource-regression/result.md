# Swift 6.4 focused resource compatibility — 2026-10-12

All twelve focused SPEC-003/004 stages passed. They retain the unchanged layout,
allocation, latency and linked-resource functions/checkers from the maintained
drivers, with the approved6.4 compiler explicitly selected. No ceiling,
optimization, ABI flag, measurement algorithm or production source changed.
The initial SPEC-002 full gate failed before resources at its interface parser;
Standard owns that exact failure and subsequent four-profile002 checks separately.

## Linked resource pairs

Each row below used two pristine builds of both baseline and candidate with6.4.
Existing repeatability checks passed for images, normalized reports and call graphs.
These are actual linked comparisons, not value-layout substitutes.

| Contract/profile | RAM delta / limit | Code or flash delta / limit | Candidate stack / limit | Other bound |
| --- | --- | --- | --- | --- |
| SPEC003 macOS Static |444 /512 B|592 /24576 B|64 /384 B|p99 42 ns /100000 ns|
| SPEC003 macOS Dynamic |1596 /2048 B|532 /32768 B|64 /512 B|p99 84 ns /100000 ns|
| SPEC003 ARMv6 |488 /512 B|23876 /24576 B|40 /384 B|50 reachable instructions, descriptive|
| SPEC003 nRF52840 |256 /320 B|132 /16384 B|24 /256 B|38 /4096 reachable instructions|
| SPEC004 nRF52840 |252 B delta;8828 /196608 B total|4752 B delta;30484 /1048576 B total|80 /256 B|44 /96 initialization operations|

SPEC004 additionally passes202 /512 B named capability storage and2560 /16384 B
display staging. Its flash warning threshold is917504 B; total30484 B is below it.
The ARMv6 SPEC003 code margin is700 B. That is current measured headroom, not an
optimization claim or permission to exceed future bounds.

Native timing probes each retain1000 warm-up iterations and10000 raw samples;
both report reference_runner_match=true for the contract reference machine/OS.
No target firmware or ARMv6 executable ran. ARMv6 hardware latency was not measured
and is not inferred from host timings or instruction counts. The specified cross
resource commands are hardware-free build/inspection seams.

## Value layout, allocation and ABI

SPEC003 checks23 value layouts on macOS Static/Dynamic, ARMv6 and nRF52840.
Owned-state sizes pass426 /512 B for nativeStatic and ARMv6,1578 /2048 B for
nativeDynamic and234 /320 B for nRF. Static and Dynamic native allocation probes
both report zero allocations with maximum counted steps37 /64, normalization5 /8,
and diagnostic selection8 /8. SPEC004's native Static probe reports zero
allocations and10 bounded layouts; its ARMv6 and nRF target IR each pass the
same10 declared layout ceilings.

Twelve final baseline/candidate ELFs across both builds were separately inspected:
ARMv6 reports CPU architecturev6, nRF reportsv7E-M, and all report
Tag_ABI_VFP_args: VFP registers. The nRF doctor's pinned board, Zephyr and SDK
checks passed; Pi doctor verifies6.4 project-local host/SDK identities. No hardware,
installer, global toolchain selection, driver edit or source repair occurred.

## Evidence and exact reproduction

`focused.sh <stage>` supplies isolated report paths and explicit compiler to the
verbatim `functions-003.sh` / `functions-004.sh` extracted from the maintained
drivers. `identity.json` records exact driver/compiler hashes; extraction equality
was rechecked after execution. The approved host and nRF compiler paths are both
hashed in `raw-artifact-manifest.json`. `input-sha256.json` records554 production,
fixture and firmware inputs and was revalidated before freeze. All stage commands,
full build logs, layouts, allocation output, raw timing samples, summaries and
normalized call graphs are under `reports/`; individual stage exit records and
`ledger.json` identify every invocation.

`raw-artifact-manifest.json` records312 original report/artifact paths, sizes and
SHA256 values, including all original linked images, full disassembly and maps.
Large ARM reports remain at the exact project-local .build paths (approximately
60 MB per disassembly and10 MB per map); hashes and exact reproduction commands
are retained rather than committing hundreds of megabytes. Smaller reports and
final ELF ABI attributes are copied here. Binary executables are not committed.

The initial002 failure's complete commands/logs/metadata are retained under
`initial-spec002-failure/`: its boundary parser expected PointerPhase/identity
interface spellings that the emitted interface did not match. This result makes
no002 resource claim; its repair and final evidence belong to Standard's separate
assignment. No maintained003/004 baseline-mode driver was needed because the
unchanged focused functions expose the exact resource measurements directly.

## Closure

The finite scope is closed: twelve focused passes, one initial002 failure handed
off, zero repair cycles, zero consecutive unproductive failures. No gate was
weakened or skipped after failure. This evidence supports compiler-baseline
resource compatibility for these exact common-component paths. It does not prove
application/P08 counters, four-route early images, owner-specific runtime costs,
full SPEC conformance or P08/P11 exit. Independent review and the separately owned
SPEC002/P01/P02/P04/P07 evidence remain part of the parent completion decision.
