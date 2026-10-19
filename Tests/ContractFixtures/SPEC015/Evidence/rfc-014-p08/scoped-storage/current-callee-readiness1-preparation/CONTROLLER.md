# One-shot current-callee controller preparation — 2026-10-19

Status: **independent Strong readiness PASS; collection unused 0/1**.
The [independent review](controller-independent-review.md) closes B1/B2 and clears
only the sole bootstrap collection with external final reviewed pins.
This implements preparation review [B1/B2](independent-review.md), retaining its
applicability PASS and all historical STOPs. The collection remains **0/1 used**,
maximum **94 swiftc invocations**, zero source candidates, zero automatic source
or tooling repairs, zero retries. No compiler, build, test, controller, decoder,
counter/schema4/P07 or application runtime command ran for this preparation.
Source/AST and file/hash inspection are the only checks performed.

## Authenticated code and fixed inputs

[reviewed-launch.py](reviewed-launch.py) requires the absolute Xcode Python,
`-I -S -B -X pycache_prefix=/dev/null`, and the exact env-i bootstrap dictionary.
Full commit, repository-tree and packet-tree pins must be supplied by the
independent reviewer. The bootstrap authenticates Git object bytes and tree
joins, rejects HEAD drift, and reads controller modules from authenticated Git
blobs before executing them. It checks the entire flat packet membership and
bytes against the external tree. No workspace module import, local bytecode or
launch-time pin discovery supplies code. Read-only Git uses a complete isolated
environment, disables fsmonitor/hooks/pager/transports/external commands and
rejects configuration includes.

[controller_common.py](controller_common.py) authenticates the 388 direct
inputs, 541 inherited source hashes and complete source-discovery inventory,
the ten applicable complete SDK/compiler/Python/macro trees, exact tool
resolution, four import-root memberships, seven loader trees, every loader alias,
and decoder libraries. The two inherited Swift driver links are checked against
their separately pinned frozen-links manifest. Preexisting dirty-file hashes
must remain exact. [ENVIRONMENT.md](ENVIRONMENT.md) and
[process-environment.json](process-environment.json) define complete child
environments, including the three previously unpinned DYLD roots and explicit
system-only fallbacks. No ambient environment is copied into a child.

The recipe verifier reconstructs the SIL argv from retained command 18 and each
privacy argv from its original preparation, preserving classifiers and the
reviewed import/cache/macro substitutions. This protects all 42 ordered sources,
93 unique privacy controls, eleven module captures, 50 object captures and the
91 exact mangled plus one exact demangled body-target identity forms.

## Lock, permanent claims and detached survival

[controller_launch.py](controller_launch.py) authenticates before consumption,
then opens the existing canonical `.build/validation.lock` without following a
symlink and obtains its exclusive lock. It reauthenticates under that lock.
Another active validation writer causes rejection before marker consumption.
The canonical `.build/contracts/p08-current-callee-collection1` directory is
created exclusively and permanently consumes the collection. Its parent and
atomic launch receipt are fsynced before detaching a worker. Never remove the
directory or claims to permit another run.

The worker starts in a new session with null stdin and file stdout/stderr,
authenticated code supplied from reviewed Git bytes, and an inherited copy of
the same lock open-file description. Closing the launching command session has
no stream, controlling-terminal or process-group dependency on that worker.
No process-inspection command is used. PID and bracketed wall/monotonic readings
are observed spawn facts, not OS creation times or identities immune to PID reuse.

[controller_worker.py](controller_worker.py) permanently claims worker ownership
and each named subprocess with O_EXCL. Only that worker owner may write its
terminal. A replay cannot overwrite a prior terminal. The inherited validation
lock and marker device/inode are checked at every production boundary, together
with code, complete inputs/imports/loader roots and the fixed recipe. Every
top-level child inherits the lock; the detached worker retains it throughout.

Each child receives direct raw stdout/stderr files. Claims, start records,
raw hashes, actual wait exits and the terminal are durably written with same-
directory atomic rename and parent fsync. Only `Popen.wait()` supplies an actual
child exit. A started child is reaped even if its start recording fails. A spawn
failure retains a consumed claim and null actual exit. Termination requests stop
later children; SIGHUP is ignored by the detached worker. SIGKILL, shutdown or an
external host kill can still leave no terminal. That means unknown/incomplete,
with the attempt consumed; it never triggers a relaunch or synthesized PASS.

