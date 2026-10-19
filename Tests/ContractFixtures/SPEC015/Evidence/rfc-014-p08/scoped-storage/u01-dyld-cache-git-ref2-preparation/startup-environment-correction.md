# Offline startup-environment correction — 2026-10-19

**NOT READY pending separate Strong review. No launch/retry is cleared.**
After diagnostic `9542d659`, only the exact startup-environment predicate and
source/lock/request pins change. The original failed attempt and its uncertainty
remain recorded. The result directory is absent; no marker/session is created.

The launch input remains three entries after `env -i`. The pinned runtime then
produces one additional observed entry. The controller requires exact equality
with this four-entry value in both its constant and runtime lock:

```json
{"LANG":"C","LC_ALL":"C","TZ":"UTC","__CF_USER_TEXT_ENCODING":"0x1F5:0x7:0x3D"}
```

Any missing/different value or extra entry fails before mkdir. No arbitrary
inherited value or wildcard is accepted, and no entry is silently normalized.
The `env -i` prefix still discards all inherited proxy, credential, tracing,
Python/site/config and other environment entries before Python starts. The
fourth entry's observed name/value is pinned; the probe does not identify which
native component introduces it. Normal pinned-runtime/OS trust remains assumed.

This exact standalone probe ran once from the repository root and exited zero:

```sh
/usr/bin/env -i LANG=C LC_ALL=C TZ=UTC /opt/homebrew/Cellar/python@3.14/3.14.6/Frameworks/Python.framework/Versions/3.14/bin/python3.14 -I -S -B /Users/eugene/work/GiftUI/Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/u01-dyld-cache-git-ref2-preparation/startup-environment-probe.py
```

The [probe](startup-environment-probe.py) imports the same stdlib modules in the
same order, prints the actual/expected environment and identity/flags, and
requires exact equality. [Original stdout](startup-environment-probe.stdout.json)
records the four entries above, exact_match true, and -I/-S/-B enabled. It never
reads/imports/executes controller code, accesses network or creates a marker.

[Offline inspection](startup-environment-correction-inspection.json) pins the
probe/stdout, source/request/lock and exact argv; verifies all 2,165 dependency
hashes and 2,160 stdlib members; and preserves five dirty files, exact cache
membership/hash, three consumed marker identities and prior API 1/1 accounting.
Runtime dependency bytes are unchanged; only environment metadata changes in
the lock. No controller import/execution occurred during this correction.

Request count, accepted-body/full-stream rules, TLS, deadline, one-shot receipts,
no-follow boundary and all P08 stops stay binding. No architecture/contract/
scope/allowance or repair-budget reset occurs. Fresh Strong review and separate
launch authorization are still required; this is offline preparation only.
