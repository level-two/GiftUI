# Independent observable callback design review — 2026-10-18

**READY for a separately authorized bounded candidate.** Reviewed 9b4b9be5:
40 selector sites/six files. Packet/receipt hashes and every declaration location/
source hash verify. No known material omission was found in the selected
preserved/live-seed-install/shared-helper closure. This is design readiness only;
current source/callback FAIL/STOP, prior limited PASS and budgets remain unchanged.

The proposed module-internal ABI ownsClaim flag is within the inspected contract.
[SPEC-010 131–137](../../../../../../docs/specs/spec-010-observable-reference-state.md)
requires “exactly one release obligation” and “An application ticket cannot outlive
its caller-supplied backing.” Its 95–103 binder clause requires “noncopyable and
nonescapable with compiler-visible lifetime dependence on actual borrowed root
and model storage.” These are preserved by unchanged ticket suppression/lifetime,
checked issuance/requireClaim/endOwnership/release and the true initial flag.
Internal ABI access adds no ordinary cross-module/package setter or issuance route.

SPEC-010 408–418 protects authored wrapper access and says “The sink has no public
initializer”; the existing package sink initializer retains its three required
arguments/private fields. [SPEC-015 319–375](../../../../../../docs/specs/spec-015-host-configuration.md)
requires concrete P08 accesses “with private fields/constructors” and private
supplied/pipeline geometry/interaction. None of these clauses mandates this
framework ticket flag itself be private. This is a scoped implementation-visibility
judgment, not an exception to exactly-one release or backing lifetime. Ownership
claims/records, lifecycle private state, authored State/_model, raw-key fields and
protected P08/14-loan/Optional boundaries remain excluded.

Record's six var-backed memberwise defaults are preserved in order: ordinal=0,
keyOwner=0, keyGeneration=0, attachment=nil, published=false, encountered=false.
Route preserves lifecycle=ObservableStateRegistrationLifecycle() and dirty=false.
Matched synthesis permits these var defaults, including Optional nil; both explicit
constructors retain internal access/implicit ownership/direct assignments and
ordinary ABI bodies. They introduce no unchecked public/package constructor.

The map covers generic operation/binding, nine model wrappers and three ticket
helpers with their direct signature/read dependencies. Nongeneric ledger,
reservation, lifecycle and fixed sink/report callback bodies remain ordinary ABI;
their private implementations need not serialize. Normal seed installation,
typed failure/release and original-failure preservation must retain exact ordering.
Ownership.bind remains an explicitly unresolved phantom-Schema cost/specialization
boundary, not a passed leaf or permission to expose ledger fields.

The proposed fresh compile/privacy/physical/same 42-SIL-object gates fit this scope.
Require internal flag/helper negatives, checked-operation positives, actual Model
callbacks and normal/error release/reclaim evidence; stop at material failures.
No source/compiler/decoder/runtime or new allowance occurred in review. Full 23/42
closure, complete safety, strict cold and P08/R07/T8.1/conformance remain open.
Protected external five/pycache remain unchanged and unstaged.
