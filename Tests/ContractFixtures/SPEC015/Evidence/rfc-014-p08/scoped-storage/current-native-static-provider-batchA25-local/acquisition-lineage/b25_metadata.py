import pathlib,json,struct,hashlib,datetime
R=pathlib.Path('/Users/eugene/work/GiftUI');B=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage';P=B/'current-native-static-provider-batchA24-local';H=B/'current-native-static-provider-batchA25-local';assert not H.exists();H.mkdir();(H/'invocation').mkdir();meta=json.loads((P/'provider-slices.json').read_bytes());used=0;extra=[]
def get(p,o,n):
 global used
 assert 0<=n<=1048576
 with pathlib.Path(p).open('rb') as f:f.seek(o);b=f.read(n)
 assert len(b)==n;used+=n;return b
def rec(p,o,n,role,vm=None):
 b=get(p,o,n);s=pathlib.Path(p).stat();d={'path':p,'offset':o,'bytes':n,'sha256':hashlib.sha256(b).hexdigest(),'file_bytes':s.st_size,'device':s.st_dev,'inode':s.st_ino,'mtime_ns':s.st_mtime_ns,'role':role,'vmaddr':vm};extra.append(d);return d
maps=[(x['address'],x['address']+x['size'],p,x['file_offset']) for p,cache in meta['cache_files'].items() for x in cache['rows']]
def loc(a,n):
 hits=[(p,off+a-lo) for lo,hi,p,off in maps if lo<=a and a+n<=hi];assert len(hits)==1;return hits[0]
def vget(a,n):p,o=loc(a,n);return get(p,o,n)
def vrec(a,n,role):p,o=loc(a,n);return rec(p,o,n,role,a)
libc=meta['providers']['/usr/lib/system/libsystem_c.dylib'];d=libc['slices'][0];b=get(d['path'],d['offset'],d['bytes']);assert hashlib.sha256(b).hexdigest()==d['sha256'];ncmd=struct.unpack_from('<I',b,16)[0];at=32;sections=[];sym=None;ind=None
for _ in range(ncmd):
 cmd,size=struct.unpack_from('<II',b,at);c=b[at:at+size]
 if cmd==2:sym=struct.unpack_from('<IIII',c,8)
 elif cmd==11:ind=struct.unpack_from('<II',c,56)
 elif cmd==0x19:
  ns=struct.unpack_from('<I',c,64)[0]
  for j in range(ns):
   q=c[72+j*80:152+j*80];name=q[:16].rstrip(b'\0').decode();seg=q[16:32].rstrip(b'\0').decode();va,vs=struct.unpack_from('<QQ',q,32);flags,r1,r2=struct.unpack_from('<III',q,64)
   if flags&255==8:sections.append({'section':name,'segment':seg,'address':va,'size':vs,'reserved1':r1,'stub_bytes':r2})
 at+=size
assert sym and ind and sections
segs=libc['segments']
def filevm(off,n):
 hits=[s['vmaddr']+off-s['fileoff'] for s in segs if s['fileoff']<=off and off+n<=s['fileoff']+s['filesize']];assert len(hits)==1;return hits[0]
symoff,nsyms,stroff,strsize=sym;ioff,nind=ind;bindings=[]
for section in sections:
 step=section['stub_bytes'];assert step and section['size']%step==0
 for j in range(section['size']//step):
  index=section['reserved1']+j;assert index<nind;ivm=filevm(ioff+index*4,4);ib=vget(ivm,4);si=struct.unpack('<I',ib)[0]
  if si&0xc0000000:continue
  assert si<nsyms;svm=filevm(symoff+si*16,16);nl=vget(svm,16);strx,typ,sect,desc,val=struct.unpack('<IBBHQ',nl);assert strx<strsize
  nmvm=filevm(stroff+strx,min(256,strsize-strx));raw=vget(nmvm,min(256,strsize-strx));end=raw.index(0)+1
  records=[vrec(ivm,4,'stub-indirect-index'),vrec(svm,16,'stub-nlist'),vrec(nmvm,end,'stub-import-name')]
  bindings.append({'address':section['address']+j*step,'stub_bytes':step,'symbol':raw[:end-1].decode(),'n_desc':desc,'library_ordinal':desc>>8,'records':records})
state=vrec(0x1ecf457d8,512,'pristine-__sF-array-selected-range')
sp,so=loc(0x1ecf457d8,512);header=get(sp,0,320);mo,mc=struct.unpack_from('<II',header,312);assert mc<=64;tab=get(sp,mo,mc*56);slide=[]
rec(sp,0,320,'state-cache-header-through-slide-descriptor');rec(sp,mo,mc*56,'state-cache-slide-mapping-table')
for i in range(mc):
 va,sz,fo,sio,sis,flags,mp,ip=struct.unpack_from('<QQQQQQII',tab,i*56)
 if va<=0x1ecf457d8<va+sz:
  assert sis>=32;slide.append({'mapping_vmaddr':va,'mapping_bytes':sz,'slide_info_offset':sio,'slide_info_bytes':sis,'header':rec(sp,sio,32,'state-slide-info-header')})
assert slide
meta['extra_slices']=extra;meta['stdio_stub_bindings']=bindings;meta['pristine_state_range']=state;meta['state_slide_metadata']=slide;meta['additional_metadata_read_bytes']=used;meta['additional_freeze_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();(H/'provider-slices.json').write_text(json.dumps(meta,indent=2)+'\n')
print(json.dumps({'added_frozen_range_bytes':sum(x['bytes'] for x in extra),'stub_binding_count':len(bindings),'metadata_opaque_read_bytes':used,'semantic_body_examination':False}))
