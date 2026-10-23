from pathlib import Path
import json,hashlib,struct,datetime,subprocess,shlex,sys,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda b:hashlib.sha256(b).hexdigest()
A={'started_utc':'2026-10-23T02:49:13.291989+00:00','deadline_utc':'2026-10-23T04:49:13.291989+00:00','orientation_processing_upper':1048576,'orientation_transcript_upper':65536,'orientation_exact_aggregate_certified':False,'scope':'Exact installed Swift getType/getWitness providers; metadata and opaque code hashes only before authentication','extents':[]}
args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';A['requests']=[{'code':code,'args':args}];A['processing']=1048576+Path(__file__).stat().st_size*12+len(code.encode())*3;A['transcript']=65536+len(code.encode())+len(json.dumps(args,separators=(',',':')).encode())
def save():(H/'acquisition.json').write_text(json.dumps(A,indent=2)+'\n')
def get(p,o,n,role,vm=None):
 if not 0<=n<=16777216:raise RuntimeError('bounded acquisition extent '+str(n))
 p=Path(p);s=p.stat();A['processing']+=n*3;save()
 if A['processing']+16777216>536870912:raise RuntimeError('acquisition processing reserve')
 with p.open('rb') as f:f.seek(o);b=f.read(n)
 if len(b)!=n:raise RuntimeError('short exact installed extent')
 d={'path':str(p),'offset':o,'bytes':n,'sha256':sha(b),'file_bytes':s.st_size,'device':s.st_dev,'inode':s.st_ino,'mtime_ns':s.st_mtime_ns,'role':role,'vmaddr':vm};A['extents'].append(d);save();return b,d
