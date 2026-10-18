# Focused semantic C result — 87 bodies PASS, escape fixture discarded value

Source **f2325b85** fixed. All87 unique serialized positive bodies PASS. Checked
borrow positive and internal initializer negative PASS. Escape negative compiled
with zero errors; [exact stderr](logs/semantic-c-borrow-escape-negative.stderr) warns
that its SemanticRecordView expression is unused. `_ =` left generic Result free
to become Void; closure discarded the view instead of returning it. This is a
concrete harness flaw, not evidence that a view escaped the lifetime boundary.
SIL correctly blocked/not invoked. Earlier ill-typed solver diagnostic does not
qualify the corrected fixture's inferred return type.

[Raw result](result.json), [diagnosis](diagnosis.json), [receipt](receipt.json) and
[hashes](manifest.json) preserve87records/threechecks/alllogpairs.1293 frozen inputs
verify. No source/compiler/test/decoder/runtime during freeze; sourcecandidate1/1
fixed/zeroautomaticSOURCErepairs/oldbudgets unchanged. Next exact escapecontrol must
force an explicit returned view type/value with matching owned-result positive;
independent review before any focused continuation. No speculative compiler pretest.
ActualC/safety/14loans/Optional/lifetime/strictcold/P08 remain unqualified.
