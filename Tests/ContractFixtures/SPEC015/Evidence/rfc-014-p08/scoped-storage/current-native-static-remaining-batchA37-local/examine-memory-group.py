from pathlib import Path
import ast,json,hashlib,datetime,sys
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();src=(H/'page.py').read_bytes();assert sha(src)==F['helper_sha256'];t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'))
args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);save();lines=[]
for c in S['known_memory_edge_resolution']['captures']:
 z=(H/('known-memory-'+str(c['index'])+'.stdout')).read_bytes();charge(len(z)*3);assert len(z)==c['stdout_bytes'] and sha(z)==c['stdout_sha256'];lines+=['EXACT_MEMORY_PROVIDER '+str(c['index'])+' '+c['stdout_sha256']]+z.decode().splitlines()
pages=[];buf=[]
for line in lines:
 if buf and (len(buf)>=100 or len(('\n'.join(buf+[line])+'\n').encode())>8192):pages.append(buf);buf=[]
 assert len(line.encode())<=8192;buf.append(line)
if buf:pages.append(buf)
v=[{'page':i+1,'of':len(pages),'lines':len(p),'text':'\n'.join(p)+'\n'} for i,p in enumerate(pages)];assert len(json.dumps(v).encode())<12288;S['provider_union_examination']={'indices':list(range(1,4)),'ordered_union_sha256':sha(('\n'.join(lines)+'\n').encode()),'pages':len(pages)};save();emit({'s':'COMPLETE_MEMORY_PROVIDER_BODY_UNION','union':S['provider_union_examination'],'pages':v})
