# Runner isolation implementation

2026-10-04. TOOL-01 code and fixture validation complete; real aggregate integration remains pending T11.6.

Unique retained parent directories and serialized contract entry points protect shared build/cache roots. The permanent lock inode is inherited by child processes; nested checks reuse the owning invocation. TERM/INT/HUP forward to the child group while keeping the lock until teardown. Latest publication is atomic. Failure/interruption ledgers, child publication IDs and latest observations are retained; incomplete staging directories are listed separately. No automatic pruning.

Three maintained runner fixtures pass (28 assertions): overlapping same-selection invocations, failure followed by reuse, interruption followed by lock reuse. They run the real runner against cheap stub checks and a shared scratch sentinel. All governance tooling fixtures and repository validation also pass. Standalone commands retain their arguments. See [fixtures](fixtures.log) and [governance](governance.log). Full all-profile integration will supply the real runner evidence before TOOL-01 is marked complete.
