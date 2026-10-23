from pathlib import Path
import ast,json,hashlib,datetime,sys,shlex
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();src=(H/'page.py').read_bytes();assert sha(src)==F['helper_sha256'];t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'))
args={'cmd':'python3 '+str(Path(__file__).relative_to(R))+' '+' '.join(shlex.quote(x) for x in sys.argv[1:]),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);save();p=H/sys.argv[1];assert p.parent==H;z=p.read_bytes();charge(len(z)*3);assert len(z)<=1048576;lines=z.decode().splitlines();pages=[];buf=[]
for line in lines:
 if buf and (len(buf)>=100 or len(('\n'.join(buf+[line])+'\n').encode())>8192):pages.append(buf);buf=[]
 assert len(line.encode())<=8192;buf.append(line)
if buf:pages.append(buf)
n=int(sys.argv[2]);assert 1<=n<=len(pages);emit({'s':'DERIVED_CALLEE_PAGE','raw_path':str(p.relative_to(R)),'raw_sha256':sha(z),'page':n,'of':len(pages),'text':'\n'.join(pages[n-1])+'\n'})