## Gates and exact later meaning

The worker collects all 93 independent privacy controls with their original
positive/negative error text, regex, count and exit classifiers. It captures
the eleven complete module dumps and 50 matching-object streams independently.
The existing pinned interpreter source is read once, hash-authenticated and
passed as an isolated Python code string, preserving its complete table/hash/
offset/raw-prefix checks and demangler. No mutable script import supplies it.

The new boundaries-decode-prepared.json contains exactly the reviewed module
commands. All eleven complete indexes must retain schema [0,1003] and full
function counts. Each of the 92 body targets must resolve uniquely with its
reviewed exact identity, serialized_kind != 0 and basic_blocks > 0; the single
exact demangled target retains its freshly captured full mangled record. No
prefix, regex, guessed remangling or missing-body acceptance replaces a target.

Only all privacy/body/object prerequisites passing releases the single actual-host
SIL compiler invocation. Its actual exit must be zero and its new SIL regular,
nonempty and hash-recorded. Any prerequisite failure blocks it. All independent
privacy controls retain collection behavior; this supplies no repair/retry.
The worker enforces at most 94 permanent compiler claims and actual exits.

An eventual `PASS_collection_only_current_callee_interpretation_pending` means
exactly that collection completed. It does not prove transitive callee costs,
full lifetime/safety, strict cold, zero heap, physical bounds or P08 acceptance.
Complete current Static/P08 paths, helpers, Text/UTF8 and Error/witness cold
paths, observer attribution, all 14 loans, private checked construction,
Optional/provenance/exclusivity and failure cleanup still require independent
interpretation. Strict-cold preparation follows only applicable callee+safety
PASS, with the existing observation windows and enforcement unchanged.

## Independent readiness handoff and future command

Review the complete committed code/environment packet, source/applicability joins,
environment and loader closure, exclusive lock/marker/claim semantics, durable
actual exits, privacy classifiers, body-index gates and all stop paths. Code has
not been executed or adversarially tested in this preparation; AST inspection
does not establish runtime correctness. Do not infer readiness from a commit.
The [independent review](controller-independent-review.md) is complete. Its reviewer
supplies full external final HEAD/tree and packet-tree pins after committing the
verdict; that review provides the bounded launch clearance.

Only after that separate independent readiness PASS, the sole bootstrap form is:

```sh
/usr/bin/env -i HOME=/Users/eugene TMPDIR=/private/tmp PATH=/usr/bin:/bin:/usr/sbin:/sbin LC_CTYPE=C.UTF-8 GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_SYSTEM=/dev/null GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0 GIT_NO_LAZY_FETCH=1 GIT_ALLOW_PROTOCOL= /usr/bin/git --no-replace-objects --no-pager --no-optional-locks -c core.fsmonitor=false -c core.hooksPath=/dev/null -c diff.external= -c credential.helper= -c core.sshCommand=/usr/bin/false -c submodule.recurse=false show --no-ext-diff --no-textconv REVIEWED_COMMIT:Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-readiness1-preparation/reviewed-launch.py | /usr/bin/env -i HOME=/Users/eugene TMPDIR=/private/tmp PATH=/usr/bin:/bin:/usr/sbin:/sbin /Applications/Xcode.app/Contents/Developer/usr/bin/python3 -I -S -B -X pycache_prefix=/dev/null - REVIEWED_COMMIT REVIEWED_REPOSITORY_TREE REVIEWED_PACKET_TREE
```

Read-only polling may inspect launch.json, detach.json, worker-claim.json,
worker-start.json, progress.json, individual claim/start/exit records, raw streams
and terminal.json below the permanent output marker. Polling must never call the
bootstrap, launcher or worker again. Archive any eventual raw output in a new
result packet and obtain independent result review. Historical evidence remains
untouched. P08/R07/T8.1, all still-unmet criteria and I4-07/P09–P12 remain open.
