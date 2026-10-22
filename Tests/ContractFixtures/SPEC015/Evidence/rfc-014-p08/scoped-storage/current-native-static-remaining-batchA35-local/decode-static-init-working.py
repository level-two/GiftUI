from pathlib import Path
import ast,json,hashlib,datetime,sys,subprocess
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();src=(H/'page.py').read_bytes();assert sha(src)==F['helper_sha256'];t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'))
args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+len(Path(__file__).read_bytes())*12);record={'source':str(Path(__file__).relative_to(R)),'sha256':sha(Path(__file__).read_bytes()),'started_utc':now(),'scope':'Exact known working decoder form, no --macho; already resolved range0x349a8–0x34bd0, no metadata/parser replay'};S.setdefault('ordinary_direct_commands',[]).append(record);save()
try:
 obj=read(F['inputs']['object']);tool=Path('/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/llvm-objdump');charge(tool.stat().st_size+len(obj));argv=[str(tool),'--disassemble','--reloc','--no-show-raw-insn','--start-address=0x349a8','--stop-address=0x34bd0',str(R/F['inputs']['object']['path'])];record['argv']=argv;save();r=subprocess.run(argv,capture_output=True);record.update({'returned_utc':now(),'returncode':r.returncode,'stdout_bytes':len(r.stdout),'stdout_sha256':sha(r.stdout),'stdout_lines':len(r.stdout.splitlines()),'stderr_bytes':len(r.stderr),'stderr_sha256':sha(r.stderr)});(H/'static-init-working-capture.json').write_text(json.dumps(record,indent=2)+'\n');save();charge(len(r.stdout)*4+len(r.stderr)*4)
  
 if len(r.stdout)+len(r.stderr)>1048576 or len(r.stdout.splitlines())+len(r.stderr.splitlines())>16384:raise RuntimeError('actual selected output exceeds original excerpt bound; raw size/hash captured')
 (H/'static-init-working.stdout').write_bytes(r.stdout);(H/'static-init-working.stderr').write_bytes(r.stderr)
 if r.returncode:raise RuntimeError('decoder returncode '+str(r.returncode))
 lines=r.stdout.decode().splitlines();pages=[];buf=[]
 for line in lines:
  if buf and (len(buf)>=100 or len(('\n'.join(buf+[line])+'\n').encode())>8192):pages.append(buf);buf=[]
  assert len(line.encode())<=8192;buf.append(line)
 if buf:pages.append(buf)
 record['page_count']=len(pages);save();emit({'s':'EXACT_CURRENT_CALLEE','capture':record,'stderr':r.stderr.decode(),'total_pages':len(pages),'pages':[{'page':i+1,'of':len(pages),'text':'\n'.join(p)+'\n'} for i,p in enumerate(pages[:1])]});(H/'invocation/direct-working-exit.json').write_text(json.dumps({'exit':0,'utc':now()})+'\n')
except BaseException as e:
 S['errors'].append('working decoder '+type(e).__name__+': '+str(e));S['stopped_utc']=now();save();emit({'s':'STOP','error':S['errors'][-1],'capture':record});(H/'invocation/direct-working-exit.json').write_text(json.dumps({'exit':2,'utc':now()})+'\n');sys.exit(2)
