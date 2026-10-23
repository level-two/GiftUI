from pathlib import Path
import json,hashlib,datetime,sys,subprocess,shlex,os
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;F=json.loads((H/'freeze.json').read_bytes());P=H/'ledger.json';mode=sys.argv[1]
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda b:hashlib.sha256(b).hexdigest()
S=json.loads(P.read_bytes()) if P.exists() else {'started_utc':F['started_utc'],'processing':F['setup_processing_upper'],'transcript':0,'requests':[],'pages':[],'errors':[]}
def save():P.write_text(json.dumps(S,indent=2)+'\n')
def charge(n):
 if S['processing']+n+16777216>536870912:raise RuntimeError('processing plus final reserve')
 if (datetime.datetime.now(datetime.timezone.utc)-datetime.datetime.fromisoformat(S['started_utc'])).total_seconds()>7200:raise RuntimeError('7200 session')
 S['processing']+=n
def read(d):
 p=R/d['path'];charge(p.stat().st_size*2);z=p.read_bytes();assert len(z)==d['bytes'] and sha(z)==d['sha256'];return z
def emit(v):
 z=(json.dumps(v,separators=(',',':'))+'\n').encode();foot=sum(p.stat().st_size for p in H.rglob('*') if p.is_file());assert foot+S['transcript']+len(z)*3+1048576<=8388608;charge(len(z)*3);S['transcript']+=len(z);n=len(list((H/'invocation').glob('output-*')));(H/'invocation'/('output-'+str(n)+'.json')).write_bytes(z);save();sys.stdout.buffer.write(z)
try:
 assert sha(Path(__file__).read_bytes())==F['helper_sha256'];args={'cmd':'python3 /tmp/g43 '+' '.join(shlex.quote(x) for x in sys.argv[1:]),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+len(json.dumps(args).encode())*3)
 if mode=='a':
  for n,d in F['inputs'].items():read(d)
  q=subprocess.run(['git','rev-parse','HEAD'],capture_output=True,text=True);charge(len(q.stdout)+len(q.stderr)+4096);assert q.returncode==0 and q.stdout.strip()==F['HEAD'];S['auth_utc']=now();z=read(F['inputs']['body']);lines=z.decode().splitlines();charge(len(z));pages=[];buf=[]
  for line in lines:
   if buf and (len(buf)>=100 or len(('\n'.join(buf+[line])+'\n').encode())>8192):pages.append(buf);buf=[]
   assert len(line.encode())<=8192;buf.append(line)
  if buf:pages.append(buf)
  S['page_count']=len(pages);S['line_count']=len(lines);emit({'s':'AUTH','started':S['started_utc'],'auth':S['auth_utc'],'body':F['inputs']['body'],'pages':len(pages),'lines':len(lines),'reuse':F['reuse']})
 elif mode=='p':
  z=read(F['inputs']['body']);charge(len(z));lines=z.decode().splitlines();pages=[];buf=[]
  for line in lines:
   if buf and (len(buf)>=100 or len(('\n'.join(buf+[line])+'\n').encode())>8192):pages.append(buf);buf=[]
   assert len(line.encode())<=8192;buf.append(line)
  if buf:pages.append(buf)
  lo,hi=map(int,sys.argv[2:4]);assert 1<=lo<=hi<=len(pages) and hi-lo<4;v=[]
  for n in range(lo,hi+1):
   zz=('\n'.join(pages[n-1])+'\n').encode();v.append({'page':n,'of':len(pages),'bytes':len(zz),'sha256':sha(zz),'text':zz.decode()});S['pages'].append(n)
  assert len(json.dumps(v).encode())<12288;emit({'s':'PAGES','identity':F['inputs']['body']['sha256'],'pages':v})
 elif mode=='i':
  m=json.loads(read(F['inputs']['machine']));emit({'s':'EXACT_EXISTING_INDEX','after_object':m['after']['sha256'],'caller_range':m['after']['caller_range'],'caller_symbol':m['after']['caller_symbol'],'sites':m['after']['whole_object_allocator_import_sites']})
 elif mode=='f':
  S['findings']=json.loads(sys.argv[2]);S['model_end_utc']=now()
  for n,d in F['inputs'].items():read(d)
  q=subprocess.run(['git','rev-parse','HEAD'],capture_output=True,text=True);charge(len(q.stdout)+4096);assert q.stdout.strip()==F['HEAD'];S['finished_utc']=now();S['elapsed_seconds']=(datetime.datetime.fromisoformat(S['finished_utc'])-datetime.datetime.fromisoformat(S['started_utc'])).total_seconds();save();emit({'s':'CLOSED','processing':S['processing'],'transcript':S['transcript'],'elapsed':S['elapsed_seconds'],'pages':sorted(set(S['pages']))})
 else:raise RuntimeError('unknown operation')
 (H/'invocation'/('exit-'+str(len(S['requests']))+'.json')).write_text(json.dumps({'utc':now(),'exit':0,'mode':mode})+'\n')
except BaseException as e:
 S['errors'].append(type(e).__name__+': '+str(e));S['stopped_utc']=now();save();z=(json.dumps({'s':'STOP','error':S['errors'][-1]})+'\n').encode();S['transcript']+=len(z);S['processing']+=len(z)*3;save();(H/'invocation'/('exit-'+str(len(S['requests']))+'.json')).write_text(json.dumps({'utc':now(),'exit':2,'mode':mode})+'\n');sys.stdout.buffer.write(z);sys.exit(2)
