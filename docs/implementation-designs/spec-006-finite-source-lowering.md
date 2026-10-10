---
spec: SPEC-006
feature: giftui-mvp-architecture
title: Implementation Design — Finite Source Lowering
status: current
authors:
  - codex
created: 2026-10-10
updated: 2026-10-10
implementation_plan: ../implementation-plans/spec-006-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Finite Source Lowering

> This note explains a replaceable realization of the approved contract. It
> does not introduce architecture or amend the governing Specification.

## Purpose and Boundary

P02 realizes [SPEC-006's compiled View and traversal contract](../specs/spec-006-declarative-view-semantics.md#compiled-view-and-traversal),
DV-RD-001, DV-001/002/011/015–017. Its input surface is the P01
[route inventory](../../Tests/ContractFixtures/SPEC002/CompilerBaseline/route-inventory.tsv).
P03 owns State and checked mutation storage, P06 owns Canvas witnesses, and
P08/P09 own full counter/analyzer integration. A declaration compilation receipt
is not evidence that those owners or both complete applications have migrated.

## Current-Code Context and Source Organization

GiftUI's existing declaration files are amended in place. There is one maintained
View ABI and no migration conditional-compilation flag or duplicate source tree.
Historical comparison uses the P01 baseline revision and receipts. Existing runtime
consumers migrate in P03–P09 before the integrated P10 gate; a successful focused
P02 module build does not claim that the whole repository has completed migration.

The existing `GiftUIMacros` target owns finite source lowering through an explicit
`--lower-source` build invocation as well as compiler macro expansion. There is no
additional lowering target, public product or runtime dependency.
Generated schema imports GiftUI and existing application Domain modules;
generated Presentation imports that schema and GiftUI. Host/profile code supplies
the concrete read-domain Slot. GiftUI never imports application schemas.

## Data and Control Flow

A custom declaration is specialized to one D, with a generated
`_giftUIEvaluate(read:) throws(_GiftUIAccessFailure) -> some View<D>` witness.
The compiler infers Body. Stateless custom views use the same custom dispatch;
they do not receive leaf defaults. Framework leaves dispatch explicitly and keep
Never in the framework empty domain. Builder zero is lifted to D, and every
fixed/conditional/optional child must have D.

Model keys own no storage. Their logical owner/allocation/slot fields and
FrameRead's Span are visible only inside the repository package. Generated
read facades borrow the read's lifetime, validate binding through the domain
bridge and return owned typed scalars. Indexed access uses typed failure.
Source rewriting preserves expression order and control flow. SwiftOperators
folds the standard precedence table before rewriting. Throwing `&&`/`||` become
conditional expressions and throwing `??` becomes a typed immediate closure,
because Swift's standard rethrows operators otherwise erase the failure type.
Model binding remains at the original access site, including lazy operands.
No rewritten expression may manufacture a read, resolver or owning ticket.

The custom visitor owns read creation after binding. Its accessor returns an
owned body; the read's scope ends before traversing that body's children. P04
implements this sequence in Semantic Core, and P03 supplies its State bridge.
The macro emits the same-domain stateful accessor with a borrowing declaration
and read. Lowering supplies the evaluate witness before macro expansion.

## Algorithms, Effects and Diagnostics

SwiftSyntax parses and rewrites declaration bodies and constructors, never
occurrence topology, branch selections or parent/child tables. The finite call
inventory is checked before output. Unsupported calls, unknown model members,
mutable reference declarations and unchecked inout receive original file/line/
column diagnostics. Swift checks mixed domains, missing Body and scoped-value
escapes in generated modules. No output is accepted after a diagnostic.

Pure value helpers retain their input/output semantics. Helpers returning views
need D for composition; ordinary arithmetic/formatting helpers do not acquire a
model generic merely because they are called from a view. Additional inventory
syntax is implemented within P02; unknown effects cannot be silently admitted
by adding a permissive default. Checked mutation and Canvas implementations
remain their named packages' obligations.

## Profiles, Resources and Failure Behavior

The same lowering runs for native Dynamic/Static, ARMv6 and Embedded Swift.
Only the host supplies storage realization. SwiftSyntax/Foundation are host
build dependencies and never linked into GiftUI or target images. The new core
contains owned declaration temporaries, keys and borrowed spans, no registry or
expanded graph. P03/P04 measure actual store/record costs; P11 measures complete
linked costs. This note makes no zero-heap or complete-resource claim.

Typed body failure preserves `_GiftUIAccessFailure` until the coordinator maps
it through SPEC-010. Visitor declarations do not reinterpret it as capacity.
Storage validity and live-owner acquisition are bridge obligations, not facts
established by a generation comparison or a source transform.

## Alternatives and Open Questions

A blanket Never default was rejected because it admits missing custom bodies.
A universal Body.Domain constraint was rejected because leaves use Never.
Textual substitution was rejected because it cannot reliably distinguish call,
member, string and comment syntax. Expanded-graph generation is prohibited by
the governing contract. No architecture decision remains open here.

## Code and Evidence Links

- [Typed declarations](../../Sources/GiftUI/DeclarativeView.swift)
- [Finite lowering](../../Sources/GiftUIMacros/FiniteSourceLowering.swift)
- [State-host macro](../../Sources/GiftUIMacros/ObservableStateHostMacro.swift)
- [P02 progress and validation](../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p02/progress.md).
