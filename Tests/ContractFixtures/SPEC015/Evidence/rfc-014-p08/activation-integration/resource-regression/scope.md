# Swift6.4 focused resource compatibility scope — 2026-10-12

Approved correction267616c9 requires unchanged ABI/value-size/allocation/resource
limits (SPEC002/003/004/013). Parent assigned this supporting step separately from
Standard's P01/P02/P04/P07 four-profile rebuilds. No maintained Swift or driver
edits, hardware actions, ceilings/exemptions or P08/P11 exit claims are authorized.

Execute exactly these six bounded stages in the evidence-local harness:
1. `scripts/contracts/run-spec-002.sh --profile macos-static --compiler-baseline rfc-014`
2. `bash focused.sh 003-native`: unchanged SPEC003 run_layout_probe and
   run_allocation_probe functions, verified6.4 compiler, native Static -O/WMO.
3. `bash focused.sh 004-native`: unchanged SPEC004 run_allocation_probe and its
   existing allocation/layout checker, verified6.4 native Static -O/WMO.
4. `bash focused.sh 003-linked`: unchanged SPEC003 run_macos_resource_pair with
   both baseline/candidate on6.4, original linked RAM/stack/code bounds, two pristine
   builds and exact repeatability gate. Stop at first source incompatibility.
5. `bash focused.sh 003-nrf-layout`: unchanged SPEC003 core/diagnostic layout probes
   with bundled armv7em module, Embedded -Osize/WMO and original hard-float flags.
6. `bash focused.sh 004-nrf-layout`: unchanged SPEC004 target-layout probe/checker
   with the same Embedded target flags. No nRF flash or CPU execution.

Existing003/004 main drivers have no compiler-baseline option and hard-code the
historical xcrun native compiler. Extract their functions verbatim into an isolated
harness; record source hashes and explicit compiler. This is focused evidence,
not a falsely relabelled complete driver pass. Output/cache/generated paths stay
under .build/rfc-014-swift64/resource-regression; freeze full logs, commands,
receipts and report hashes, not binary artifacts. SPEC002 remains the public
rfc014 route and may expose obsolete foundation-fixture assumptions.

At most two narrowly justified harness-command repairs after initial stages;
stop a component on source/API incompatibility rather than migrate it here.
Stop two consecutive unproductive failures. Independent components may complete
once an incompatibility has specifically narrowed one component; do not repeat
that same blocked component. Freeze exact outcomes and resource dimensions not
measured. Native linked-resource failure cannot be replaced by a layout pass.
Full ARMv6/nRF linked resource pairs remain required where contracts prescribe
them; existing support-module API failure should be identified before costly
repetition of the same invalid source graph. Baseline correction and parent
closure decisions must retain any such unmet prerequisite explicitly.
