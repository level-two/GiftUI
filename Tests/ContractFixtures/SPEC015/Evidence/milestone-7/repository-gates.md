# SPEC-015 T7.3 Deterministic Repository Gates

On 2026-09-19, revision `2aeeb81` passed `scripts/format-swift.sh` and the
complete `scripts/test.sh --profile all-hardware-free` matrix. The run includes
documentation/governance checks, focused Host Configuration tests, all four
SPEC-015 immutable driver modes, dependency and portable-source scans,
generated-manifest freshness, package-surface compilation, and cross-profile
semantic/resource comparison.

Each profile report records the compiler, target, optimization, exact command,
revision/dirty state, fixture input identity, semantic output hash, artifact
identity, and evidence kind. ARMv6 and nRF entries are final-artifact
cross-build inspection and explicitly retain `connected_execution` as not
collected. No deployment, remote access, service restart, or flash occurred.

The first aggregate exposed and the final aggregate verified repairs to two
shared prerequisites: SPEC-013 same-input report reuse and SPEC-007's current
nRF Semantic/Canvas compile inventory. No SPEC-015 contract was weakened.
