# Static successor identity map

These hashes describe this unexecuted static packet. They confer no campaign
or execution authority. Paths below are relative to this sibling.

| Path | Bytes | SHA-256 |
| --- | ---: | --- |
| `diagnostic_parser.py` | 9351 | `e5c4bd884ad0317ef8bf37734ff48808e116743a6ff2269dc9b65758433a8116` |
| `run-static-fixtures.py` | 6428 | `e24c86e3a52493fe3fbf92e79d050db71e7352ddd15b0e9d6db86c58acf4d36b` |
| `policy.json` | 798 | `7fdab23b783ec3811623f5b2e3dd60763f98f2871014856d788b15c4abb2f925` |
| `opt-in-control.json` | 1632 | `d1662da4a2fbd4403b9522670e6ea3877448ae00ec987894132e926a8adca411` |
| `inherited-A4-control.json` | 1042 | `3f6792aa34e9f1bfc189689c45480b68973beb49576cdc7d6ea931b96991e36c` |
| `inherited-cases.json` | 40358 | `f79bc14bbfdb36cd20f9178fa6aaef1f299233533cec7b485cd006e2ee4b3c99` |
| `new-cases.json` | 134206 | `74ff0b1e03f0d4f37b7e073812f0f51dba55bcd4c1f05cf1a0bffa849fbe4913` |
| `inputs/SignalPrimitiveValues.swift` | 1564 | `9c19b9df952323041e6b0f4e7bce3bcfe73d3557af2e40c47719c19e55993e1d` |
| `inputs/archived-A4.stdout` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `inputs/archived-A4.stderr` | 766 | `391335ae6ec9476f0bcdd8171297309390cf67f1fc6d115832c7cbdcb5d6b624` |
| `invocation.json` | 1123 | `e4a8d0680b2bdf777567495ab9d16cfe42eddea4fa075ffdbcbf4469facc4c44` |
| `preserved-inventory.json` | 53653 | `1c641d5e16976175700ab6ff4f35d1133fb66a0b696a382c7a95c344d7fe65f4` |
| `static-inspection.json` | 1136 | `e70d1266a1ce9fcdb8c14e532e25670a5ab420064f203e8ea688776c88124889` |


`packet-freeze.json` freezes all payload files (including this map) plus the
150 preserved candidate2 identities and exact future argv. Its own hash is
reported with the implementation commit; it excludes itself from its payload
list. The 15 historical proposal pins were compared byte-for-byte by identity
hashing; `static-inspection.json` records the count, not a diagnostic outcome.

The archived A4 input hash is the policy opt-in identity. The original complete
541-input postformat freeze is retained byte-identically in the preserved
inventory. Its source/compiler/SDK/plugin applicability has not been requalified.
