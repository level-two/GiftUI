from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess,struct,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R))+' '+sys.argv[1],'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);S.setdefault('selected_predicates',[]);save()
def check(name,v,actual):
 S['selected_predicates'].append({'predicate':name,'value':bool(v),'actual':actual});save()
 if not v:raise RuntimeError(name)
try:
 check('frozen page identity',sha(src)==F['helper_sha256'],sha(src));z=read(F['inputs']['group_code']);check('ordinary code frozen',sha(Path(__file__).read_bytes())==sha(z),sha(z));z=read(F['inputs']['parser']);ns={'struct':struct};t=ast.parse(z);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name=='object_metadata'],type_ignores=[]),'<exact-frozen-structural-function>','exec'),ns);obj=read(F['inputs']['object']);charge(len(obj)*3);m=ns['object_metadata'](obj);selection=json.loads(sys.argv[1]);selected={}
 for mode,value in selection:
  pc=int(value,0)
  if mode=='callsite':
   rr=m['relocs'].get(pc);check('exact callsite relocation '+value,rr is not None,rr);name=rr['symbol'];hits=m['aliases'].get(name,[]);check('exact call target alias '+value,len(hits)==1,{'symbol':name,'hits':hits});lo=hits[0]['address']
  else:
   check('explicit selected entry '+value,pc in m['bounds'],{'address':value});lo=pc;name=m['texts'].get(lo)
  i=m['bounds'].index(lo);check('callee extent bound '+hex(lo),i+1<len(m['bounds']),{'index':i});hi=m['bounds'][i+1];selected[(lo,hi)]={'origin_mode':mode,'origin':value,'symbol':name}
 forecast=len(selected)*(F['tool']['bytes']+len(obj)+65536)+sum(d['bytes']*2 for d in F['inputs'].values())+16777216;check('complete decode+final reserve',S['processing']+forecast<536870912,{'processing':S['processing'],'forecast':forecast});caps=S.setdefault('selected_captures',[])
 for (lo,hi),origin in selected.items():
  index=len(caps)+1;argv=[F['tool']['path'],'--disassemble','--reloc','--no-show-raw-insn','--start-address='+hex(lo),'--stop-address='+hex(hi),str(R/F['inputs']['object']['path'])];charge(F['tool']['bytes']+len(obj));S['pending_decoder']={'argv':argv,'started_utc':now(),'origin':origin};save();r=subprocess.run(argv,capture_output=True);c={'index':index,'origin':origin,'range':[hex(lo),hex(hi)],'argv':argv,'returncode':r.returncode,'stdout_bytes':len(r.stdout),'stdout_lines':len(r.stdout.splitlines()),'stdout_sha256':sha(r.stdout),'stderr_bytes':len(r.stderr),'stderr_sha256':sha(r.stderr),'stderr':r.stderr.decode(errors='replace'),'ended_utc':now()};caps.append(c);(H/'selected-captures.json').write_text(json.dumps(caps,indent=2)+'\n');save();charge(len(r.stdout)*4+len(r.stderr)*4);check('raw excerpt bound',len(r.stdout)+len(r.stderr)<=1048576 and len(r.stdout.splitlines())+len(r.stderr.splitlines())<=16384,c);(H/('selected-'+str(index)+'.stdout')).write_bytes(r.stdout);(H/('selected-'+str(index)+'.stderr')).write_bytes(r.stderr);check('known decoder exit0',r.returncode==0,c)
 S['pending_decoder']=None;save();emit({'s':'EXACT_SELECTED_CALLEES_CAPTURED','new_captures':caps[-len(selected):]})
except BaseException as e:
 S['selected_exception']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','exception':S['selected_exception'],'pending':S.get('pending_decoder')});sys.exit(2)