try:
 oldp=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-remaining-batchA37-local/provider-slices.json';old=json.loads(oldp.read_bytes());A['processing']+=oldp.stat().st_size*3
 exe=R/'.build/contracts/p08-counter-m1vlvrlf/counter-static-resource-v1';eb,ed=get(exe,0,exe.stat().st_size,'current-executable-auth-and-import-metadata');at=32;deps=[];rpaths=[];sym=None
 for _ in range(struct.unpack_from('<I',eb,16)[0]):
  cmd,size=struct.unpack_from('<II',eb,at)
  if cmd in [0xc,0x80000018,0x8000001f,0x80000023]:no=struct.unpack_from('<I',eb,at+8)[0];deps.append(eb[at+no:at+size].split(b'\0')[0].decode())
  if cmd==0x8000001c:no=struct.unpack_from('<I',eb,at+8)[0];rpaths.append(eb[at+no:at+size].split(b'\0')[0].decode())
  if cmd==2:sym=struct.unpack_from('<4I',eb,at+8)
  at+=size
 wanted=['_swift_getTypeByMangledNameInContext2','_swift_getWitnessTable'];imports=[]
 if sym is None:raise RuntimeError('exact current executable lacks symbol metadata')
 so,nn,st,sz=sym
 for i in range(nn):
  no,typ,sec,desc,val=struct.unpack_from('<IBBHQ',eb,so+16*i)
  if no and typ&14==0:
   end=eb.find(b'\0',st+no,st+sz);name=eb[st+no:end].decode()
   if name in wanted:
    ordinal=desc>>8;imports.append({'symbol':name,'ordinal':ordinal,'provider':deps[ordinal-1] if 1<=ordinal<=len(deps) else None,'nlist_index':i,'n_desc':desc})
 A['current_imports']=imports;A['current_rpaths']=rpaths;A['executable']=ed;save()
 if len(imports)!=2 or len({x['provider'] for x in imports})!=1:raise RuntimeError('two exact imports do not select one declared provider')
 provider=imports[0]['provider'];A['declared_provider']=provider;save()
 if provider!='/usr/lib/swift/libswiftCore.dylib':raise RuntimeError('declared provider requires exact path/rpath resolution before cache acquisition: '+str(provider))
 cm=old['cache_map'];mb,md=get(cm['path'],cm['offset'],cm['bytes'],'exact-installed-cache-image-map')
 if sha(mb)!=cm['sha256']:raise RuntimeError('accepted cache map changed')
 active=False;base=None
 for line in mb.decode().splitlines():
  if line.startswith('/'):active=line.strip()==provider
  elif active and '__TEXT ' in line:base=int(line.split('0x',1)[1].split()[0],16);break
 if base is None:raise RuntimeError('exact declared provider not in authenticated cache image map')
 def vm(a,n,role):
  hits=[(p,c,m) for p,c in old['cache_files'].items() for m in c['rows'] if m['address']<=a and a+n<=m['address']+m['size']]
  if len(hits)!=1:raise RuntimeError('exact VM mapping count '+str(len(hits)))
  p,c,m=hits[0];s=Path(p).stat();ref=c['header']
  if [s.st_size,s.st_dev,s.st_ino,s.st_mtime_ns]!=[ref['file_bytes'],ref['device'],ref['inode'],ref['mtime_ns']]:raise RuntimeError('accepted cache file identity changed')
  return get(p,m['file_offset']+a-m['address'],n,role,a)
 head,hd=vm(base,32,'image-header');magic,cpu,sub,typ,ncmd,sz,flags,res=struct.unpack('<IiiIIIII',head)
 if magic!=0xfeedfacf or cpu!=0x100000c or sz>65536:raise RuntimeError('unsupported exact provider header')
 raw,cmdD=vm(base,32+sz,'image-load-commands');at=32;segments=[];dependencies=[];uuid=None;identity=None;export=None;starts=None;text=None
 for _ in range(ncmd):
  cmd,size=struct.unpack_from('<II',raw,at)
  if cmd==0x19:
   name=raw[at+8:at+24].split(b'\0')[0].decode();va,vs,fo,fs=struct.unpack_from('<QQQQ',raw,at+24);ns=struct.unpack_from('<I',raw,at+64)[0];segments.append({'name':name,'vmaddr':va,'vmsize':vs,'fileoff':fo,'filesize':fs})
   for j in range(ns):
    q=at+72+80*j
    if raw[q:q+16].split(b'\0')[0]==b'__text':text=struct.unpack_from('<QQ',raw,q+32)
  elif cmd==0x1b:uuid=raw[at+8:at+24].hex()
  elif cmd in [0xd,0xc,0x80000018,0x8000001f,0x80000023]:
   no,ts,cv,co=struct.unpack_from('<4I',raw,at+8);row={'name':raw[at+no:at+size].split(b'\0')[0].decode(),'command':cmd,'current_version':cv,'compatibility_version':co}
   if cmd==0xd:identity=row
   else:dependencies.append(row)
  elif cmd==0x80000033:export=struct.unpack_from('<II',raw,at+8)
  elif cmd==0x26:starts=struct.unpack_from('<II',raw,at+8)
  at+=size
 if not (uuid and identity and identity['name']==provider and export and starts and text):raise RuntimeError('provider required identity/extents incomplete')
 link=next(x for x in segments if x['name']=='__LINKEDIT');slices=[cmdD]
 for role,extent in [('__TEXT',text),('exports-trie',(link['vmaddr']+export[0]-link['fileoff'],export[1])),('function-starts',(link['vmaddr']+starts[0]-link['fileoff'],starts[1]))]:
  _,d=vm(extent[0],extent[1],role);slices.append(d)
 meta={'authority':'Explicit human bounded installed-provider read-only approval; no runtime acquisition','frozen_utc':now(),'providers':{provider:{'base':base,'uuid':uuid,'identity':identity,'dependencies':dependencies,'segments':segments,'slices':slices}},'cache_files':old['cache_files'],'cache_map':md,'selected_imports':wanted,'current_executable':ed,'current_imports':imports,'current_rpaths':rpaths,'scope':'Installed pristine body+metadata, not actual loaded target or live cache state'};(H/'provider-slices.json').write_text(json.dumps(meta,indent=2)+'\n');A['acquisition_complete_utc']=now();A['provider_identity']={'uuid':uuid,'identity':identity,'text_bytes':text[1]};out={'s':'EXACT_SWIFT_PROVIDER_OPAQUE_METADATA_FROZEN','imports':imports,'rpaths':rpaths,'provider':A['provider_identity'],'exact_extent_bytes':sum(x['bytes'] for x in A['extents']),'processing_upper':A['processing'],'semantics_examined':False}
except BaseException as e:
 A['error']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};out={'s':'ACQUISITION_STOP','error':A['error'],'imports':A.get('current_imports'),'rpaths':A.get('current_rpaths')}
payload=(json.dumps(out,separators=(',',':'))+'\n').encode();A['transcript']+=len(payload);A['processing']+=len(payload)*3;save();(H/'acquisition.stdout').write_bytes(payload);(H/'acquisition-exit.json').write_text(json.dumps({'utc':now(),'exit':2 if 'error' in A else 0})+'\n');sys.stdout.buffer.write(payload);sys.exit(2 if 'error' in A else 0)
