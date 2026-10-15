# P08 resource diagnosis/design activity — 2026-10-15

Status: **independent Strong design review PASS; candidate A ready for a bounded source attempt; P08 fit remains failed**.
[Independent design review](p08-resource-design-independent-review.md) verifies
the lower bounds and internal realization, without a limit change. Parent records
a new one-candidate / one-screen source activity with zero automatic repairs
before dispatch; this read-only activity does not reset historical budgets.
Entry `8371e09a`, final compiled source `0d3e3c7d`. The independently confirmed
[previous failure package](p08-remaining-images-resource-result.md) and its
[exit review](p08-remaining-independent-exit-review.md) remain unchanged.

Eugene asked whether the 27,648-byte stack must remain fixed or approximately
30 KB would be acceptable. After the recommendation to investigate avoidable
copies/temporaries and compare them with a justified modest increase, Eugene
said: **“Please proceed as you recommended.”** This authorizes a concrete,
evidence-grounded diagnosis/design package, not a changed resource contract.

This new activity permits sequential Strong read-only inspection of existing
source, exact ELF/DWARF/disassembly, budget origin and RAM/IRQ accounting; compact
artifact extraction; an internal realization design and focused validation
proposal; and documentary commits. It does not authorize source fixes, compiler
variants, builds, whole suites, target execution, hardware or a new stack limit.
If an exact targeted compile experiment is needed, record the minimal recipe and
why existing artifacts cannot answer it for parent disposition.

The prior remaining-completion **2/2 corrective cycles remain consumed/closed**.
This activity establishes no automatic repair allowance or reset. Keep 27,648
bytes as the acceptance baseline and 196,608 bytes as the application RAM ceiling.
Separate proven frame/path lower bounds from unknown upper bounds, including
ABI/alignment/MPU, simultaneously live helpers, IRQ and allocator consequences.
Preserve the required counter corpus and its coverage; do not silently remove
test scaffolding from the registered image workload to manufacture fit.

Deliver a concrete attribution of the largest frames and retained 128,000-byte
backing, a comparison of contract-preserving realization versus a justified
budget/contract decision, and a bounded next source/early-stack/focused-validation
package with affected files/profiles and exact evidence limits. Independent
Strong review follows sequentially. SPEC-011/013/015 remain implementing;
P08/R07/T8.1/HC-RD-003, I4-07/analyzer, P09–P12, hardware and timing remain open.

## Prepared boundary

The [draft implementation note](../../../../../../docs/implementation-designs/spec-015-p08-stack-materialization.md)
and [exact artifact packet](resource-design/README.md) establish the required
213,120-byte three-frame lower bound, computed-getter and state-transfer
materialization, current RAM/MPU accounting and the historical stack origin.
A 30 KiB budget-only change is insufficient. The note proposes one grouped
private realization and an early fresh nRF object rejection screen; no stack
reduction is promised before that measurement. The existing image handoff full-
receipt guard is preserved. Independent design review is complete; independent source review still precedes
the recorded candidate screen.

Compiler-free verification passes for 15 source/header identities, 14 preserved
payloads and decompressed hashes, seven frame prologues, both nested BL edges,
the 213,120-byte arithmetic and new local links. Packet manifest SHA-256 is
`27f18423d9d8b7795bb0c672b21e548526493cfe089fca0898a1351c3ef089f4`.
`git diff --check` and `scripts/validate-governance.rb` pass (200 authority nodes,
2,026 edges; seven features, 76 lifecycle artifacts). All maintained Swift,
compiler inputs, old full receipts, image artifacts and required limits remain
unchanged. The unrelated generated `scripts/contracts/__pycache__` is untouched.
