# TypedBacking61 full4h2 guard launch review

Verdict: **PASS for launching the one human-authorized fresh full4h2 collection with the unchanged four-hour / 2 GiB / 32 MiB boundaries.** No material launch blocker was found in the task-local guard and completed finite controls. This review applies only to the guard/control boundary; it does not reopen fixture/authority proof, qualify the previous failed run, or accept the forthcoming full result. No additional approval is required by this review.

Reviewed [launch-full4h2.py](../current-native-static-typedBacking61-local/launch-full4h2.py), SHA256 **`2e2cf6378f9d870c5b6c9c2156ea111d7f357b5af200fbf8a0c17a59657ce2d0`**, and its [grouped control driver](../current-native-static-typedBacking61-local/guard4h2-controls.py). The candidate's hash equals all five retained `launch-guard.py` control copies. The exact completed control record is `.build/contracts/p08-native-static-typedBacking61/guard4h2-controls/controls.json`, finished **2026-10-25 19:32:06.109387 UTC**. No guard, source or control workload was rerun by this reviewer.

## Guard behavior

The deadline runs in a separate OS process. Its armed event is awaited before workload spawn, and its deadlines start before caffeinate/watchdog startup and spawning. It checks the minimum remaining wall-clock and monotonic time. Recursive usage scanning runs asynchronously in a daemon thread; the watchdog does not call that scanner, and finalization waits for it for at most 0.5 seconds. The stalled-scanner control exercises this separation directly.

For the actual four-hour duration, deadline termination starts with a three-second lead, sends TERM to the owned process group and then KILL after at most one second of grace. The watchdog records escalation completion against both deadlines. The main guard retains terminal time/deadline status and cleans up the watchdog and task-local caffeinate. Caffeinate uses `-dims -w <guard-pid>`; it does not alter global power or toolchain configuration. The workload starts a new session, its PID/owned group and guard/watchdog/caffeinate PIDs are captured, and stdout/stderr are durable files. Launch, ownership, deadline/output events and terminal records identify the actual run rather than a proposed launch.

The output path uses a preflight forecast plus protected reserve, samples usage asynchronously, and performs owned-group TERM/KILL on threshold or scan error. The terminal accurately labels the retained-size sample as non-final and reports a blocked scanner rather than waiting indefinitely. This is sampled enforcement, not an instantaneous filesystem quota or proof of final retained bytes; the actual full terminal/evidence must retain that distinction.

## Actual finite controls

| Control | Observed disposition |
| --- | --- |
| Success | Exit 0, captured terminal, no guard event, within deadline. |
| Nonzero | Exit 7 preserved, captured terminal, no guard event, within deadline. |
| Launch failure | FileNotFoundError retained, no workload exit invented, terminal within deadline. |
| Stalled scan + TERM-ignoring parent/child | The 60-second scanner remained blocked. Parent group PID **37383** received TERM at **19:31:32.743625 UTC**; KILL completed **19:31:33.747923 UTC**, before fixed deadline **19:31:34.742593 UTC**. Child exit was −9 and terminal **19:31:34.259781 UTC** was within the cap. The coordinator's elevated `ps -p 37386` confirmation returned no row/exit 1 for the descendant. The initial sandbox `ps` failure remains preserved; no workload retry supplied this confirmation. |
| Output stop | Synthetic usage reached 1,048,576 B, triggered the output-envelope stop, and recorded TERM/KILL completion plus exit −15 within the deadline. The last-sample envelope flag is correctly false for this deliberately over-threshold control. |

All five controls report PASS. The stalled-scanner control demonstrates that recursive accounting cannot delay normal userspace deadline escalation or terminal capture, including a TERM-ignoring descendant in the owned group. It does not establish an absolute guarantee against OS suspension, scheduling failure or process/OS failure. The guard explicitly discloses that limit; task-local caffeinate mitigates ordinary sleep. **The cause of full4h1's late enforcement remains unproved.** No system investigation or causal conclusion is added here.

## Launch and successor boundary

The reviewed candidate may launch the already authorized **single** fresh full4h2 immediately, with the frozen five-source identity check, existing maintained command/prerequisites, independent watchdog and exact capture paths. The failed full4h1 remains immutable and does not count as a resumable complete receipt. No silent cap extension, reuse relaxation, further guard trial, source candidate, second retry or renewed twelve-hour allowance follows.

After termination, one successor package review must classify the actual full receipt, exact current artifact applicability, outputs and boundaries. A guard/control PASS is not a full-validation PASS. Unit FAILED / Interaction UNEXECUTED, historical FALSE/failed sessions and remaining provider/live/resource/profile/P08 gates remain unchanged.
