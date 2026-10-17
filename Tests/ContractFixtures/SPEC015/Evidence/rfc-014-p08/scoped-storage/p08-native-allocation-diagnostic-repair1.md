# Native allocation collector repair1 — 2026-10-17

**Diagnostic repair/preparation PASS; matched rerun not executed.** This consumes
repair1 of the explicitly authorized maximum2 diagnostic repair cycles. It is
collector correctness work, not a new application source allowance. The
[updated executable protocol](native-allocation-diagnostic/README.md) is ready
for one sequential mechanical rerun into a new directory; stop on first failure.

## Preserved failure and mechanism

The first matched Dynamic process exited11 before Static or any repeat ran.
Its cold/reuse entry counts are both1,734,943. The immutable local directory
`.build/contracts/p08-native-allocation-matched-20261017` and wrapper
`.build/contracts/p08-integrated-activity/20261017T013743427204Z-p08-native-allocation-matched/`
remain unchanged. The [compact frozen inventory](native-allocation-diagnostic/repair1/failed-summary.json)
pins the77,521,832-byte stderr, stdout, executables, original observer/driver and
manifests by SHA. [Read-only extractor](native-allocation-diagnostic/repair1/inspect_failed.py)
reproduces the summary; the77MB text is not copied into Git.

All8,192 retained full-stack groups are distinct paths with resolved PCs
(1,363unique PCs, zero unknown-image frames). Unique prefixes grow67→1,009→2,613
at2/8/12frames;7,391groups hit24frames. This is real path diversity, not a corrupt
frame-address key. The fixed full-path group table fills despite a maximum436
simultaneous allocation records. Cold flags27,236group saturations and93,069
truncations; reuse flags95,154saturations/92,147truncations, because the full table
cannot admit its separate cohort. Foreign/allocator-failure flags are zero.
Dropped/truncated groups are **not accepted attribution or resource evidence**.

The repair removes in-process full-path grouping. Exact allocation/retirement
records, allocation identities and captured PC vectors stream to a new file via
a preopened descriptor and64KiB buffer. Capture must reach the actual C driver
frame within512PCs; invalid chains/truncation, PC/record capacity or I/O failure
reject the run. Unique PC symbols are reported once, avoiding repeated enormous
symbol strings. Offline exact replay checks sequence, cold/reuse baseline,
retirement identities and every client-live/count/peak field against C, then
retains all exact full-vector groups without a fixed group capacity or prefix
collapse. No unrecorded group becomes covered by aggregation.

## Focused verification and handoff

Final local preparation is `.build/contracts/p08-native-allocation-repair1-validation-c`.
The [manifest](native-allocation-diagnostic/repair1/validation/manifest.json) and
[commands](native-allocation-diagnostic/repair1/validation/commands.json) bind both
25-original-object links,201current input hashes/profile, compiler and original
object-size/SHA/owning-receipt checks. No Swift source was compiled. The
[standalone log](native-allocation-diagnostic/repair1/validation/validation.log)
and [small event trace](native-allocation-diagnostic/repair1/validation/validation.events)
replay exactly:130events/32groups, max36frames for a32-deep call control; valid
captures reach the driver. Deliberate two-frame truncation, one-record/one-PC
capacity overflow and closed-output writes are rejected by the same predicate as
the matched process. Replay rejects partial records and truncated-root captures.
The synthetic20,000distinct full paths sharing8-PC prefixes remain20,000groups;
these are collector controls, not workload execution. Positive public API,
retained-cold/reuse and foreign-thread controls remain passing. The original
public-hook direct-zone blind spot remains an explicit negative control.

Run the README command once with `--run`; preserve the full event files and
replayed compressed groups. Requested/reserved values remain rounded client
storage, not allocator arena/VM bookkeeping; Swift headers/control already inside
requests need source/runtime attribution. Observer buffers/capture/PC tables and
I/O remain diagnostic costs. Actual direct-zone/VM/temp/runtime reachability,
selected Static versus common fixture attribution and complete Native/Pi
stack/physical evidence remain open. No source optimization, firmware/compiler
suite, target execution, lifecycle change or repair-budget reset occurred.
Five external files and known pycache stay untouched/uncommitted.
