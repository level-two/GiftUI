"""Derive a quieter disposable copy while preserving the accepted verbose copy."""
from pathlib import Path
import hashlib,json,shutil,subprocess
root=Path.cwd();base=root/'.build/raspberry-pi/spike-013/package';out=root/'.build/raspberry-pi/spike-013/aggregate';app=out/'package'
shutil.copytree(base,app,dirs_exist_ok=True)
p=app/'Sources/GiftUIPlatformRaspberryPi/LinuxPiScreenDevices.swift';s=p.read_text()
old='                print("pi-research-mmap \\(elapsed) \\(bytes.count)")'
assert s.count(old)==1
s=s.replace(old,'                PiResearchFramebufferMetrics.microseconds += UInt64(elapsed)\n                PiResearchFramebufferMetrics.calls += 1\n                PiResearchFramebufferMetrics.bytes += UInt64(bytes.count)')
s+='''
#if os(Linux)
package enum PiResearchFramebufferMetrics {
    nonisolated(unsafe) package static var microseconds: UInt64 = 0
    nonisolated(unsafe) package static var calls: UInt64 = 0
    nonisolated(unsafe) package static var bytes: UInt64 = 0
    package static func reset() { microseconds = 0; calls = 0; bytes = 0 }
    package static func read() -> (UInt64, UInt64, UInt64) { (microseconds, calls, bytes) }
}
#endif
''';p.write_text(s)
p=app/'Sources/SignalAnalyzerTargetHost/PiResearchClock.swift';s=p.read_text()
s=s.replace('    package static func now()', '    nonisolated(unsafe) package static var resetFramebuffer: (() -> Void)?\n    nonisolated(unsafe) package static var readFramebuffer: (() -> (UInt64, UInt64, UInt64))?\n    package static func now()')
s=s.replace('    package static func begin() {','    package static func begin() {\n        resetFramebuffer?()')
s=s.replace('        let elapsed = now() - origin','        let elapsed = now() - origin\n        let framebuffer = readFramebuffer!()\n        print("pi-research-mmap-total \\(framebuffer.0) \\(framebuffer.1) \\(framebuffer.2)")');p.write_text(s)
p=app/'Sources/SignalAnalyzerPiResearch/LinuxSignalAnalyzerPiProcessLoop.swift';s=p.read_text();start=s.index('        static func run(');pos=s.index('{',start)+1
s=s[:pos]+'''\n            PiResearchClock.resetFramebuffer = { PiResearchFramebufferMetrics.reset() }
            PiResearchClock.readFramebuffer = { PiResearchFramebufferMetrics.read() }
            defer { PiResearchClock.resetFramebuffer = nil; PiResearchClock.readFramebuffer = nil }
'''+s[pos:];p.write_text(s)
record={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'source':'accepted verbose package; original copied-owner bodies and module dependencies retained','inputs':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in (app/'Package.swift',app/'Sources/GiftUIPlatformRaspberryPi/LinuxPiScreenDevices.swift',app/'Sources/SignalAnalyzerTargetHost/PiResearchClock.swift',app/'Sources/SignalAnalyzerPiResearch/LinuxSignalAnalyzerPiProcessLoop.swift',root/'experiments/spike-013-connected-host-followup/prepare-pi-aggregate.py')}}
(root/'experiments/spike-013-connected-host-followup/evidence/pi-aggregate-preparation.json').write_text(json.dumps(record,indent=2)+'\n');print('Prepared accumulated-counter copy; original verbose package preserved.')
