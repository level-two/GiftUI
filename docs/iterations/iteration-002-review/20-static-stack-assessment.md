# Step 20 — Static stack evidence and its stopping boundary

The remaining hardware-free resource assessment now has an addressed static
inspection of production, named-role, snapshot-counting and clean-generation
ELFs. This step investigates whether available compiler metadata and direct
call-graph inspection establish a whole-stack replacement bound. The result
is **inconclusive for a whole-stack bound**, with explicit reproducible barriers.
It is not an unperformed measurement silently treated as a pass.

Run `python3 docs/iterations/iteration-002-review/inspect-hierarchy-stack.py`
after the four builds. [Hashed results and instructions](evidence/20-static-stack-inspection.json)
record nm-sized function intervals, addressed objdump instructions, direct
calls/external branches, register-indirect sites and observed entry allocations.
The script deliberately does not implement verified control-flow stack analysis.

| Image | Directly reachable functions from selected roots | Register-indirect sites | Largest observed entry allocation |
| --- | ---: | ---: | ---: |
| Production packed stage | 94 | 22 | 632 bytes |
| Named roles | 94 | 22 | 632 bytes |
| Production plus snapshot-counting entry | 227 | 35 | 1,224 bytes |
| Clean generation | 94 | 22 | 632 bytes |

No cycle is found in these **direct** graphs. Indirect targets are not followed,
so neither absence of recursion nor complete reachability is established.
Numbers are static sites/functions, not executed counts. The snapshot counting
Swift entry itself allocates 1,080 bytes at entry (36 saved-register bytes plus
1,044 stack bytes); the largest observed nested traversal entry is 1,224 bytes
(32 saved-register bytes plus 1,192 stack bytes). The C entry thunk adds eight
bytes. These local quantities must not be summed as a claimed high-water bound.

The paired compiler accepts `-Xllvm -stack-size-section` for the standalone
snapshot object but emits no `.stack_sizes` section. The evidence includes the
exact command in SPIKE-010 and the object hash/section-list identity here. Therefore
that metadata request cannot supply complete frame costs with this target.
Resolving register targets, all body stack mutations, all live ancestor frames,
failure paths, callers and interrupts would require a verified analyzer or
target stack measurement. This inspection stops at those explicit barriers.

## Planning disposition

Retain the packed runtime hierarchy. Clean generation emits identical source
and introduces no runtime algorithm/storage change; it does not require
proving a new traversal stack/time budget. The named-role candidate has local
frame observations and zero RAM delta, but those alone do not prove complete
stack neutrality. Its production adoption still needs the stated profile gate
and appropriate resource evidence.

Full declaration replacement is not a cleanup commitment: SPIKE-010 lacks
identity/state/publication parity and complete resource evidence. Budgeted
whole-stack and target timing are prerequisites if a later scope explicitly
selects that design. Connected timing/high-water remains deferred by the
maintainer's instruction, preserved through existing FW-031/032/033 and
conformance exceptions. No flashing/deployment occurred.

This completes the bounded static resource investigation with an inconclusive
bound disposition. A missing target timing result cannot be recovered from
native timings, linked RAM or a configured stack reservation.
