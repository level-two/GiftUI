# SPEC-010 T7.3 Diagnostic Isolation Evidence

The test-only diagnostic projection matrix covers diagnostics absent, enabled,
disabled by selection, lost by the sink, and saturated at the sink. Every case
compares the same complete correctness snapshot: typed observable-state result,
live set, attachment generation, dirty locations, semantic wake state,
publication generation, and correlated failure.

The production Observable State failure adapter neither imports nor depends on
diagnostics. Selected sinks receive only an immutable diagnostic record and an
explicit attack attempt cannot mutate authoritative state. Disabled and absent
projections construct and consume nothing; loss and saturation alter only
diagnostic delivery counters. Thus projection availability and delivery outcome
cannot change correctness.
