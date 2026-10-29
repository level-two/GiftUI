from pathlib import Path
import sys,json,hashlib
from meter import Meter
m=Meter();B=Path(__file__).resolve().parent
paths=['Sources/GiftUI/GiftUI.swift','Sources/GiftUILayout/LayoutValues.swift','Sources/GiftUIDrawing/DrawingLimits.swift','Sources/GiftUIRenderLowering/RenderProductionValues.swift']
old={p:m.read(p) for p in paths};m.save('source-before.json',{p:{'bytes':len(s),'sha256':hashlib.sha256(s).hexdigest()} for p,s in old.items()})
annotation='    #if GIFTUI_GEOMETRY_QUALIFICATION\n        @_noAllocation\n    #endif\n'
targets={paths[0]:['    public init(x:', '    public init?(width:', '    public init?(origin:', '    package static func add('],paths[1]:['    package init?('],paths[2]:['    package init?(\n        maximumLineWidth:'],paths[3]:['    package init?(']}
for p,needles in targets.items():
 s=old[p].decode()
 for needle in needles:
  expected=2 if p==paths[3] else 1
  assert s.count(needle)==expected,(p,needle,s.count(needle))
  s=s.replace(needle,annotation+needle)
 Path(p).write_text(s)

recipes=json.loads(m.read(B/'base-recipes.json'))
entry=json.loads(m.read('Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-static-physical-dispatch1-result/dispatch-plan2.json'))['jobs'][0]['argv']
# Every existing artifact/source passed to the exact entry and producer recipes is bound before use.
inputs=set()
for a in entry:
 p=Path(a)
 if p.is_file() and a.endswith(('.swift','.swiftmodule','.o')):inputs.add(p)
for args in recipes.values():
 for a in args:
  if a.endswith('.swift') and Path(a).is_file():inputs.add(Path(a))
for d in ['.build/contracts/p08-native-static-namespace-qualification1/production','.build/contracts/p08-native-static-physical-accounting1/qualified2','.build/contracts/p08-native-static-physical-accounting1/modules','.build/contracts/p08-native-static-graph-client-emission1/host','.build/contracts/p08-counter-8erdhh4s','.build/contracts/p08-scoped-host-eq4djphq','.build/contracts/spec-006-rfc-014-swift64/8e72c5a1adf5f02b-i9ayjitl/macos-static']:
 for p in Path(d).glob('*.swiftmodule'):inputs.add(p)
for p in Path('Sources/GiftUI').glob('*.swift'):inputs.add(p)
m.save('input-freeze.json',{str(p):{'bytes':p.stat().st_size,'sha256':hashlib.sha256(m.read(p)).hexdigest()} for p in sorted(inputs)})
(B/'qualified').mkdir();(B/'ordinary').mkdir()
imports=['-I',str(B/'qualified'),'-I',str(Path('.build/contracts/p08-native-static-namespace-qualification1/production').resolve()),'-I',str(Path('.build/contracts/p08-native-static-physical-accounting1/qualified2').resolve()),'-I',str(Path('.build/contracts/p08-native-static-physical-accounting1/modules').resolve()),'-I',str(Path('.build/contracts/p08-counter-8erdhh4s').resolve())]
jobs=[]
for generation in ['qualified','ordinary']:
 for name in ['GiftUI','GiftUILayout','GiftUIRenderLowering','GiftUIDrawing']:
  if name=='GiftUI':
   args=list(recipes['GiftUIDrawing']);start=next(i for i,a in enumerate(args) if a.endswith('.swift'));end=args.index('-emit-module-path');args[start:end]=[str(p.resolve()) for p in sorted(Path('Sources/GiftUI').glob('*.swift'))];args[args.index('-module-name')+1]=name;args[args.index('-emit-module-path')+1]='${OUT}/GiftUI.swiftmodule';args[args.index('-o')+1]='${OUT}/GiftUI.o'
  else:args=list(recipes[name])
  out=B/generation
  args=[a.replace('${OUT}',str(out)) for a in args]
  # Prepend correct lower-module pairs while retaining all original package/target/lifetime arguments.
  localimports=list(imports);localimports[1]=str(out)
  args=args[:1]+localimports+args[1:]
  # Reuse the frozen existing compiler module cache rather than generating a second cache tree.
  args[args.index('-module-cache-path')+1]=str(Path('.build/contracts/p08-counter-8erdhh4s/cache').resolve())
  if generation=='qualified': args[1:1]=['-experimental-performance-annotations','-D','GIFTUI_GEOMETRY_QUALIFICATION']
  jobs.append({'name':generation+'-'+name,'argv':args,'file_cap':600000,'outputs':[str(out/(name+'.swiftmodule')),str(out/(name+'.o'))]})
full=entry[:1]+imports+entry[1:]
jobs.insert(4,{'name':'actual-entry','argv':full,'file_cap':1000000,'expected_exit':1})
m.save('batch-plan.json',{'baseline':'1e147925','fixed_deadline':m.state['session_deadline_utc'],'source_scope':paths,'family':'eight actual scalar geometry/limit constructors plus reached checked add; no adjacent APIs','forecast':{'two_generations_pairs_bytes':4500000,'focused_executable_hardcap_bytes':1600000,'all_raw_hardcap_bytes':500000,'records_archive_bytes':400000,'reserves_bytes':771000,'total_forecast_bytes':7771000},'jobs':jobs})
print('PREPARED',paths,'jobs',len(jobs))
