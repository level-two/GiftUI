# Matched Resource Harness

`Baseline/` and `Candidate/` are the checked-in source roots for the two
pristine matched builds required by SPEC-003. Both expose the same retained
fixed-width entry. Baseline executes a retained no-op; Candidate exercises the
production outcome, correlation, health, annotation, and residual-policy path
while retaining the default diagnostic storage outside the measured stack
path.

The baseline and candidate must keep identical entry signatures, corpus
inputs, observable fixed-width sinks, compiler and linker flags, runtime/test
support, and shared-library set. Baseline performs a retained no-op without
importing or linking production failure modules. Candidate observably executes
the production failure path. Generated wrappers, object files, images, maps,
disassembly, call graphs, and section reports belong only under the
deterministic `.build` roots documented in the parent README.

`Support.c` is identical in both host/cross images. It supplies the observable
sink and finite final-image bodies for memory helpers the optimizer may emit.
The nRF Zephyr wrapper uses the same C entry and sink contract.
