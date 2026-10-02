# Approved landscape fixture revalidation — 2026-10-02

The registered gate collected fresh owner evidence in all four profiles.
Every prerequisite except the six explicitly pending acceptance-ledger rows
passed. The six rows are now revalidated using these current reports, rather
than borrowing a pass from the original 480×320 fixture.

| Profile | Immutable collection ID |
| --- | --- |
| macOS Dynamic / Static | `a3434d85519aec30b875114076b8bed220cb17b8-a261cfe24bcf7689` |
| ARMv6 / nRF52840 | `ea3a895c4a63ded6a9dfaa12c794092c07925e44-a261cfe24bcf7689` |

BI-002 uses the current contribution/effective-value/mismatch corpus.
BI-003 uses the exact 320×240, 320×4, 640-byte-row, 2,560-byte nRF fixture,
link map, ABI and forbidden-buffer inspection. BI-006 uses current resource,
borrow-lifetime and transaction instrumentation. BI-007 uses both fresh macOS
production corpora and the zero-tolerance cross-profile comparison. BI-013
uses current 32/64-bit declaration probes, optimized allocation inspection,
sections/symbols and explicitly bounded cross-build workspace estimates.
BI-015 uses all four standalone driver collections, the registered driver and
path audits, and this acceptance reconciliation.

The comparator joins 19 fixture IDs with zero field differences. nRF records
2,560 bytes in the tile, payload and in-flight domains, 60 tile/payload visits,
and 240 regions; Pi records 7,680 bytes, 15 visits/payloads, and 240 regions.
Both constrained collectors report zero optimized heap allocation instructions
and the supported hard-float ABI. No ceiling or contract is relaxed.

`landscape-profile-revalidation.tar.gz` retains the current metadata, hashed
inputs, original prerequisite/evidence dispositions, normalized fixtures and
resource/layout/allocation/ABI reports. `landscape-profile-comparison.tsv`
retains the exact fixture join. Subsequent standalone runs recheck the newly
completed ledger. Cross-build stack/workspace estimates are not connected
application stack measurements, pixel review, physical input or timing proof.

## Completed-ledger rerun

All four standalone drivers pass with collection ID
`ea3a895c4a63ded6a9dfaa12c794092c07925e44-520b1a62dd94b4d0`.
The rerun archive preserves each prerequisite, metadata and hashed input set;
none of the original gate exit statuses is changed.
