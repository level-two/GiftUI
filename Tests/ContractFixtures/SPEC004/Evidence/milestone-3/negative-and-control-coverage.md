# SPEC-004 T3.3 Negative and Control Coverage

The typed resolver, raw adapter tests, and normalized semantic corpus together
cover the complete negative/control surface without manufacturing malformed
typed values.

| Required boundary | Evidence |
| --- | --- |
| Missing contributor | Empty typed buffer returns the lowest missing role, render producer, and constructs no required snapshot |
| Duplicate contributor | A distinct second producer is rejected, the first producer remains stored, resolution returns the duplicate reason, and no snapshot is constructed |
| Malformed raw adapter | Every one of 11 malformed fields is preserved for every one of four roles; simultaneous failures choose lowest role then lowest field |
| Extent conversion | Zero dimensions map to malformed extent, values above `UInt16.max` map to logical extent overflow, and a valid 640 x 480 control is preserved |
| Optional and required absence | The same unavailable result yields a snapshot with a nil family only for optional absence; required absence yields no snapshot |
| Resolver workspace | Two normalized candidates with one usable slot return exact required/available counts 2 and 1 and leave no candidate residue |
| Unsupported extent | Candidate width, surface width, candidate full height, and surface full height each return unsupported logical extent |
| Policy | A technically conforming RGB565 path excluded only by policy returns policy unavailable; the one-field allow control is available, never weakened |
| Arithmetic overflow | The constructible shared row-usage overflow returns raster byte-count overflow before capacity evaluation |
| Raster capacities | Requirement, realization, and policy each pass at exact equality and fail at first excess |
| Payload capacities | Requirement, realization, and policy each pass at exact equality and fail at first excess |
| In-flight capacities | Requirement, surface, and policy each pass at exact equality and fail at first excess; zero available bytes remain zero |

No failure path traps in the 110-test package suite or contract probe. Results
are closed typed values and contain no diagnostic handle. Dependency, public
surface, and undefined-symbol checks prove the capability leaf does not import
or consult diagnostic facilities. Failed required resolution cannot expose a
partial effective value; duplicate insertion cannot perform last-writer
substitution; policy cannot manufacture a weaker path.

Validated on 2026-08-30 with `swift test` and all four
`scripts/contracts/run-spec-004.sh --profile ...` commands. The 42-row semantic
transcript passes in both executable macOS profiles, and unchanged production
declarations cross-compile for ARMv6 and nRF52840. Cross-target results are
hardware-free evidence only.
