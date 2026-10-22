from pathlib import Path
import subprocess,json,datetime,os,hashlib,time
b=Path("Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage")
o=b/"current-callee-u03-fault-control5-result"
build=Path(".build/contracts/p08-root-stopped-activation-control5")
build.mkdir(exist_ok=False)
root=Path.cwd();tc=root/".toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin";fixture=root/"Tests/ContractFixtures/SPEC015/RootStoppedActivationFaultControl.swift"
base=root/".build/contracts/spec-006-rfc-014-swift64/8e72c5a1adf5f02b-i9ayjitl/macos-static"
state=root/".build/contracts/p08-counter-npoej3u2"
env=os.environ.copy();env["PATH"]=str(tc)+os.pathsep+env.get("PATH","")
commands=[("fixture-format",[str(tc/"swift"),"format","format","--configuration",str(root/".swift-format"),"--in-place",str(fixture)]),("maintained-format-lint",["scripts/format-swift.sh","--lint"]),("compile",[str(tc/"swiftc"),"-swift-version","6","-enable-experimental-feature","LifetimeDependence","-enable-experimental-feature","Lifetimes","-package-name","giftui","-target","arm64-apple-macosx26.0","-parse-as-library","-module-name","P08RootStoppedActivationFaultControl","-I",str(base),"-I",str(state),str(fixture),str(base/"GiftUI.o"),str(state/"GiftUIObservableState.o"),"-o",str(root/build/"control")])]
receipt={"started_UTC":datetime.datetime.now(datetime.timezone.utc).isoformat(),"commands":[],"scope":"focused fixture only, existing source-bound library objects, no product source changes"}
(o/"execution.json").write_text(json.dumps(receipt,indent=2)+"\n")
for name,cmd in commands:
 start=datetime.datetime.now(datetime.timezone.utc);clock=time.monotonic();log=o/(name+".log")
 with log.open("wb") as stream:r=subprocess.run(cmd,stdout=stream,stderr=subprocess.STDOUT,env=env)
 receipt["commands"].append({"name":name,"argv":cmd,"exit_code":r.returncode,"started_UTC":start.isoformat(),"elapsed_seconds":time.monotonic()-clock,"log":str(log),"log_bytes":log.stat().st_size,"log_sha256":hashlib.sha256(log.read_bytes()).hexdigest()})
 (o/"execution.json").write_text(json.dumps(receipt,indent=2)+"\n")
 if name=="fixture-format" and r.returncode:break
 if name=="compile" and r.returncode==0:
  start=datetime.datetime.now(datetime.timezone.utc);clock=time.monotonic();log=o/"control.log"
  with log.open("wb") as stream:test=subprocess.run([str(root/build/"control")],stdout=stream,stderr=subprocess.STDOUT,env=env)
  receipt["commands"].append({"name":"run-control","argv":[str(root/build/"control")],"exit_code":test.returncode,"started_UTC":start.isoformat(),"elapsed_seconds":time.monotonic()-clock,"log":str(log),"log_bytes":log.stat().st_size,"log_sha256":hashlib.sha256(log.read_bytes()).hexdigest()})
receipt["ended_UTC"]=datetime.datetime.now(datetime.timezone.utc).isoformat();receipt["fixture_sha256"]=hashlib.sha256(fixture.read_bytes()).hexdigest()
(o/"execution.json").write_text(json.dumps(receipt,indent=2)+"\n")
summary=json.dumps({"commands":[[x["name"],x["exit_code"],round(x["elapsed_seconds"],3),x["log_bytes"]] for x in receipt["commands"]]});assert len(summary.encode())<1000;print(summary)
