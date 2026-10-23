from pathlib import Path
import ast,json,hashlib,datetime,sys,re
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);raw=read(F['inputs']['result']);charge(len(raw));j=json.loads(raw);v={'result':F['inputs']['result'],'schema':{k:{'type':type(x).__name__,'size':len(x) if isinstance(x,(dict,list,str)) else None} for k,x in j.items()},'scalars':{k:x for k,x in j.items() if isinstance(x,(bool,int,float)) or isinstance(x,str) and len(x)<256},'record_schema':{},'possible_route_records':[]}
for k,x in j.items():
 if isinstance(x,list) and x and isinstance(x[0],dict):
  v['record_schema'][k]=list(x[0])
  for i,row in enumerate(x):
   label=' '.join(str(row.get(q,'')) for q in ['label','name','id','family','group','kind'])
   if any(q in label.lower() for q in ['scoped','route','runtime','fw038']):v['possible_route_records'].append({'list':k,'index':i,'label':label[:240],'keys':list(row)})
 if isinstance(x,dict):v.setdefault('dictionary_keys',{})[k]=list(x)[:40]
(H/'current-result-metadata.json').write_text(json.dumps(v,indent=2)+'\n');charge((H/'current-result-metadata.json').stat().st_size*3);docs=[]
for name in ['docs/specs/spec-013-runtime-profiles.md','docs/specs/spec-015-host-configuration.md']:
 p=R/name;b=p.read_bytes();charge(len(b)*3);lines=b.decode().splitlines();hits=[]
 for i,line in enumerate(lines):
  if ('strictNativeStatic' in line or 'HC-SO-001' in line or 'HC-SO-002' in line or 'HC-SO-007' in line or 'HC-SO-07' in line):hits.append({'line':i+1,'text':'\n'.join(str(n+1)+':'+lines[n] for n in range(max(0,i-1),min(len(lines),i+4)))})
 docs.append({'path':name,'bytes':len(b),'sha256':sha(b),'read_role':'Separate ordinary approved-contract/workload interpretation, not AUTH-only source promotion into frozen callee semantics','hits':hits})
(H/'scope-contract-excerpts.json').write_text(json.dumps(docs,indent=2)+'\n');charge((H/'scope-contract-excerpts.json').stat().st_size*3);save();emit({'s':'CURRENT_RETAINED_ROUTE_RECORD_AND_SCOPE_LOCATORS','metadata':v,'contract_excerpts':docs})
