# P07 CycleScene correction: isolated macOS Static probe result

The one reviewed invocation from preparation commit
`68d1854cc7f5f13d610223e71ab5d3950e6ac954` returned exit 0. Its terminal
status is `PASS_isolated_P07_only_no_dependent_release`, with one source candidate,
zero retries, and zero automatic repairs. The original P07 driver used the
authenticated campaign11 macOS Static P02 core receipt and created the sole new
output directory recorded in `probe/terminal.json`.

The driver receipt reports 33 passing checks: 21 positive stages and 12 intended
negative checks. Native execution reported `P07 values assertions=5904 failures=0`.
The static and dynamic logical transcripts agreed across 26 cases, and both
storage reports were produced. This validates the focused macOS Static P07
correction; it does not resume or repair campaign11.

`manifest.json` records original paths, byte counts, and SHA-256 values for 75
copied files: the exact probe launch/terminal/raw streams and the driver's Swift
sources, commands, logs, receipt, transcripts, and storage reports. Every copy
was compared byte-for-byte with its original. Binary modules, objects, cache,
and executable remain under `.build/`; their hashes are recorded in
`probe/terminal.json` and `driver/result.json`.

The 80 Analyzer ABI receipts from campaign11 remain historical evidence.
Schema-4 activation and counter384 were not run. Their release requires a
separate reviewed retained-evidence applicability decision or a fresh campaign.
