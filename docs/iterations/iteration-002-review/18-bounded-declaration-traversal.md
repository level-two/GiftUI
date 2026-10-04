# Step 18 — Bounded declaration traversal prerequisite

The maintainer requested the remaining hardware-free work and explicitly kept
connected validation deferred. [SPIKE-010](../../spikes/spike-010-bounded-declaration-traversal.md)
tests a concrete snapshot lowering of the actual analyzer body rather than
stopping with SPIKE-009's whole-module rejection.

Native and paired Embedded compilation pass; 42 traversal cases and 84
contained depth/node refusals pass. The complete actual body is retained, but
the root observable carrier and capture ownership are explicitly lowered.
Serial identities and a counting sink provide prerequisite evidence only.

The production image plus reachable probe costs +34,184 flash bytes and zero
additional linked RAM, with the expected ABI and disabled heaps. It preserves
production behavior in the repository. No packed identity/text/action/Canvas/
pixel parity or full replacement-budget claim follows from this result.

**Planning disposition:** retain the packed hierarchy during cleanup; runtime
replacement would require a selected design, comparison budgets and complete
conformance machinery. Clean offline generation is the next bounded research
alternative. Static stack inspection will record what the linked image can
and cannot prove; physical timing/high-water remain explicitly deferred.

See the Spike for exact inputs, commands, results and stop boundary. None of
the eight findings is closed as fixed by this experiment.
