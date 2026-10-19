# Retained macOS Static counter426 requalification 1

This result preserves the single compiler-free requalification of the previously
collected counter driver evidence. The independent readiness review cleared the
exact launch pins `8021c0965d06e34f1692afc61214c5f52b83c5f2`, repository
tree `e6f0b59cead521bda88f63e6c33b823c7333ce20`, and packet tree
`ead3b1e8fdbc30487bf906b09330040d34c7cb10` after all 35 adversarial
static tests passed. The first candidate's readiness BLOCK remains historical.

The one permitted qualifier invocation exited zero and wrote the copied
`claim.json` and `terminal.json` under the permanent marker
`.build/contracts/p08-retained-evidence-counter426-requalification1`.
The terminal status is `PASS_retained_macos_static_counter426_only`: 426 unique
checks, 1,736,320 assertions, zero failures, 904 artifacts, 193 qualified
compiler-negative exit-one rows, and the separately qualified native
fatal-access exit `-6`. The disjoint check composition is 384 scoped (192
positive and 192 negative), two supplemental, 13 reuse, and 27 other. The
qualifier launched no compiler, counter driver, or schema-4 stage. It used the
reviewed retained driver archive and live evidence; the historical wrapper
terminal remains STOP with its original SHA-256
`71c478591e6cc0a47f4df89090686cc27a767ec9f0416bbd17c090cd7944171b`.

Raw copied payload identities:

| File | SHA-256 |
| --- | --- |
| `claim.json` | `e4fd9852e3a65f87749eb53a7d7ef6011cf2dd944f3d0b6d52cc9132bee9052f` |
| `terminal.json` | `c7c9e62e12c3270797e8e19d0f05fc4cc11b5ecbfbc98926e790346b781b7284` |

This is retained **macOS Static** counter evidence only. Campaign11 still
records its original P07 STOP; the corrected P07 probe and schema-4 receipt
are separate historical results. No four-profile campaign was rerun here.
P08, R07, T8.1, other profile and hardware evidence, full current-callee
safety, resource bounds, and conformance remain open.
