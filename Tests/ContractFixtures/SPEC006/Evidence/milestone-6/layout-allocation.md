# SPEC-006 T6.4 Layout, Allocation, and ABI Evidence

Each compiler emits LLVM IR for one shared probe. The verifier extracts
constant size, stride, and alignment for `SemanticExpansionLimits`,
`SemanticExpansionSummary`, `SemanticExpansionError`, and
`SemanticExpansionResult`, enforcing the two 10-byte maxima, exact one-byte
error, and 12-byte result maximum.

The optimized Semantic Core SIL contains no heap allocation instruction. The
ARMv6 relocatable object is inspected as ARM EABI5 hard-float, while the nRF
relocatable ELF must identify Cortex-M4, ARMv7E-M, VFPv4-D16, and VFP-register
arguments. Cross artifacts are inspected without connected hardware.
