# Counter-only resource configuration — 2026-10-16

**Configuration implemented and independently reviewed PASS; ready for the normal
guarded counter build. No firmware build or new-image fit claim.**
The [independent authority/configuration review](p08-counter-resource-configuration-independent-review.md)
confirms the narrow routing and preserved guards.
[ADR-040](../../../../../../docs/adrs/adr-040-counter-physical-sram-budget.md) and
[explicit human acceptance](../../../../../../docs/iterations/iteration-003-review/p08-counter-resource-acceptance.md)
are committed at `a9ccac89`. They authorize the finite counter's physical 262,144
RAM ceiling and delegated sufficient reservations. The
[independent corrected proof review](p08-current-firmware-complete-bound-independent-review.md)
accepts frozen bounds 95,469 main / 6,672 ISR and selected payloads 106,496 / 8,192.
The new linked image still requires complete address-specific requalification.

The supported [nRF build route](../../../../../../scripts/nrf52840/build.sh)
selects [counter.conf](../../../../../../firmware/nrf52840/applications/signal-analyzer-static/counter.conf)
through `EXTRA_CONF_FILE` only with `--counter-build`. It keeps the existing
complete-receipt/source/compiler/layout handoff before the build. The counter
branch alone selects a local RAM limit 262,144; default routes still consume the
unchanged 196,608 toolchain setting. Analyzer `prj.conf`, its default build checks
and `toolchain.env` are byte-identical to the authority commit.

Reports now state actual Kconfig main/ISR values, selected resource scope/RAM
limit, RAM PT_LOAD charge and distinct address extent. Counter checks enforce
both Kconfig payloads and guarded stack symbol sizes (106,560 / 8,256, including
each existing 64-byte guard), selected RAM limit and physical RAM segment range
`[0x20000000,0x20040000)`. Existing flash, hard-float/ARMv7E-M, 160-root layout,
entry/symbol and disabled-arena/allocator-symbol guards remain active. These
build checks do not replace complete rooted allocator or feasible stack proof.

Validation: `bash -n` passes for the working script and the separately staged
script. The [read-only shell-fragment harness](counter-resource-configuration/check-shell-boundaries.py)
passes all **16 synthetic cases**, recorded in
[its output](counter-resource-configuration/shell-boundary-results.json).
It executes the actual route-selection, RAM arithmetic and build-check parser
with synthetic text inputs: accepted counter projection/boundary; rejected charge
and address overflow, wrong main/ISR/guarded symbol/budget, enabled heap and malloc;
analyzer 196,608 pass / 196,609 reject; counter-only overlay selection; wrong
application rejection; failed complete-receipt handoff stops the route. The handoff
subprocess is stubbed here, not bypassed in the maintained route. No compiler,
west, image build, application runtime or hardware is invoked by this harness.
Tested fragments are byte-identical to the staged script. Governance and local
links pass; no Swift application, corpus, ownership, capacity or repair allowance
changes occur.

## Separate working-tree provenance

Two externally created changes appeared during this package and are deliberately
left unstaged/uncommitted: analyzer CMake adds ObservableTargetGeneration and
InteractionFailurePrecedence sources plus LifetimeDependence/Lifetimes flags;
build.sh changes empty-array expansion. They were neither authored nor attributed
by this package. Only our resource hunks were staged with a reviewed index patch.
The remaining two-file external diff SHA256 at staging is
`be7a87e5c1d25fe7067d66b3d2dde7a962d71da26dccae094d74a17c5b8ec360`.
At finalization, two additional external unstaged analyzer edits appeared in
`SignalAnalyzerCycleFailureNormalizer.swift` and
`StaticSignalAnalyzerNRFInteractionTargetProjection.swift`. Neither is a counter
receipt input; both remain outside this package. The two-file hash above describes
only the earlier CMake/shell deltas, not these subsequent source edits.
The CMake edits lie after the counter branch's return and do not affect its source
recipe; no new analyzer-build result is inferred. Known untracked contract pycache
is untouched.

## Next authorized boundary

After independent configuration review, use the normal sequence:

```sh
scripts/nrf52840/doctor.sh
scripts/nrf52840/build.sh --application signal-analyzer-static --counter-build .build/nrf52840/contracts/p08-counter-yq7m79g3 --pristine
```

The existing complete 227/227 collection may be used only while its strict handoff
source/artifact/compiler hashes validate; this package changes none of its Swift
inputs. Preserve its reused-runtime/host receipt qualifications. Freeze the new
ELF/map/config and reports, audit all old→new address/function/site/data mappings,
rerun the corrected proof with fresh premises, and independently review actual
charge/extent, stack guards, recursion/callbacks, allocation, ABI and flash before
accepting fit. Then complete the four-route/SO matrix and independent P08 exit
review. P08/R07/T8.1 remain open; no hardware action is included.
