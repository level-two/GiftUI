from pathlib import Path
import subprocess,json,datetime,os,time,hashlib
b=Path("Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-u03-fault-control5-result")
p=b/"execution.json";r=json.loads(p.read_text());cmd=r["commands"][-1]["argv"]
cache=Path(".build/contracts/p08-root-stopped-activation-control5/module-cache").resolve();cache.mkdir(exist_ok=True);cmd=cmd[:-2]+["-module-cache-path",str(cache)]+cmd[-2:]
env=os.environ.copy();env["CLANG_MODULE_CACHE_PATH"]=str(cache)
for name,args in [("compile-local-cache",cmd),("run-control",[cmd[-1]])]:
 start=datetime.datetime.now(datetime.timezone.utc);t=time.monotonic();log=b/(name+".log")
 with log.open("wb") as stream:result=subprocess.run(args,stdout=stream,stderr=subprocess.STDOUT,env=env)
 row={"name":name,"argv":args,"exit_code":result.returncode,"started_UTC":start.isoformat(),"elapsed_seconds":time.monotonic()-t,"log":str(log),"log_bytes":log.stat().st_size,"log_sha256":hashlib.sha256(log.read_bytes()).hexdigest()};r["commands"].append(row);p.write_text(json.dumps(r,indent=2)+"\n")
 if result.returncode:break
r["ended_UTC"]=datetime.datetime.now(datetime.timezone.utc).isoformat();p.write_text(json.dumps(r,indent=2)+"\n");s=json.dumps([[x["name"],x["exit_code"],round(x["elapsed_seconds"],3),x["log_bytes"]] for x in r["commands"][-2:]]);assert len(s.encode())<1000;print(s)
