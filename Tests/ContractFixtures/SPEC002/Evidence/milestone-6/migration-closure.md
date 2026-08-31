# SPEC-002 Migration Closure

Implementation-plan task `T6.1` re-ran the six governed-name queries against
the immutable annotated `PoC` tag and closed all 24 PF-008 ledger rows.

| Query | Paths | Ordered output SHA-256 |
| --- | ---: | --- |
| `Point` | 53 | `6979992f8927344a293456c59b51037e8d75d33cffd9968788c5480bfabbad62` |
| `Size` | 51 | `557ebd6bf9ecb209ec61c764e7098a20b199efaa183b04efc454befc525e1ed7` |
| `Rect` | 32 | `eaea6d1fe367369346f207a5488bdacdc952cb9841fca6c901eeff9b45601416` |
| `ProposedSize` | 7 | `b3770fa50575bb9cacdd4da8967c01956c182a1ed5f16b4565e46b2e8e4de5f0` |
| `LayoutArithmetic` | 8 | `e9b491c5d2b4ad79159cc86f93c175cc9de413303295c40d8c82df00bc6e9b58` |
| `InputEvent` | 14 | `a7f2e09e5f5277983f18768022a7c8324c2a10c169be02b13f4f653f7440de28` |

The checker pins tag object
`2b2837a66b94df38c7b74ead33ebbb54aa08a06d` and peeled commit
`d5d6330432caa7c983d8dba35cf9f23c3800860b`. It also requires the exact one-file
Foundation source inventory and verifies the fixed-width public geometry,
failable size/proposal/rectangle construction, optional package arithmetic,
bounded package input wrappers, mandatory event provenance, and package-only
normalized input family.

The same audit rejects mutable public storage, Foundation preconditions or
fatal traps, legacy `LayoutArithmetic`/`require*` shims, and a public
`InputEvent` compatibility family. Every ledger row now names its exact code
location or absence check; there are no approved exceptions or remaining
SPEC-002 owner blockers. Downstream PoC consumer families remain removed and
are not recreated by this task.

Validation:

```text
scripts/contracts/check-spec-002-migration.rb
scripts/contracts/run-spec-002.sh --profile macos-dynamic
```

Both commands pass. The registered standalone driver makes the closure audit
part of the repository's ordinary SPEC-002 contract surface.
