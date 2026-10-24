from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess,struct,re,shlex,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';fb=(H/'freeze.json').read_bytes();lb=P.read_bytes();F=json.loads(fb);S=json.loads(lb);sha=lambda b:hashlib.sha256(b).hexdigest();src=(H/'page.py').read_bytes();tree=ast.parse(src);exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'<frozen accounting>','exec'))
args={'cmd':'python3 '+str(Path(__file__).relative_to(R))+' '+shlex.quote(sys.argv[1]),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';charge((len(fb)+len(lb)+len(src))*3+len(code.encode())*3+len(json.dumps(args).encode())*3+Path(__file__).stat().st_size*3+4096);S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());save()
def check(n,v,a):
 S.setdefault('predicates',[]).append({'name':n,'ok':bool(v),'actual':a});save()
 if not v:raise RuntimeError(n)
def parse(z):
 off=32;secs=[];sym=None
 for i in range(struct.unpack_from('<I',z,16)[0]):
  c,size=struct.unpack_from('<II',z,off)
  if c==0x19:
   for j in range(struct.unpack_from('<I',z,off+64)[0]):
    q=off+72+80*j;sn,sg,a,sz,fo,al,ro,nr,fl,*_=struct.unpack_from('<16s16sQQIIIIIIII',z,q);secs.append({'name':sn.rstrip(b'\0').decode(),'addr':a,'bytes':sz,'file':fo,'reloff':ro,'nreloc':nr})
  if c==2:sym=struct.unpack_from('<IIII',z,off+8)
  off+=size
 check('LC_SYMTAB',sym is not None,{'present':sym is not None});so,ns,st,ss=sym;rows=[];consumed=0
 for i in range(ns):
  si,t,se,d,a=struct.unpack_from('<IBBHQ',z,so+i*16);en=z.index(0,st+si);raw=z[st+si:en];consumed+=len(raw);rows.append({'symbol':raw.decode(),'address':a,'section':se,'type':t})
 charge(ns*16+consumed*3);return secs,rows
try:
 check('frozen meter',sha(src)==F['helper_sha256'],sha(src));check('frozen current selected operation',sha(Path(__file__).read_bytes())==F['inputs']['current_code']['sha256'],sha(Path(__file__).read_bytes()));selection=json.loads(sys.argv[1]);cache={};captures=[];details=[]
 for key,name in selection:
  if key not in cache:
   z=read(F['inputs'][key]);cache[key]=(z,*parse(z))
  z,secs,rows=cache[key];hits=[x for x in rows if x['symbol']==name];check('exact selected symbol',len(hits)==1,{'object':key,'symbol':name,'matches':len(hits)});row=hits[0];se=secs[row['section']-1];a=row['address']
  if se['name']=='__text':
   end=min([x['address'] for x in rows if x['section']==row['section'] and x['address']>a]+[se['addr']+se['bytes']]);argv=[F['tool']['path'],'--disassemble','--reloc','--no-show-raw-insn','--start-address='+hex(a),'--stop-address='+hex(end),str(R/F['inputs'][key]['path'])];forecast=F['tool']['bytes']+F['inputs'][key]['bytes']+sum(v['bytes']*2 for v in F['inputs'].values())+16777216+1048576;check('decode plus final reserve',S['processing']+forecast<=536870912,{'processing':S['processing'],'forecast':forecast});charge(F['tool']['bytes']+F['inputs'][key]['bytes']);S['pending_argv']=argv;save();r=subprocess.run(argv,capture_output=True);charge((len(r.stdout)+len(r.stderr))*4);n=len(S.get('captures',[]))+1;cap={'object':key,'symbol':name,'start':hex(a),'end':hex(end),'argv':argv,'exit':r.returncode,'stdout_bytes':len(r.stdout),'stdout_lines':len(r.stdout.splitlines()),'stdout_sha256':sha(r.stdout),'stderr':r.stderr.decode(),'raw':'capture-'+str(n)+'.stdout'};S.setdefault('captures',[]).append(cap);save();(H/cap['raw']).write_bytes(r.stdout);(H/('capture-'+str(n)+'.stderr')).write_bytes(r.stderr);check('actual group excerpt',sum(c['stdout_bytes'] for c in S['captures'])<=1048576 and sum(c['stdout_lines'] for c in S['captures'])<=16384,{'bytes':sum(c['stdout_bytes'] for c in S['captures']),'lines':sum(c['stdout_lines'] for c in S['captures'])});check('known decoder exit0',r.returncode==0,cap);S.pop('pending_argv',None);captures.append(cap)
  else:
   nearby=[x for x in rows if x['symbol'].startswith(name[:-3]) and x['section']>0];details.append({'object':key,'exact_symbol':row,'section':se,'related_exact_nominal_prefix_symbols':nearby});charge(len(json.dumps(details).encode())*3)
 save();emit({'s':'CURRENT_SELECTED','captures':captures,'data_details':details,'processing':S['processing']})
except BaseException as e:
 S['exception']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','exception':S['exception'],'pending':S.get('pending_argv')});sys.exit(2)
