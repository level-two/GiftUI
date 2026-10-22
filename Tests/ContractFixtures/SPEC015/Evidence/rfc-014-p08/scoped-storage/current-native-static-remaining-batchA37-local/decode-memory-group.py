from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess,struct,bisect
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes();assert sha(src)==F['helper_sha256'];t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'))
args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);save()
def extent(d):
 p=Path(d['path']);st=p.stat();assert [st.st_size,st.st_dev,st.st_ino,st.st_mtime_ns]==[d['file_bytes'],d['device'],d['inode'],d['mtime_ns']];charge(d['bytes']*3)
 with p.open('rb') as f:f.seek(d['offset']);b=f.read(d['bytes'])
 assert len(b)==d['bytes'] and sha(b)==d['sha256'];return b
def uleb(b,i):
 v=0;s=0
 while True:
  x=b[i];i+=1;v|=(x&127)<<s
  if not x&128:return v,i
  s+=7;assert s<=63
def trie(b,base):
 out={};todo=[(0,'')];seen=set()
 while todo:
  off,prefix=todo.pop();assert (off,prefix) not in seen;seen.add((off,prefix));n,i=uleb(b,off);end=i+n
  if n:
   flags,j=uleb(b,i)
   if flags&8:ordinal,j=uleb(b,j);out[prefix]={'flags':flags,'ordinal':ordinal,'import_name':b[j:end].split(b'\0')[0].decode()}
   else:
    address,j=uleb(b,j);out[prefix]={'flags':flags,'address':address if flags&3==2 else base+address}
    if flags&16:resolver,j=uleb(b,j);out[prefix]['resolver']=base+resolver
  i=end;count=b[i];i+=1
  for _ in range(count):end=b.index(0,i);edge=b[i:end].decode();child,i=uleb(b,end+1);todo.append((child,prefix+edge))
 charge(len(b)*3);return out
