# Independent finite non-Canvas constructor design review — 2026-10-18

**READY for a separately authorized bounded candidate.** Reviewed c57f59a9:
three selectors/two maintained files. Packet and maintained source hashes verify.
No material gap was found in this finite constructor rule; no source, compiler,
runtime, new candidate or repair allowance occurred in review.

The predicate must inspect the original initializer's direct owning struct and
source-file ancestry before rewritten generic parameters/attributes are considered.
Direct member ownership, direct top-level source-file placement, validated inventory
membership and that owner's own View/non-Canvas inheritance jointly prevent inherited
insideView flags or same-spelling inventory names from qualifying nested helpers.
This covers the known CounterScreen/ChildScreen family without name matching.

Only an existing explicit, ordinary, zero-parameter, body-bearing initializer can
gain one @usableFromInline: internal/package/default access and an ABI-eligible
original nongeneric owner (including public owners) are required. Public/private/
fileprivate/already-ABI initializers, Canvas members, parameter/default, generic/where,
failable/effectful forms, conditional/local/extension/nested owners and other
attribute/modifier forms keep their existing behavior.
@available is preserved. Exclusion is an annotation predicate, not added syntax
acceptance/rejection or a claim that excluded semantic fixtures compile.

Ordinary ABI access is appropriate for this failure: a serialized caller can name
the existing constructor while its private State initialization remains an ordinary
body. Matched formal-access rules require both member and enclosing nominal scope;
the proposal preserves the existing nominal rule and forbids @inlinable on these
constructors. It creates no constructor, required/default parameter, unchecked
issuance route or backing-field access, and preserves body/ownership/lifetime and
authored access. Existing Canvas initializer emission remains unchanged.

The retained 17-method actual-lowerer test family and explicit owner/overload/access/
effect/attribute matrix are suitable focused regressions. Require exact emitted
constructor attributes/signatures/body and private State tokens, including nested
helper/name-collision controls; do not equate parsing/expansion with semantic compile.
Fresh macro producer and main/multiple/nested Presentation/Table pairs must compile
through the registered fresh 25-owner closure before privacy/index/object/42-SIL
gates. The original nested 70→92 failure remains the regression receipt. Ordinary
constructor machine costs and complete private P08/14-loan/Optional/lifetime safety,
strict cold, zero heap and P08 acceptance remain unqualified. No general constructor
language expansion or remaining frontier source changes are approved by this review.
Protected external five/pycache remain untouched and unstaged.
