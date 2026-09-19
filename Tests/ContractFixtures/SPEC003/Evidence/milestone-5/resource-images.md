# SPEC-003 T5.4 Matched-Image Resource Evidence

Plan task: `SPEC-003 T5.4`

The resource mechanism is implemented for all four exact standalone profile
commands. Each command now builds two pristine baseline/candidate pairs from
one stable generated path and records final-image hashes, maps, complete
section and symbol inventories, disassembly, loaded-library identities,
normalized section accounting, a resolved call graph, the conservative stack
bound, and nRF reachable instruction count.

The checker fails closed on missing bodies, reachable indirect calls, dynamic
stack adjustment, recursion, unequal libraries, resource-limit breaches, and
non-repeatable images or normalized reports. ARMv6 and nRF runs remain
hardware-free and perform no remote access, deployment, or flashing.

Current disposition on 2026-09-19:

- `macos-dynamic`: the complete pipeline passes, including two identical
  images and normalized reports. Run ID
  `badd7575630a6cc5a15707d15cf1e82939019e12-dd196d587dbb490c` records a
  1,700-byte writable delta, 25,675-byte code delta, and 64-byte stack.
- `nrf52840-embedded`: the complete pipeline passes. Its measured candidate
  delta is 256 bytes writable RAM and 132 bytes linked code, with a 24-byte
  conservative stack and 38 reachable instructions in the first passing run.
- `macos-static`: the pipeline reaches the enforced final-image check but the
  548-byte linked writable delta exceeds the frozen 512-byte limit. The
  426-byte named production state fits its owned-state sub-bound;
  compiler-emitted witness and lazy-token storage makes the complete
  final-image delta 36 bytes too large.
- `raspberry-pi-armv6`: the pipeline reaches the enforced final-image check but
  the static-runtime candidate pulls 8,456 bytes more writable storage than
  the matched baseline, exceeding the frozen 512-byte limit.

Therefore the missing tooling blocker is removed, but T5.4 remains blocked by
two measured resource nonconformances. The plan cannot grant an exception.
The implementation must reduce those final-image contributions within the
approved contract or return the bounds/build contract to Specification review.
