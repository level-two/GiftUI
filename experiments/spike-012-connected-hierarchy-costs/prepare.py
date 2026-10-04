"""Prepare copied applications; preserve maintained production and prior evidence."""
from pathlib import Path
import hashlib,json,shutil,subprocess
root=Path.cwd(); spike=root/'experiments/spike-012-connected-hierarchy-costs'
source=root/'firmware/nrf52840/applications/signal-analyzer-static'
lowered=root/'.build/nrf52840/spike-010-bounded-declaration-traversal/LoweredBody.swift'
prior=json.loads((root/'experiments/spike-010-bounded-declaration-traversal/evidence/result.json').read_text())
assert hashlib.sha256(lowered.read_bytes()).hexdigest()==prior['lowered_source_sha256']
record={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'inputs':{}}
for mode in ('packed','roles','snapshot'):
 out=root/f'.build/nrf52840/spike-012-connected-{mode}'; app=out/'application'
 shutil.copytree(source,app,dirs_exist_ok=True)
 cmake=(source/'CMakeLists.txt').read_text().replace('${CMAKE_CURRENT_SOURCE_DIR}/../../../..',str(root))
 if mode=='roles':
  for name in ('StaticSignalAnalyzerNRFModelTextWriter.swift','StaticSignalAnalyzerNRFModelModifierWriter.swift'):
   original=root/'Sources/SignalAnalyzerTargetHost'/name
   changed=root/'.build/nrf52840/spike-009-hierarchy-roles/Sources/SignalAnalyzerTargetHost'/name
   cmake=cmake.replace('${giftui_project_root}/Sources/SignalAnalyzerTargetHost/'+name,str(changed))
   record['inputs'][str(changed.relative_to(root))]=hashlib.sha256(changed.read_bytes()).hexdigest()
  roles=root/'.build/nrf52840/spike-009-hierarchy-roles/SpikeRoles.swift'
  cmake=cmake.replace('    "${CMAKE_CURRENT_SOURCE_DIR}/src/StaticPreset.swift"',f'    "{roles}"\n    "${{CMAKE_CURRENT_SOURCE_DIR}}/src/StaticPreset.swift"')
  record['inputs'][str(roles.relative_to(root))]=hashlib.sha256(roles.read_bytes()).hexdigest()
 cmake=cmake.replace('    "${CMAKE_CURRENT_SOURCE_DIR}/src/StaticPreset.swift"',f'    "{lowered}"\n    "{spike}/Benchmark.swift"\n    "${{CMAKE_CURRENT_SOURCE_DIR}}/src/StaticPreset.swift"')
 (app/'CMakeLists.txt').write_text(cmake)
 main=(source/'src/main.c').read_text()
 main=main.replace('int main(void)',f'#define SPIKE012_MODE {2 if mode=="snapshot" else 1 if mode=="roles" else 0}\n#include "{spike}/benchmark.c"\n\nint main(void)')
 main=main.replace('    struct giftui_static_host_storage regions;','    if (giftui_spike012_run() != 0) return 1;\n    struct giftui_static_host_storage regions;')
 (app/'src/main.c').write_text(main)
 for path in (app/'CMakeLists.txt',app/'src/main.c'):
  record['inputs'][str(path.relative_to(root))]=hashlib.sha256(path.read_bytes()).hexdigest()
for path in (lowered,spike/'Benchmark.swift',spike/'benchmark.c',spike/'prepare.py'):
 record['inputs'][str(path.relative_to(root))]=hashlib.sha256(path.read_bytes()).hexdigest()
(spike/'evidence/preparation.json').write_text(json.dumps(record,indent=2)+'\n')
print('Prepared packed, roles, snapshot; pinned SPIKE-010 lowering unchanged.')
