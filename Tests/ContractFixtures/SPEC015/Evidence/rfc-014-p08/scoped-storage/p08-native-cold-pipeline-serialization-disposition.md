# Independent serialization boundary disposition — 2026-10-17

Subsequent [physical-module decode and bounded ABI-visibility proposal](native-cold-pipeline-serialization-result/README.md)
establishes body absence for the exact traversal and evaluate records, with a
serialized state-visitor control. It identifies the enclosing nominal formal-scope
gate; proposed correction remains unexecuted and requires independent review.

**No evidence-backed final source correction identified.** Reviewed `6869697e`,
`65d011e4`, preceding diagnostic results, provider/source linkage and the existing
tool inventory. Offline loading-packet verification passes (all21 members);
observer raw stderr/SIL hashes match. Fresh physical imports and actual generated
`@inlinable` / `@inline(__always)` are established. The actual host generic apply
persists. Duplicate modules or a missing source annotation do not explain this
replay. **1/2 corrective cycles consumed; corrective2 remains unstarted.**

## What is and is not established

The observer has **14 declaration-shaped SIL dumps, each with no basic block**.
Its earlier reported28 is a counting error: the exact mangled symbol occurs28
times as14 headers plus14 end-function lines. The [observer result](native-cold-pipeline-consumer-pass-observer/result.json)
is corrected explicitly; raw artifacts are unchanged. PerformanceSILLinker ran,
but neither that fact nor absent bodies in these dumps identifies its per-symbol
request/lookup/deserialization decision. The earlier original-object generic host
call `0x54874` remains valid independently of this count.

Provider emitted SIL has a body; generated traversal/evaluate methods are package
members of package `CounterScreen`, with the private read closure. Provider SIL
headers carry heuristic-always-inline but do not display a serialized marker.
These are concrete linkage/visibility observations, not a sufficient physical
serialization diagnosis. The matching44856-byte provider module is unchanged.
There is no justified choice here among changing enclosing declaration visibility,
forcing another emission attribute, changing consumer forwarding, or doing nothing
until deserialization is understood. In particular, do not publish an unchecked
constructor, widen the normative API, enable package-CMO/unchecked policy, or spend
the last cycle on a stronger-annotation guess.

The precise missing observation is the exact symbol's **physical serialized SIL
function/body record and index/linkage**, or a matching deserializer observation
that states whether that record was requested/found/accepted and why it was not
provided. The symbol is:

```text
$s22P08CounterPresentation0B6ScreenV15_giftUITraverseyyqd__z6DomainQyd__Rsz6GiftUI01_H26UISemanticTraversalVisitorRd__Ri_d__Ri0_d__lF
```

No-body final/intermediate optimized output does not answer that question. This
is not proof of a Swift defect, impossibility or inability to specialize recursion.
Layout's failed compile and other changed owners also remain unqualified.

## Smallest next assignment

**Stop the current compiler-replay package and assign one bounded read-only
artifact-decoding investigation.** This is a tooling/task-boundary decision under
the existing strict implementation authorization, not a newly discovered
architecture/contract choice or a reason to ask the user to reconfirm that goal.
No next compiler replay or application source correction is authorized by this
disposition. All prior activity/repair limits and the aborted restoration remain.

The next assignment should do exactly this:

1. Inspect only frozen `P08CounterPresentation.swiftmodule`, SHA256
   `aa24dafcd48c8dc1079bae766633e723f980767af04240b7f11bd4b125e71439`,
   and its exact traversal symbol above, with the immediate evaluate/read closure
   records needed to interpret its serialization. Use the committed loading
   packet's `provider-prior-pass/P08CounterPresentation.swiftmodule` or matching
   original module; verify44856 bytes and hash before/after. Do not regenerate it.
2. Establish a decoder executable before running any more Swift compilation.
   The pinned tool inventory, Xcode tool bin, `.toolchains` and existing checkout
   search reveal no ready `llvm-bcanalyzer`, `sil-opt`, SIL function extractor or
   Swift serialization source. A compatible **analysis-only** LLVM bitstream
   decoder plus matching Swift6.4 serialization schema is therefore an external
   tooling prerequisite, not a change to the application's pinned compiler.
   Use a local existing decoder if found; otherwise obtain a verified prebuilt
   analysis tool under `.toolchains/` and the official matching release's
   serialization schema in a separate bounded tooling assignment. Do not install
   globally or start a compiler/toolchain build campaign. Record tool/version/hash
   and schema release/hash; if no compatible prebuilt route exists, stop there.
3. The concrete artifact operation, once that tool is qualified, is
   `llvm-bcanalyzer -dump <frozen-P08CounterPresentation.swiftmodule>` with stdout/
   stderr/exit/hash retained. It must actually recognize the Swift module's
   bitstream, not merely list printable strings. Resolve the exact symbol through
   the decoded SIL index/string references to its record/body offset and inspect
   its serialization/linkage/body/block records using the matching schema.
   A generic block count, declaration AST body or similarly named witness is not
   that observation. This command is a proposed external-tool route, not a claim
   that an absent local executable has been validated.
4. Stop after this one decode and interpretation. Report **body present**, **body
   absent with complete index/record evidence**, or **decoder/schema insufficient**.
   Body present would move the missing evidence to the exact consumer's
   deserializer eligibility/request/rejection reason; it would not itself explain
   the optimizer. That result requires a separately scoped deserializer
   investigation before any instrumented compiler build/replay, not an automatic
   fallback. Body absent may support a precise serialization repair only after
   matching the declaration/linkage rule to the recorded source. Neither result
   promises a zero-heap candidate or authorizes a policy/API/algorithm change.

The frozen help also lists `--parse-serialized-sil` as “Parse the output of a
serialized module”. It supplies no established physical-module input command or
per-symbol failure explanation in this packet. It is not an executable substitute
for the missing decoder route, and does not justify another consumer flag probe.

A specific internal repair, if established, can use the remaining grouped cycle
under standing authorization and must pass all reviewed codegen/lifetime/private
client and actual cold/reuse gates. Until then the source experiment remains
unaccepted; P08/R07/T8.1 and all remaining resource/profile/exit ledgers stay open.
No full-suite, runtime, image, source edit, restoration or compiler operation ran
in this review. External five files and pycache remain unchanged. Governance,
local links and whitespace pass.
