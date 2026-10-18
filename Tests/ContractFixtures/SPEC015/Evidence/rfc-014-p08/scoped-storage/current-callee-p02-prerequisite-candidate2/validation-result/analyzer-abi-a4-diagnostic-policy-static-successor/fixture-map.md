# Closed A4 static fixture inventory

All expectations below are unexecuted oracles. Each row is one concrete input.
The 22 inherited cases are preserved in `inherited-cases.json` with their original
IDs and expectations; no mutation is applied to that file.

| Input ID | Case ID | Expected outcome | Exact construction |
| --- | --- | --- | --- |
| A4-P01 | A4-P01 | accept, display notes 1 | Exact archived A4 streams/exit/control plus explicit policy opt-in. |
| A4-P02 | A4-P02 | accept, display notes 1 | Remap exact cell root consistently in header, control and trusted input inventory; retain source bytes. |
| A4-P03 | A4-P03 | accept, display notes 0 | Remove declaration excerpt and its display-note gutter only. |
| A4-N01.exit-zero | A4-N01 | reject | Replace exit with 0. |
| A4-N01.exit-two | A4-N01 | reject | Replace exit with 2. |
| A4-N01.signal-minus-eleven | A4-N01 | reject | Replace exit with -11. |
| A4-N01.boolean-true | A4-N01 | reject | Replace exit with True. |
| A4-N02.stack-dump | A4-N02 | reject | Append exact crash/fatal marker 'Stack dump:'. |
| A4-N02.llvm-error | A4-N02 | reject | Append exact crash/fatal marker 'LLVM ERROR:'. |
| A4-N02.fatal-error | A4-N02 | reject | Append exact crash/fatal marker 'fatal error: unexpected'. |
| A4-N03 | A4-N03 | reject | Replace primary located header path with undeclared sibling. |
| A4-N04 | A4-N04 | reject | Remove file/line/column prefix from primary header. |
| A4-N05 | A4-N05 | reject | Append unrelated located primary at allowed file. |
| A4-N06 | A4-N06 | reject | Replace primary header message with named OtherChannelID ABI dependency. |
| A4-N07 | A4-N07 | reject | Remove symbol from primary row 22; declaration excerpt remains. |
| A4-N08 | A4-N08 | reject | Put symbol only in neighboring rows 21 and 23, omitting row 22. |
| A4-N09 | A4-N09 | reject | Prepend generic ABI primary without its own symbol before qualifying primary. |
| A4-N10 | A4-N10 | reject | Move header alone to stdout; all excerpt/note rows stay in stderr. |
| A4-N11 | A4-N11 | reject | Move declaration excerpt/display note before any primary. |
| A4-N12 | A4-N12 | reject | Insert located warning after primary, before declaration excerpt. |
| A4-N13 | A4-N13 | reject | Insert one ordinary line between declaration excerpt and note. |
| A4-N14 | A4-N14 | reject | Replace declaration excerpt line 1 with line 2. |
| A4-N15.excerpt-byte | A4-N15 | reject | Replace one declaration excerpt byte. |
| A4-N15.gutter-byte | A4-N15 | reject | Remove one space from display gutter. |
| A4-N16.message | A4-N16 | reject | Replace note message with type declared elsewhere. |
| A4-N16.severity | A4-N16 | reject | Replace display note severity with error. |
| A4-N17 | A4-N17 | reject | Duplicate declaration excerpt and exact display note. |
| A4-N18.omit-opt-in | A4-N18 | reject | Omit display-only opt-in. |
| A4-N18.control-id | A4-N18 | reject | Replace control ID. |
| A4-N18.profile | A4-N18 | reject | Replace profile. |
| A4-N18.input-hash | A4-N18 | reject | Replace one byte of declared input hash. |
| A4-N19.line | A4-N19 | reject | Replace primary location with 21:17. |
| A4-N19.column | A4-N19 | reject | Replace primary location with 22:18. |
| A4-N20.unparsed-note | A4-N20 | reject | Append 'note: unexpected unparsed note'. |
| A4-N20.malformed-note | A4-N20 | reject | Append '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign2/macos-static/scratch/negative-A4/inputs/SignalPrimitiveValues.swift:22:x: note: type declared here'. |
| A4-N20.unknown-remark | A4-N20 | reject | Append 'remark: unexpected unknown remark'. |
| A4-N21 | A4-N21 | reject | Append located note at undeclared imported virtual file. |
