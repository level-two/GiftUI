# SPIKE-069 scoped model access

Disposable evidence for [the committed recipe](../../docs/spikes/spike-069-scoped-model-access.md).
No production API or owner is changed. Run from the repository root:

```sh
python3 experiments/spike-069-scoped-model-access/run.py a
python3 experiments/spike-069-scoped-model-access/run.py b
python3 experiments/spike-069-scoped-model-access/run.py negatives
python3 experiments/spike-069-scoped-model-access/run.py driver
python3 experiments/spike-069-scoped-model-access/run.py composition
python3 experiments/spike-069-scoped-model-access/run.py reachability
```

The commands above describe the completed recipe. The runner now refuses new
trials because a terminal result exists; a later reproduction needs a separately
authorized bounded window. `inspect.py` can recheck existing local artifacts
without compiling or running the fixture.

The runner charges every compiler and test executable invocation to one
append-only evidence ledger, checks the 48-call/21:35 UTC boundary and preserves
source snapshots for each attempt. Re-running is another charged attempt.
Use the existing ledger; deleting it does not renew the authorization.

The A fixture compiles exact maintained State and Static model-storage bodies
with imports and the unrelated macro declaration removed. It includes the exact
observable result enums from their maintained source. This single-module audit
isolates escape enforcement; it is not a supported whole-owner composition.
No escaped production pointer is dereferenced.

B uses a noncopyable owner over caller-supplied backing and a nonescapable Span
view. Host backing validity is an explicit unsafe precondition, not something a
generation check or Span can prove. Read/callback APIs never expose raw pointers.
Tests of modeled pool/transaction behavior do not substitute for production
registration, traversal or generated Canvas tests.

Native builds keep the maintained macOS 15 deployment floor. InlineArray is
therefore not used: the installed Swift interface marks it macOS 26+. Target
objects use the pinned Pi ARMv6 SDK or nRF hard-float flags. Native harness
allocation is test scaffolding and is excluded from candidate object claims.

`composition` compiles all actual GiftUI declaration sources unchanged, first
with an owned scalar body and then with a borrowed view captured by actual
Canvas. It does not invoke Semantic Core or a generated Static callable.
`reachability` recompiles the B driver using the maintained firmware's
`-Xfrontend -function-sections` flag, then performs a relocatable garbage-
collecting link rooted at both exported fixture entries. This distinguishes
reachable allocator references from Embedded Swift's emitted runtime helpers;
it is still not a final firmware ELF or whole-application zero-heap proof.

See [result](evidence/result.md), [ledger](evidence/ledger.json), and
[inspection summary](evidence/inspection.json). Exact Swift inputs for each
trial are preserved in `evidence/input-snapshots.tar.gz`, with per-input hashes
in the ledger. Target objects remain in their `.build/` directories; their
hashes and raw inspections are committed, not the generated binaries.
