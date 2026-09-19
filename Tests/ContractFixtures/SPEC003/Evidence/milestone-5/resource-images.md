# SPEC-003 T5.4 Matched-Image Resource Evidence

Plan task: `SPEC-003 T5.4`

The resource mechanism is implemented for all four exact standalone profile
commands. Each command now builds two pristine baseline/candidate pairs from
one stable generated path and records final-image hashes, maps, complete
section and symbol inventories, disassembly, loaded-library identities,
normalized section accounting, a resolved call graph, the conservative stack
bound, and nRF reachable instruction count.

The checker fails closed on missing bodies, reachable indirect calls, dynamic
stack adjustment, recursion, unequal libraries, resource-limit breaches, and
non-repeatable images or normalized reports. ARMv6 and nRF runs remain
hardware-free and perform no remote access, deployment, or flashing.

Passing disposition on 2026-09-19:

| Profile | Writable RAM delta | Linked-code delta | Stack | Reachable instructions |
| --- | ---: | ---: | ---: | ---: |
| `macos-dynamic` | 1,596 / 2,048 B | 532 / 32,768 B | 64 / 512 B | 45 |
| `macos-static` | 444 / 512 B | 592 / 24,576 B | 64 / 384 B | 45 |
| `raspberry-pi-armv6` | -40 / 512 B | 24,388 / 24,576 B | 40 / 384 B | 50 |
| `nrf52840-embedded` | 256 / 320 B | 132 / 16,384 B | 24 / 256 B | 38 / 4,096 |

Every row comes from two byte-identical final images and identical normalized
reports. Immutable reports are published under
`.build/contract-reports/spec-003/<revision>-<input-digest>/<profile>/`; each
report records its exact revision, dirty state, commands, inputs, and hashes.

The closed macOS measurement image removes unused Swift runtime registration
records before final dead stripping. Its retained image executes successfully
and preserves the named health, counter, and buffer storage plus the resolved
production path. The ARMv6 image uses a non-PIE executable export boundary,
removes nondeterministic loader hashes, and places compiler-emitted immutable
Swift tables in read-only sections. The checker rejects writable replacements
or any dynamic relocation targeting those sections. Loader, unwind, and Swift
runtime-registration tables are excluded from linked code as loader metadata;
executable code and retained read-only production data remain counted.

T5.4 is complete. These ARMv6 results are hardware-free cross-build evidence,
not the connected `armv6l` execution and latency evidence required by T6.2.
