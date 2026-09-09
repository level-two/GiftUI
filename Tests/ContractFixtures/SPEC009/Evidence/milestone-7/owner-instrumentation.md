# SPEC-009 T7.5 Owner Failure and Instrumentation Evidence

The owner corpus names all five finite `UInt32` fixture cases with their exact
raw values and detecting mutation/derivation contexts. Every case crosses all
32 cleanup-fault combinations, retains the first failure without fallback,
finishes mandatory cleanup, produces a summary, and records the four/eight-byte
owner/result ceilings plus zero static heap allocation.

The fixture-only resource probe registers per-phase duration, three required
latencies, retry attempts and pacing, queue/workspace/stack high-water, stale
drops, sequence and activation cancellations, operation and heap-allocation
counts, linked-section delta, and a four-word inline link-map digest. Milestone
8 drivers own the actual per-profile samples.
