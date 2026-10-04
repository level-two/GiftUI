"""Prepare an isolated Pi package/product; never replace the production artifact."""
from pathlib import Path
import hashlib,json,re,shutil,subprocess
root=Path.cwd();spike=root/'experiments/spike-013-connected-host-followup';out=root/'.build/raspberry-pi/spike-013';app=out/'package';app.mkdir(parents=True,exist_ok=True)
shutil.copytree(root/'Sources',app/'Sources',dirs_exist_ok=True)
# Test target paths remain present for manifest validation; tests are not built here.
shutil.copytree(root/'Tests',app/'Tests',dirs_exist_ok=True)
manifest=(root/'Package.swift').read_text().replace('SignalAnalyzerRaspberryPiARMv6','SignalAnalyzerPiResearch')
manifest=re.sub(r'\.package\(\s*url: "https://github.com/swiftlang/swift-syntax.git",\s*exact: "603.0.2"\s*\)',f'.package(path: "{root}/.build/raspberry-pi/scratch/SignalAnalyzerRaspberryPiARMv6-release-static/checkouts/swift-syntax")',manifest)
manifest+='\nfor target in package.targets { target.swiftSettings = (target.swiftSettings ?? []) + [.define("GIFTUI_DYNAMIC_PROFILE")] }\n'
(app/'Package.swift').write_text(manifest)
old=app/'Sources/SignalAnalyzerRaspberryPiARMv6';new=app/'Sources/SignalAnalyzerPiResearch'
if new.exists():shutil.rmtree(new)
old.rename(new)
p=app/'Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiInitialPresentationOwner.swift';s=p.read_text()
stages=json.loads((spike/'evidence/preparation.json').read_text())['stages']
for i,name in enumerate(stages):
 start=s.index('    package mutating func '+name+'(');pos=s.index('{',start)+1
 s=s[:pos]+f'\n        let researchStart = PiResearchClock.now()\n        defer {{ PiResearchClock.stage({i}, researchStart) }}\n'+s[pos:]
s=s.replace('        let result = RuntimeCompletePipeline.run(owner: &self)','        PiResearchClock.begin()\n        let result = RuntimeCompletePipeline.run(owner: &self)\n        PiResearchClock.end(model.state.capture.transitions.count)')
p.write_text(s)
(app/'Sources/SignalAnalyzerTargetHost/PiResearchClock.swift').write_text('''#if os(Linux)
import Glibc
package enum PiResearchClock {
    nonisolated(unsafe) static var times = [UInt64](repeating: 0, count: 11)
    nonisolated(unsafe) static var origin: UInt64 = 0
    nonisolated(unsafe) static var count: UInt32 = 0
    package static func now() -> UInt64 {
        var value = timespec()
        precondition(clock_gettime(CLOCK_MONOTONIC, &value) == 0)
        return UInt64(value.tv_sec) * 1_000_000 + UInt64(value.tv_nsec) / 1_000
    }
    package static func begin() {
        times = [UInt64](repeating: 0, count: 11); count += 1; origin = now()
        print("pi-research-begin \\(count)")
    }
    package static func stage(_ index: Int, _ start: UInt64) { times[index] += now() - start }
    package static func end(_ captureCount: Int) {
        let elapsed = now() - origin
        print("pi-research-end \\(count) \\(elapsed) \\(captureCount) " + times.map(String.init).joined(separator: ","))
    }
}
#endif
''')
# Capture the real mmap projection duration, not panel flush completion.
p=app/'Sources/GiftUIPlatformRaspberryPi/LinuxPiScreenDevices.swift';s=p.read_text();start=s.index('        package func presentRGB565BigEndian(');pos=s.index('{',start)+1
s=s[:pos]+'''\n            var researchStart = timespec()
            precondition(Glibc.clock_gettime(CLOCK_MONOTONIC, &researchStart) == 0)
            defer {
                var finish = timespec()
                precondition(Glibc.clock_gettime(CLOCK_MONOTONIC, &finish) == 0)
                let elapsed = (finish.tv_sec - researchStart.tv_sec) * 1_000_000 + (finish.tv_nsec - researchStart.tv_nsec) / 1_000
                print("pi-research-mmap \\(elapsed) \\(bytes.count)")
            }
'''+s[pos:];p.write_text(s)
p=app/'Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiLifecycleOwner.swift';s=p.read_text()
old='        return source.deliverScheduledTransition(generation: generation)'
assert s.count(old)==1
s=s.replace(old, '        let result = source.deliverScheduledTransition(generation: generation)\n        print("pi-research-source \\(PiResearchClock.now()) \\(result)")\n        return result')
p.write_text(s)
record={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'stages':stages,'product':'SignalAnalyzerPiResearch','inputs':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [app/'Package.swift',app/'Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiInitialPresentationOwner.swift',app/'Sources/SignalAnalyzerTargetHost/PiResearchClock.swift',app/'Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiLifecycleOwner.swift',app/'Sources/GiftUIPlatformRaspberryPi/LinuxPiScreenDevices.swift',spike/'prepare-pi.py']}}
(spike/'evidence/pi-preparation.json').write_text(json.dumps(record,indent=2)+'\n');print('Prepared copied Pi package and separate research product.')
