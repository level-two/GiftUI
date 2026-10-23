from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess,struct,shlex,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;F=json.loads((H/'freeze.json').read_bytes());P=H/'ledger.json';S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args,'ordinary_code_sha256':sha(Path(__file__).read_bytes()),'before_read_utc':now()});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);save()
try:
 meta=json.loads(read(F['inputs']['provider_descriptor']));provider=meta['providers']['/usr/lib/swift/libswiftCore.dylib'];extra=[]
 def vm(a,n,role):
  hits=[(p,c,m) for p,c in meta['cache_files'].items() for m in c['rows'] if m['address']<=a and a+n<=m['address']+m['size']]
  if len(hits)!=1:raise RuntimeError('exact selected VM map count '+str(len(hits)))
  p,c,m=hits[0];s=Path(p).stat();r=c['header'];o=m['file_offset']+a-m['address']
  if [s.st_size,s.st_dev,s.st_ino,s.st_mtime_ns]!=[r['file_bytes'],r['device'],r['inode'],r['mtime_ns']]:raise RuntimeError('cache identity changed')
  charge(n*4)
  with Path(p).open('rb') as f:f.seek(o);b=f.read(n)
  if len(b)!=n:raise RuntimeError('short selected VM extent')
  d={'path':p,'offset':o,'bytes':n,'sha256':sha(b),'vmaddr':hex(a),'role':role,'frozen_before_model_utc':now()};extra.append(d);S['additional_frozen_slices']=S.get('additional_frozen_slices',[])+[d];save();return b
 ld=next(x for x in provider['slices'] if x['role']=='image-load-commands');raw=vm(ld['vmaddr'],ld['bytes'],'authenticated provider loadcommands')
 if sha(raw)!=ld['sha256']:raise RuntimeError('frozen loadcommand mismatch')
 at=32;secs=[];sym=None;ind=None
 for _ in range(struct.unpack_from('<I',raw,16)[0]):
  cmd,n=struct.unpack_from('<II',raw,at)
  if cmd==2:sym=struct.unpack_from('<4I',raw,at+8)
  if cmd==0xb:ind=struct.unpack_from('<II',raw,at+56)
  if cmd==0x19:
   for j in range(struct.unpack_from('<I',raw,at+64)[0]):
    q=at+72+80*j;va,sz=struct.unpack_from('<QQ',raw,q+32);fo,al,re,nr,fl,r1,r2=struct.unpack_from('<7I',raw,q+48);secs.append({'name':raw[q:q+16].split(b'\0')[0].decode(),'vmaddr':va,'bytes':sz,'fileoff':fo,'flags':fl,'reserved1':r1,'reserved2':r2})
  at+=n
 if sym is None or ind is None:raise RuntimeError('frozen provider indirect/symbol metadata unavailable')
 def link(off,n):
  hits=[x for x in provider['segments'] if x['fileoff']<=off and off+n<=x['fileoff']+x['filesize']]
  if len(hits)!=1:raise RuntimeError('selected LINKEDIT file extent mapping')
  s=hits[0];return vm(s['vmaddr']+off-s['fileoff'],n,'selected indirect-symbol metadata')
 rows=[];so,nn,st,sz=sym
 for address in [0x1940ef64c,0x1940ef65c,0x1940ef4cc,0x1940ede8c]:
  hits=[s for s in secs if s['vmaddr']<=address<s['vmaddr']+s['bytes'] and s['flags']&255==8]
  row={'call_target':hex(address),'stub_sections':hits};rows.append(row)
  if len(hits)!=1:continue
  sec=hits[0];stride=sec['reserved2'];slot=sec['reserved1']+(address-sec['vmaddr'])//stride;ix=struct.unpack('<I',link(ind[0]+4*slot,4))[0];row.update({'indirect_slot':slot,'indirect_value':ix,'stub_raw':vm(address,stride,'exact selected imported-call stub').hex()})
  if ix&0xc0000000:continue
  no,typ,sn,desc,value=struct.unpack('<IBBHQ',link(so+16*ix,16));name=link(st+no,min(256,sz-no)).split(b'\0')[0].decode();ordinal=desc>>8;row.update({'symbol':name,'nlist_index':ix,'n_type':typ,'n_desc':desc,'ordinal':ordinal,'declared_provider':provider['dependencies'][ordinal-1]['name'] if 1<=ordinal<=len(provider['dependencies']) else None})
 state=[]
 for address,n in [(0x1ed05b3f8,8),(0x1ed06b7a8,56)]:
  b=vm(address,n,'selected pristine Swift dispatch/cache state');state.append({'address':hex(address),'bytes':n,'raw':b.hex(),'u64_words':[int.from_bytes(b[j:j+8],'little') for j in range(0,len(b),8)]})
 S['selected_swift_stub_imports']=rows;S['selected_pristine_swift_state']=state;save();emit({'s':'EXACT_SWIFT_SELECTED_IMPORT_AND_PRISTINE_STATE','imports':rows,'pristine_state':state,'new_slices':extra,'processing':S['processing'],'scope':'Installed bytes only, not actual loaded pointers or live state'})
except BaseException as e:
 S['swift_state_exception']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','exception':S['swift_state_exception']});sys.exit(2)
