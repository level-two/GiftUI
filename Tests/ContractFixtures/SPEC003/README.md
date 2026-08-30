# SPEC-003 Contract Fixtures

This directory contains only fixtures and evidence derived from approved
SPEC-003. It provides one deterministic input surface for dynamic, static,
cross-built, and later connected-target evidence; it does not contain a
runtime, backend, platform, capability, host-policy, or hardware substitute.

## Layout

```text
Fixtures/
  Positive/<fixture-id>/main.swift
  Negative/<fixture-id>/main.swift
  Negative/<fixture-id>/expected-diagnostic-patterns.txt
SemanticCorpus/
  cases.tsv
ProfileCorpusProbe/
  ProfileCorpusProbe.swift
  main.swift
ResourceHarness/
  Baseline/
  Candidate/
Evidence/<milestone>/
fixture-manifest.tsv
```

`fixture-manifest.tsv` is the ordered compile-fixture registry. Every data row
has five tab-separated fields: a stable identifier, `pass` or `fail`, `public`
or `package`, one `main.swift` entry point, and either `-` or the negative
fixture's fixed-string diagnostic-pattern file. Drivers execute rows in file
order and fail on duplicate identifiers, unknown values, missing files,
unregistered fixture directories, unexpected compilation success, or missing
diagnostic patterns. Negative fixtures are always public.

Every compile fixture has one entry point so the same source can be compiled
by each profile-specific command. Public fixtures compile as external clients.
Package fixtures use the checked-in GiftUI package identity only when package
SPI must be tested. Fixtures must not provide fallback declarations, PoC
compatibility shims, or target-specific semantic implementations.

`SemanticCorpus/cases.tsv` is the shared semantic input registry. Its rows are
ordered and use fixed-width decimal or hexadecimal tokens only; free-form
strings and profile-specific cases are forbidden. The corpus schema is
documented beside the registry. A driver must hash the checked-in corpus and
feed the same ordered rows to every profile. Profile adapters may encode the
rows for their compiler target but may not omit, add, reorder, or reinterpret
them.

`ProfileCorpusProbe/ProfileCorpusProbe.swift` is the collection-free compiled
form of the ordered corpus cases used by every T5.1 profile. macOS profiles
execute it through `main.swift`; ARMv6 and nRF profiles compile the same probe
source against their pinned target module without claiming target execution.

`ResourceHarness/Baseline` and `ResourceHarness/Candidate` hold the matched
checked-in source inputs for resource evidence. Both sides must use identical
corpus input, observable fixed-width sinks, entry-point signatures, compiler
mode, linker support, and runtime/test support. Baseline retains a no-op and
must not import or link production failure modules; Candidate exercises the
production failure path. Profile-generated sources and build products never
belong in this fixture tree.

Generated inputs have one deterministic root:

```text
.build/contract-generated/spec-003/<profile>/
```

Reports have one deterministic root:

```text
.build/contract-reports/spec-003/<profile>/
```

Within a report, compile-fixture output belongs under
`fixtures/<fixture-id>/`, semantic transcripts under `semantics/`, matched
images under `resources/{build-1,build-2}/{baseline,candidate}/`, and complete
profile/revision/toolchain/source metadata in `metadata.txt`. Re-running one
profile replaces only that profile's generated and report directories.
Selected stable transcripts may be copied deliberately to
`Evidence/<milestone>/`; generated trees are never committed.

## Evidence Claims

- **Hardware-free host evidence** runs pure fixtures on the local macOS host.
  It can prove portable semantics and host-observed layouts, but not another
  architecture's binary or runtime behavior.
- **Hardware-free cross-built evidence** compiles and inspects the pinned
  ARMv6 or nRF target image without remote access, deployment, execution, or
  flashing. It can prove compiler, target, ELF, section, disassembly, and
  static-bound properties, but not connected-device latency or behavior.
- **Connected-target evidence** executes on an explicitly selected target and
  must record its reported architecture and environment. It is collected only
  when an owning integration exists and the user has separately authorized the
  connected-target change. No SPEC-003 contract command deploys, restarts a
  service, or flashes hardware.

The standalone command surface is introduced by plan task `T0.3`:

```sh
scripts/contracts/run-spec-003.sh --profile macos-dynamic
scripts/contracts/run-spec-003.sh --profile macos-static
scripts/contracts/run-spec-003.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-003.sh --profile nrf52840-embedded
```

Registration in the repository aggregate must preserve these exact standalone
commands and must not turn hardware-free aggregation into connected access.
