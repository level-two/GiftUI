# Separate report-root follow-up — 2026-10-05

The 74-check invocation run-ZP4SPN01 passed at revision 759cf594; all 60
registered profile reports verify. SPEC-014 uses .build/spec-014/reports,
and its four published identities are already present in the publisher ledger.
Extend latest-pointer and interrupted-staging discovery to that explicit root.
The interruption fixture now checks its retained staging path: 3 tests and
30 assertions pass. Publication/identity fixtures pass 5 tests/34 assertions.
Fixture publications clear the inherited production ledger environment so their
disposable temporary IDs do not enter future production ledgers. The original
raw ledger is preserved, including its two visibly external fixture receipts;
the archive indexes only registered reports under this repository's .build.

This follow-up changes report collection only; it does not change any of the
74 check commands, supported profiles, production sources or contracts. Focused
runner/publication validation supplies the affected evidence; the existing
fresh four-profile product gate remains applicable to its exact frozen inputs.
