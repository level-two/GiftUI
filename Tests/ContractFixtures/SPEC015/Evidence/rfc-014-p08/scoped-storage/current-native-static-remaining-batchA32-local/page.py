import pathlib,json,hashlib,datetime,sys,subprocess,os,stat,ast,shlex
ROOT=pathlib.Path('/Users/eugene/work/GiftUI');HERE=pathlib.Path(__file__).resolve().parent;BASE=HERE.parent;PREP=BASE/'current-callee-u02-attribution1-preparation';COMMIT='3db4e1b13a728947569a700f35957bb4d17ef943';NAMES=['README.md','inputs.json','roots.json','selected-rows.json','preservation.json','preservation-reads.json'];LIMIT=536870912;RESERVE=218103808
mode=sys.argv[1];final=mode=='f';F=json.loads((HERE/'freeze.json').read_bytes());statepath=HERE/'ledger.json';refresh=json.loads((HERE/'refresh.json').read_bytes());startup=F
utc=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
dt=datetime.datetime.fromisoformat
digest=lambda b:hashlib.sha256(b).hexdigest()
if mode=='a':
 assert not statepath.exists();state={'started_utc':utc(),'used':8388608,'charges':{'preauth_orientation_hash_code_upper':8388608},'transcript':0,'errors':[],'page_coverage':[],'model_findings':None}
else:state=json.loads(statepath.read_bytes())
def charge(n,k):
 if state['used']+n+(0 if final else RESERVE)>LIMIT:raise RuntimeError('processing plus final reserve')
 state['used']+=n;state['charges'][k]=state['charges'].get(k,0)+n
 if not final and (dt(utc())-dt(state['started_utc'])).total_seconds()>7200:raise RuntimeError('7200 total session')
def footprint():return sum(x.stat().st_size for x in HERE.rglob('*') if x.is_file())+sum(x.stat().st_size for x in (BASE/'current-native-static-remaining-batchA32-result').rglob('*') if x.is_file())
def save():
 data=(json.dumps(state,indent=2)+'\n').encode();state['used']+=len(data);statepath.write_text(json.dumps(state,indent=2)+'\n')
def emit(value):
 out=(json.dumps(value,separators=(',',':'))+'\n').encode();assert footprint()+state['transcript']+len(out)*3+1048576<=8388608
 charge(len(out)*4,'payload capture forward');state['transcript']+=len(out);(HERE/'invocation'/('output-'+str(len(list((HERE/'invocation').glob('output-*'))))+'.json')).write_bytes(out);save();sys.stdout.buffer.write(out)
def stream(desc,k):
 p=ROOT/desc['path'];assert p.stat().st_size==desc['bytes'];h=hashlib.sha256()
 with p.open('rb') as f:
  for z in iter(lambda:f.read(1048576),b''):charge(len(z),k);h.update(z)
 assert h.hexdigest()==desc['sha256']
def selected(name):
 d=F['selected'][name];z=(ROOT/d['path']).read_bytes();charge(len(z)*2,'selected read decode');assert len(z)==d['bytes'] and digest(z)==d['sha256'];return z
