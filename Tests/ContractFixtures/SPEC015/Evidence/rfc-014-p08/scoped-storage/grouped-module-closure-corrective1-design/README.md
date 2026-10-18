# Corrective1 design — targeted serialized root/dependency closure

**Independent design PASS; source/compiler unexecuted.** The
[review](../p08-grouped-module-closure-corrective1-independent-design-review.md)
passes the finite map and constructor guard below. Initial1/1 is
frozen at [physical/callee FAIL](../grouped-module-closure-codegen-result/README.md);
corrections0/2. The first reviewed corrective source edit consumes1/2, without
resetting any historical activity. [Exact map](candidate-map.json): **28 files,
67 named ABI type/protocol selectors,81 field/property selectors,65 serialized
function/helper selectors and42 ordinary ABI callee selectors**. These are targets,
not a blanket annotation script. Each file maps every named selector to R1–R6 or
its required caller/helper root and pins exact source bytes. Existing qualified
selectors are no-ops, excluded from implementation changes (none of the67 nominal
selectors currently has the target annotation). No unlisted member/type/file is
permitted; inherited or synthesized compiler diagnostics need grouped disposition.

## Evidence-backed mechanism

The exact [matching compiler source hashes](compiler-source-hashes.json) use
`swift-6.4.0-RELEASE`, commit `b8189d766d86ad7fc8106787d6ce9e402f38dd72`.
[CMO](https://github.com/swiftlang/swift/blob/b8189d766d86ad7fc8106787d6ce9e402f38dd72/lib/SILOptimizer/IPO/CrossModuleOptimization.cpp)
Default mode is conservative (1181–1192): candidate functions need Public SIL
linkage (331–350), referenced functions need suitable public linkage (632–635),
and the abstract size20 threshold still applies to generics (568–590). Merely
annotating signature types cannot guarantee large-body promotion. Explicitly
serialized functions bypass that heuristic at528–531. Type/import/callee validity
and source access remain separate checks; no policy flag change is selected.
[Mandatory inlining](https://github.com/swiftlang/swift/blob/b8189d766d86ad7fc8106787d6ce9e402f38dd72/lib/SILOptimizer/Mandatory/MandatoryInlining.cpp#L799)
first needs a loadable body and legal serialized linkage; an always-inline hint
cannot supply an absent body. No wrapper architecture or optimizer preproof is
claimed. Physical/caller gates must qualify the actual result.

1. Restore explicit source serialization only at the six proven required roots:
   Canvas lender, host activate/teardown, publication, scoped Canvas invocation
   and record dispatch, after making their exact signatures/bodies legal.
2. Include the two observed ordinary generic outer callers: `layout` (`0x11cac`)
   and `CanvasPlanProducer.derive` (`0x11e84`). Their named generic helper closure
   is explicit; otherwise serializing only publication/invocation cannot specialize
   these actual calls. Nongeneric arithmetic/counter helpers need ABI-callable
   linkage, without forcing their implementations into the client.
3. Include only actual checked factory callees: macOSStatic (`0x65f54`) and
   macOSDynamic (`0x668f4`), plus their same existing checked initializer. The Pi/
   nRF factories and their failure enums are excluded. Preserve kind validation,
   Optional result and `@_lifetime(copy owner)` exactly.
4. Apply `@usableFromInline` only to named package/internal nominal/protocol,
   field/getter and ordinary callee dependencies. Annotating a protocol gives its
   existing requirements the relevant formal scope; do not add implementation
   attributes to bodyless requirements. Do not annotate fields merely because
   their nominal is referenced. GlyphID's explicit RawRepresentable witnesses
   are named separately.
5. Where required, framework implementation fields/helpers become **internal**,
   never public/package capabilities. Package getters retain package access;
   named setters move private/fileprivate→internal only. Add only two explicit
   internal initializer equivalents: existing CanvasStagedEntry memberwise
   initialization (including invoked=false) and StackMeasure zero initialization.
   Match original field ownership/defaults and constructor behavior, not a new
   unchecked client path. All other bodies/algorithms are byte-preserved.

The two explicit initializer equivalents are already selected constructor targets
and must themselves be ABI-callable from the selected serialized bodies using
the existing attribute mechanism; do not rely on an inaccessible synthesized
initializer. Preserve CanvasStagedEntry's optional value/default nil and invoked
default false, along with identity/witness/value ownership and field assignment
order. StackMeasure retains all four zero defaults and existing zero-construction
behavior. Neither constructor gains package/public access, new backing or checks.

## Authority and forbidden boundary

The initial no-promotion realization was a derived choice, not a universal Spec
ban on framework-internal ABI implementation. Existing ObservableModelScope and
State.Storage demonstrate internal ABI-only realization with source-inaccessible
backing and lifetime-bound construction. Accepted ADR-039 and approved
[S11.2](../../../../../../../docs/specs/spec-011-interaction.md#s112-access-and-transaction-semantics)
require restricted access/no exported raw bank capability. Explicit private
requirements in [S13.1](../../../../../../../docs/specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
and [S15.1](../../../../../../../docs/specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement)
remain exact: concrete P08 accesses/session/provenance/inventory, supplied/pipeline/
retired fields/constructors, and coordinator admission/opportunity private setters
are **not edit targets**. Authored `_model`, State/macros/tests/helper realization,
all14 loans, Optional destination/complete lifetime union, exclusivity, checked
provenance/capacities, failure order, cleanup/backing-last, counts/IDs/payloads,
limits and compiler/enforcement policy remain unchanged. No public API or package
unchecked initializer/raw pointer getter is added. Normal-import same-package
and external clients must still reject internal scope construction/field access.

## Frozen corrective gate sequence

After independent design PASS, implement only the exact map, format, freeze source/
commands and start corrective1/2. Reuse only the unchanged qualified GiftUI,
Capabilities,FailureCore,CounterSchema/Presentation artifacts when all source/tool/
import identities match; rebuild every affected owner and dependent (including
CounterTable, registered8Static/13Dynamic owners and42-source actual host).
Sequentially collect all independently runnable owner diagnostics; block dependents,
never use stale modules, edit mid-sweep or auto-repair. This is no exhaustive
preproof of compiler-dependent inherited/signature/synthesized visibility legality.

A passing fresh closure precedes applicable normal-import privacy twins and the
existing original-State/read/lifetime/14-loan/Optional/cleanup controls. Fresh
negatives must specifically reject internal Canvas pointer construction/backing
access and host setters, with accessible checked-lender/factory positives.
Then require physical bodies for all named roots/callees, actual concrete host
SIL/object specialization and current ordinary/silent observer attribution at all42
origins. Stop/freeze any material failure for grouped review; no automatic source
repair. Only complete codegen+safety PASS permits unchanged strict host-first cold/
reuse. No prewarm, altered windows/counts/baselines, allocation exemption, broader
suite/image or connected action. Resource costs (including key-failure witness)
and P08/R07/T8.1 remain unaccepted.
