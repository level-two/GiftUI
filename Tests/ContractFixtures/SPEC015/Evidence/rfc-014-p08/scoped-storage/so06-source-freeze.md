# SO-06 initial source freeze — 2026-10-14

Approved input `9f832f6f`; sequential source checkpoints are SO-04
`fd879ad0` and SO-05 `825603a2`. This record and the SO-06 source/registration
changes form the final initial-pass checkpoint. The parent imposed the package
boundary at the current worktree: no further source edits or corrective pass.
Independent Strong SOURCE review is next, before any separately approved
validation. This is a source handoff, not acceptance of SO-04–06 criteria.

The source adds `CounterScopedStorageProbe.swift`, scoped owner/session corpus,
physical reservation/fault/cleanup controls, and mechanical source registration
in the existing SPEC-011/013/015 drivers. Selected Static/Dynamic host-kind
checks now use the actual selected host kind. `CounterAdmission.swift` changed
only the four approved conformance requirements in SO-05; runtime coordinator
source and target/CMake/firmware recipes were not changed.

Source-present corpus intentions include before/after faults at each initialized
object (Static/Embedded 14, Dynamic 9), Embedded partial UInt8 prefixes,
below/equal capacity controls, unequal/oversized R1 reservations, original
addresses/extents and reverse destruction, three repeated sessions, six R/H
exchanges with unequal committed counts, discard/poison controls, five early
body stages and all eleven construction stages. Existing host activation,
graph, action, semantic, pixel, join, wake and admission controls remain.
Native overlap uses an actual owner borrow and opaque competing access, with a
positive twin, under a test-only define. None of these cases was executed.

## Exact newly registered labels

`check-spec-015-counter.py` registers each Cartesian combination below, in
source order, with a positive before its negative. These are planned command
labels, not results or permission to execute.

* `so06-union-{route}-{mode}-{origin}-{polarity}`: route `static`, then
  `dynamic` (dynamic omitted for Embedded); mode `direct`, then `generic`;
  origin `geometry`, `candidateRecords`, `candidateHitRegions`,
  `candidateCommittedRecords`, `committedRecords`, `committedHitRegions`,
  `models`, `root`, `semantic`, `values`, `control`, `activationSpan`;
  polarity `positive`, then `negative`. 96 labels native/Pi; 48 Embedded.
* Each of `counter-host-copy`, `counter-host-backing`,
  `so06-use-after-consume`, `so06-owned-return`, `so06-private-construction`,
  `so06-private-extraction`, `so06-arbitrary-factory`,
  `so06-optional-erasure`, `so06-tuple-erasure`, `so06-generic-erasure`,
  `so06-closure-erasure`, `so06-sendable`, `so06-static-overlap` receives
  `-positive`, then `-negative`. 26 labels each profile.
* Non-Embedded additionally registers
  `counter-dynamic-host-backing-positive`,
  `counter-dynamic-host-backing-negative`, `so06-task-positive`,
  `so06-task-negative`, `so06-async-positive`, `so06-async-negative`.
* Native additionally registers `so06-native-exclusivity-module`,
  `so06-native-exclusivity-positive-link`,
  `so06-native-exclusivity-positive-execute`,
  `so06-native-exclusivity-negative-link`,
  `so06-native-exclusivity-negative-execute`. Negative execution expects both
  `Simultaneous accesses` and `Fatal access conflict`.

Totals: 128 compiler oracle labels per non-Embedded route, 74 Embedded;
five additional Native runtime-overlap labels. Existing module/link/route
labels remain in the driver. Source registration in other drivers does not
claim that those drivers exercise the private counter package.

## Honest limitations and review handoff

All source is uncompiled and all new positives/negatives unvalidated. Review
must assess Swift declaration/lifetime syntax, Optional-slot projection and
aliasing, full carrier union, consuming retirement, every cleanup path,
reservation/audit arithmetic, and intended diagnostic specificity. The label
`counter-dynamic-host-backing` currently uses the common session escape seam,
not a distinct Dynamic host escape body; do not infer specialized coverage.
Native runtime exclusivity is an intended dynamic overlap, not a demonstrated
trap. Corpus intentions do not establish that every required criterion has a
sufficient independent oracle.

Checked runtime layout source exists; an emitted target-constant ELF layout
table and numeric C-reservation reconciliation are not supplied by this
checkpoint. The Embedded surplus test borrows two idle existing caller slots;
its `counterEmbeddedSlotBytes * 2` expression has not been checked for overflow
by the source and requires review against the arithmetic requirement. No C
reservation size or target limit was changed. Allocation reachability, ABI,
destruction, exact resource costs, target layout and whole-image/stack fit are
unproved. The historic 58,648 versus 27,648 stack failure remains open.

Permitted checks pass: `git diff --check`, `scripts/validate-governance.rb`
(198 nodes, 2,019 edges; existing task evidence manifests), and 342 local
Markdown file links across this ledger and three current navigation records,
with no missing files.

No Swift compiler, build, test harness/executable, formatter, debugger, IR,
image, target or hardware invocation occurred. Only permitted whitespace and
governance/document checks accompany this checkpoint. The initial source pass
is now frozen; zero post-freeze corrective passes, no reset or new allowance.
All SO criteria, fit, P08/R07/T8.1, I4-07/P09–P12, lifecycle statuses, historic
budgets and the cumulative guard remain unchanged. SO-07–09 remain separately
gated; source review must classify completeness/gaps before validation dispatch.
