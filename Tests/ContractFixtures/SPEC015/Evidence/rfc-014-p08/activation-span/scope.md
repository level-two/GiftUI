# P08 retained activation-span correction — 2026-10-11

Bounded assignment under the maintainer's continuing request to resolve the P08
blocker and delegate bounded work without repeated permission. The prior token
assignment is closed at `25806a1e`; its accepted reachable escape controls remain
failed evidence, not an adopted implementation. No previous budget is reopened.

## Evidence and one hypothesis

Generic supplied storage and scoped-control constructors allow actual runtime
activation, opportunity and quiescence. An annotation-only callback token does
not supply the required containment in tested controls: the active enum retains
the coordinator, whose concrete fields retain only raw control pointers.

Test one stronger, concrete representation: a `Span<UInt8>` borrowing an actual
callback-local `InlineArray<1, UInt8>`, retained explicitly in both inert and
active states and read before runtime use. The span is supplied by the standard
library's safe projection, not an unsafe pointer lifetime override. SE-0456
describes that borrowing relationship:
https://github.com/swiftlang/swift-evolution/blob/main/proposals/0456-stdlib-span-properties.md
This motivates the control, but does not establish behavior of the pinned
compiler; only the recorded tests may do that.

First discriminate the direct span lifetime in the same callback/capture shape.
Then, only if that primitive rejects a reachable forbidden escape, apply the
retained span to the actual join. Keep real model/root/semantic/Canvas/geometry/
control scopes, activation ordering, existing owner roles and compiler unchanged.
The marker neither substitutes for backing ownership nor allows any scope to end
while the host remains usable. Account for its actual inline/view storage if
adopted. Factory construction must keep the marker inside the supplying callbacks.

## Bound and acceptance

Strong Astra 6 Medium, one compiler owner, no nested delegation; at most eight
fresh compiler invocations including corrections and links. Stop after two
consecutive attempts with no passing check or narrower cause, completion, budget
exhaustion, or failure of the direct span primitive. Preserve all commands,
sources, compiler/dependency hashes and diagnostics. Accepted negative executables
must never run.

Required: direct primitive positive/escape comparison; actual initialization,
activation/opportunity/quiescence positive execution; copy rejection; reachable
active callback escape rejection; local-profile backing-expiry rejection. An
unused negative function is insufficient. Freeze/commit the result for independent
Strong review before adoption into maintained host/controller regression.

This changes no approved contract, public or cross-module API, toolchain,
hardware authorization, package scope or lifecycle acceptance.
