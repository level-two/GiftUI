# Current-callee complete environment preparation — 2026-10-19

Compiler-free response to [independent review B2](independent-review.md).
Readiness remains pending. No compiler, build, test, runtime or decoder ran;
collection use remains 0/1, maximum 94 swiftc invocations, zero repairs/retries.

[process-environment.json](process-environment.json) supplies complete dictionaries
for the env-i bootstrap, controller, compiler and inherited macro process,
decoder, and isolated interpreter/demangler. Every child receives an explicit
complete dictionary. Ambient PATH, Python/startup, loader, Swift and Git settings
are excluded. Python uses the absolute Xcode interpreter with
`-I -S -B -X pycache_prefix=/dev/null`. Only the named exact interpreter-added
LC_CTYPE/CF encoding values may appear at the bootstrap boundary.

[loader-roots.json](loader-roots.json) inventories all seven proposed loader
roots, including the three omitted by the earlier inherited manifest:
Developer/Library/PrivateFrameworks, Contents/SharedFrameworks and
/Library/Developer/PrivateFrameworks. It retains every file hash/size, directory
and link, 8,578 entries total. [loader-aliases.json](loader-aliases.json) joins
1,062 symlinks to their resolved file identities or directory paths; every
resolved endpoint is inside the seven inventoried roots. No missing alias was
observed. The testing-library and decoder-library roots are included.

[controller-context-policy.json](controller-context-policy.json) selects the ten
applicable inherited complete compiler/SDK/Python/macro trees. Current import
trees and retained producer evidence remain independently frozen by the earlier
packet. Inherited historical target/probe trees are not current compiler inputs;
their historical evidence and limits remain unchanged. The controller must
reauthenticate complete applicable inventories at production boundaries.

Apple's installed system loader and /usr/lib and /System/Library runtimes remain
the explicit OS trust boundary. This packet does not claim a portable hermetic
OS image. Developer/user/toolchain search roots are frozen, including symlink
resolution; existence alone supplies no authentication.

[environment-preparation-inspection.json](environment-preparation-inspection.json)
records file-read/hash/inventory observations only. The next dependency is the
concrete one-shot controller plus independent Strong readiness review of the
complete code/environment packet. These snapshots do not authorize a launch.
