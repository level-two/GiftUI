from pathlib import Path
import ast,json,hashlib,datetime,sys,re
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R))+' '+' '.join(sys.argv[1:]),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);p=H/sys.argv[1];b=p.read_bytes();charge(len(b)*3);lines=b.decode().splitlines();lo,hi=map(int,sys.argv[2:4]);out=[]
for n in range(lo,hi+1):
 a=(n-1)*100;part=[]
 for i,line in enumerate(lines[a:a+100],a+1):
  if not line.rstrip().endswith('>:'):line=re.sub(r'\s*<[^>]+>','',line)
  part.append(str(i)+':'+line)
 text='\n'.join(part)+'\n'
 if len(text.encode())>8192:raise RuntimeError('actual compact page exceeds8KiB')
 out.append({'page100':n,'raw_lines':[a+1,min(a+100,len(lines))],'text':text})
v={'s':'ORDERED_CURRENT_BODY_PAGES','raw_path':str(p.relative_to(R)),'raw_sha256':sha(b),'raw_lines':len(lines),'annotation_rule':'Only redundant <symbol+offset> annotations stripped from instruction lines; every instruction/address/operand/relocation retained. Full raw exact identity retained.','pages':out}
if len(json.dumps(v).encode())>=12288:raise RuntimeError('actual combined response exceeds12KiB')
S.setdefault('current_body_examined_pages',{}).setdefault(p.name,[]).extend(range(lo,hi+1));save();emit(v)
