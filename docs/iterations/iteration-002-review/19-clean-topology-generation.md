# Step 19 — Clean offline generation

[SPIKE-011](../../spikes/spike-011-clean-topology-generation.md) answers the
remaining clean-generation question with an actual disposable generator.
Both outputs of the current updater are emitted from empty directories using
measured projections, codec/scaffold templates and explicit identity-keyed
binding policy. Previous generated Swift is used only afterward as an oracle.

Two clean runs reproduce both complete files byte-for-byte; 12 invalid/stale/
nonempty-input checks fail closed before producing partial output. All 42
semantic transcripts match. The linked firmware remains 275,600 flash bytes
and 191,104 RAM bytes, with the expected ABI and disabled heaps.

**Planning disposition:** this is a supported bounded tooling candidate for
CBR-002. Retain packed runtime storage, make codec templates/policy explicit,
and replace patch-in-place output updates with clean generation. Coordinate
projection freshness, supported failure diagnostics and generator gates in
the implementation task. Named model roles remain a separate optional cleanup.

This result does not eliminate specialized binding policy, derive all runtime
semantics directly from the portable declaration, approve implementation or
close a finding as fixed. See the Spike for reproducibility and limitations.
