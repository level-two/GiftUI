# R07 production GOT source step

Entry93d15431, reviewed handoff got-placement/independent-review.md.
Counter.cmake adds the existing Zephyr RODATA hook; adjacent counter_got.ld
is exactly the prescribed ALIGN4/boundary/four-pattern snippet plus explanation.
No normal-analyzer recipe or generated Zephyr script is edited.

Required formatter PASS exit0, no maintained Swift changes. All346frozen inputs
match except the explicitly edited Counter.cmake; the new snippet hash is added.
Exact two-file source patch and current hashes are adjacent. This is the source
step only: no production validation invocation yet, no image/resource pass.

One supported build remains authorized, with normal CMake stages; record actual
outcome, then STOP for independent result review. Diagnostic1/1 and historical
helper2/2+B031/1 remain closed; no source/flags/runtime/config/workload/limit
relaxation, automatic repair, target execution or hardware.
