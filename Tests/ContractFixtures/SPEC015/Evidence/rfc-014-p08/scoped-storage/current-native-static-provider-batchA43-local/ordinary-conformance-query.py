from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess,struct,shlex,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;F=json.loads((H/'freeze.json').read_bytes());P=H/'ledger.json';S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args,'ordinary_code_sha256':sha(Path(__file__).read_bytes()),'frozen_before_selected_read_utc':now()});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);save()
try:
 b=read(F['inputs']['executable']);charge(len(b)*3);magic,_,_,_,nc,_,_,_=struct.unpack_from('<8I',b);S['conformance_header_predicate']={'magic':hex(magic),'ncmds':nc};save()
 if magic!=0xfeedfacf:raise RuntimeError('selected current executable is not MachO64')
 at=32;secs=[];sym=None
 for _ in range(nc):
  cmd,size=struct.unpack_from('<II',b,at)
  if cmd==2:sym=struct.unpack_from('<4I',b,at+8)
  if cmd==0x19:
   ns=struct.unpack_from('<I',b,at+64)[0]
   for j in range(ns):
    p=at+72+80*j;va,n=struct.unpack_from('<QQ',b,p+32);fo=struct.unpack_from('<I',b,p+48)[0];secs.append({'name':b[p:p+16].split(b'\0')[0].decode(),'segment':b[p+16:p+32].split(b'\0')[0].decode(),'vmaddr':va,'bytes':n,'fileoff':fo})
  at+=size
 if sym is None:raise RuntimeError('current executable LC_SYMTAB absent')
 so,nn,st,sz=sym;names=['_$s18GiftUISemanticCore24SemanticCompleteIdentityVSQAAMc','_$s18GiftUISemanticCore24SemanticCompleteIdentityVN'];rows=[]
 for i in range(nn):
  no,typ,sec,desc,val=struct.unpack_from('<IBBHQ',b,so+16*i)
  if not no:continue
  name=b[st+no:b.find(b'\0',st+no,st+sz)].decode(errors='replace')
  if name not in names:continue
  row={'symbol':name,'nlist_index':i,'n_type':typ,'section_index':sec,'description':desc,'address':hex(val)}
  hits=[s for s in secs if s['vmaddr']<=val and val+16<=s['vmaddr']+s['bytes']]
  if len(hits)!=1:raise RuntimeError('selected symbol file-backed section count '+str(len(hits)))
  s=hits[0];o=s['fileoff']+val-s['vmaddr'];z=b[o:o+16];row.update({'file_offset':o,'section':s,'raw16':z.hex()})
  if name.endswith('Mc'):
   rel=struct.unpack_from('<i',z,8)[0];flags=struct.unpack_from('<I',z,12)[0];target=val+8+rel;row.update({'flags':flags,'bit17':bool(flags&(1<<17)),'bit7':bool(flags&(1<<7)),'relative_witness_table':rel,'relative_witness_target':hex(target),'provider_fast_return_predicates':{'bit17_clear':not bool(flags&(1<<17)),'relative_nonzero':rel!=0,'target_nonzero':target!=0,'bit7_clear':not bool(flags&(1<<7))}})
   x9=val+16+((flags>>6)&1)*4+((flags>>8)&255)*12+((flags>>21)&0x7f8);x9=(x9+3)&~3;x9off=s['fileoff']+x9-s['vmaddr'];count=struct.unpack_from('<I',b,x9off)[0] if flags&(1<<16) else 0;x26=x9+(((flags>>16)&1)*4)+count*8;xo=s['fileoff']+x26-s['vmaddr']
   if not (s['vmaddr']<=x26 and x26+32<=s['vmaddr']+s['bytes']):raise RuntimeError('selected conformance extension bounds')
   row.update({'provider_computed_x9':hex(x9),'conditional_count_word':count,'provider_computed_x26':hex(x26),'x26_file_offset':xo,'x26_raw32':b[xo:xo+32].hex(),'x26_u16_0':struct.unpack_from('<H',b,xo)[0],'x26_u16_2':struct.unpack_from('<H',b,xo+2)[0],'x26_u32_4':struct.unpack_from('<I',b,xo+4)[0],'x26_i32_8':struct.unpack_from('<i',b,xo+8)[0]})
  rows.append(row)
 S['exact_current_conformance_rows']=rows;save();emit({'s':'EXACT_CURRENT_CONFORMANCE_DATA','executable':F['inputs']['executable'],'rows':rows,'processing':S['processing']})
except BaseException as e:
 S['conformance_exception']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','exception':S['conformance_exception']});sys.exit(2)
