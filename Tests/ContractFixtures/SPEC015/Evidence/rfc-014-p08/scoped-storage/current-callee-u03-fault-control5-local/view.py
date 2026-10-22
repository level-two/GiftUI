from pathlib import Path
import json,sys,hashlib,datetime
b=Path('Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage')
out=b/'current-callee-u03-fault-control5-result';ap=out/'accounting.json'
previous=ap.read_bytes();a=json.loads(previous);planned=[];errors=[]
a['processing_known_bytes']+=len(previous)+Path(__file__).stat().st_size+len(sys.argv[1].encode())
try:
 for item in json.loads(sys.argv[1]):
  p=Path(item['path']);data=p.read_bytes();a['processing_known_bytes']+=len(data)
  a['reads'].append({'path':str(p),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'mode':item['mode']})
  planned.append(str(p));ls=data.decode().splitlines()
  if item['mode']=='find':
   planned.extend(str(n)+':'+line.strip() for n,line in enumerate(ls,1) if any(word in line for word in item['words']))
  elif item['mode']=='lines':
   for lo,hi in item['ranges']:
    planned.extend(str(n)+':'+ls[n-1].strip() for n in range(lo,min(hi,len(ls))+1) if ls[n-1].strip())
  elif item['mode']=='func':
   for i,line in enumerate(ls):
    if not any('func '+name+'(' in line or 'func '+name+'<' in line for name in item['names']):continue
    depth=0;opened=False;end=i
    for j in range(i,len(ls)):
     depth+=ls[j].count('{')-ls[j].count('}');opened=opened or '{' in ls[j]
     if opened and depth==0:end=j;break
    planned.extend(str(n)+':'+ls[n-1].strip() for n in range(i+1,end+2) if ls[n-1].strip())
except BaseException as e:errors.append(type(e).__name__+': '+str(e))
remaining=min(20000,a['model_display_hard_cap']-a['model_display_bytes']);display=[];count=0;omitted=0
for line in planned:
 n=len((line+'\n').encode())
 if count+n>remaining:omitted+=1;continue
 display.append(line);count+=n
text='\n'.join(display)+'\n';a['processing_known_bytes']+=len(text.encode());a['model_display_bytes']+=len(text.encode())
a['helper_exits'].append({'argv':sys.argv[1],'intended_exit':0 if not errors else 2,'errors':errors,'display_bytes':len(text.encode()),'omitted_lines':omitted})
a['last_UTC']=datetime.datetime.now(datetime.timezone.utc).isoformat()
assert (datetime.datetime.now(datetime.timezone.utc)-datetime.datetime.fromisoformat(a['started_UTC'])).total_seconds()<a['time_cap_seconds']
assert a['processing_known_bytes']+a['completion_reserve_bytes']<a['processing_cap_bytes']
assert a['model_display_bytes']<=a['model_display_hard_cap']
baseline=a['processing_known_bytes']
for _ in range(8):
 encoded=(json.dumps(a,indent=2)+'\n').encode();a['processing_known_bytes']=baseline+len(encoded)
ap.write_bytes((json.dumps(a,indent=2)+'\n').encode());print(text,end='');sys.exit(0 if not errors else 2)
