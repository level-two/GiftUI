# Independent counter authority/configuration review — 2026-10-16

**PASS: ready for the normal guarded counter build.** Reviewed authority commit
`a9ccac89` and configuration commit `22837277`, including their committed versions
separately from external working-tree changes. No code correction is required.
This review does not claim a newly built image or final resource fit.

[ADR-040](../../../../../../docs/adrs/adr-040-counter-physical-sram-budget.md) and
[human acceptance](../../../../../../docs/iterations/iteration-003-review/p08-counter-resource-acceptance.md)
accurately record the explicit counter-only stack/physical-SRAM exception and
delegated numerical selection. SPEC-004/SPEC-015, ADR-039 and RFC-015 preserve
historical rationale and clearly identify the narrow amendment. Existing analyzer
budgets, ownership, workloads, capacities, heap/flash and complete proof obligations
remain. SPEC-004's historical implemented status does not certify this pending
counter image. FW-039 captures the unexecuted prepared-lending optimization without
renewing its source allowance or deferring required safety evidence. No new human
approval is needed for these already authorized reservations.

The [configuration result](p08-counter-resource-configuration-result.md) matches
the committed routing: only nonempty `--counter-build` for
`signal-analyzer-static` selects the separate build directory, `counter.conf`
overlay and local RAM limit 262,144. The strict complete receipt/source/artifact/
compiler handoff runs first and failures abort. Default routes keep their original
RAM limit and receive no overlay; separate CMake build directories prevent counter
cache settings from carrying into the analyzer. `prj.conf`, default
`build-checks.conf` and `scripts/nrf52840/toolchain.env` remain byte-identical to
the authority commit.

The overlay requests payloads 106,496 / 8,192. Exact Kconfig lines and guarded ELF
symbols 106,560 / 8,256 are checked, retaining each 64-byte guard. Required-config
and RAM-limit parser branches reject malformed values, mismatched payloads and
wrong scope limits; existing unknown-key rejection remains. RAM LOAD memory sizes
are summed separately from minimum-start/maximum-end extent. The counter checks
both charge ≤262,144 and segment endpoints inside
`[0x20000000,0x20040000)`; sparse gaps cannot hide physical overflow. Arithmetic
uses readelf's hexadecimal ELF32 fields in Bash's wider integer range. Reports
name actual stack values, selected limit/scope, charge and extent. Existing flash,
ARMv7E-M/VFP ABI, required symbols, 160-root layout and disabled heap/arena guards
remain active. These checks are necessary image guards, not substitutes for
rooted allocator or feasible stack/IRQ proof.

The recorded 16 synthetic cases are appropriately bounded shell-guard evidence.
Independent inspection verified their memory/parser fragment hashes against
`22837277`, reviewed their positive/negative assertions and checked shell syntax;
no firmware or runtime result is inferred. Governance, local documentation links
and whitespace checks pass. No build, contract collection, target execution or
hardware operation ran in this review.

External unstaged CMake edits occur after the counter branch return. The two
external SignalAnalyzer Swift files are absent from the current 227-check counter
receipt inputs. The unstaged empty-array shell expansion is separate from the
reviewed resource hunks and does not change the populated counter arguments.
Those four external files and preexisting contract pycache were not edited,
staged or attributed by this review.

Next: execute the doctor and normal pristine counter build in the configuration
result, retaining strict current handoff qualifications and all receipts. Freeze
its new ELF/map/config/reports and inputs, then apply the audited address-rebasing,
corrected executable closure and independent acceptance requirements in the
[complete-bound review](p08-current-firmware-complete-bound-independent-review.md#required-final-image-requalification).
Recompute stack, guard/alignment, allocator, charge/extent, ABI and flash evidence
for that actual image. A successful build alone does not establish its stack fit.
P08/R07/T8.1, full four-route/SO coverage and independent P08 exit remain open;
no source optimization allowance or later P09–P12/I4-07 allocation changes.
