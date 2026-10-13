# SO-03 single native invocation result — 2026-10-13

**FAILED; source frozen, no repair or retry.** Unvalidated source commit
`4c7e8bc22e0febd9f2adf0fbae8939906e62a824` was clean at driver entry. The exact
[invocation/exit/count record](attempt-1/invocation.json),
[full invocation output](attempt-1/invocation.log),
[failure-safe driver receipt](attempt-1/result.json),
[actual complete planned argv](attempt-1/planned-commands.json) and
[attempted argv](attempt-1/commands.txt) preserve the one authorized run:

```text
scripts/contracts/run-spec-011.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014-swift64/af66aaf967e3fe8f-__4p5wu2/macos-dynamic
```

Driver exit1. Allowance is **1/1 invocation consumed,0 remaining; automatic
repairs0**. Planned42compiler+1execute43; actual14compiler commands,13 passed
and1 failed. Both added prerequisite cells passed. The27 focused probe cells,
link and execute were not reached. Unattempted cells are absent evidence and
create no further invocation allowance.

| Attempted cell(s) | Result / boundary |
| --- | --- |
| GiftUISemanticCore, GiftUITextResources, GiftUILayout, GiftUIRenderCore, GiftUIExecution | Module compile success |
| GiftUIInteraction | Exact declarations/state/owned instrumentation module compiled; no complete lifetime matrix claim |
| GiftUIObservableState | Actual protocol/source tuple compiled |
| so03-prereq-render-lowering, so03-prereq-drawing | Both exact real prerequisites compiled |
| GiftUIRuntimeStatic, GiftUIRuntimeDynamic | Registered owned bank/model/root inputs compiled |
| GiftUIRuntimeCore | All six real consumer sources plus RuntimeOwnerFailure compiled |
| key-layout | Existing14-value IR layout check passed; [facts](attempt-1/key-layout.json) and [IR](attempt-1/key-layout.ll) retained |
| OwnedKeyProbe | Positive fixture compilation failed; no runtime or expected-negative pass |

The exact [OwnedKeyProbe diagnostics](attempt-1/OwnedKeyProbe.log) identify eight
primary error locations in new ScopedStorageProbe.swift. Committed exchange
lines68/70 and hit exchange101/103 cannot partially reinitialize self/other after
consuming their MutableSpan fields. Committed method64 and hit method97 also
report lifetime-dependent self/other variables escaping their scope because each
acquires the other's lifetime. These are observed compiler diagnostics in the
minimal fixture realization; this result does not establish a governing-contract
failure, a selected SO-04 physical-owner failure or a repair choice. No source
change followed the first failure.

[Source freeze](source-freeze.json) and [source diff](source.diff) remain the exact
precompiler inputs. All122 frozen source hashes still match after failure.
The original analyzer factory hashes,24 unaffected core/factory pins and pinned
compiler/macro hashes were verified read-only before entry. Driver receipt
freezes actual flags, hashes and exact43 planned argv before its first compiler.
The [80 partial artifact hashes](attempt-1/artifact-hashes.json) all match actual
files. Complete text logs/plans/IR/result are copied here; generated object/module
artifacts remain untouched in the immutable local directory
`.build/contracts/spec-011-owned-keys/tmpubqsj1v5/macos-dynamic`. No binary is
presented as a linked or executable result.

Precompiler formatter, governance198nodes/2019edges/task manifests, Python AST/
static command arithmetic and diff checks passed. The four mechanical owned
measurement-signature additions are documented in the dispatch; this component
route hashes/source-inspects the Counter/Cycle measurement callers but does not
compile their complete later fixture graphs. Their compatibility evidence stays
open. Actual analyzer factories remain unchanged, with mandatory unresolved
I4-07 integration/owned-return evidence and existing separate P09/P10–12 handoff.

No target/image/repository-suite/compiler-probe/automatic repair/hardware action
ran. All nine SO criteria, HC-RD-003, P08/R07/T8.1, physical resource/stack fit and
later conformance remain open. Historical consumed allowances,58,648/27,648
failure and two-consecutive-unproductive guard are unchanged. This implementer
does not classify the run productive/unproductive; independent review owns that
disposition.

## Exact independent review handoff

Sequential independent Strong read-only result review must inspect source
`4c7e8bc2`, this frozen attempt and approved S11/design/packet. Verify source/input/
compiler/macro/artifact identities, finite counts and immediate failure stop;
assess the owned instrumentation/only-four-signature propagation and complete
caller applicability. Determine whether the eight fixture diagnostics are a local
realization defect or expose a contract/required-scope choice, and assess the
unreached positive/negative matrix without treating module compilation as its
substitute. Record productive/unproductive guard disposition and the smallest
concrete next handoff/required authority. No source fix, compiler/test/driver,
image or hardware action is authorized by this outcome. SO-04–09 remain
proposed/unapproved; any repair and renewed invocation need their exact separate
allowance after review.
