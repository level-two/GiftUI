from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess,struct,bisect,shlex,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R))+' '+shlex.quote(sys.argv[1]),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);save()
def check(name,ok,actual):
 S.setdefault('provider_predicates',[]).append({'name':name,'ok':bool(ok),'actual':actual});save()
 if not ok:raise RuntimeError(name)
def extent(d):
 p=Path(d['path']);st=p.stat();check('exact installed extent identity', [st.st_size,st.st_dev,st.st_ino,st.st_mtime_ns]==[d['file_bytes'],d['device'],d['inode'],d['mtime_ns']],{'path':str(p),'offset':d['offset'],'bytes':d['bytes']});charge(d['bytes']*3)
 with p.open('rb') as f:f.seek(d['offset']);b=f.read(d['bytes'])
 check('exact installed extent hash',len(b)==d['bytes'] and sha(b)==d['sha256'],{'sha256':sha(b),'bytes':len(b)});return b
def uleb(b,i):
 v=0;s=0
 while True:
  x=b[i];i+=1;v|=(x&127)<<s
  if not x&128:return v,i
  s+=7
  if s>63:raise RuntimeError('ULEB width')
def trie(b,base):
 out={};todo=[(0,'')]
 while todo:
  off,prefix=todo.pop();n,i=uleb(b,off);end=i+n
  if n:
   flags,j=uleb(b,i)
   if flags&8:ordinal,j=uleb(b,j);out[prefix]={'flags':flags,'ordinal':ordinal,'import_name':b[j:end].split(b'\0')[0].decode()}
   else:
    address,j=uleb(b,j);out[prefix]={'flags':flags,'address':address if flags&3==2 else base+address}
    if flags&16:resolver,j=uleb(b,j);out[prefix]['resolver']=base+resolver
  i=end;count=b[i];i+=1
  for _ in range(count):end=b.index(0,i);edge=b[i:end].decode();child,i=uleb(b,end+1);todo.append((child,prefix+edge))
 charge(len(b)*4);return out
try:
 check('frozen delivery helper',sha(src)==F['helper_sha256'],sha(src));check('frozen decoder script',sha(Path(__file__).read_bytes())==F['inputs']['decode_code']['sha256'],sha(Path(__file__).read_bytes()));meta=json.loads(read(F['inputs']['provider_descriptor']));provider='/usr/lib/swift/libswiftCore.dylib';p=meta['providers'][provider];sl={x['role']:x for x in p['slices']};extent(sl['image-load-commands']);exports=trie(extent(sl['exports-trie']),p['base']);z=extent(sl['function-starts']);a=0;pc=p['base'];starts=[]
 while a<len(z):
  delta,a=uleb(z,a)
  if not delta:break
  pc+=delta;starts.append(pc)
 text=extent(sl['__TEXT']);d=sl['__TEXT'];selection=json.loads(sys.argv[1]);selected={};joins=[]
 for value in selection:
  if value.startswith('0x'):address=int(value,16);row=None
  else:
   row=exports.get(value);check('exact selected provider export',row is not None,{'symbol':value,'row':row});check('direct regular export',row.get('flags')==0 and 'address' in row,{'symbol':value,'row':row});address=row['address']
  i=bisect.bisect_right(starts,address)-1;check('exact selected function bounds',0<=i<len(starts)-1,{'entry':hex(address),'index':i});lo,hi=starts[i],starts[i+1];check('selected code extent is frozen',d['vmaddr']<=lo<=address<hi<=d['vmaddr']+len(text),{'lo':hex(lo),'hi':hex(hi)});selected[(lo,hi)]={'selected':value,'entry':address,'export':row};joins.append({'selected':value,'entry':hex(address),'range':[hex(lo),hex(hi)],'export':row})
 caps=S.setdefault('swift_captures',[]);forecast=len(selected)*(F['tool']['bytes']+65536)+sum(v['bytes']*2 for v in F['inputs'].values())+16777216;check('complete decode and terminal reserve',S['processing']+forecast<536870912,{'processing':S['processing'],'forecast':forecast})
 for (lo,hi),origin in selected.items():
  off=lo-d['vmaddr'];body=text[off:off+hi-lo];index=len(caps)+1;header=struct.pack('<IiiIIIII',0xfeedfacf,0x100000c,2,1,1,152,0,0);seg=struct.pack('<II16sQQQQiiII',0x19,152,b'__TEXT',lo,len(body),4096,len(body),7,5,1,0);sec=struct.pack('<16s16sQQIIIIIIII',b'__text',b'__TEXT',lo,len(body),4096,2,0,0,0x80000400,0,0,0);projected=(header+seg+sec).ljust(4096,b'\0')+body;path=H/('swift-'+str(index)+'.o');charge(len(projected)*3);path.write_bytes(projected);argv=[F['tool']['path'],'--disassemble','--no-show-raw-insn',str(path)];charge(F['tool']['bytes']+len(projected));S['provider_pending']={'argv':argv,'origin':origin,'started_utc':now()};save();r=subprocess.run(argv,capture_output=True);c={'index':index,'provider':provider,'provider_uuid':p['uuid'],'origin':origin,'range':[hex(lo),hex(hi)],'argv':argv,'returncode':r.returncode,'stdout_bytes':len(r.stdout),'stdout_lines':len(r.stdout.splitlines()),'stdout_sha256':sha(r.stdout),'stderr_bytes':len(r.stderr),'stderr_sha256':sha(r.stderr),'stderr':r.stderr.decode(errors='replace'),'raw_cache_path':d['path'],'raw_cache_offset':d['offset']+off,'raw_cache_bytes':len(body),'code_sha256':sha(body),'ended_utc':now()};caps.append(c);S['swift_joins']=S.get('swift_joins',[])+joins;save();(H/'swift-captures.json').write_text(json.dumps(caps,indent=2)+'\n');charge(len(r.stdout)*4+len(r.stderr)*4);total=sum(x['stdout_bytes']+x['stderr_bytes'] for x in caps);lines=sum(x['stdout_lines'] for x in caps);check('aggregate original group excerpt reserve',total+65536<=1048576 and lines+1024<=16384,{'bytes':total,'lines':lines,'reserved_bytes':65536,'reserved_lines':1024});(H/('swift-'+str(index)+'.stdout')).write_bytes(r.stdout);(H/('swift-'+str(index)+'.stderr')).write_bytes(r.stderr);check('known provider decoder exit0',r.returncode==0,c)
 S['provider_pending']=None;save();emit({'s':'EXACT_SWIFT_PROVIDER_GROUP_CAPTURED','joins':joins,'captures':caps[-len(selected):],'processing':S['processing']});(H/'invocation'/'swift-decode-exit.json').write_text(json.dumps({'exit':0,'utc':now()})+'\n')
except BaseException as e:
 S['provider_exception']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','exception':S['provider_exception'],'pending':S.get('provider_pending')});(H/'invocation'/'swift-decode-exit.json').write_text(json.dumps({'exit':2,'utc':now()})+'\n');sys.exit(2)
