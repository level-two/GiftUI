# P08 resource diagnosis/design activity — 2026-10-15

Status: **active diagnosis/design only; P08 fit remains failed**.
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
