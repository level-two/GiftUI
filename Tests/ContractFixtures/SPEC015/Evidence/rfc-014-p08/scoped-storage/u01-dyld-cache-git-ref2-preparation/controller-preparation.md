# U01 ref2 enforcing controller preparation — 2026-10-19

**Offline preparation only; readiness NOT READY; controller unexecuted.**
This implements the narrowly authorized preparation after `0625592a`, addressing
the mechanisms missing in B01/B02. It grants no launch permission and makes no
claim that independent review has accepted these mechanisms.

`controller.py` uses Python standard-library sockets and verified TLS directly.
There is no Git process, repository discovery, config parser, subprocess, HTTP
client retry facility, proxy, cookie jar, credential provider or prompt. It uses
fixed host/path/request bytes, one address from one DNS resolution per permitted
operation, and no connection fallback. DNS resolution and TLS setup do not count
as additional HTTP requests; neither is claimed to be a single network packet.
Only the two fixed operation slots exist. The second is reachable only after
successful protocol-v2 capability validation. Request intents are durably
recorded before DNS/connect/send, conservatively consuming a slot even if no
HTTP bytes reach the peer. `sendall` is called once per slot; partial failure
never replays. GET and POST use separate TLS connections with `Connection: close`.

Response status/headers are read without application-level body prefetch. Only
HTTP/1.1 with a unique Content-Length or exactly `Transfer-Encoding: chunked`
is accepted. Conflicting/duplicate headers, folded headers, informational status,
unsupported framing/content decoding, chunk extensions and trailers fail closed.
Failure statuses may have their bounded bodies retained, but never permit the
second operation. Unknown/inconsistent framing stops without completing a body.
Content-Encoding is absent or identity; no decompression exists. Complete framed
bodies alone are interpreted. The shared 1,048,576-byte budget counts **accepted
HTTP entity-body octets**, including error-body octets, across both operations.
Every receive request for body data is bounded by the remaining budget. An
overlarge declared body/chunk stops before accepting that body/chunk. This can
leave a partial response without consuming every allowed byte; STOP is required.
Reaching CAP in any retained stream is STOP, including a complete framed body. The body reader records all received octets in its local and aggregate counters before raising at equality, so a full GET body cannot reach capability parsing or POST. Exclusive metadata/request writers reject equality before writing; the supervisor hashes any full raw file and forces STOP. Aggregate equality alone is not a full-stream condition when both individual body streams stay below CAP and have complete framing. There is no
over-budget sentinel read. TLS buffering, HTTP headers/chunk framing, TCP/TLS/DNS
traffic and server-sent but unaccepted bytes are outside this body-byte measure.
**No total wire-byte cap is claimed.** Headers and chunk framing are each capped
at 65,536 bytes per operation; each retained file is capped at 1 MiB.

The fixed result directory is created exclusively, fsynced in its parent, then
an exclusive fsynced `launch.json` is written before any network emission. That
directory is the permanent consumed one-session marker; it is never removed,
renamed, replaced, resumed or bypassed with another destination. Failure before
the launch receipt is complete still leaves the marker consumed. Prior API/P08
markers are separate and remain untouched. External review must freeze the
controller and runtime-lock hashes supplied as argv; neither is self-approved
from a mutable request packet. Identity/environment failures stop before emission.

One monotonic deadline starts immediately after importing Python's `time`, before
the other imports, identity checks, marker/receipt creation, fork or network.
Exhausted startup time prevents launch. The supervisor waits against that same
absolute 30-second deadline and kills the child's entire process group plus the
child PID on timeout/interruption; the child also has a matching real-time alarm
and checks remaining monotonic time before socket operations. Blocking DNS is
bounded by the supervisor. The child starts a new session and cannot spawn other
processes. No process is started except this fork of the same pinned runtime.
Filesystem/bootstrap delays before the supervisor exists cannot emit network;
receipt cleanup may continue after the network deadline. An uncatchable death of
the supervisor leaves at most the child's matching alarm and a consumed marker;
absence/incompleteness of terminal accounting is STOP, never permission to retry.

