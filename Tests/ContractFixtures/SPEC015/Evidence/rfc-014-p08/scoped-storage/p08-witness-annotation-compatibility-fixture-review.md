# Independent grouped annotation compatibility fixture review — 2026-10-17

**PASS for the fixture-only continuation; source remains frozen and unaccepted.**
Reviewed candidate `22589fec`, the [result and raw archive](annotation-compatibility-candidate1/README.md),
all three remaining ordinary fixture forms, explicit-D.Type scope twins and their
exact stored commands. No compiler, test, runtime, decoder or source edit ran in
this review. The result archive's 101 file hashes and all 81 frozen input hashes
match, including production source, maintained tests, providers/harness inputs,
the five external modifications and pycache. The exact 17 registered maintained
methods ran with zero failures/skips; fresh provider and five clean privacy
controls pass. Four ordinary visibility positives pass. The public positive's
sole error is its package-only generic constraint in a public declaration.

`CounterReadDomain` is `@usableFromInline package`, not public. Each of
`ordinary-public.swift`, `ordinary-abi.swift` and `ordinary-enclosing-private.swift`
declares the same public generic host with that constraint. ABI visibility does
not make the source signature legal. All three fixtures need the same single
constraint substitution to the existing public `_GiftUIReadDomain`. They use
`EmptyView<D>` and private concrete Counter State schema/seed, with no Counter
domain operation, so the weaker constraint meets their complete type needs.
Their private backing, host/Domain/evaluation access, original macro invocation,
private dependency in the ABI control and private enclosure remain identical.
The corrected public host's exported signature references only public types;
the package schema stays solely in private storage. No provider access widening
or production correction is warranted by this failed test setup.

Permit exactly five continuation invocations: the three corrected ordinary
positives, then the unchanged scope positive and isolated package-access negative.
Create corrected fixture copies and fresh logs/freeze/argv under a new output
directory; preserve the archived failed and unrun original bytes. Use the exact
original source/test, provider module/object and plugin hashes. Reuse the stored
pinned compiler/SDK/lifetime/optimization/import/module-name recipe, remapping
only fixture/output/cache paths. Freeze copies, argv and input hashes before
execution. No maintained source/test/runner, provider, protocol or annotation
change, extra control or source candidate is included.

The scope fixture has D directly in `D.Type`, and constructs the nonescapable
FrameRead only from its supplied Span. It imports GiftUI normally. Both commands
use identical source, module name and compiler flags; their only semantic
difference is package `giftui` versus `outside`. The same-package positive must
compile first. The external negative must contain exactly the intended package
initializer error, with every error diagnostic inspected and no signature,
lookup/import/type/lifetime error. Do not accept a nonzero exit or substring alone.

The continuation must stop/freeze its first unexpected failure and preserve the
original 18-attempt STOP receipt. Candidate1/1 and zero automatic source repairs
remain exact; checked-State initial1/1/corrections2/2 and Native pipeline2/2 stay
closed. This fixture validity correction is inside the original testing scope;
it is no production retry, allowance reset or source acceptance. Physical
serialized-body/helper/actual-consumer command review and execution, then safety
and strict host-first cold gates, still require all compatibility/privacy PASS.
P08/R07/T8.1/conformance remain open. Whitespace and local review links were
checked; no connected hardware, toolchain change or new design activity follows.
