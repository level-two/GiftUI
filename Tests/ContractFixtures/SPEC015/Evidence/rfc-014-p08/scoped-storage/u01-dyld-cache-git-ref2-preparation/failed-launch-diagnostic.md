# U01 ref2 failed pre-marker launch diagnostic — 2026-10-19

**STOP / current invocation cannot satisfy its environment check. No retry is
authorized.** The exact request.json argv was submitted after readiness review
`3dca5f0a` of source `e9c7a059`. The invoking task reports tool exit 1, empty output,
and no fixed result directory immediately afterward. Those observations do not
establish whether the tool started the process or rejected it; no approval or
rejection explanation surfaced. This diagnostic did not execute or import the
controller, and does not reconstruct the earlier process's unrecorded exception.

## Reproducible startup blocker

A standalone Python diagnostic used the exact absolute executable, clean
`env -i LANG=C LC_ALL=C TZ=UTC` and `-I -S -B`, from the repository root. It
imported the controller's standard-library modules in the same order, without
reading its source as code, importing it, or calling its functions:

```python
import time
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import signal
import socket
import ssl
import sys
print(json.dumps(dict(os.environ), sort_keys=True))
```

The observed environment is:

```json
{"LANG": "C", "LC_ALL": "C", "TZ": "UTC", "__CF_USER_TEXT_ENCODING": "0x1F5:0x7:0x3D"}
```

The same clean command prefix running `/usr/bin/env` instead of Python prints
only LANG, LC_ALL and TZ. The Python process therefore sees an extra entry despite
the clean invocation; this diagnostic does not identify the native component
that introduces it. [Controller](controller.py) line 317 requires
`dict(os.environ) == ENV`, where ENV has only those three declared entries.
The observed runtime deterministically fails that predicate with
`Stop('require exact clean environment')`. All preceding identity predicates
match current bytes/runtime; the standalone inspection also checked the later
runtime predicates and found no other mismatch. [Inspection evidence](failed-launch-diagnostic-inspection.json)
records the scope and preservation results.

`main` calls this check at line 360, before exclusive result mkdir at line 363.
Its outer BaseException handler at lines 454–456 calls `os._exit(1)` without
printing the reason or creating a receipt. This explains how the current
environment yields exactly an empty exit 1 before the marker. It is a concrete
present blocker and a sufficient explanation **if the reviewed process ran**;
the earlier tool result alone cannot prove that causal attribution.

## Network and allowance boundary

The fixed result directory remains absent. In the inspected controller every
DNS/connect/send path is in the child after exclusive fixed mkdir, parent fsync,
durable launch receipt and fork. With the packet's normal filesystem/OS trust
boundary and preserved marker policy, emission from this controller is
impossible without that permanent directory. This is source-order and local
state evidence, not an independent network-history or hostile-OS attestation.
No ref2 request intent/session marker or HTTP request allowance was consumed;
the submitted launch command is still a failed attempt, not an unused-command
claim or permission to retry. Diagnostic network operations, controller imports
and controller executions are all zero.

Prior API GET remains 1/1 consumed (retained HTTP 403). Three P08 markers remain
`[16777234,29640436] / [16777234,29650609] / [16777234,29652748]`, each 1/1 consumed;
repairs/retries remain zero. Five dirty-file hashes, exact sole cache member/hash
and retained API/tag metadata hashes/sizes match the prior review baseline.
All 2,165 runtime file hashes, 2,160 resolved stdlib members, absent zip path,
executable/version/SSL/OS/search paths/flags and imported-module origins match.
The controller, request and lock pins remain unchanged. The preparation README's
known difference from the e9c7a059 inspection is the historical readiness
navigation added in 3dca5f0a; it is not a controller or runtime change.

## Exact next prerequisite

Prepare a narrowly scoped **offline** revision that explicitly reconciles actual
startup environment with the enforced clean-environment policy, preserves the
request/body/deadline/TLS/one-shot boundaries, and freezes the resulting exact
source/packet/runtime pins. Demonstrate the actual non-controller startup state
for its exact invocation, then obtain a fresh independent readiness review of
that frozen revision and this failure disposition. Do not silently relax the
environment predicate, edit the reviewed invocation in place, create a result
marker, or automatically run another attempt. A later launch needs separate
authorization after that review; no successor/follow/read allowance follows.

This is post-MVP ITERATION-003 revision 5 I3-04/I3-05 evidence under accepted
ADR-039/040 and implementing SPEC-015, with closed ITERATION-001 obligations
preserved. Candidate existence/build/dyld/cache applicability remains unknown;
S/old B remain closed and U01/R01–R04, ordinary identity/Error costs/U02–U05,
full callee/safety, strict cold/zero heap, profile resources/SO/conformance,
P08/R07/T8.1 and I4-07/P09–P12 remain open. Only this evidence and minimal
navigation changed; no architecture, contract, scope, lifecycle or allowance
decision was made. This is a current readiness blocker, not deferred work; no
new optional out-of-scope item arose. No compiler/build/test/target operation,
network, source/header/object acquisition or dyld/cache tool ran.
