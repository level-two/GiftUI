# Corrective2: earliest presentation compile/privacy FAIL

**Both corrective cycles are consumed (2/2).** The partial source experiment is
unaccepted/not adopted. Stop this activity: no third candidate, reset, restoration
or additional compiler/runtime gate follows automatically.

The reviewed ABI-only nominal change is in one maintained file,
`Sources/GiftUIMacros/FiniteSourceLowering.swift` (**51 additions /4 deletions**).
It emits ABI usability for finite View/Canvas nominals, their Domain aliases,
finite Action enums, inventoried pure helpers and generated schema/facade
nominals. Package access is retained. Authored Counter.swift, private State,
checked facade constructors, algorithms, lifetime annotations, storage/loans,
capacities, payloads and workload assertions are unchanged.

The fresh macro tool compiles/links; lowering succeeds; the new matching
`P08CounterSchema` compiles. The first actual `P08CounterPresentation` invocation
fails with24 compiler errors, including **five private `_model` errors**:

```swift
// Generated evaluate body: four direct key reads, including
try CounterRead<D>(try _model._giftUIKey(), read: read)
// Generated declaration visitor:
visitor.visit(&_model, declarationOrdinal: 0)
```

Swift reports `property '_model' is private and cannot be referenced from an
'@inlinable' function`, pointing to the preserved private `@State` declaration.
This is the reviewed material stop boundary, not a negative-client test pass.
Other diagnostics name package facade init/getter, Canvas model/init and State
key-method ABI visibility; those allowlisted dependencies remain unfinished.
Fixing their visibility alone would not remove the private backing references.
No public/package backing access, new alias/owner, unchecked projection or new
State representation was attempted. No presentation module/object was emitted.

Consequently no new physical-body decode, concrete consumer compile, wider owner
qualification (including Layout), private-client/lifetime/partial-init controls,
cold/reuse execution, allocation measurements, suite or image followed. Copied
unchanged shared dependencies qualify only this partial compiler attempt; they
are not fresh qualification of all corrective1 owner changes. Earlier immutable
runtime/image receipts remain evidence for their own frozen inputs.

This failed mechanism does **not** prove the strict contract impossible. The
[approved review](../p08-native-cold-pipeline-correction2-design-review.md) required
authored State privacy and original checked borrows; it prohibited changing the
State owner/alias/projection merely to serialize these methods. The present direct
body cannot satisfy that boundary. A future implementation effort would need a
new, bounded design/disposition specifically for **checked State declaration/read
access across the client-serialization boundary**, with fresh allowance and safety
evidence. A design retaining all normative contracts is an implementation choice;
exposing backing or unchecked construction, changing scope/lifetime/ownership APIs,
relaxing zero heap or changing compiler/runtime policy needs the actual upstream
ADR/Spec decision. No such decision or inevitability is inferred here.

The archive retains exact generated sources, current macro compiler inputs,
argv/raw logs and fresh schema outputs. An initial generated attribute-trivia
error was corrected **before presentation compilation**; that uncompiled output
is preserved. Macro compile/link and schema compile each occurred twice during
preparation. The first presentation compile failed once; there was no retry after
the private State error. The original plugin/modules were not overwritten.

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-correction2-result/verify.py
```

The verifier is offline and executes no compiler/workload. Maintained Swift
format lint, governance, local links and whitespace pass. Five external files and
the existing pycache are preserved. P08/R07/T8.1 and conformance remain open.
