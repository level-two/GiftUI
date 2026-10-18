# Independent grouped pipeline design review — 2026-10-18

**NOT READY as frozen at `b448f010`: one exact constructor-default correction.**
The53-site/six-file proposal otherwise has no known material gap for its stated
run/helper availability boundary. It is not a full42-origin specialization map.
No source candidate, new budget or execution authority is granted by this review.

Remove the proposed `nil` defaults from these three parameters, preserving their
Optional types and required argument labels/order:

- RuntimePipelineCompletion.committedPresentationRevision
- RuntimePipelineCompletion.operational
- RuntimePipelineFailureRecord.publication

All three original stored properties are `let`. Matched Swift6.4 commit
`b8189d766d86ad7fc8106787d6ce9e402f38dd72`
[CodeSynthesis.cpp134–138](https://github.com/swiftlang/swift/blob/b8189d766d86ad7fc8106787d6ce9e402f38dd72/lib/Sema/CodeSynthesis.cpp#L134)
returns immediately when `var->isLet()`, before Optional nil synthesis at170–182.
Downloaded source SHA256:
`c06efd79b7c2a587b9c0f49d12f83c8433c29c9332585671c2f22f1b2934a109`.
Those defaults would add omission behavior absent from the synthesized memberwise
initializers; remove them from correction-map.json and the README's equivalence
claim. The earlier Canvas mutable optional default remains a separate valid case.
This proposal-only amendment leaves53 sites/six files and all maintained source
unchanged. Also correct the matched TypeCheckProtocol upstream link's filename
from the local `giftui-TypeCheckProtocol.cpp` to `TypeCheckProtocol.cpp`.

Verified all573 frozen inputs, all50 declaration locations/source hashes, matched
compiler source hashes/excerpts and compatibility identities. The enclosing
formal-access restriction explains the observed run body omission; the root
already has both inline annotations. The proposed ABI parent/protocol/signature
closure, three internal serialized generic helpers, ordinary cleanup ABI calls,
reached flags and generic constructor field access form a bounded coherent map.
The three constructors must retain original internal access, implicit ownership,
labels/types/order and assignments, with no pointer/capability construction.
Nongeneric constructor bodies and unrelated stored members need no serialization.

The matched both-scope witness rule supports leaving both current nonABI conformers
and all16 Counter witnesses/fields unchanged. The16-stage direct SIL references
and23 distinct project-generic declaration-only records verify against the current
fresh SIL. Treat them as downstream validation obligations, not automatic edits
or a claim that every generic edge is a blocker. Synthesized conformance,
OptionSet/Optional/static initialization, concrete specialization, reached private
callees and resource attribution remain compiler/codegen gates.

After the exact proposal amendment, a short map recheck can establish design
readiness for a separately authorized bounded candidate. Fresh25 compile,
selected22 privacy and six selected bodies remain PASS; the current required
callee gate remains FAIL/STOP. Full codegen/safety and strict cold remain
unqualified. No compiler, decoder, runtime or maintained-source edit was performed;
protected external five/pycache and all exhausted budgets remain unchanged.
