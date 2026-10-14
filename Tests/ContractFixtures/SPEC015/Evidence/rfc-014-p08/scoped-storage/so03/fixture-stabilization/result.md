# SO-03 fixture stabilization validation — 2026-10-14

**The single macOS Dynamic component invocation passed; independent boundary
review is pending.** Source checkpoint `57175025` was clean before the run.
The only fixture source correction is the checked Canvas `appendRecord` in
`InteractionProbe.swift`, following the [joint source review](source-review.md).

Exactly one invocation ran:

```text
scripts/contracts/run-spec-011.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014-swift64/af66aaf967e3fe8f-__4p5wu2/macos-dynamic
```

Driver exit **0**. All **43 planned commands** ran once and passed their
oracles: 42 compiler cells (30 successful, 12 intended negative rejections)
and one executable. The 42 include the two prerequisites, 27 focused SO-03
probe cells, real source modules, layout IR and link. The executable reported
`P05 Interaction assertions=215 P03 root regressions=183 SO03 scoped/owned
assertions=61 failures=0`. This establishes the bounded native component
fixture result; it does not establish target-profile, full counter/cycle,
resource-fit or analyzer integration acceptance.

[The preserved receipt](attempt-1/result.json), [verification](attempt-1/verification.json)
and 49-file [snapshot manifest](attempt-1/snapshot-hashes.json) record the
complete planned/actual argv, exact input hashes, compiler diagnostics,
layout facts, raw logs and execute output. Independent read-only verification
matched all 43 argv in order, all 128 input hashes, all 130 artifact hashes
and sizes, and all positive/negative cell oracles. The local `.build` result
SHA-256 was `31613bfeb49590cbf9e01b107f72aea39a4102f89c2f41e4a5eccc1eb9d72496`.
The immutable local output is
`.build/contracts/spec-011-owned-keys/tmphg9s2wgt/macos-dynamic`.

This package's one source repair pass and one native invocation are consumed;
automatic follow-up repairs **0**. All three earlier native allowances and the
diagnostic remain 1/1 consumed; historical budgets and the consecutive
unproductive guard remain unchanged. No second compilation, retry, debugger,
target build, full suite or hardware action ran. The next step is a fresh
read-only Strong review of source, oracles, preserved evidence and remaining
scope before any further work.

All nine SO criteria, physical fit and the 58,648-versus-27,648 stack finding,
HC-RD-003/P08/R07/T8.1 and mandatory I4-07/P09–P12 duties remain open. SO-04–09
remain unapproved. No contract, lifecycle status or manifest change is claimed.
