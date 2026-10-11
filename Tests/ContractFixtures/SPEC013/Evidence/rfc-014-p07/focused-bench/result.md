# Focused P07 workaround bench result

## Result and recommendation

Candidate 2 passes on pinned Swift 6.3.2: keep the existing generic, consuming
`CyclePipelineOwner` arrangement and observe retained storage through that owner
while the concrete coordinator owns it. The local native complete-cycle probe
runs **535 assertions, zero failures** across its Dynamic and Static profiles.
The actual owner remains noncopyable and nonescapable: borrowing compiles; copy,
use after consuming transfer, and storage in an Escapable wrapper each fail for
the intended reason. No lifetime annotation/check was disabled.

This is a validated ownership workaround direction, not an audited factory or
P07 acceptance. Production adoption is outside this bench authorization. The
next authorized implementation should keep the consuming transfer and introduce
truthful per-owner measurement at that ownership location; it must still prove
all required audit fields, finite admission, profile/limit rejection, and the
remaining transcript/lifecycle/four-route obligations.

## What was tested

The preserved failure reproduces with exact saved source hashes and pinned
imports. Seven of twelve permitted diagnostic variants were used; both allowed
workaround candidates were used. Full commands, exits, source hashes and
compiler diagnostics are in `results/`.

1. Candidate 1 made the four scoped fields private and supplied explicit
   lifetime-bound borrowing methods for model/root access. It fails with two
   precise noncopyable-copy compiler errors on `models.borrowedScope()` and
   `root.borrowedRoot()`. This narrows D07: synthesized read accessors expose
   the issue, but explicit borrowed projection from this loadable owner also
   fails. It is not a defensible repair on this compiler.
2. Candidate 2 restores the c234058e generic consuming owner in the isolated
   fixture copy. Geometry and Interaction move into that actual owner, then
   into the maintained DynamicRuntimeExecutionCoordinator or
   StaticRuntimeExecutionCoordinator. It adds bench-only borrowing geometry
   observations before transfer, while coordinator-owned before execution,
   and after two quiesce calls. Each profile checks the same backing snapshot
   at the latter two locations (four added assertions). Existing real cycle,
   admitted mutation, refusal, cleanup and stopped-entry checks still run.

Dynamic observations read twenty actual retained array-buffer addresses from
layout, resolved layout, drawing plan, live path and render storage. Addresses
are compared as a sorted multiset because publication exchanges bank roles;
this proves the same allocation set, not each buffer's semantic role. Static
observations capture the four supplied geometry region addresses at construction
(scopes, overlaid text/layout/render, path, plan), then compare those records
through the consuming owner. The overlay is represented once. Neither observer
creates another production geometry/Interaction owner. Observation arrays and
four Static address fields are bench metadata, not production retained storage.

The payload figure in this observation is a consistency sentinel: Dynamic uses
available retained-payload properties, Static uses the fixture's four supplied
region sizes. It is **not** an independently validated count/stride/alignment
or full-runtime memory audit. Model/root/semantic/Canvas and Interaction retain
their actual existing owner lifetimes; their individual backing addresses are
not measured by this bench. Returning ownership after quiescence was unnecessary
and is not tested. Fresh compilation of all modules, Embedded/ARM execution,
allocator interception, image and stack measurement are not claimed.

## Reproduction and prerequisites

Run from repository root:

```sh
python3 Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/run.py baseline
python3 Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/run.py c01-explicit-scope-borrows
python3 Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/candidate2.py
python3 Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/negative-controls.py
```

The first two intentionally record compiler failure (the diagnostic runner's
process exit is not the recorded compiler exit). Candidate 2 and its controls
must exit zero. Negative controls additionally require their intended diagnostic.
`run.py` preflights SHA-256 for the compiler, every recorded imported module/object,
and cached command/Main inputs in `pinned-inputs.json`; missing or altered inputs
fail clearly rather than silently generating new identities. It then verifies
all restored patched source hashes against the historical source-state record.

This is **not a clean-checkout standalone rebuild**: it requires the historical
`.build/contracts/spec-013-runtime-cycle/tmpuzqrfive/macos-static`,
`tmp_zcszbtn/macos-static`, and pinned core-build artifacts identified by the
manifest, plus the repository-local Swift 6.3.2 toolchain. These cached artifacts
are not committed. The script can reproduce with those exact prerequisites;
it does not recreate a deleted historical cache or certify an arbitrary rebuild
as equivalent. Candidate 2 builds its observational Dynamic module and complete
fixture module fresh against those verified imports. Generated sources, SIL,
objects and executable stay under `.build/p07-focused-bench/`.

## Boundary and guard

The original production repair stop remains **2/2 exhausted**, unchanged.
This separately authorized bench used **7/12 diagnostics and 2/2 candidates**.
Candidate 1 provided a narrower source-located cause; candidate 2 passed positive
and negative checks. There were no consecutive unproductive workaround repairs
in this bench. No third candidate, production adoption, compiler upgrade, P08,
remote operation or board flash was attempted. Maintained source is identical
to c234058e. Stop here for the maintainer/root decision on a subsequent package.
