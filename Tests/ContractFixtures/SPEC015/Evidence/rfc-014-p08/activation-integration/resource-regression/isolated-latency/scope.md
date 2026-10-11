# Isolated native latency correction — 2026-10-12

SPEC003's Reproducible latency and instruction evidence clause requires at least
10000 iterations after1000 warm-up iterations with no other repository job
running. The prior42/84ns samples identify the correct machine/OS but lack the
required isolation record and are informative only. Preserve all raw originals.

Parent explicitly assigned exactly two fresh latency-only runs after Standard's
SPEC002 routes finish and parent sends explicit all-builds-idle clearance.
No execution is authorized before that clearance. Use the frozen unchanged
run_latency_probe function, approved6.4 compiler, same SDK/target and -O/WMO flags,
with separate new Static/Dynamic output trees. This entails four compiler/link
invocations and two positive executions, no other resource rebuild or repair.

Record parent clearance, commit/source/compiler/function identities, timestamps,
filtered repository build-process snapshots before/after, full commands/logs,
runner identity and both10000-sample streams. Keep all other agents' repository
jobs stopped through both runs. Stop any failure or loss of isolation; no retry
is authorized by this scope. Independent review follows the committed correction
receipt. Amend the resource result's previous timing claim and refresh its
manifest while preserving all original raw receipts byte-for-byte.