The child redirects inherited stdio to `/dev/null`, closes inherited descriptors,
disables core dumps, and caps file writes with RLIMIT_FSIZE. Empty stdout/stderr
files are explicit; diagnostics use bounded JSON. Raw headers, framing and body
files are created exclusively before connection and written as received; body
chunks are fsynced as accepted. Abrupt termination can leave partial files and
missing child accounting. The supervisor records actual wait status/exit or
signal, timeout, file sizes/SHA-256 and missing-child status. Only exit zero,
complete framed accounting and a child observation before the deadline can yield
`OBSERVED`. Missing/malformed receipts or truncated streams mean STOP. These are
local controller receipts and hashes, not independent transport attestations.

`runtime-lock.json` pins the resolved Homebrew Python 3.14.6 executable, framework,
2,160 resolved stdlib source/extension/cached-bytecode members, OpenSSL libssl/libcrypto, and `/etc/ssl/cert.pem`
by exact byte SHA-256 (2,165 total pinned paths including five additional paths). Version strings and exact Darwin
release/kernel build are checked. System shared-cache libraries are identified
by that OS build; they were not extracted or hashed and this is not a runtime
attestation. The fixed `env -i` invocation in revised request.json removes all
inherited environment before interpreter startup; `-I -S -B` removes Python
environment/search/site effects and bytecode writes. Existing bytecode reads remain possible, so exact stdlib/bytecode membership and hashes, import search paths/absent archive paths, and loaded module origins are also checked. No custom import path or
environment variable is accepted. Normal filesystem/OS trust remains necessary;
the pins are reproducible identity checks, not a defense against a hostile kernel.

Offline validation parsed controller source with `ast.parse` without importing
or executing it, inspected forbidden imports, and compared the five dirty files,
exact cache membership/hash and three device/inode pairs with the retained
baseline. The [inspection](controller-preparation-inspection.json) records PASS
for these limited checks. No behavioral/network test, result directory, request,
dyld research source/header/Git-object read or dyld/cache tool ran. No maintained Swift change or
repository test gate is part of this tooling preparation. All original API 1/1,
markers 1/1, repair/retry zero and P08 open/closed dispositions remain binding.


## Full-stream correction after review 49228097

The parent authorized only this offline B01 correction. `save` now requires
length strictly below CAP. `take` preserves and increments local/aggregate body
counts before rejecting a body at CAP, and cannot return that full GET body to
capability parsing or POST. The supervisor retains full-file size/hash accounting,
records its names in `full_retained_streams`, and includes an empty list in its
success prerequisites. A full/truncated stream cannot pass even with completed
HTTP framing. The aggregate accepted-body ceiling stays <=1 MiB; no wire-byte
claim, request, time, environment or protocol rule changed.

Runtime dependency bytes/membership were rehashed offline and remain unchanged;
the lock SHA-256 is retained. Only source/packet pins change. Validation is AST
and byte/hash/JSON/stat inspection only, with no controller execution/import.
Readiness remains NOT READY pending separate independent re-review. Historical
review records are unchanged; all preservation and no-follow boundaries remain.


## Startup-environment correction after diagnostic 9542d659

Only the pre-marker environment predicate and its pins are revised. The exact
launch still supplies `env -i LANG=C LC_ALL=C TZ=UTC` before the same absolute
Python and -I/-S/-B flags. All inherited entries are discarded before Python
starts. The standalone probe confirms the runtime then adds exactly
`__CF_USER_TEXT_ENCODING=0x1F5:0x7:0x3D`. The controller ENV constant and runtime
lock now pin that exact fourth key/value. The predicate requires exact equality
of actual environment, ENV and lock startup_environment. It neither accepts
arbitrary values nor removes/ignores unexpected keys; missing/different CF
encoding or any extra entry stops before the marker. Launch receipt records the
actual four-entry environment; request.json distinguishes the three-entry launch
input from the four-entry startup state. No proxy, credential, cookie, tracing,
Python/site or Git/config variable is introduced.

[startup-environment-probe.py](startup-environment-probe.py) is a separate script
that imports only the same stdlib modules in order and prints environment and
runtime identity/flags. It never reads/imports/executes controller code, connects
or creates a marker. Its exact command and retained stdout are in the correction
inspection. All runtime dependency hashes/membership remain unchanged; only the
lock's explicit environment metadata and resulting lock/source pins change.
Readiness is NOT READY pending separate Strong review. The failed earlier
attempt stays failed, with no automatic retry, session allowance or repair
budget reset. A later launch needs separate authorization after review.
