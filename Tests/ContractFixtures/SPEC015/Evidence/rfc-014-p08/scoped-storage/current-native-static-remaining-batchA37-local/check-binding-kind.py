from pathlib import Path
import ast,json,hashlib,datetime,sys,struct,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes()
assert sha(src)==F['helper_sha256'];t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'))
args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12)
S.setdefault('first_closed_snapshot',{'finished_utc':S.get('finished_utc'),'model_end_utc':S.get('model_end_utc'),'elapsed_seconds':S.get('elapsed_seconds'),'processing_before_postclose':S['processing'],'transcript_before_postclose':S['transcript']});S['postclose_metadata_started_utc']=now();save()
try:
 b=read(F['inputs']['executable']);a=32;sects=[];commands=[];sym=None;dy=None;di=None;chain=None
 for _ in range(struct.unpack_from('<I',b,16)[0]):
  cmd,size=struct.unpack_from('<II',b,a);commands.append({'cmd':hex(cmd),'size':size})
  if cmd==2:sym=struct.unpack_from('<IIII',b,a+8)
  if cmd==11:dy=struct.unpack_from('<IIIIIIIIIIIIIIIIII',b,a+8)
  if cmd==0x80000022:di=struct.unpack_from('<IIIIIIIIII',b,a+8)
  if cmd==0x80000034:chain=struct.unpack_from('<II',b,a+8)
  if cmd==0x19:
   ns=struct.unpack_from('<I',b,a+64)[0]
   for j in range(ns):
    q=a+72+j*80;name,seg,addr,sz,off,align,relo,nrel,flags,r1,r2,r3=struct.unpack_from('<16s16sQQIIIIIIII',b,q);sects.append({'section':name.rstrip(b'\0').decode(),'segment':seg.rstrip(b'\0').decode(),'addr':addr,'size':sz,'offset':off,'flags':flags,'reserved1':r1,'reserved2':r2})
  a+=size
 so,nn,st,sz=sym;wanted={'_memcpy','_bzero','___stack_chk_guard','___stack_chk_fail'};hits={};indices={}
 for i in range(nn):
  no,typ,sec,desc,val=struct.unpack_from('<IBBHQ',b,so+16*i);name=b[st+no:b.find(b'\0',st+no,st+sz)].decode() if no else ''
  if name in wanted and typ&14==0:hits[name]={'nlist_index':i,'n_type':typ,'n_desc':desc,'ordinal':desc>>8,'reference_type_low3':desc&7};indices[i]=name
 slots=[]
 if dy:
  io,ni=dy[12:14]
  for sec in sects:
   typ=sec['flags']&255
   if typ not in (6,7,8):continue
   stride=sec['reserved2'] if typ==8 else 8
   for j in range(sec['size']//stride):
    k=sec['reserved1']+j
    if k>=ni:continue
    ix=struct.unpack_from('<I',b,io+4*k)[0]
    if ix in indices:slots.append({'symbol':indices[ix],'address':hex(sec['addr']+j*stride),'section':sec['section'],'segment':sec['segment'],'section_type':typ,'indirect_index':k,'nlist_index':ix,'stride':stride})
 result={'executable':F['inputs']['executable'],'imports':hits,'selected_indirect_slots':slots,'dyld_info':None if di is None else dict(zip(['rebase_off','rebase_bytes','bind_off','bind_bytes','weak_off','weak_bytes','lazy_off','lazy_bytes','export_off','export_bytes'],di)),'chained_fixups':None if chain is None else {'offset':chain[0],'bytes':chain[1]},'regular_provider_leaf_exports':{'__platform_memmove':{'flags':0,'address':'0x180509360'},'__platform_bzero':{'flags':0,'address':'0x180509030'}},'scope':'Frozen executable static metadata only; no loaded-image or actual fixup execution substitution.'}
 z=(json.dumps(result,indent=2)+'\n').encode();charge(len(z)*3);(H/'binding-kind.json').write_bytes(z);S['binding_kind_sha256']=sha(z);S['postclose_metadata_end_utc']=now();save();emit({'s':'FROZEN_BINDING_KIND','result':result,'sha256':sha(z)})
except BaseException as e:
 S['postclose_metadata_error']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','error':S['postclose_metadata_error']});sys.exit(2)
