from pathlib import Path
import sys,json,hashlib,subprocess
from meter import Meter
from run import run
m=Meter();B=Path(__file__).resolve().parent
jobs=[]
for n in ['positive','allocation-negative']:
 old=json.loads(m.read(Path('.build/contracts/p08-native-static-namespace-qualification1')/(n+'.json')))
 args=list(old['argv']);args[args.index('-o')+1]=str(B/(n+'.o'))
 source=next(x for x in args if x.endswith('.swift'));m.save(n+'-source.json',{'source':source,'sha256':hashlib.sha256(m.read(source)).hexdigest()})
 jobs.append({'name':n,'argv':args,'file_cap':100000,'outputs':[str(B/(n+'.o'))] if n=='positive' else [],'expected_exit':0 if n=='positive' else 1})
# This mandated repository lint performs no source mutation.
jobs.append({'name':'repository-format-lint','argv':['scripts/format-swift.sh','--lint'],'file_cap':100000})
plan=json.loads(m.read(B/'batch-plan.json'));plan['jobs']+=jobs;m.save('batch-plan.json',plan)
for x in jobs:
 r=run(x['name'],x['argv'],x['file_cap'],x.get('outputs',[]));assert r['exit']==x.get('expected_exit',0) and not r['breach'],x['name']

# Record complete defined global-symbol inventories as digests plus exact zero diffs.
# Input objects are hashed before invoking nm; all streamed bytes are conservatively
# charged BEFORE each bounded pipe read. No unchecked full nm capture is retained.
old_dirs={'GiftUI':Path('.build/contracts/spec-006-rfc-014-swift64/8e72c5a1adf5f02b-i9ayjitl/macos-static')}
out={}
for n in ['GiftUI','GiftUILayout','GiftUIRenderLowering','GiftUIDrawing']:
 sets={};ids={}
 for generation in ['baseline','ordinary','qualified']:
  q=(old_dirs.get(n,Path('.build/contracts/p08-counter-8erdhh4s')) if generation=='baseline' else B/generation)/(n+'.o')
  ids[generation]={'path':str(q),'bytes':q.stat().st_size,'sha256':hashlib.sha256(m.read(q)).hexdigest()}
  process=subprocess.Popen(['/usr/bin/nm','-gUj',str(q)],stdout=subprocess.PIPE,stderr=subprocess.PIPE);chunks=[];read_size=65536;charged=0
  while True:
   m.charge('nm-pipe-read-precharge',read_size,str(q));data=process.stdout.read(read_size);charged+=read_size
   if not data:break
   chunks.append(data);assert sum(map(len,chunks))<=500000
  m.charge('nm-stderr-read-precharge',10000,str(q));err=process.stderr.read(10000);code=process.wait();assert not err and code==0
  symbols=sorted(set(b''.join(chunks).decode().splitlines()));sets[generation]=set(symbols);ids[generation].update({'defined_global_symbol_count':len(symbols),'symbol_inventory_sha256':hashlib.sha256(('\n'.join(symbols)+'\n').encode()).hexdigest(),'pipe_processing_charged_bytes':charged+10000})
 assert sets['baseline']==sets['ordinary']==sets['qualified'],n
 out[n]={'inputs':ids,'baseline_to_ordinary_added':[],'baseline_to_ordinary_removed':[],'ordinary_to_qualified_added':[],'ordinary_to_qualified_removed':[],'all_equal':True}
m.save('ordinary-qualified-symbol-comparison.json',out)
print(json.dumps({'symbol_comparison':'all four baseline/ordinary/qualified inventories equal','retained_bytes':m.retained(),'processing_charged':m.state['processing_own_metered_bytes'],'reserved_bytes':m.reserve()}))