try:
 meta=json.loads(read(F['inputs']['provider_descriptor']));extent(meta['cache_map'])
 for c in meta['cache_files'].values():extent(c['header']);extent(c['mapping'])
 exports={};starts={};texts={};S['provider_before']={}
 for name,p in meta['providers'].items():
  for d in p['slices']:extent(d)
  slices={d['role']:d for d in p['slices']};exports[name]=trie(extent(slices['exports-trie']),p['base']);z=extent(slices['function-starts']);a=0;pc=p['base'];seq=[]
  while a<len(z):
   delta,a=uleb(z,a)
   if not delta:break
   pc+=delta;seq.append(pc)
  starts[name]=seq;texts[name]=(extent(slices['__TEXT']),slices['__TEXT']);S['provider_before'][name]={'uuid':p['uuid'],'identity':p['identity']}
 # Exact current executable two-level import ordinals select providers, not API-name inference.
 exe=read(F['inputs']['executable']);assert struct.unpack_from('<I',exe)[0]==0xfeedfacf;at=32;deps=[];sym=None
 for _ in range(struct.unpack_from('<I',exe,16)[0]):
  cmd,size=struct.unpack_from('<II',exe,at)
  if cmd in [0xc,0x80000018,0x8000001f,0x80000023]:no=struct.unpack_from('<I',exe,at+8)[0];deps.append(exe[at+no:at+size].split(b'\0')[0].decode())
  if cmd==2:sym=struct.unpack_from('<IIII',exe,at+8)
  at+=size
 assert sym;so,nn,st,sz=sym;imports={};wanted=meta['selected_imports']
 for i in range(nn):
  no,typ,sec,desc,val=struct.unpack_from('<IBBHQ',exe,so+i*16);name=exe[st+no:exe.find(b'\0',st+no,st+sz)].decode() if no else ''
  if name in wanted and typ&0xe==0:ordinal=desc>>8;imports.setdefault(name,[]).append({'nlist_index':i,'ordinal':ordinal,'provider':deps[ordinal-1] if 1<=ordinal<=len(deps) else None,'n_desc':desc})
 bindings=[];selected=[]
 for symbol in wanted:
  hits=imports.get(symbol,[]);assert len(hits)==1;provider=hits[0]['provider'];name=symbol;chain=[]
  while True:
   if provider not in exports:raise RuntimeError('exact imported/reexport dependency outside frozen provider group: '+str(provider))
   row=exports[provider].get(name);assert row is not None;chain.append({'provider':provider,'symbol':name,'export':row})
   if 'ordinal' in row:provider=meta['providers'][provider]['dependencies'][row['ordinal']-1]['name'];name=row['import_name'] or name;continue
   break
  binding={'import':symbol,'current_executable_import':hits[0],'chain':chain};bindings.append(binding)
  if symbol=='___stack_chk_guard':continue
  for role,address in [('entry',row['address'])]+([('resolver',row['resolver'])] if 'resolver' in row else []):
   seq=starts[provider];i=bisect.bisect_right(seq,address)-1;assert i>=0 and i+1<len(seq);lo,hi=seq[i],seq[i+1];assert address%4==0 and lo<=address<hi;selected.append({'provider':provider,'symbol':symbol,'role':role,'entry':address,'lo':lo,'hi':hi})
 S['memory_bindings']=bindings;S['provider_function_captures']=[];save()
 for ix,x in enumerate(selected,1):
  text,d=texts[x['provider']];off=x['lo']-d['vmaddr'];body=text[off:off+x['hi']-x['lo']];assert len(body)==x['hi']-x['lo'] and len(body)%4==0;address=x['lo'];header=struct.pack('<IiiIIIII',0xfeedfacf,0x100000c,2,1,1,152,0,0);seg=struct.pack('<II16sQQQQiiII',0x19,152,b'__TEXT',address,len(body),4096,len(body),7,5,1,0);sec=struct.pack('<16s16sQQIIIIIIII',b'__text',b'__TEXT',address,len(body),4096,2,0,0,0x80000400,0,0,0);projected=(header+seg+sec).ljust(4096,b'\0')+body;p=H/('memory-'+str(ix)+'.o');charge(len(projected)*3);p.write_bytes(projected);argv=[F['tool']['path'],'--disassemble','--no-show-raw-insn',str(p)];charge(F['tool']['bytes']+len(projected));S['provider_pending']={'index':ix,'argv':argv};save();r=subprocess.run(argv,capture_output=True);capture={**x,'index':ix,'argv':argv,'returncode':r.returncode,'stdout_bytes':len(r.stdout),'stdout_lines':len(r.stdout.splitlines()),'stdout_sha256':sha(r.stdout),'stderr_bytes':len(r.stderr),'stderr_sha256':sha(r.stderr),'provider_uuid':meta['providers'][x['provider']]['uuid'],'code_sha256':sha(body),'raw_cache_path':d['path'],'raw_cache_offset':d['offset']+off,'raw_cache_bytes':len(body)};S['provider_function_captures'].append(capture);(H/'memory-captures.json').write_text(json.dumps(S['provider_function_captures'],indent=2)+'\n');save();charge(len(r.stdout)*4+len(r.stderr)*4)
  if len(r.stdout)+len(r.stderr)>1048576 or len(r.stdout.splitlines())+len(r.stderr.splitlines())>16384:raise RuntimeError('selected provider excerpt exceeded original bound')
  (H/('memory-'+str(ix)+'.stdout')).write_bytes(r.stdout);(H/('memory-'+str(ix)+'.stderr')).write_bytes(r.stderr)
  if r.returncode:raise RuntimeError('provider decoder nonzero '+str(r.returncode))
 S['provider_pending']=None;S['provider_auth_utc']=now();save();emit({'s':'EXACT_CURRENT_IMPORT_AND_INSTALLED_PROVIDER_GROUP','bindings':bindings,'identities':S['provider_before'],'captured_functions':[{'index':c['index'],'import':c['symbol'],'role':c['role'],'provider':c['provider'],'entry':hex(c['entry']),'range':[hex(c['lo']),hex(c['hi'])],'stdout_bytes':c['stdout_bytes'],'stdout_lines':c['stdout_lines'],'sha256':c['stdout_sha256']} for c in S['provider_function_captures']],'scope':'Installed exact body/import/reexport proof only. No historical loaded image or live state substitution.'});(H/'invocation/memory-group-exit.json').write_text(json.dumps({'exit':0,'utc':now()})+'\n')
except BaseException as e:
 S['errors'].append('memory group '+type(e).__name__+': '+str(e));S['stopped_utc']=now();save();emit({'s':'STOP','error':S['errors'][-1],'pending':S.get('provider_pending')});(H/'invocation/memory-group-exit.json').write_text(json.dumps({'exit':2,'utc':now()})+'\n');sys.exit(2)
