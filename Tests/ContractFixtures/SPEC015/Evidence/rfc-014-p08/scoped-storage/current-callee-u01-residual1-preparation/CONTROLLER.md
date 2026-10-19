# U01 residual A-only controller preparation — 2026-10-19

**Prepared, unexecuted and not independently cleared.** This follows B1's
environment correction at `e6704db4` and the explicit instruction to prepare a
concrete controller. It is one proposed new orchestration bootstrap, with no
execution authorization and no borrowed historical allowance. Independent Strong
readiness review is next. No acquisition, decoder, controller, runtime, compiler,
build, test or strict-cold operation ran during preparation.

## Concrete boundary and closed provider gate

[controller.py](controller.py) captures only A's three exact request commands:
counter metadata, numeric symbols, and linked body/data. The reviewed request's
six-command ceiling remains; [controller-accounting.json](controller-accounting.json)
sets this concrete controller's maximum to **three**, bootstrap use **0/1**,
repairs **0**, retries **0**, acquisitions **0**. The three conditional B commands
are always recorded skipped by this controller.

[gate-policy.json](gate-policy.json) is explicitly
`STOP_AFTER_A_PROVIDER_PROOF_UNESTABLISHED`, with `B_launch_enabled=false`.
No exact applicable provider proof or reviewed automated verifier exists yet.
The controller therefore writes a terminal **STOP** after successful A captures;
matching names, versions or raw-record tokens cannot release B. It neither
pauses for human input nor loads revised gate data mid-attempt. Any later B
inspection requires new reviewed proof/preparation, external final pins and
explicit allowance. This conservative realization preserves the original
request's mandatory stop when provider proof is unavailable; it makes no
contract, resource or scope choice.

## External final pins and isolated bootstrap

[reviewed-launch.py](reviewed-launch.py) is bootstrap source, not a self-clearing
launcher. The caller must obtain its exact bytes from the **final independently
reviewed Git blob**, verify their SHA-256 against the reviewer's external pin,
then pass those bytes as the isolated interpreter's literal `-c` program. Do not
execute the mutable workspace file or select pins from current HEAD at launch.

The complete argv shape is the absolute Xcode interpreter with
`-I -S -B -X pycache_prefix=/dev/null -c`, followed by the verified bootstrap
source and one external JSON argument. Use an empty inherited environment with
exactly `loader-policy.json.bootstrap_environment`, including both explicit
system-only DYLD fallback paths. The only accepted extra interpreter-added value
is the exact CF encoding in that policy; LC_CTYPE is already explicitly present.
No shell interpolation, repository imports, site initialization or Python cache
writes are required.

The external JSON must contain full `commit`, `repository_tree`, `packet_tree`
Git identities and a `files` map with exact SHA-256 values for these nine files:

- `reviewed-launch.py` and `controller.py`;
- `request.json` and `controller-inputs.json`;
- `loader-policy.json`, `loader-roots.json`, `loader-aliases.json`;
- `gate-policy.json` and `controller-accounting.json`.

These final values can only be supplied after readiness review. No locally
generated pin record or source constant supplies them. The bootstrap authenticates
Git objects by their object hashes, final HEAD/repository/packet joins, every
packet blob and exact workspace membership, and the nine external file pins.
It executes controller source from the authenticated Git blob in memory. Its
read-only Git children receive complete restricted environments, disabled
configuration includes/external helpers/replacements/lazy fetching, and the
remaining aggregate timeout.

## Ownership, authentication, caps and durable records

The **360-second monotonic deadline starts at bootstrap entry** and carries
unchanged through Git authentication, packet/context authentication, each child,
raw-record checks and provider-gate handling. A real-time alarm and monotonic
checks prevent authentication or gate pauses from resetting that budget. Every
decoder has a separate **60-second** limit bounded by the same remaining deadline.

After external packet authentication, the controller atomically creates the
fresh `.build/contracts/p08-u01-residual-static1` directory, permanently refusing
duplicates/resume. It writes and fsyncs `attempt-consumed.json`, including the new
directory's identity and external pins, **before any decoder child**. The output
is never removed or reset. Historical marker `[16777234,29640436]` is untouched.

[controller-inputs.json](controller-inputs.json) freezes **180 direct files**,
six absent paths, current source/preservation/cache identities, and the concrete
request/loader manifests. Initial and per-command authentication compare those
files' bytes, sizes and resolved aliases; all **8,720 loader entries**, exact
root membership and **72 aliases**; packet bytes/HEAD; and cache membership.
Installed Apple `/usr/lib` and `/System/Library` loader/runtime remain the explicit
OS trust boundary. Complete child dictionaries exclude HOME fallbacks and
ambient loader/startup variables. No counter, dylib probe or application runs.

Each exact decoder gets a new process group. Raw stdout/stderr are streamed into
fresh files; the combined per-command caps remain **8/16/128 MiB for A**, below
the overall **512-MiB** request cap. On timeout, output cap, signal or recording
exception the controller kills its child group. It records actual `Popen.wait`
exit values, raw-prefix sizes/hashes, observed/retained counts, timeout/cap and
truncation states before any interpretation. Minimal expected raw-record tokens
only detect absent output; they never prove provider selection or U01 PASS.
There is no substitute tool, retry or added command on unsupported options.

After work stops, finite child reaping (at most two seconds) and durable receipt
persistence may finish; no decoder continuation, authentication retry or gate
work follows the deadline. Managed termination signals are blocked only while
preserving raw/actual-exit receipts, then restored. OS hard kill, host/filesystem
failure or receipt-write failure may leave partial evidence: the permanent
consumption directory still forbids automatic resume/retry, and no missing exit
may be invented. Skipped commands receive explicit null actual-exit records.

## Preparation and independent readiness handoff

[prepare-controller.py](prepare-controller.py) only reads/hashes retained inputs
and writes context/gate/accounting JSON. It never imports or invokes the
bootstrap/controller. Controller source has only been read as text/AST for
syntax inspection; behavioral validation has not run and is not claimed.

Review final pins, isolated environment/loader trust, exact packet/context
membership, marker ownership/duplicate refusal, pre-child authentication,
aggregate/per-command deadlines, process-group cap handling, durable actual
exits and the closed gate. Do not launch a decoder/controller as part of review.
Any necessary controller correction remains a separately reviewable preparation
edit, with no automatic execution/production repair allowance.

Strict cold remains ineligible; complete callee **and** safety PASS still precede
any new current strict-cold manifest. R01–R04 and U02–U05 remain open, as do
P08/R07/T8.1, remaining SO, zero-heap, four-profile, ABI/resources, independent
exit and later conformance gates. Accepted ADR-039/040 and implementing SPEC-015
remain authoritative; no historical counter ceiling is reinstated. The five
preexisting dirty files and Python cache remain unchanged.
