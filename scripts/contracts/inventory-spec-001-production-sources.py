from pathlib import Path
import re,json,subprocess,hashlib,os
r=Path(__file__).resolve().parents[2]; out=r/'.build/contract-reports/spec-001/milestone-10'; out.mkdir(parents=True,exist_ok=True)
cm=r/'firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt'
s=cm.read_text().split('set(giftui_static_swift_inputs',1)[1].split('set_property',1)[0]
paths=[]
for x in re.findall(r'"([^"]+)"',s):
 x=x.replace('${giftui_project_root}',str(r)).replace('${CMAKE_CURRENT_SOURCE_DIR}',str(cm.parent)).replace('${giftui_reference_bitmap}',str(r/'Sources/GiftUIReferenceTextResources/Generated/ReferenceBitmapPayload.generated.swift'))
 p=Path(x)
 if p.exists():paths.append(p)
with (out/'selected-sources.tsv').open('w') as f:
 f.write('source\towner\tsha256\timports\tembedded_branch\n')
 for p in paths:
  src=p.read_text(); rel=p.relative_to(r); owner=rel.parts[1] if rel.parts[0]=='Sources' else 'firmware-host'
  imports=','.join(re.findall(r'^import (\w+)',src,re.M))
  f.write(f'{rel}\t{owner}\t{hashlib.sha256(src.encode()).hexdigest()}\t{imports}\t{int("GIFTUI_NRF_EMBEDDED" in src)}\n')
env=os.environ.copy()
env['CLANG_MODULE_CACHE_PATH']=str(out/'clang-cache')
(out/'clang-cache').mkdir(exist_ok=True)
pkg=json.loads(subprocess.check_output(['swift','package','--disable-sandbox','dump-package'],cwd=r,env=env))
with (out/'targets.tsv').open('w') as f:
 f.write('target\tkind\tdependencies\n')
 for t in pkg['targets']:
  deps=[next(iter(d.values()))[0] for d in t['dependencies']]
  f.write(f'{t["name"]}\t{t["type"]}\t{",".join(deps)}\n')
print('selected sources:',len(paths))