# Reuse frozen, reviewed authentication/preservation operations, not their semantic extractor.
source=(BASE/'current-native-static-remaining-batchA31-local/inspect.py').read_bytes();charge(len(source)*3,'auth operation code read');tree=ast.parse(source);wanted={'read','git','controls','preservation','provider_read','provider_auth'};exec(compile(ast.Module(body=[x for x in tree.body if isinstance(x,ast.FunctionDef) and x.name in wanted],type_ignores=[]),'<retained-auth-operations>','exec'))
try:
 assert digest(pathlib.Path(__file__).read_bytes())==F['helper_sha256'];assert os.readlink('/tmp/g32')==F['alias_target'];assert digest(source)==F['auth_operations_sha256']
 cmd='python3 /tmp/g32 '+ ' '.join(shlex.quote(x) for x in sys.argv[1:]);args={'cmd':cmd,'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\n'+'const r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';state['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());state.setdefault('request_identities',[]).append({'code':code,'args':args});charge(32768+len(code.encode())*3,'invocation code request capture reserve')
 if mode=='a':
  c=controls();ins=json.loads(c['inputs.json']);pres=json.loads(c['preservation-reads.json']);prior=json.loads(selected('prior_ledger'));assert prior['finished_utc'] and prior['after'] and prior['provider_after'];assert prior['controls']=={n:{'bytes':len(v),'sha256':digest(v)} for n,v in c.items()}
  assert len(ins['files'])==79 and sum(x['bytes'] for x in ins['files'])==126694715
  for d in ins['files']:read(d['path'],'fresh_original_worktree_hash',d['bytes'],d['sha256'])
  state['Git_blob_auth_reuse']='Original immutable blob identities and exact priorA31 comparison reused; all79 worktree hashes fresh. No altered evidence authority.'
  for d in pres['files']:
   d=refresh.get(d['path'],d);read(d['path'],'preservation fresh hash',d['bytes'],d['sha256'])
  for d in refresh.values():read(d['path'],'current refresh fresh hash',d['bytes'],d['sha256'])
  for key in ['packet','identity_map','frontier']:selected(key)
  stream(F['sil'],'current SIL authentication only')
  assert git(['rev-parse','HEAD'],128).decode().strip()==F['HEAD'];state['before']=preservation(pres);state['provider_before']=provider_auth();state['auth_utc']=utc();emit({'s':'AUTH','started':state['started_utc'],'cutoff':'2026-10-22T19:43:00Z'})
 elif mode=='p':
  packet=json.loads(selected('packet'));lines=[]
  for body in packet['complete_bodies']:
   lines+=['BODY '+body['base']]+body['code'].splitlines()
  pages=[];buf=[]
  for line in lines:
   if buf and (len(buf)>=100 or len(('\n'.join(buf+[line])+'\n').encode())>8192):pages.append(buf);buf=[]
   assert len(line.encode())<=8192;buf.append(line)
  if buf:pages.append(buf)
  lo,hi=map(int,sys.argv[2:4]);assert 1<=lo<=hi<=len(pages) and hi-lo<4
  values=[]
  for n in range(lo,hi+1):
   z=('\n'.join(pages[n-1])+'\n').encode();values.append({'page':n,'of':len(pages),'lines':len(pages[n-1]),'bytes':len(z),'sha256':digest(z),'text':z.decode()});state['page_coverage'].append(n)
  state['total_pages']=len(pages);state['ordered_projection_sha256']=digest(('\n'.join(lines)+'\n').encode());emit({'s':'PAGES','packet_sha256':F['selected']['packet']['sha256'],'pages':values})
 elif mode=='j':
  objects=[json.loads(z) for z in selected('identity_map').splitlines()];caller=next(x for x in objects if x['body']==F['caller_symbol']);emit({'s':'EXACT_IDENTITIES','ids':{x:caller['labels'][x] for x in sys.argv[2:]}})
 elif mode=='s':
  target=F['caller_symbol'].lstrip('_').encode();total=0;hash=hashlib.sha256();inside=False;function=[];start=0
  with (ROOT/F['sil']['path']).open('rb') as f:
   for n,line in enumerate(f,1):
    total+=len(line);hash.update(line);charge(len(line),'selective SIL byte stream')
    if line.startswith(b'sil ') and b'@'+target+b' :' in line:inside=True;start=n
    if inside:function.append((n,line))
    if inside and line.startswith(b'} // end sil function'):inside=False
  assert hash.hexdigest()==F['sil']['sha256'];assert function
  indexes=set([0]);
  for i,(n,line) in enumerate(function):
   if b'alloc_ref' in line or b'array_literal' in line or b'ContiguousArrayStorage' in line:indexes.update(range(max(0,i-6),min(len(function),i+10)))
  out=[str(function[i][0])+':'+function[i][1].decode().rstrip() for i in sorted(indexes)];z=('\n'.join(out)+'\n').encode();assert len(z)<=1048576 and len(out)<=16384;charge(len(z)*3,'SIL selected excerpt decode retain');(HERE/'selected-type.sil.txt').write_bytes(z);emit({'s':'CURRENT_FOCUSED_SIL_EXPLANATORY','source_identity':F['sil'],'function_start':start,'full_function_lines':len(function),'selected_context':out,'binding_limit':'Focused object differs from full; literal types explain matching exact function name/body, not automatic operation address identity.'})
 elif mode=='f':
  state['model_findings']=json.loads(sys.argv[2]);state['model_ended_utc']=utc();state['model_elapsed_seconds']=(dt(state['model_ended_utc'])-dt(state['started_utc'])).total_seconds();c=controls();ins=json.loads(c['inputs.json']);pres=json.loads(c['preservation-reads.json'])
  for d in ins['files']:read(d['path'],'final original hash',d['bytes'],d['sha256'])
  for d in pres['files']:
   d=refresh.get(d['path'],d);read(d['path'],'final preservation hash',d['bytes'],d['sha256'])
  for d in refresh.values():read(d['path'],'final current refresh hash',d['bytes'],d['sha256'])
  stream(F['sil'],'final current SIL hash')
  for key in ['packet','identity_map','frontier','prior_ledger']:selected(key)
  assert git(['rev-parse','HEAD'],128).decode().strip()==F['HEAD'];state['after']=preservation(pres);state['provider_after']=provider_auth();state['finished_utc']=utc();state['complete_page_coverage']=sorted(set(state['page_coverage']))==list(range(1,state.get('total_pages',0)+1));result=BASE/'current-native-static-remaining-batchA32-result';result.mkdir();charge(524288,'final files ledger output reserve');save()
  (result/'rows.json').write_text(json.dumps(state['model_findings'],indent=2)+'\n');(result/'inspection-accounting.json').write_text(json.dumps(state,indent=2)+'\n');(result/'preservation.json').write_text(json.dumps({'before':state['before'],'after':state['after'],'provider_before':state['provider_before'],'provider_after':state['provider_after'],'Git_blob_auth_reuse':state['Git_blob_auth_reuse']},indent=2)+'\n');(result/'README.md').write_text('# Batch A32 ordered retained-packet examination\n\nSee rows.json for substantive outcome and residuals, inspection-accounting.json for exact self-attested request/payload counting and known processing, and preservation.json for final checks. Old STOPs remain unchanged. No build, source change, runtime/provider experiment, image or hardware execution.\n');emit({'s':'PRESERVED','elapsed':state['model_elapsed_seconds'],'used':state['used'],'transcript':state['transcript'],'page_coverage_complete':state['complete_page_coverage'],'retained_bytes_before_final_status':footprint()});(result/'inspection-accounting.json').write_text(json.dumps(state,indent=2)+'\n')
 else:raise RuntimeError('unknown mode')
except BaseException as exc:
 state['errors'].append(type(exc).__name__+': '+str(exc));state['stopped_utc']=utc();save();emit({'s':'STOP','error':state['errors'][-1]});sys.exit(2)
