# Existing-image P08 materialization evidence — 2026-10-15

Read-only extraction for the [resource design activity](../p08-resource-design-activity.md)
and [implementation note](../../../../../../../docs/implementation-designs/spec-015-p08-stack-materialization.md).
No compiler/build/target execution or changed source/limit. Existing linked ELF
SHA-256 `66ca1113d997c6424aedb258c1477692ce4bf5b42ed77f42bb1d5cba66339da9`;
the original [image/disassembly packet](../remaining-early-images/image-manifest.json)
and historical failures remain frozen.

- `frames-and-direct-calls.json.xz`: exact ELF STT_FUNC symbols/extents,
  demangled names, prologues, direct call/tail targets and bounded copy windows
  for eight large functions. Each `0xADDRESS.disassembly.txt.xz` stores its
  actual complete numeric instructions from the already preserved full dump.
  No nearest printed objdump label is used to identify a function.
- `qualified-copy-observations.json`: explicit immediate memcpy lengths only
  when no intervening BL follows the r2 initialization. Wake controls have 138
  3,889-byte and six 4,200-byte sites. These are static transfer-site counts,
  not dynamic execution counts or a sum of live bytes. Exact tag/project/destroy
  helper symbols tie the former to CounterHostState; getter call at0x2359c ties
  the latter sample to CounterControl.admission. Materialization is not semantic
  duplication of noncopyable authority.
- `path-and-ram-arithmetic.json`: seven exact frame lower bounds, two nested
  BL edges and source predicates; 213,120-byte repeated-host lower bound;
  conditional stack-object/total-RAM arithmetic with unchanged other bytes.
  It is not a complete feasible-path upper bound or proposed stack limit.
- `dwarf-observation.json` / `nrf-dwarf-info.txt.xz`: exact readelf command/tool/
  ELF/output identity. Output has ANSI C99 and assembler compilation languages,
  zero Swift-named DIE lines. The existing Swift recipe has no debug flags;
  there are no Swift variable locations for a precise frame partition here.
- `inputs-and-packet.json`: exact current source and toolchain-header identities,
  compressed/uncompressed payload hashes and source-budget history attribution.
  Source `6d82a31d` and its linked connected record establish the origin of27,648;
  that historical result is not current-image fit.

Numeric disassembly derives from the existing full `objdump -d` output (command
and SHA in the previous packet). Names were decoded with the pinned existing
`swift-demangle --compact`, feeding all exact ELF function names on stdin;
the tool hash is in the frame metadata. This is symbol decoding, not compilation.
DWARF used `arm-zephyr-eabi-readelf --debug-dump=info` on that same ELF; its exact
argv/output hash is separately recorded. Generic ET_REL function offset alone
cannot identify a unique future function: section identity is required too.

To inspect compact metadata without executing target code:

```sh
python3 -B -c 'import json,lzma,pathlib; p=pathlib.Path("Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/resource-design/frames-and-direct-calls.json.xz"); d=json.loads(lzma.decompress(p.read_bytes())); print([(x["address"],x["demangled"]) for x in d["frames"]])'
```

The proposed source candidate and one early target-object rejection screen are
in the design note. Their stack effect is unknown until measured; no probe,
changed toolchain/flags, unsafe enum projection or workload reduction is selected.
