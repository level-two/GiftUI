from pathlib import Path
import json,hashlib,struct,datetime
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;A=json.loads((H/'acquisition.json').read_bytes());oldpath=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-remaining-batchA32-local/provider-slices.json';old=json.loads(oldpath.read_bytes());A['charged_metadata_bytes']+=oldpath.stat().st_size*3;sha=lambda b:hashlib.sha256(b).hexdigest();extents=[]
def vm(addr,n,role):
 for path,c in old['cache_files'].items():
  for m in c['rows']:
   if m['address']<=addr and addr+n<=m['address']+m['size']:
    p=Path(path);s=p.stat();ref=c['header'];assert [s.st_size,s.st_dev,s.st_ino,s.st_mtime_ns]==[ref['file_bytes'],ref['device'],ref['inode'],ref['mtime_ns']];off=m['file_offset']+addr-m['address'];A['charged_metadata_bytes']+=n*3
    with p.open('rb') as f:f.seek(off);b=f.read(n)
    assert len(b)==n;d={'path':path,'offset':off,'bytes':n,'sha256':sha(b),'file_bytes':s.st_size,'device':s.st_dev,'inode':s.st_ino,'mtime_ns':s.st_mtime_ns,'role':role,'vmaddr':addr};extents.append(d);return b,d
 raise RuntimeError('exact VM extent not in existing frozen mappings')
base=0x180506000;header,hd=vm(base,32,'image-header');magic,cpu,sub,typ,ncmd,sizeofcmd,flags,res=struct.unpack('<IiiIIIII',header);assert magic==0xfeedfacf and cpu==0x100000c and sizeofcmd<=65536;raw,cmd_desc=vm(base,32+sizeofcmd,'image-load-commands');at=32;segments=[];deps=[];identity=None;uuid=None;export=None;starts=None;text=None
for _ in range(ncmd):
 cmd,size=struct.unpack_from('<II',raw,at);assert size>=8 and at+size<=len(raw)
 if cmd==0x19:
  name=raw[at+8:at+24].split(b'\0')[0].decode();va,vs,fo,fs=struct.unpack_from('<QQQQ',raw,at+24);nsects=struct.unpack_from('<I',raw,at+64)[0];segments.append({'name':name,'vmaddr':va,'vmsize':vs,'fileoff':fo,'filesize':fs})
  for j in range(nsects):
   q=at+72+80*j;sn=raw[q:q+16].split(b'\0')[0]
   if sn==b'__text':text=struct.unpack_from('<QQ',raw,q+32)
 elif cmd==0x1b:uuid=raw[at+8:at+24].hex()
 elif cmd in [0xd,0xc,0x80000018,0x8000001f,0x80000023]:
  no,ts,cv,compat=struct.unpack_from('<IIII',raw,at+8);name=raw[at+no:at+size].split(b'\0')[0].decode();d={'name':name,'command':cmd,'current_version':cv,'compatibility_version':compat}
  if cmd==0xd:identity=d
  else:deps.append(d)
 elif cmd==0x80000033:export=struct.unpack_from('<II',raw,at+8)
 elif cmd==0x26:starts=struct.unpack_from('<II',raw,at+8)
 elif cmd==0x80000022:
  eo,es=struct.unpack_from('<II',raw,at+40)
  if es:export=(eo,es)
 at+=size
assert identity['name']=='/usr/lib/system/libsystem_platform.dylib' and uuid and export and starts and text
link=next(s for s in segments if s['name']=='__LINKEDIT');slices=[cmd_desc]
for role,extent in [('__TEXT',text),('exports-trie',(link['vmaddr']+export[0]-link['fileoff'],export[1])),('function-starts',(link['vmaddr']+starts[0]-link['fileoff'],starts[1]))]:
 data,desc=vm(extent[0],extent[1],role);slices.append(desc)
# Opaque exact code extents are hashed/frozen here; no provider instructions interpreted.
platform={'base':base,'uuid':uuid,'identity':identity,'dependencies':deps,'segments':segments,'slices':slices};meta={'authority':'Standing explicit bounded installed-provider read-only authority; exact selected shared memory/stack dependency group','freeze_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'cache_files':old['cache_files'],'cache_map':old['cache_map'],'providers':{n:old['providers'][n] for n in ['/usr/lib/libSystem.B.dylib','/usr/lib/system/libsystem_c.dylib']},'acquisition_record':'acquisition.json','selected_imports':['_memcpy','_bzero','___stack_chk_guard','___stack_chk_fail'],'scope':'Installed pristine image code/metadata; not historical loaded-provider/process state'};meta['providers'][identity['name']]=platform;(H/'provider-slices.json').write_text(json.dumps(meta,indent=2)+'\n');A['new_exact_extents']=extents;A['last_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();A['installed_platform_identity']={'uuid':uuid,'identity':identity,'text_bytes':text[1]};A['no_provider_body_model_read']=True;(H/'acquisition.json').write_text(json.dumps(A,indent=2)+'\n');print(json.dumps({'s':'EXACT_PROVIDER_METADATA_FROZEN','uuid':uuid,'identity':identity,'new_extent_bytes':sum(x['bytes'] for x in extents),'charged_acquisition_content_upper':A['charged_metadata_bytes']+A['prior_orientation_content_processing_upper'],'body_semantics_examined':False}))
