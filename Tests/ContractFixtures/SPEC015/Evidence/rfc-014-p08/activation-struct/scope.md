# P08 invariant struct anchor — 2026-10-12

Bounded assignment under the maintainer's continuing request to resolve P08 with
bounded delegated work. The matched-boundary assignment is closed: its minimal
enum-wrapped span, independently of all GiftUI modules, accepts a reachable
callback escape under the same boundary where the direct span rejects it.
Prior raw controls and closed ledgers remain unchanged.

Test one internal representation change: a noncopyable scoped struct retains an
invariant private `Span<UInt8>` field outside its mutable inert/active enum state.
Keep the borrowed anchor separate from the consumed/reconstructed enum payload.
This remains one concrete host owner with private state, not a new host role,
public abstraction, module boundary, compiler feature, or contract change.

First establish a minimal struct positive and reachable escape negative under
the exact passing primitive boundary. If that negative is accepted, stop; do not
try the real host or another representation. If it rejects correctly, use the
struct to contain the previously compiling real activation state, with actual
backing scopes and constructors unchanged. Keep the anchor read before use and
retain the existing checked receiver-dependence annotations where applicable.

Strong Astra 6 Medium; one compiler owner; no nested delegation. At most eight
fresh compiler invocations including corrections/links. Required controls are
minimal struct positive/negative, actual activation/opportunity/quiescence
execution, reachable active callback escape, copy rejection, local backing-expiry
rejection, and constant-seed callback escape. Never execute accepted negatives.
Stop at completion, budget exhaustion, the failed primitive, or two consecutive
attempts without a passing check or narrower cause. Record exact source, command,
compiler/dependency identity and complete diagnostics for every invocation.

Freeze and commit the outcome for independent Strong review before adoption.
The maintained regression checker remains unapplied until a verified pattern
exists. No package acceptance, resource waiver, or hardware work is implied.
