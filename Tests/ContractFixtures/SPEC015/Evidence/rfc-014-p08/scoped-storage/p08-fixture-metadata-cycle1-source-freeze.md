# P08 metadata correction 1 — owned assertion conditions

**SOURCE ONLY, ready for focused independent reassessment.** Correction1/2
consumed under the current package; no compiler/runtime/build or fit claim.
Initial source `c277403a` and blocked review `416fda38` remain immutable.

B01 now evaluates `current[index] == original[index]` into owned `same` before
precondition. Both borrowing array parameters, all14 complete-entry comparisons
and original lenders remain; no array copy or lifetime-bound change.

The required same-cause scan also found two RHS captures of the newly borrowed
host in `p08ReuseRejectAction`. Prepare/delivery now evaluate the original full
fingerprint equality, then original model equality, into owned Booleans before
combining them. Neither borrowed value enters the `&&` RHS or assertion closure.
Both observations are pure and preserve their original order, logical condition
and failure assertion. No other operation, capture, effect or oracle changes.

The scan covered new borrowing recording/endpoint/runtime-slot/full-baseline
methods, frozen sensitivity controls, borrowed host helpers, graph/outer helpers,
cold metadata helpers, case dispatcher and caller idle assertions. Other new
assertions already consume owned Booleans or owned pointer/scalar projections;
no additional same-cause change was identified. This is source assessment, not a
claim of current compiler acceptance.

[Exact narrow diff/manifest](fixture-metadata-cycle1-source/manifest.json) pins
the three Swift equality boundaries, driver qualification glue and regression
checks. [Qualification](p08-fixture-metadata-cycle1-applicability.json) SHA256
`970cbb77f965a808a7df26f709674cf41d75122d71e08c5edb725bb576f0b106`
rechecks the same seven receipt hashes/actual argv inventories and ten source
exclusions. Only CounterScopedStorage's candidate hash changed. The existing
765-artifact proof is pinned and unchanged, not repeated; no changed counter
compiled input, full collection or image is qualified.

34 compiler-free layout/source tests, pinned maintained formatter, fixture grammar,
Python AST, inverse source-equivalence and whitespace checks passed. Source-only
controls remain 384/202,26 reuse labels, active129+metadata31 roots and all physical
cleanup/loan semantics. After focused source PASS, use the manifest's unchanged
fresh nRF so07 command; no execution occurred in this correction.
