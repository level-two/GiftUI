# Independent checked-State corrective1 failure / final correction review — 2026-10-17

**Evidence PASS; final grouped corrective2 recipe PASS.** Reviewed `e12983d0`,
the [corrective1 packet](checked-state-correction1/README.md), current lowerer,
helper validator/tests and all declaration boundaries in the emitted counter.
Initial1/1 and corrections1/2 are consumed; **one final correction remains**.
Historical Native pipeline2/2 stays closed. No maintained-source edit, compiler,
parser execution, decoder or runtime occurred in this review. No implementation,
privacy, resource or cold feasibility PASS is claimed.

## Failure and scope

Offline verification passes all52 archived members; all20 archived maintained
source identities match current files. The exact six fresh invocations ran once:
macro compile/link, actual lowering, GiftUI and schema compile PASS, then first
presentation compile FAIL. The mapper annotation is exactly the previously
reviewed one-line change, and resolves the earlier schema failure.

The raw presentation log contains exactly two `consecutive declarations` errors
at emitted lines72/76, both `}@usableFromInline`. Read-only inspection confirms
evaluation→storage projection and storage projection→key helper are the two
missing separators. Both arise from `Lowerer.visit(StructDeclSyntax)` appending
`MemberBlockItemSyntax(decl: helper)` while the helper begins with an attribute
and the preceding declaration ends with `}`. Every helper uses that one append
site; the Domain insertion already carries a trailing newline. Other displayed
schema/presentation declaration boundaries are separated, and no third helper
or new unallowlisted direct reference is introduced by this correction.

Existing helper macro tests build strings using `joined(separator: "\n")`, so
they validate helper selection but conceal the actual assembly defect. Lowering
checks authored input syntax and lowering diagnostics, then writes the rewritten
presentation without parsing it. Corrective1 stops before a presentation module,
private-client controls, physical bodies/yield, actual consumer or runtime.

## Final grouped source recipe

Within the existing exact lowerer/test allowlist:

1. At the existing helper append, give **every appended helper member** separating
   leading newline trivia. Preserve the full helper AST, token spelling, ABI
   attributes, opaque bodies, original private State field, concrete schema,
   checked key access, declaration ordering and semantic visit ordinals. One
   newline at this assembly boundary handles both current errors and successive
   pairs for multiple States. Do not patch generated Counter.swift, insert
   semicolons by string replacement, depend on a formatter repairing output, or
   alter schema/evaluation/ownership algorithms.
2. In `ObservableStateHostMacroTests.swift`, add a focused regression invoking
   **actual `lowerGiftUISource` and reading its written presentation verbatim**.
   Parse that output before macro expansion, asserting no parser error/missing
   separator and the expected distinct original-wrapper helper members. Cover the
   actual unchanged Counter/schema and supported multiple/nested-State inputs;
   retain existing malicious helper controls and lexical ordinals. Do not join
   helper strings, reformat output, reconstruct declarations or replace delimiters
   to make the positive parse succeed. Test the parser's sensitivity against the
   frozen failing emitted output (the two known missing separators), so a checker
   that misses this defect cannot certify the regression.
3. Format maintained Swift, rebuild the changed macro once and run that focused
   actual-output parse regression **before** fresh GiftUI/schema/presentation
   compilation. Archive the actual emitted source, parser result, exact commands,
   tool/module/source hashes and expected negative result. The negative parser
   control is an intentional expected failure, not a source repair or retry.
   Avoid the broad suite. A failed positive regression is a material failure:
   freeze it and stop rather than adding another source variant.

The new regression belongs in the already allowlisted test file; no production
parse-policy/API or new dependency is required. The source correction belongs to
the already allowlisted `Lowerer.visit(StructDeclSyntax)` helper append. This is
emission correctness under the approved contract, not an architectural decision
or additional activity. No upstream approval is missing for this exact recipe.

## Continuation and final stop

The author may begin this final grouped correction under the standing authorized
activity after recording the exact pre-edit freeze. Its first source edit consumes
correction2/2. A focused parse PASS permits unchanged fresh provider/privacy gates;
then require real serialized evaluate/traverse/visitor bodies, opaque owning-helper
definitions and the actual concrete binder/schema/domain consumer before further
pipeline or safety/cold gates. Retain exact original-wrapper yield and coroutine
cleanup, privacy, fourteen actual-owner loans, provenance/Optional lifetime union,
exclusivity, failure-prefix unwind and strict construction/action/teardown zero heap.

No further automatic source variant follows a material failure: freeze the exact
residual and obtain independent final disposition. A passing provider alone does
not accept source or close P08/R07/T8.1. Affected profile/image, complete physical/
allocation/stack and Dynamic/caller/exit obligations remain as already recorded.
No new allowance, restore, deployment, flashing or global toolchain change.
Five external edits and pycache are preserved. Documentation/governance/local
target/whitespace checks pass; no correctness question is deferred.
