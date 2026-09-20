# SPEC-015 Milestone 6 — Four-Preset Comparison

Evidence kinds: `host-execution` for macOS and normalized semantic oracles;
`cross-build` for Raspberry Pi and nRF52840 artifacts. Connected Pi and nRF
execution remains `not-collected`.

Reproduce the complete hardware-free comparison from the repository root:

```sh
scripts/contracts/run-spec-015-milestone-6.sh
```

The gate consumes four independently emitted immutable reports. The current
evidence is bound to repository revision `b85007d4176f2152f52c29b21e252fda0e72fc7a`
and immutable run
`b85007d4176f2152f52c29b21e252fda0e72fc7a-451f863b0bdd06df`. It requires
equal checksum, graph-role count, semantic and render-semantic counts, layout
scope and traversal bounds, text lines, glyphs, ordinary and Drawing
operations, actions, inputs, completion facts, admission capacity, Canvas
count, and live/plan point bounds. All roots report checksum `360515885`, 18
roles, 48 semantic nodes, 62 render-semantic scopes, 53 layout scopes, depth 6, 21 text lines, 139
glyphs, 30 ordinary operations, five Drawing operations, six actions/inputs,
one completion fact, 32 compact-fact slots, five canvases, 202 live points,
and 832 plan points. The same generated runtime-limit source and successful
profile audit underlie each report. Existing focused lifecycle, publication,
failure, and executor transcripts are shared production-owner inputs rather
than target-specific replicas.

Physical and resource differences remain explicit:

| Preset | Profile storage | Raster staging | ABI | Linked RAM | Linked flash |
| --- | ---: | ---: | --- | ---: | ---: |
| macOS Dynamic | 33,816 B | 307,200 B | native macOS | not collected | n/a |
| macOS Static | 30,608 B | 307,200 B | native macOS | not collected | n/a |
| Pi 1 ARMv6 Dynamic | 33,816 B | 7,680 B | ARMv6 hard-float | not collected | not collected |
| nRF52840 Static | 30,608 B | 3,840 B | ARMv7E-M VFP hard-float | 175,296 B | 31,928 B |

Each root resolves four capability contributions once at startup and performs
zero later resolver calls. Static owner paths reuse the approved zero-allocation
evidence from SPEC-004 through SPEC-014; the nRF linked image additionally has
both heap arenas disabled and no global allocation entry point. Its separately
named application storage is 30,608 bytes of profile workspace, 115,392 bytes
of capture/snapshot storage, and one 3,840-byte raster/payload/in-flight slot.
The nRF entry path has no task, thread, reflection, Objective-C, dynamic
collection, throw, or exception operation; the two-byte protected personality
leaf retained by the Swift toolchain is unreachable from that entry.
The aggregate remains below the approved 196,608-byte application RAM and 1
MiB flash limits. SPEC-004's incremental capability costs and SPEC-014's exact
one-slot backend costs remain separate rather than being folded into semantic
equivalence.

The machine-readable result is
`.build/spec-015/comparison/report.tsv`. No deploy, flash, service restart, or
connected-target claim is part of this gate.
