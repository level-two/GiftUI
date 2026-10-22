import pathlib,json,struct,hashlib,os,datetime
R=pathlib.Path('/Users/eugene/work/GiftUI');H=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-provider-batchA22-local';D=pathlib.Path('/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld');used=0;opened={};maps=[]
def get(p,o,n):
 global used
 assert 0<=n<=8388608 and o>=0
 with p.open('rb') as f:f.seek(o);b=f.read(n)
 assert len(b)==n;used+=n;return b
def record(p,o,n,role,vm=None):
 b=get(p,o,n);s=p.stat();return {'path':str(p),'offset':o,'bytes':n,'sha256':hashlib.sha256(b).hexdigest(),'file_bytes':s.st_size,'device':s.st_dev,'inode':s.st_ino,'mtime_ns':s.st_mtime_ns,'role':role,'vmaddr':vm}
for p in sorted(D.glob('dyld_shared_cache_arm64e*')):
 if p.suffix in ['.map','.atlas']:continue
 b=get(p,0,128)
 if not b.startswith(b'dyld_v1'):raise RuntimeError('unsupported cache magic')
 off,count=struct.unpack_from('<II',b,16);assert count<=64 and off<65536
 mb=get(p,off,count*32);rows=[]
 for i in range(count):
  a,n,f,mp,ip=struct.unpack_from('<QQQII',mb,i*32);maps.append((a,a+n,p,f));rows.append({'address':a,'size':n,'file_offset':f,'max_prot':mp,'init_prot':ip})
 opened[str(p)]={'uuid':b[88:104].hex(),'header':record(p,0,128,'cache-header'),'mapping':record(p,off,count*32,'cache-mapping'),'rows':rows}
def locate(a,n):
 hits=[(p,f+a-lo) for lo,hi,p,f in maps if lo<=a and a+n<=hi]
 assert len(hits)==1,('mapping not unique',hex(a),n,len(hits));return hits[0]
def vmget(a,n):p,o=locate(a,n);return get(p,o,n)
def vmrec(a,n,role):p,o=locate(a,n);return record(p,o,n,role,a)
mp=D/'dyld_shared_cache_arm64e.map';txt=get(mp,0,mp.stat().st_size).decode();images={};active=None
for l in txt.splitlines():
 if l.startswith('/'):active=l.strip();images[active]={}
 elif active:
  import re
  m=re.match(r'\s+(\S+) 0x([0-9A-Fa-f]+) -> 0x([0-9A-Fa-f]+)',l)
  if m:images[active][m[1]]=(int(m[2],16),int(m[3],16))
providers={}
for name in ['/usr/lib/libSystem.B.dylib','/usr/lib/system/libsystem_c.dylib','/usr/lib/system/libsystem_malloc.dylib','/usr/lib/system/libsystem_pthread.dylib']:
 assert name in images and '__TEXT' in images[name]
 base=images[name]['__TEXT'][0];head=vmget(base,32);magic,cpu,sub,typ,ncmd,sz,flags,res=struct.unpack('<IiiIIIII',head);assert magic==0xfeedfacf and ncmd<=128 and sz<=65536
 cmds=vmget(base+32,sz);at=0;segments=[];exports=None;starts=None;uuid=None;identity=None;deps=[]
 for _ in range(ncmd):
  cmd,size=struct.unpack_from('<II',cmds,at);assert size>=8 and at+size<=len(cmds);c=cmds[at:at+size]
  if cmd==0x19:
   seg=c[8:24].rstrip(b'\0').decode();va,vs,fo,fs=struct.unpack_from('<QQQQ',c,24);segments.append({'name':seg,'vmaddr':va,'vmsize':vs,'fileoff':fo,'filesize':fs})
  elif cmd==0x1b:uuid=c[8:24].hex()
  elif cmd in [0xd,0xc,0x8000001f,0x80000018]:
   no,ts,cv,co=struct.unpack_from('<IIII',c,8);row={'name':c[no:].split(b'\0')[0].decode(),'command':cmd,'current_version':cv,'compatibility_version':co};identity=row if cmd==0xd else identity
   if cmd!=0xd:deps.append(row)
  elif cmd==0x80000033:exports=struct.unpack_from('<II',c,8)
  elif cmd in [0x80000022,0x22] and exports is None:exports=struct.unpack_from('<II',c,40)
  elif cmd==0x26:starts=struct.unpack_from('<II',c,8)
  at+=size
 assert at==len(cmds) and uuid and identity
 text=[x for x in segments if x['name']=='__TEXT'];assert len(text)==1
 slices=[vmrec(base,32+sz,'image-load-commands')]
 for seg in segments:
  if seg['name'] in ['__TEXT','__DATA','__DATA_CONST','__AUTH','__AUTH_CONST'] and seg['filesize']:
   slices.append(vmrec(seg['vmaddr'],seg['filesize'],seg['name']))
 def linkrec(pair,role):
  assert pair and pair[1]
  off,n=pair;ss=[x for x in segments if x['fileoff']<=off and off+n<=x['fileoff']+x['filesize']];assert len(ss)==1,(role,ss)
  return vmrec(ss[0]['vmaddr']+off-ss[0]['fileoff'],n,role)
 slices.append(linkrec(exports,'exports-trie'));slices.append(linkrec(starts,'function-starts'))
 providers[name]={'base':base,'uuid':uuid,'identity':identity,'dependencies':deps,'segments':segments,'slices':slices}
# Only bounded exact slices are hashed; no provider code semantics interpreted here.
meta={'authority':'Human approved exact installed-provider bounded read-only evidence','freeze_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'cache_files':opened,'cache_map':record(mp,0,mp.stat().st_size,'cache-image-map'),'providers':providers,'metadata_and_opaque_slice_bytes_read':used,'interpretation':'Metadata/provenance and opaque hashes only preauth; code/conditions/type reading starts under active group'}
(H/'provider-slices.json').write_text(json.dumps(meta,indent=2)+'\n')
print(json.dumps({'frozen_provider_slice_bytes':sum(v['bytes'] for p in providers.values() for v in p['slices']),'provider_slice_counts':{k:len(p['slices']) for k,p in providers.items()},'preauth_bytes':used,'provider_code_semantic_reads':0}))
