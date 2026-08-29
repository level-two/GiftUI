# Matched Resource Harness

`Baseline/` and `Candidate/` are the checked-in source roots for the two
pristine matched builds required by SPEC-003. Each root gains its production
entry point only when the corresponding semantic contract exists.

The baseline and candidate must keep identical entry signatures, corpus
inputs, observable fixed-width sinks, compiler and linker flags, runtime/test
support, and shared-library set. Baseline performs a retained no-op without
importing or linking production failure modules. Candidate observably executes
the production failure path. Generated wrappers, object files, images, maps,
disassembly, call graphs, and section reports belong only under the
deterministic `.build` roots documented in the parent README.
