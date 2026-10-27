# Supplied Sink terminal review — 27 October 2026

**Disposition: terminal evidence accepted; implementation acceptance BLOCKED.** The scoped compiled removal and six current maintained gates remain PASS within their recorded applicability. The full native collection stopped at its time cap and supplies no aggregate, runtime-oracle, output-equivalence, resource, or commit acceptance. Timeout does not establish a source or runtime defect.

This independent review performed only bounded reads, SHA-256 authentication and accounting of existing artifacts, and wrote this review. It did not compile, execute a test, acquire semantic proof, change source/index, or authorize another producer.

## Authenticated evidence

Reviewed `canonical-supplied-sink-result.json`, `-validation.json`, `-terminal.json`, `-full-transfer.json`, `-scope.json`, and the five copied files in the local `allocation/canonical-supplied-sink-full-timecap/` directory.

- The source-freeze receipt SHA-256 is `92d4468f38da7ffe978481462e08c918a26e5384559ef4b92e59e8e32f514d14`; all 62 recorded current source hashes match.
- All 373 selected scope evidence files match their recorded hashes and sizes.
- All twelve representative object hashes and all twelve full-emitted object hashes match their saved snapshots. All twelve after-exit hashes match the actual full-emitted files. Saved transfer comparisons agree for complete symbol rows, text and relocation maps, and sections excluding module hashes. This authenticates the saved comparison, without newly decoding machine code or claiming whole-object equality between builds.
- All six current gate receipt hashes, their 576 input entries and 663 artifact entries match. Their recorded checks support P07, schema4, SPEC006, SPEC007, SPEC011 and SPEC012 PASS. P07 reports 5914 assertions/0 failures; schema4 reports 428/0. Expected negative compilation checks, including schema4 checks explicitly marked `passed: true`, are not failures.
- Copied launch, ownership, terminal, stdout and stderr files are byte-identical to the retained full1 originals. Both outer stdout and stderr are empty; they do not replace missing execution results.

## Exact terminal and bounds

Full1 started at **10:03:35.822574 UTC**, with effective deadline **12:24:23.730598 UTC** and unchanged absolute phase cap **12:24:28.720613 UTC**. The watchdog triggered for `deadline` at **12:24:20.732149 UTC**, recorded group termination complete at **12:24:21.734382 UTC**, and the producer finished at **12:24:21.817770 UTC**, exit **-15**, without launch error. Elapsed time was **8445.995196 seconds**, ending **1.912828 seconds before the effective deadline**.

The last output sample was 801118333 bytes and explicitly was not final certification. The saved post-exit measurement was 801121244 bytes; with the 33554432-byte reserve it was **834675676 bytes**, below the **2147483648-byte** cap. This review independently summed the recorded, deduplicated bounded roots at **801134356 bytes before writing this review**; later terminal documentation explains why this exceeds the earlier saved measurement. It remains below the cap with reserve. No claim of continuous peak measurement or absolute operating-system enforcement is made.

The two complete finalization evidence directories contained **8110653 bytes before this review**, below the retained **8388608-byte** envelope; this small review fits the remaining 277955 bytes.

The full producer directory has **422 command-log entries**, no `result.json`, and no execute logs. Entries record issued commands, not completed checks. The transfer manifest's earlier `last_issued_output` is a snapshot, not the terminal command; the terminal record is authoritative for the last issued output. Scope text referring to the formerly active full receipt/afterhash remains historical planning context: afterhash is now authenticated, but the complete receipt never appeared.

## Applicability and next decision

The supplied concrete Sink/Codec removes the scoped old standalone generic RecordSink ownership/cleanup dependency. This review preserves the saved scoped compiled PASS; it does not independently redo that machine-code proof or broaden it. The accepted historical generic-Sink conditional allocator counterexample remains tied to its old source/key, not the new concrete Sink or changed Traversal key. Earlier failed, clipped and nonqualified evidence remains failed or nonqualified.

Changed Workspace/Traversal metadata and visitor-witness eligibility, other provider/error/indirect frontiers, actual live/cold state and full resource applicability remain OPEN. Unit FAILED and Interaction UNEXECUTED remain explicit; P09/P10 are outside this scope. Six component passes cannot substitute for the incomplete maintained full collection or these separate obligations.

**Stop with sources preserved and uncommitted.** The expired phase gives no automatic retry or extension. Recommended next authorization: **one fresh full-only maintained run, with a four-hour wall-clock cap, cumulative 2 GiB output limit and 32 MiB reserve, reusing the six hash-matching prerequisites and frozen source; no tooling, source or test changes.** The prior shared phase spent approximately 1 hour 39 minutes before full1, leaving approximately 2 hours 21 minutes for it; its timeout does not show a full-only four-hour run cannot finish, nor guarantee it will. Absent that explicit new budget, retain STOP. Enlarging an evidence allowance is not wall-clock authorization. A new run would permit work toward missing evidence, not waive full validation, remaining resource/safety obligations, or final independent acceptance. No architectural redesign or source repair is justified by this timeout alone.
