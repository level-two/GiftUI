# One diagnostic type-layout compilation

**Completed: one compilation / zero retries; 120/120 scalar facts proved.**
The initial decoder inventory failed because actual exported roots have
STV_PROTECTED (3), rather than assumed STV_DEFAULT (0). All 120 are exact defined
STB_GLOBAL/STT_FUNC symbols. `decoder-before-protected-fix.py.txt`,
`initial-decoder-reproduction.json` and `actual-root-symbols.json` preserve the old
parser, reproducible failure and actual names/table/index metadata. Only the
visibility predicate changed to exact 3. Unchanged strict decoding proves all
bodies/edges/relocations; no compiler retry or byte grammar relaxation.
[Numeric ledger](type-layout-ledger.json), compressed full proofs and original
execution receipts support the
[assessment](../../../../../../../docs/implementation-designs/spec-015-p08-physical-representation-assessment.md).

Prepared under the user-authorized physical-representation assessment. The recipe
below is immutable preparation; its invocation is now used. This is one
diagnostic module compilation, not an optimization
candidate, acceptance receipt, linker image, runtime experiment or renewed repair
budget. The historical typed-stage 2/2 allowance remains closed.

The existing object proves large inline recording/endpoint contributions, but
does not provide a complete target layout ledger for the generic state carrier.
Forty concrete types cover the host/state/coordinator/pipeline chain, actual
scoped accesses and owners, owned assembly metadata, endpoint/raster/recording,
complete identity, reuse fingerprint and original control. `roots.json` is the
exact type list: size/stride/alignment, 120 scalar roots. No field or stored
physical object is added. There is no capability construction or observation of
a live value. Dynamic sizes are not measured by this Embedded-only diagnostic.

`prepared.json` pins the original receipt, object, compiler, plugin, driver/source
inputs, imported module files, strict decoder and generated temporary source.
All 374 pinned inputs matched during preparation. The baseline object is
`917e93305c4b2c9f46bf83fb92df407bb141955a73cf53379f26ce14fcc0f904`;
the baseline receipt is
`cdead491a37a2f5bc7f7f1de005df78894c1d4b0e34d855fd65a918c1ae02465`.

The temporary `CounterScopedStorage.swift` is the exact original bytes plus a
newline and `accessors.swift.txt`. All other source paths and compiler flags are
unchanged. `compile.argv.json` is parsed from the actual successful counter-module
command; its only substitutions are the temporary source, module-cache directory,
output module and output object. All are explicitly listed in `prepared.json`.
Original module search paths and dependencies remain in place. Outputs are
confined to `.build/nrf52840/contracts/p08-physical-representation-diagnostic/`.

Sequential executor, from the repository root:

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/physical-representation-diagnostic/run-once.py
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/physical-representation-diagnostic/decode.py
```

Run the second command only if compilation exits zero. The first verifies all
pins before the single compiler subprocess and writes an invocation marker,
stdout/stderr and diagnostic result with exact argv/artifact hashes. It refuses
another invocation. Only a separately established mechanical invocation error may
be retried; a source/compiler diagnostic or unsupported constant body is a result,
not a reason to edit and retry.

The second uses unchanged `p08_layout_facts.ELF.constant` directly, without
the unrelated 129-root layout-table inventory. It requires exactly the 120
defined global assessment function roots and records each immediate leaf,
permitted tail edge and actual relocation identity. Existing strict byte/body/
relocation/alias/hop rules remain intact. It collects unsupported roots as errors
and exits nonzero if any fail. No value is guessed from source or disassembly.

These extra exported roots can affect optimizer decisions: neither their module
nor its stack frames replace frozen acceptance evidence. Scalar layout facts
only attribute physical type size; they do not prove an upper stack bound,
successful compaction, lifetime correctness of a future rewrite or target fit.
Preparation checks were Python syntax, exact source suffix/argv substitutions,
input hashing and whitespace only. The preparer did not compile; the sequential executor subsequently used the one
invocation. Result collection used read-only object decoding, with no further
compiler/build/link/runtime invocation.
