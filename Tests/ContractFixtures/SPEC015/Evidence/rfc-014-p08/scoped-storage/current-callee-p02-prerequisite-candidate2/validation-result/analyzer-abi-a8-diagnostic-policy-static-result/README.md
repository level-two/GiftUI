# A8 diagnostic-policy static result

The one reviewed static invocation of corrected packet `76841d74` exited zero
with `STATIC_FIXTURE_EXPECTATIONS_MATCHED_ONLY`. All 196 frozen inputs matched
their oracles: 113 inherited and 83 new A8 cases; 12 accepted and 184 rejected.
The exact archived `static-result.json` has SHA-256
`3b12285668cf3eaaadddc9a92e0f0c2964022b2f0a28ba3cd4690c98107efb1f`
and names freeze
`837c376e9eec929f2db345697bc1122cbe6a1c5a2dc6bf5acac3a36de9a2a192`.

This was one parser-only run, with no compiler, producer or campaign invocation
and no repair or retry. It does not requalify campaign4 A8 or establish
integrated compiler behavior. Campaign4 remains terminal STOP; P08 and later
gates remain open.
