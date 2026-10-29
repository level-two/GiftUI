from pathlib import Path
import os,sys,json,subprocess,selectors,resource,time,datetime,hashlib
from meter import Meter
B=Path(__file__).resolve().parent
m=Meter()

def run(name,argv,cap=1000000,outputs=()):
    deadline=datetime.datetime.fromisoformat(m.state['session_deadline_utc']).timestamp()
    start=time.time(); rawbytes=0; lines=0; breach=None
    def bounds():
        resource.setrlimit(resource.RLIMIT_FSIZE,(cap,cap));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
    raw=B/(name+'.raw'); assert not raw.exists()
    p=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,preexec_fn=bounds,start_new_session=True)
    sel=selectors.DefaultSelector();sel.register(p.stdout,selectors.EVENT_READ)
    with raw.open('xb') as f:
        while sel.get_map():
            if time.time()>min(deadline,start+900) and p.poll() is None:
                breach='fixed child/session deadline';os.killpg(p.pid,9)
            for key,_ in sel.select(.25):
                data=os.read(key.fd,16384)
                if not data:sel.unregister(key.fileobj);continue
                m.charge('child-raw-read',len(data),name);rawbytes+=len(data);lines+=data.count(b'\n')
                totalraw=sum(q.stat().st_size for q in B.glob('*.raw'))
                if breach is None and (totalraw+len(data)>500000 or lines>32768 or m.retained()+m.external_retained()+len(data)+m.reserve()>m.state['retention_limit_bytes']):
                    breach='capture hard bound';os.killpg(p.pid,9)
                if breach is None:f.write(data)
    code=p.wait();art={}
    for path in outputs:
        q=Path(path)
        if q.exists():art[str(q)]={'bytes':q.stat().st_size,'sha256':hashlib.sha256(m.read(q)).hexdigest()}
    result={'name':name,'argv':argv,'start_utc':datetime.datetime.fromtimestamp(start,datetime.timezone.utc).isoformat(),'duration_seconds':time.time()-start,'exit':code,'raw_read_bytes':rawbytes,'raw_retained_bytes':raw.stat().st_size,'raw_lines':lines,'breach':breach,'artifacts':art,'per_file_hard_cap':cap,'deadline_utc':m.state['session_deadline_utc'],'pipe_accounting':'All bytes read/drained charged; no claim unread compiler-emitted bytes equal read.','raw_sha256':hashlib.sha256(m.read(raw)).hexdigest()}
    m.save(name+'.json',result);print(json.dumps({'name':name,'exit':code,'raw':rawbytes,'artifacts':{str(Path(k).name):v['bytes'] for k,v in art.items()},'breach':breach}),flush=True)
    return result

if __name__=='__main__':
    plan=json.loads(m.read(B/'batch-plan.json'))
    for job in plan['jobs']:
        if job['name'] not in sys.argv[1:]:continue
        r=run(job['name'],job['argv'],job['file_cap'],job.get('outputs',[]))
        if r['exit']!=job.get('expected_exit',0) or r['breach']:sys.exit(1)
