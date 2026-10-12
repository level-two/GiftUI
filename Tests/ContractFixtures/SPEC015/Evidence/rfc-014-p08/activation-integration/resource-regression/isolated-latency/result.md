# Isolated native latency correction

The coordinated isolated runs pass SPEC003's native latency ceiling. Static p99
is250 ns and Dynamic p99 is125 ns, each below100000 ns. Both preserve1000 warm-up
iterations and10000 raw measured samples, -O/WMO, approvedSwift6.4 and the reference
Mac15,7 /macOS26.6.2 build25G83 identity. No measured sample was discarded.

The interval is2026-10-12T05:11:32.085925+00:00 through
2026-10-12T05:11:35.973892+00:00; exact per-profile start/end, commit, compiler,
commands and source hashes are in receipt.json. Four compile/link invocations
and two executions completed, with no repair or retry.

Before clearance the parent inspected repository build/compiler processes and
found only its inspection shell/filter. Standard had no active build process,
reviewer was idle, and parent held all other repository jobs until the FINISHED
message after both runs. pre-process-check.json preserves the supplied command,
reported output and ordering. The inspection had no absolute timestamp; none is
invented. The only running repository task in the recorded interval was this
latency check. This is coordinated isolation evidence, not merely runner_match.

A post-run process snapshot is unavailable: sandbox ps failed, and its escalated
retry remained pending until interruption without output. This happened after
both measurements. No post-run inspection success is claimed. Isolation relies
on the recorded pre-inspection and held coordination interval; no concurrent job
was observed or reported in that interval. Independent review must assess this
explicit limitation against the scope's originally requested post-snapshot.

The earlier42 ns Static /84 ns Dynamic samples remain intact as informative
measurements because their concurrent-job condition was not established. These
new samples supersede their normative timing claim. Other resource/layout/ABI
results are unchanged. All commands, logs, runner identity and raw samples are
copied under reports; artifact-manifest.json includes original executable and
library identities. No additional resource build or compiler gate ran here.
