# A7 diagnostic-policy static result

The single reviewed static invocation of packet `7bf633e0` exited zero with
`STATIC_FIXTURE_EXPECTATIONS_MATCHED_ONLY`. All 113 frozen inputs matched their
oracles: 59 inherited and 54 new A7 cases; 10 accepted and 103 rejected.
The exact `static-result.json` is archived here, SHA-256
`43c16178dde87491c79403658ff8d70a1de4341a88bb136e82d7dbfe478835fd`.
It names packet freeze
`a271243acaa828e857ab03c1cb03f72e78cb02d68a807fbe646805ce801a60e8`.

This was one parser fixture invocation with zero compiler/producer/campaign
invocations and no repair or retry. The result does not requalify campaign3 A7
or establish integrated compiler behavior. Campaign3 remains terminal STOP;
P08 and all later gates remain open.
