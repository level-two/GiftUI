from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess,struct,traceback,shlex
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';fb=(H/'freeze.json').read_bytes();F=json.loads(fb);pb=P.read_bytes();S=json.loads(pb);sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12)
if 'inline_query_failure' not in S:
 S['inline_query_failure']={'error':"AttributeError: module 'sys' has no attribute 'orig_argv'",'before_selected_parser_or_object_read':True,'pre_emission_counting_qualification':False,'unrecorded_request_capture_upper':65536,'control_processing_upper':12*(len(src)+len(fb)+len(pb))+65536};S['transcript']+=65536;charge(S['inline_query_failure']['control_processing_upper']);save()
try:
 z=read(F['inputs']['parser']);charge(len(z)*8);ns={'struct':struct};t=ast.parse(z);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name=='object_metadata'],type_ignores=[]),'','exec'),ns);obj=read(F['inputs']['object']);charge(len(obj)*3);m=ns['object_metadata'](obj)
 names=['_$s18GiftUISemanticCore24SemanticCompleteIdentityVACSQAAWL','_$s17GiftUIInteraction16InteractionStateVy17P08CounterRuntime0E15CandidateAccess33_480B1BD841D053AE4FCDC18507668536LLVAD0e9CommittedI0AFLLVAD0e3HitI0AFLLVGMD','_$s17GiftUIInteraction24InteractionOwnedKeyStateVy17P08CounterRuntime0G15CandidateAccess33_480B1BD841D053AE4FCDC18507668536LLVAD0g9CommittedK0AFLLVAD0g3HitK0AFLLVGMD'];rows=[{'name':n,'aliases':m['aliases'].get(n,[])} for n in names]
 # The retained function parser intentionally exposes only executable aliases.
 # Select only these three exact nlist data symbols and their eight-byte cells.
 magic,_,_,_,ncmds,_,_,_=struct.unpack_from('<8I',obj,0);S['cache_data_predicates']={'magic':hex(magic),'ncmds':ncmds};save()
 if magic!=0xfeedfacf:raise RuntimeError('expected frozen little-endian Mach-O64')
 off=32;sections=[];symtab=None
 for _ in range(ncmds):
  cmd,size=struct.unpack_from('<II',obj,off)
  if cmd==2:symtab=struct.unpack_from('<4I',obj,off+8)
  if cmd==0x19:
   nsct=struct.unpack_from('<I',obj,off+64)[0]
   for j in range(nsct):
    p=off+72+80*j;addr,extent=struct.unpack_from('<QQ',obj,p+32);fileoff=struct.unpack_from('<I',obj,p+48)[0];reloff,nreloc,flags=struct.unpack_from('<III',obj,p+56);sections.append({'name':obj[p:p+16].split(b'\0')[0].decode(),'segment':obj[p+16:p+32].split(b'\0')[0].decode(),'address':addr,'bytes':extent,'fileoff':fileoff,'reloff':reloff,'nreloc':nreloc,'flags':flags})
  off+=size
 S['cache_data_predicates']['symtab']=symtab;save()
 if symtab is None:raise RuntimeError('frozen object LC_SYMTAB not found')
 symoff,nsyms,stroff,strsize=symtab;selected=[]
 for i in range(nsyms):
  sx,typ,sect,desc,value=struct.unpack_from('<IBBHQ',obj,symoff+16*i)
  if sx>=strsize:continue
  end=obj.find(b'\0',stroff+sx,stroff+strsize);name=obj[stroff+sx:end].decode(errors='replace')
  if name not in names:continue
  row={'name':name,'nlist_index':i,'type':typ,'section_index':sect,'value':hex(value),'description':desc}
  if 1<=sect<=len(sections):
   sec=sections[sect-1];delta=value-sec['address'];row['section']=sec;row['section_delta']=delta
   if not 0<=delta<=sec['bytes']-8:raise RuntimeError('selected cache cell outside declared section')
   zero=(sec['flags']&255) in (1,12,18);word=b'\0'*8 if zero else obj[sec['fileoff']+delta:sec['fileoff']+delta+8];row.update({'zero_fill':zero,'file_offset':None if zero else sec['fileoff']+delta,'raw_word_le_hex':word.hex(),'unsigned':int.from_bytes(word,'little'),'signed':int.from_bytes(word,'little',signed=True),'cell_relocations':[]})
   for j in range(sec['nreloc']):
    ra,ri=struct.unpack_from('<iI',obj,sec['reloff']+8*j)
    if delta<=ra<delta+8:row['cell_relocations'].append({'offset':ra,'symbolnum':ri&0xffffff,'pcrel':(ri>>24)&1,'length':(ri>>25)&3,'extern':(ri>>27)&1,'type':ri>>28})
  selected.append(row)
 charge(len(obj)*2);S['cache_symbol_rows']=rows;S['cache_data_words']=selected;save();emit({'s':'EXACT_CURRENT_CACHE_DATA_WORDS','object':F['inputs']['object'],'function_parser_data_aliases':rows,'selected_words':selected,'processing':S['processing']})
except BaseException as e:
 S['ordinary_exception']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','exception':S['ordinary_exception']});sys.exit(2)
