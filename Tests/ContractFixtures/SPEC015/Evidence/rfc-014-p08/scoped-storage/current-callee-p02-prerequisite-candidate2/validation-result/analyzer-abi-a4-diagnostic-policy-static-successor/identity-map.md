# Static successor identity map

These hashes describe this unexecuted static packet. They confer no campaign
or execution authority. Paths below are relative to this sibling.

| Path | Bytes | SHA-256 |
| --- | ---: | --- |
| `diagnostic_parser.py` | 9620 | `fe25ee0d8918635c25aff6766f6541428311e16fbd6719603a50f592cd28001a` |
| `run-static-fixtures.py` | 6687 | `f3c9b361fc90440cd627e062f85d569186fbd3b32c223c4ad93726cd70ec3633` |
| `policy.json` | 798 | `7fdab23b783ec3811623f5b2e3dd60763f98f2871014856d788b15c4abb2f925` |
| `opt-in-control.json` | 1632 | `d1662da4a2fbd4403b9522670e6ea3877448ae00ec987894132e926a8adca411` |
| `inherited-A4-control.json` | 1042 | `3f6792aa34e9f1bfc189689c45480b68973beb49576cdc7d6ea931b96991e36c` |
| `inherited-cases.json` | 40358 | `f79bc14bbfdb36cd20f9178fa6aaef1f299233533cec7b485cd006e2ee4b3c99` |
| `new-cases.json` | 134271 | `b4153279abc9bcc596843e3eabd3c4e0906261f2a1eef8aa738c0aee68750d1f` |
| `inputs/SignalPrimitiveValues.swift` | 1564 | `9c19b9df952323041e6b0f4e7bce3bcfe73d3557af2e40c47719c19e55993e1d` |
| `inputs/archived-A4.stdout` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `inputs/archived-A4.stderr` | 766 | `391335ae6ec9476f0bcdd8171297309390cf67f1fc6d115832c7cbdcb5d6b624` |
| `invocation.json` | 1243 | `fc1e0a9b1804d993d82301133f3e604a044006ac189087a5f0522f655d2e5ced` |
| `preserved-inventory.json` | 53653 | `1c641d5e16976175700ab6ff4f35d1133fb66a0b696a382c7a95c344d7fe65f4` |
| `static-inspection.json` | 1385 | `ffb12ef57096802150a465d92b97b05f801f7a2b33bd0bc0d89fbc4d1ea06e69` |


`packet-freeze.json` freezes all payload files (including this map) plus the
150 preserved candidate2 identities and exact future argv. Its own hash is
reported with the implementation commit; it excludes itself from its payload
list. The 15 historical proposal pins were compared byte-for-byte by identity
hashing; `static-inspection.json` records the count, not a diagnostic outcome.

The archived A4 input hash is the policy opt-in identity. The original complete
541-input postformat freeze is retained byte-identically in the preserved
inventory. Its source/compiler/SDK/plugin applicability has not been requalified.
