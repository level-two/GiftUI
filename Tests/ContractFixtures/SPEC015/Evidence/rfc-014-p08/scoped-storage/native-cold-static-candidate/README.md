# Candidate 1 cold-screen recipe

Preparation and source-access checks compile/link only. `run.py` is the first
actual profile execution. It must be handed to the sequential mechanical runner
only after the implementation candidate commit. Initial corrective cycles: **0/2**.
No command here runs a full collection, firmware build or hardware action.

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-static-candidate/prepare.py --output .build/contracts/p08-native-cold-static-screen-candidate1-fresh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-static-candidate/check_access.py --prepared .build/contracts/p08-native-cold-static-screen-candidate1-fresh
```

The already prepared output is
`.build/contracts/p08-native-cold-static-screen-candidate1-current`.
Its manifest SHA256 is
`2f0f63d81b95f22a0747eb27e6411409d5140655544736d144dc4439cc8a37c2`.
Four links and source-access controls are ready. To execute exactly one bounded
comparison (four fresh processes, each cold then identical reuse):

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-static-candidate/run.py --prepared .build/contracts/p08-native-cold-static-screen-candidate1-current --repetitions 1
```

Do not run twice into that output or overwrite a failed observation. Count/replay
failure stops the runner with a preserved `run/result.json`; do not retry by
changing an expected result. A new source correction needs the recorded cycle
and fresh preparation. Three repetitions are supported only after interpreting
the first bounded screen, not as an automatic repair loop.

## What the comparison establishes

- `baseline-host-first` links the exact retained 25 original objects and a tiny
  Swift/C shim calling the original package `p08CounterHost()` directly. It
  derives the host-only expected check count independently of candidate source.
- `candidate-silent-host-first` executes that same host workload before graph
  warmup. Two diagnostic source copies suppress exactly three successful trace/
  reuse-label/role-label print statements. Assertions, error output and required
  computations remain. Count equality to baseline and ordinary host is required.
  This different diagnostic image cannot alone prove ordinary-route conformance.
- `candidate-host-first` retains all normal output and invokes the same host-first
  entry; `candidate-ordinary` invokes the unchanged registered C route including
  graph and scoped controls. Ordinary cold/reuse must both equal1735019.

Each process includes assembly, concrete root construction, first actions,
finite lifecycle/failure scenarios, shutdown/reuse/destruction. Neither host-first
entry calls `p08CounterGraph` first. Source/object/image hashes, exact commands,
loaded library UUIDs, complete event streams and strict replay groups are retained.
The old common-graph-first metadata warmup cannot be counted as cold proof.

The observer and Driver.o are unchanged hash-pinned repair1 artifacts. Positive/
negative observer validation remains the accepted prior diagnostic evidence;
**direct malloc-zone callbacks, raw VM/temp-route coverage and complete allocation
absence remain unproved**. Do not turn zero captured public-route events into a
zero-heap PASS. No allocator failure/foreign-thread/truncation/I/O evidence is
accepted by replay. Any selected profile allocation, including metadata outside
11/336, fails the cold screen and requires exact attribution before a correction.
Fixture oracle arrays/printing must be identified from actual stacks and source;
they are not a blanket permission to exclude a frame family or change a window.
Requested/malloc usable counts do not measure allocator arenas or all headers.

Preparation rebuilds the changed owners and direct scope-layout consumers with
the existing pinned Native flags; it does not claim suite conformance. Retained
runtime/host dependencies keep their existing `compiled=false` and
`original_manifest_current=false` qualifications. The preparation manifest
records their current source deltas explicitly; unchanged retained object/owner
receipt hashes remain pinned. The current counter's201 inputs may differ only
on the explicit candidate source allowlist. Fresh GiftUI serialization inputs
are tracked separately. No external SignalAnalyzer/build edits enter these links.
