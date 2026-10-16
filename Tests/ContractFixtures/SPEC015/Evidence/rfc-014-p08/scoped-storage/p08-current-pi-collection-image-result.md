# Current Pi counter collection and early image — 2026-10-16

**PASS: complete current Pi compilation/control collection 409/409 and supported
early ARMv6 hard-float image link.** Independent bounded receipt/ABI review passes.
This is not a complete stack/allocation/physical-fit result or target execution.
The [remaining campaign](p08-remaining-acceptance-campaign.md) retains those duties,
Native missing families, caller reconciliation and independent P08 exit.

The [immutable packet manifest](current-pi-collection-image/manifest.json) pins
compact receipts/reports/map/commands/source hashes and diagnostic logs/probes,
without binaries. Full local snapshot
`.build/raspberry-pi/p08-current-pi-evidence-20261016T213118Z/manifest.json` has SHA
`d547701005fd89bb9e9cbf7e0f633819c338311b1352b7b46cec6aad228f7a69`.
All **934 preserved files** and declared sizes/hashes were independently verified;
all **228 current counter input hashes** match. The packet includes executable
read-only `verify.py`, which requires the preserved local snapshot to reverify
binary hashes. No build or compiler command ran during this review.

## Collected evidence

At revision `bb4f9f77`, one full sequential command ran:

```sh
scripts/contracts/run-spec-015.sh --profile raspberry-pi-armv6 --corpus rfc-014-counter --runtime-build .build/raspberry-pi/contracts/spec-013-runtime-cycle/tmpsb8yw4yu/raspberry-pi-armv6 --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures
```

Wrapper `20261016T194209188955Z-p08-current-pi-full-collection` records
19:42:09–21:29:46 UTC, exit0. Output receipt is
`.build/raspberry-pi/contracts/p08-counter-hvxrlng0/result.json`:
collection_complete=true, passed=true, all409 statuses passed, no focused/legacy/
resume substitution. It contains 25 preparation checks and 384 scoped controls
(192 positive/negative pairs). Every recorded log hash and diagnostic classifier,
including exact structured error-site requirements, was independently rechecked;
each negative retains its passing positive twin. This is ARMv6 cross-compilation,
not a Linux runtime/exclusivity execution claim.

The runtime and host source recipes remain the explicitly qualified
`p08-constructor-caller-cycle2` prerequisites. Their CounterScopedStorage metadata
hashes are historical (`compiled=false`, `original_manifest_current=false`);
actual recorded Swift argument inventories exclude that candidate. Their exact
receipt hashes and qualification objects are preserved. No old runtime/host
receipt is relabeled as freshly compiled. The counter's selected target modules,
full trusted source and control variants are freshly compiled in this collection.

A single doctor pass (21:30:45–21:30:49 UTC) preceded one supported build:

```sh
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6 --counter-build .build/raspberry-pi/contracts/p08-counter-hvxrlng0
```

Wrapper `20261016T213054492503Z-p08-current-pi-counter-image` records
21:30:54–21:30:55 UTC, exit0. The helper's strict successful-complete-receipt,
current inputs/artifacts/compiler and 25 link-object checks validate. Compiler SHA
is `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`.
The exact SDK static Swift destination and command are archived.

| Frozen artifact | SHA256 |
| --- | --- |
| Unstripped `counter.elf` | `c1c6682ea8eebf8a88dbd171377bca70c56712ef76692991504b907b878efb33` |
| Stripped product | `f8a0057667144c63b7824466749afa8e2151bbfc4a8e76554c9adc7ab4538035` |
| `counter.map` | `798caddc579950c2287d464dc01076161ce08a7471c9369372dfa6d8869791c2` |

## Independent review and boundary

**Package, current collection, early link and ABI PASS; no blocker found for these
claims.** The live frozen ELF's attributes were independently reread: ARM ELF32,
ARMv6, VFPv2, VFP-register arguments and EABI hard-float. The recorded target is
`armv6-unknown-linux-gnueabihf`; no ARMv7/AArch64 substitution. It selects the Dynamic
counter profile and static Swift standard library. It remains a Linux PIE with
`/lib/ld-linux-armhf.so.3` and libc/libm/libstdc++/libatomic/libgcc dependencies;
“static Swift” does not mean a wholly static Linux executable.

ELF/map/report and link-input hashes bind the early image to the new409 receipt.
Required runtime allocation, native/Pi feasible stack/library/temporary cost,
retained Dynamic capacity/header/allocator accounting and overall fit remain
unproved by this packet. No malloc/stack path is assumed zero from link success.
The accepted nRF image proof remains its separate target-specific result.

All three wrappers preserve unchanged external working-tree provenance. Five
external analyzer/CMake/nRF/Pi shell edits and known pycache were not modified,
staged or attributed by this review. The Pi shell delta is after its counter
branch's exit, outside this command's recipe. Current source/receipt hashes,
diagnostic classifications, ABI, local documentation links, whitespace and
governance checks pass. No target runtime, deployment, service restart, connected
measurement or new source/correction allowance is claimed. P08/R07/T8.1 stay open.
