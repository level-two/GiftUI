# P08 counter resource acceptance — 2026-10-16

Eugene explicitly directed using a sufficient larger main stack instead of another
source optimization; roughly 30 KB was illustrative, not a ceiling. After the
actual live-path proof rejected the former 196,608-byte whole-RAM ceiling, he
accepted revising the counter's total RAM subject to verified fit in the physical
256 KiB nRF52840 SRAM and requested proceeding with P08 completion (“Yes accepted.”).
He delegated selection of sufficient evidence-backed reservations within that
physical ceiling. This records the explicit human exception, not approval inferred
from implementation or the age of evidence.

The [independent complete-bound review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-complete-bound-independent-review.md)
at `ee512846` passes the corrected frozen-ELF proof: main 95,469 and ISR 6,672.
Selected implementation reservations are main **106,496** and ISR **8,192**;
they are not new architectural minima. Projected linked charge 255,612 / extent
255,616 fits **262,144**. The new image still requires its own normal guarded
build and fully rebased/corrected stack/allocator/address proof before acceptance.

This acceptance authorizes [ADR-040](../../adrs/adr-040-counter-physical-sram-budget.md)
and its narrow SPEC-004/SPEC-015 resource reconciliation and counter-only build
configuration. It overrides only the counter RAM/stack exclusion of RFC-015 /
ADR-039. Preserve the original rationale and historical accepted packets. Normal
analyzer RAM 196,608 and main 27,648 remain unchanged, as do zero heap, flash,
capacities, all required checks, ownership/lifetimes and complete stack/IRQ proof.
No Swift/corpus optimization, hardware action, new source repair allowance, P08
exit, Specification implementation transition or iteration closure is granted.

The unexecuted prepared-lending optimization is retained in
[FW-039](../../future-work/fw-039-counter-prepared-lending.md). Required final-image,
full four-route/SO and independent P08 exit evidence remain current obligations;
P09–P12 / I4-07 retain their existing allocation.
