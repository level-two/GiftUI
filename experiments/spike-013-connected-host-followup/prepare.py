"""Copy production application and add bounded research instrumentation only."""
from pathlib import Path
import hashlib,json,shutil,subprocess
root=Path.cwd();spike=root/'experiments/spike-013-connected-host-followup'
source=root/'firmware/nrf52840/applications/signal-analyzer-static'
swift=(source/'src/StaticPreset.swift').read_text()
stages=('admitAndSeal','applyAdmittedWork','freezeObservableMutation','beginObservableCandidateAndExpandSemantics','resolveLayout','invokeCanvasesAndDerivePlan','preflightCombinedRender','buildInteractionCandidate','publishSemanticAndObservableCandidate','allocateCandidate','offerAndProduce')
for index,name in enumerate(stages):
 start=swift.index('    mutating func '+name+'(');pos=swift.index('{',start)+1
 swift=swift[:pos]+f'\n        let researchStart = giftUIResearchClock()\n        defer {{ giftUIResearchStage({index}, researchStart) }}\n'+swift[pos:]
old='    let result = RuntimeCompletePipeline.run(owner: &owner)\n    return owner.finish(result)'
assert swift.count(old)==1
swift=swift.replace(old,'    giftUIResearchBegin(frameRevision, initial ? 1 : 0)\n    let result = RuntimeCompletePipeline.run(owner: &owner)\n    let code = owner.finish(result)\n    giftUIResearchEnd(code)\n    return code')
swift+='''\n@_silgen_name("giftui_research_clock") private func giftUIResearchClock() -> UInt32
@_silgen_name("giftui_research_stage") private func giftUIResearchStage(_ index: UInt32, _ start: UInt32)
@_silgen_name("giftui_research_begin") private func giftUIResearchBegin(_ revision: UInt32, _ initial: UInt32)
@_silgen_name("giftui_research_end") private func giftUIResearchEnd(_ outcome: UInt32)
@_cdecl("giftui_research_fresh_input") public func giftUIResearchFreshInput() {
    giftUIStaticInput = StaticSignalAnalyzerNRFFirmwareInputStorage()
}
'''
hooks=(source/'tests/host_native_rehearsal_hooks.swift').read_text().split('nonisolated(unsafe) private var rehearsalWriteCount')[0]
swift+='\n'+hooks
record={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'stages':stages,'inputs':{}}
for mode in ('normal','refusal'):
 out=root/f'.build/nrf52840/spike-013-connected-host-{mode}';app=out/'application';shutil.copytree(source,app,dirs_exist_ok=True)
 cmake=(source/'CMakeLists.txt').read_text().replace('${CMAKE_CURRENT_SOURCE_DIR}/../../../..',str(root))
 cmake+='\ntarget_sources(app PRIVATE "'+str(spike/'research.c')+'")\ntarget_include_directories(app PRIVATE "'+str(spike)+'")\ntarget_compile_definitions(app PRIVATE RESEARCH_MODE='+str(int(mode=='refusal'))+')\n'
 (app/'CMakeLists.txt').write_text(cmake);(app/'src/StaticPreset.swift').write_text(swift)
 main=(source/'src/main.c').read_text().replace('int main(void)','__attribute__((used, retain)) int giftui_research_original_main(void)')
 main+='\n#include "research.h"\nint main(void) { return giftui_research_run(); }\n';(app/'src/main.c').write_text(main)
 host=(source/'src/production_host.c').read_text().replace('#include "production_host.h"','#include "production_host.h"\n#include "research.h"')
 assert host.count('            spi_tft_write_rgb565')==2
 host=host.replace('            spi_tft_write_rgb565','            giftui_research_write')
 host=host.replace('    *stop = 0;','    *stop = 0;\n    int research_control = giftui_research_service(regions, now);\n    if (research_control != 0) { *stop = 1; return research_control < 0 ? -EIO : 0; }')
 host=host.replace('        due_count++;','        due_count++;\n        giftui_research_source(now);')
 host=host.replace('    context->touch.valid = 0U;','    context->touch.valid = 0U;\n    giftui_research_retired(context->touch.valid);')
 (app/'src/production_host.c').write_text(host)
 for p in (app/'CMakeLists.txt',app/'src/main.c',app/'src/StaticPreset.swift',app/'src/production_host.c'):
  record['inputs'][str(p.relative_to(root))]=hashlib.sha256(p.read_bytes()).hexdigest()
for p in (source/'src/StaticPreset.swift',source/'src/production_host.c',spike/'prepare.py',spike/'research.c',spike/'research.h'):
 record['inputs'][str(p.relative_to(root))]=hashlib.sha256(p.read_bytes()).hexdigest()
(spike/'evidence/preparation.json').write_text(json.dumps(record,indent=2)+'\n');print('Prepared two copied production applications.')
