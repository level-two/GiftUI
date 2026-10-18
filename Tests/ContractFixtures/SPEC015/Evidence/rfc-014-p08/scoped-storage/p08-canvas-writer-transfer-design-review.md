# Independent Canvas writer/transfer design review — 2026-10-18

**READY for a separately authorized bounded candidate after proposal 7271feb3.**
The final focused recheck confirms entries 29–31 uniquely select the exact typed
BankBuffers fields at lines 195–197, bounded to its 192–216 nominal region; scalars
at 198 uses the same region. The three already-ABI limits fields are explicit
no-ops. Only these three replacements and scalars selector precision changed;
the other 64 edit entries, source hashes and 68-site/11-file scope are unchanged.
Updated packet hashes verify; the amendment changes proposal/docs only. This
closes the concrete blocker below without a compiler probe, source allowance or
claim that compile/privacy/codegen/safety/cold gates have passed.

Initial disposition at 3582c0be: blocked on three exact field selectors;
otherwise coherent selected design.
Reviewed proposal 3582c0be: 68 selectors/11 files, six original roots
F05/F06/F13/F14/F15/F19. Source hashes and all declared source locations agree.
No source/compiler/runtime or new candidate allowance occurred in review.

Correction-map entries 29–31 currently select SemanticRecordLimits.records,
paths and payloads at SemanticRuntimeRecords.swift:78/80/84. All three already
have @usableFromInline. They are not the buffer descriptors required by the
newly serialized clear/store/takePendingCanvas bodies. Replace these three edit
entries with the exact declarations in SemanticRecordBankBuffers at lines 195–197:

```swift
package let records: UnsafeMutableBufferPointer<SemanticRuntimeRecord>
package let paths: UnsafeMutableBufferPointer<SemanticPathEntry>
package let payloads: UnsafeMutableBufferPointer<Payload?>
```

Add @usableFromInline to these existing package fields; use the full typed selector
and enclosing BankBuffers region so repeated field names cannot match limits.
Classify the three limits fields as existing ABI no-ops. The existing scalars entry
at line 198 is correct. This is a proposal-only correction within the same finite
file/field mechanism, not permission to implement or widen source access. Update
map traces/count semantics and packet hashes coherently; no compiler probe is needed
to establish this direct field-access omission.

The selected chain otherwise covers owned Canvas/standard payload envelopes,
both codec/wrapping families, checked project, writer overloads, bank store/clear/
first-failure cleanup, candidate/bank selection, takePendingCanvas and discard.
Transfer retains the actual noescape bank callback, stages the captured value,
then replaces it with .canvas(nil); failure still discards values/candidate and
preserves existing capacity/error mapping. Only framework writer bank/limits and
project internals change source visibility; private P08/State/key/model-ledger/
Text backing and checked factories remain excluded.

SemanticRecordReference's four let fields require owner/bank/revision/ordinal:
the proposed ordinary internal ABI initializer has four required parameters and
same-order assignments, preserving the implicit internal memberwise constructor.
No nil/default, ownership, Equatable/Sendable contract or public/package creation
route is added. Existing ABI scopes/protocols and non-ABI consumer-protocol
conformances do not require blanket property/body promotion. Newly formal ABI
codec/table witnesses and associated aliases are included; synthesized witness
and compiler-dependent access legality remain grouped compile gates.

The ten generated attribute sites are exact finite CanvasWitnessLowering emissions:
Values/Table, Domain/CaptureStorage aliases, existing init/count/captureByteCount,
caseID/payload/invoke. CounterCanvas/FiniteSourceLowering stay no-ops. Ordinary
macro host eligibility/private backing must remain unchanged. The proposed fresh
macrotool, complete relevant tests, actual Counter/variant Table+Presentation
parse/compile and finite inventory/identifier guard regressions are meaningful
producer checks; textual attributes alone cannot qualify generated body access.
Generated output must be rebuilt/frozen before the fresh registered 25-owner sweep.

After the selector correction, no other known material omission was found in this
finite selected closure. Fresh privacy, complete physical indexes, same-42 SIL and
matching object interpretation remain required; neither default CMO nor protocol
conformance proves body availability. C publication three, C traversal five and
E/F commit two stay unselected/unqualified. BoundedText callback, ordinary leaves
and cold Error witness costs are not passed. Full safety/14-loan/Optional/lifetime,
strict cold, zero heap and P08 acceptance remain open. No broader inventory or
automatic repair is authorized; protected external five/pycache remain unstaged.
