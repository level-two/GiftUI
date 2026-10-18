# ARMv6 A4 integration boundary (unimplemented here)

The static caller supplies context, complete control, expected path/dependency paths,
trusted source bytes and trusted_precompile as independent arguments. Diagnostic
text cannot select compiler, profile, module, path, source bytes, SDK or flags.
`policy.json` fixes every operand literally; there is no root/suffix wildcard.
Its archived core import operand is historical provenance, not fresh-core authority.

Before any future compile, the separately reviewed campaign wrapper must capture
and authenticate the actual compiler path/hash, ARMv6 target, supported SDK
archive digest, installed SDK provenance and toolchain pin bytes/hash, complete
planned argv/environment, and every source path/size/hash under its lock and
frozen-input gates. All source identities are checked against actual bytes by
that caller; this pure parser rechecks the primary source bytes itself. Compiler
and SDK hashes in fixture maps simulate authenticated caller inputs only.

The wrapper must seal this precompile capture before launch and independently
check actual argv/environment/exit and complete output hashes afterward. Current
core imports must join a fresh qualified P02 receipt and actual module bytes.
A campaign10 integration packet must declare and review exact literal relocation
of the campaign9 paths and core import to its own authenticated roots, preserving
compiler/SDK/flags/control/source/message identities. Passing arbitrary caller
maps or rewriting stderr paths is insufficient. No wrapper, launch, producer,
receipt qualification or campaign10 preparation is included here.

After invocation the parser accepts exactly one archived diagnostic sequence, or
that same sequence with only its declaration excerpt and note gutter removed.
It returns one located ABI primary. The declaration note is audit display only;
its text supplies no symbol or dependency evidence. There is no ARMv6 privacy,
A7/A8, Embedded or Dynamic opt-in. Every existing opt-in stays separate.
