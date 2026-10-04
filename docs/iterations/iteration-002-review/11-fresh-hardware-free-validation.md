# Step 11 — Fresh hardware-free validation

On 2026-10-04, `scripts/test.sh --profile all-hardware-free` completed with
exit zero: **72 checks passed, zero failed**. HEAD remained
`b18da84a0622e2d24bfc1da8ce17fdf0c89faea7` throughout the invocation.
Maintained production source, tests and build scripts remain unchanged from
the source baseline. `scripts/format-swift.sh --lint` passed before the gate
and inside it.

| Evidence | Result / limits |
| --- | --- |
| Repository checks | Governance/tooling, formatting, registry, profile migration/storage/binding, dedicated Static checks, root tests, diagnostic capacity branches and expected conflicting-flag rejection: 12 successful checks |
| Contract drivers | SPEC-001 through SPEC-015 passed for each of macOS Dynamic, macOS Static, Pi ARMv6 and nRF Embedded: 60 successful profile-driver checks |
| Root unit/reference corpus | 298 XCTest cases and 1,160 Swift Testing cases passed; includes the complete desktop reference workloads |
| Separate SwiftUI demo | 17 XCTest cases passed; zero Swift Testing cases registered; independent of root GiftUI conformance |
| Current nRF assembled size | 275,600 flash bytes; 191,104 RAM bytes; within existing 1,048,576 flash / 196,608 RAM limits. No fresh physical stack high-water or cadence measurement |
| Source/build preservation | No maintained source/test/build input diff from `6cf31f266987e917458f31f05ed8c390cda9a202`; pending research documentation was recorded as a dirty tree |

## Preserved evidence and identities

- [Aggregate ledger](evidence/11-gate-results.tsv)
- [Exact contract report directories, run IDs and identity hashes](evidence/11-contract-runs.tsv)
- [Summary and raw-file/archive SHA-256 hashes](evidence/11-gate-summary.json)
- [Archived console, check logs, report inventories/metadata and demo log](evidence/11-validation-logs.tar.gz)
- [Capture script](capture-gate-evidence.py)
- [240 criterion review notes](evidence/11-criterion-review-notes.tsv)

The capture verifies published report hash manifests before archiving their
top-level evidence files and aggregate logs. Build caches/binaries and nested
probe trees are not copied into Git; their published manifests and local report
paths remain recorded. SPEC-001 has timestamped reports with narrower
source/fixture/artifact metadata identities; SPEC-002 through SPEC-015 use
hashed input inventories. Verified idempotent reuse is identified separately.
SPEC-014 publishes under `.build/spec-014/reports/`; the run index records
actual published paths rather than assuming one directory layout for all drivers.

Research documentation changed while HEAD and maintained production/test/build
inputs stayed fixed. The report inventories preserve their actual differing
input hashes and dirty-state metadata. This is not a clean-tree or identical
whole-repository-input claim. SPEC-001's Pi compiler metadata also disagrees
with its paired build compiler: [CBR-008 reproduction](evidence/11-pi-compiler-identity.json)
records Swift 6.3.3 in the report versus enforced Swift 6.3.2 in the build log.
The target compiler/ABI check passed; correct the evidence attribution.

## Disposition and limits

The current hardware-free gate is green. CBR-001 and CBR-007 were reproduced
outside its existing corpus and remain correctness findings; passing tests do
not resolve them. Historical criterion dispositions remain comparison evidence,
not 240 independently refreshed passes or new approval. SPEC-001/011 criterion
notes explicitly highlight the new coverage gaps.

No deployment, flashing, remote restart or connected campaign occurred. Existing
timing/input/display/failure exceptions remain under FW-027/031/032/033. Current
firmware size is baseline evidence, not measured hierarchy-replacement parity,
cost, physical stack high-water or timing. EXP-001 still needs agreed comparison
budgets and a bounded actual-declaration candidate experiment.
