from pathlib import Path
import json,datetime,hashlib
BASE=Path(__file__).resolve().parent
class Meter:
 def __init__(self):
  p=BASE/'ledger.json';data=p.read_bytes();self.state=json.loads(data);self.charge('ledger-bookkeeping',len(data),str(p));self.charge('meter-code-input',Path(__file__).stat().st_size,str(Path(__file__)))
 def charge(self,kind,n,path):
  s=self.state;s['processing_own_metered_bytes']+=n
  assert s['processing_own_metered_bytes']+s['processing_reserved_root_bytes']+s['processing_reserved_coordinator_bytes']<=s['processing_limit_bytes']
  row={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'kind':kind,'bytes':n,'path':path};encoded=json.dumps(row).encode()+b'\n';self.write_log(encoded);(BASE/'ledger.json').write_text(json.dumps(s,indent=2)+'\n')
 def write_log(self,data):
  assert self.retained()+self.external_retained()+len(data)+self.reserve()<self.state['retention_limit_bytes']
  with (BASE/'reads.jsonl').open('ab') as f:f.write(data)
 def reserve(self):return sum(self.state[k] for k in ['transcript_reserved_own_bytes','transcript_reserved_root_bytes','transcript_reserved_coordinator_bytes','closing_records_reserved_bytes'])
 def retained(self):return sum(p.stat().st_size for p in BASE.rglob('*') if p.is_file())
 def external_retained(self):
  p=Path('Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-static-geometry-qualification1-result')
  return sum(q.stat().st_size for q in p.rglob('*') if q.is_file())+self.state['external_source_retention_reserve']
 def read(self,path):
  p=Path(path);self.charge('payload-read',p.stat().st_size,str(p));return p.read_bytes()
 def save(self,name,value):
  data=json.dumps(value,indent=2).encode()+b'\n';p=BASE/name;old=p.stat().st_size if p.exists() else 0;assert self.retained()+self.external_retained()+len(data)-old+self.reserve()<self.state['retention_limit_bytes'];p.write_bytes(data)
