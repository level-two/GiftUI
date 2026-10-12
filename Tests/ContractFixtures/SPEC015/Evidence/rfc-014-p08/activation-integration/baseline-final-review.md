# Independent compiler-baseline and activation regression audit

Reviewed 2026-10-12, read-only, without additional compiler invocations.

## Disposition

PASS for the approved Swift 6.4 baseline compatibility packet and the bounded
actual generic-host activation join blocker. The original positive construction
problem and the subsequently exposed callback lifetime containment problem both
have passing maintained component evidence. This is not full P08, P11, application
acceptance, or a feature lifecycle transition.

The human baseline approval (267616c9), normative correction (470137b7), and pins
(b594997b) precede integration. The component implementation review remains
[final-review.md](final-review.md); its restrictions still apply. In particular,
application services are trace stubs and the component report is synthetic. The
real scoped supplies, runtime construction, opportunity and quiescence are
exercised. No new production host role or public contract was introduced.

## Fresh baseline and maintained component evidence

- Baseline/core/runtime receipts, frozen through d194c2c6: P01 passes 17 controls;
  P02/P04 pass all four configurations, with 120 native assertions per profile.
  The macro was freshly rebuilt with Swift 6.4. P07 passes 33 checks and 5,904
  assertions in each native profile, 32 checks on ARMv6 and 31 on nRF52840.
  Native logical transcripts retain 26 matched cases. Cross results establish
  compilation and ABI checks, not target execution.
- Maintained P08 component gates (b1b5965f) pass 37 checks and 368 assertions in
  each native profile. All four precise activation copy/callback/constant-marker/
  backing escape controls reject as intended. This supplements the earlier
  48-assertion integration evidence rather than replacing it with a marker-only
  primitive. The fresh core/runtime/macro dependency chain uses Swift 6.4.
- Final Foundation gates (107f1fb5, driver b5140b92) pass all four configurations.
  They retain semantic corpus, surface/dependency restrictions, 11 value layouts,
  allocation checks and matched linked baseline/candidate sections and maps.
  Both sides use the approved compiler. I independently verified all 6,994 input
  hashes per profile, all 54/54/21/32 output hashes, and successful metadata.

I rechecked P01/P02/P04/P07 receipt and compiler/macro identities against current
bytes; earlier input/artifact audits remain valid. The frozen component manifest
has 116 verified entries and Foundation manifest 108. Historical failures and
interrupted runs remain failures. SwiftPM's explicit native backend, exact SDK
identity restoration after archive verification, and Foundation --target selection
are scoped compatibility corrections. Swift/GiftUI interface normalization accepts
the new qualification spelling; prohibited-module checks reject both separators.
Six meaningful parser controls retain the negative boundary checks. No production
Swift API, resource ceiling, or semantic acceptance criterion was relaxed.

## Resource compatibility and isolation correction

The resource packet e0ab0fae plus isolated timing correction e6e88f7d supplies
fresh SPEC-003/004 component evidence. All 33 and 25 extracted driver functions
are byte-identical to their maintained bodies. I verified all 337 current frozen
manifest entries, 312 original raw artifacts, 554 source inputs, and 22 isolated
timing artifacts. The five linked comparison summaries match byte-for-byte across
two pristine builds of each baseline/candidate pair.

All recorded bounds pass: SPEC-003 Static/Dynamic/ARMv6/nRF RAM deltas are
444/1596/488/256 bytes; code deltas 592/532/23876/132 bytes; stacks 64/64/40/24
bytes. ARMv6 code has 700 bytes of remaining headroom. SPEC-004 nRF total RAM
8,828 bytes, flash 30,484 bytes, stack 80 bytes, named storage 202 bytes, staging
2,560 bytes and initialization 44 operations meet unchanged limits. Layout and
native zero-allocation checks pass. All twelve final cross ELF attribute records
show the required v6 or v7E-M architecture and VFP calling convention.

The original 42/84 ns latency samples are informational because concurrent jobs
were not excluded. Replacement Static/Dynamic p99 measurements are 250/125 ns,
below 100,000 ns, on the reference machine/OS with 1,000 warm-up and 10,000 measured
iterations. The recorded pre-inspection and coordinated hold of other repository
jobs cover the complete measured interval. The unavailable post-run process
snapshot is an explicit procedural evidence limitation; the normative isolation
condition is supported by that pre-inspection and held interval. No concurrent
repository job was reported or observed. No rerun beyond the two authorized
latency checks is inferred or required by this audit.

## Closure boundary

This packet meets the approved baseline correction's component compatibility
requirements; linked resource pairs are present rather than deferred as P11.
Large original maps/disassemblies and generated binaries remain at hashed local
paths with reproduction commands. Their hashes were independently checked.
No ARMv6/nRF executable or firmware was run, and no hardware was changed.

Full validator-stage ordering, all application failure/counter scenarios,
application-specific resource costs, four-route application acceptance and the
remaining P08/P11 plan criteria still require their own evidence. These limits do
not reopen the now-verified compiler lifetime containment and actual host join
component blocker.
