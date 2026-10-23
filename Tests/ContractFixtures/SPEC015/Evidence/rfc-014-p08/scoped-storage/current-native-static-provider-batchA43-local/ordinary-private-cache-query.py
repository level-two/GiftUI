from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess,struct,shlex,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;F=json.loads((H/'freeze.json').read_bytes());P=H/'ledger.json';S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args,'ordinary_code_sha256':sha(Path(__file__).read_bytes()),'before_selected_read':now()});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);save()
try:
 d=F['inputs']['executable'];p=R/d['path'];head=p.open('rb').read(32);charge(128);nc,sz=struct.unpack_from('<II',head,16)
 if sz>65536 or p.stat().st_size!=d['bytes']:raise RuntimeError('frozen executable header bound')
 with p.open('rb') as f:raw=f.read(32+sz)
 charge(len(raw)*4);at=32;segments=[];sections=[]
 for _ in range(nc):
  cmd,n=struct.unpack_from('<II',raw,at)
  if cmd==0x19:
   va,vs,fo,fs=struct.unpack_from('<4Q',raw,at+24);segments.append((va,vs,fo,fs))
   for j in range(struct.unpack_from('<I',raw,at+64)[0]):
    q=at+72+80*j;sv,sn=struct.unpack_from('<QQ',raw,q+32);sf=struct.unpack_from('<I',raw,q+48)[0];fl=struct.unpack_from('<I',raw,q+64)[0];sections.append({'name':raw[q:q+16].split(b'\0')[0].decode(),'vmaddr':sv,'bytes':sn,'fileoff':sf,'flags':fl})
  at+=n
 row=next(x for x in S['exact_current_conformance_rows'] if x['symbol'].endswith('Mc'));address=int(row['provider_computed_x26'],16)+8+row['x26_i32_8'];hits=[x for x in sections if x['vmaddr']<=address and address+64<=x['vmaddr']+x['bytes']];S['private_cache_mapping_predicate']={'address':hex(address),'matching_sections':hits};save()
 if len(hits)!=1:raise RuntimeError('descriptor-selected private cache section mapping')
 section=hits[0];zero=(section['flags']&255) in [1,12,18];off=None if zero else section['fileoff']+address-section['vmaddr'];charge(256)
 if zero:z=b'\0'*64
 else:
  with p.open('rb') as f:f.seek(off);z=f.read(64)
 r={'source_descriptor_x26':row['provider_computed_x26'],'relative_field_at_plus8':row['x26_i32_8'],'selected_address':hex(address),'file_offset':off,'section':section,'zero_fill_declaration':zero,'bytes':len(z),'sha256':sha(z),'raw':z.hex(),'u64_words':[int.from_bytes(z[i:i+8],'little') for i in range(0,64,8)],'frozen_before_model_utc':now(),'once_word_offset':56,'scope':'Emitted bytes or explicit section zero-fill declaration only; actual linked/loaded cache and initialization effects remain separate'};S['descriptor_selected_private_cache']=r;save();emit({'s':'EXACT_DESCRIPTOR_SELECTED_PRIVATE_CACHE','cache':r,'processing':S['processing']})
except BaseException as e:
 S['private_cache_exception']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','exception':S['private_cache_exception']});sys.exit(2)
