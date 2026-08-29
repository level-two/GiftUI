# SPEC-004 Matched Resource Harness

`Baseline/` and `Candidate/` are the checked-in source roots for the pristine
matched builds required by SPEC-004. Both sides must use identical entry
signatures, normalized corpus, observable fixed-width sinks, compiler/linker
mode, runtime support, and source-list rules.

Baseline retains an observable no-op without importing or linking production
capability modules. Candidate observably exercises production capability
construction, resolution, snapshot storage, and repeated access. Generated
wrappers, objects, images, maps, disassembly, call graphs, and reports belong
only under the deterministic `.build` roots documented in the parent README.
