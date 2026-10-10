#!/usr/bin/env python3
"""Final bounded validation; every compiler/link/execute attempt is recorded."""
from pathlib import Path
import datetime, hashlib, json, subprocess, sys, time
ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
EV = HERE/'evidence'; EV.mkdir(exist_ok=True)
LEDGER = EV/'ledger.json'
HOST = ROOT/'.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc'
NRF = ROOT/'.toolchains/nrf52840/swift/swift-6.3.2-RELEASE-osx/usr/bin/swiftc'
SDK = ROOT/'.toolchains/sdk/swift-6.3.2-RELEASE-raspios-bookworm-armv6/raspios-bookworm.json'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def rel(p): return str(p.relative_to(ROOT))
def now(): return datetime.datetime.now(datetime.timezone.utc)
def save(l): LEDGER.write_text(json.dumps(l,indent=2)+'\n')
def trial(label, command, inputs, outputs=(), rejection=None):
    if (EV/'result.json').exists(): raise SystemExit('STOP: terminal study')
    l=json.loads(LEDGER.read_text()) if LEDGER.exists() else {
      'started':now().isoformat(),'limit':48,'minutes':45,'repair_limit':2,'repairs':[],'trials':[],
      'baseline':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
      'compilers':{rel(p):sha(p) for p in [HOST,NRF]},'sdk':sha(SDK)}
    hashes={rel(p):sha(p) for p in inputs}
    for t in l['trials']:
        if (t['label']==label and t['inputs']==hashes and t.get('matched') and
            all((ROOT/p).exists() and sha(ROOT/p)==h for p,h in t.get('outputs',{}).items())):
            print('cached',label,flush=True); return
    elapsed=(now()-datetime.datetime.fromisoformat(l['started'])).total_seconds()
    if len(l['trials'])>=48 or elapsed>=2700: raise SystemExit('STOP: fixed ceiling reached')
    n=len(l['trials'])+1; log=EV/f'{n:02d}-{label}.log'
    (EV/'inputs').mkdir(exist_ok=True)
    for p in inputs:
        if p.suffix in ['.swift','.py']: (EV/'inputs'/(sha(p)+p.suffix+'.txt')).write_bytes(p.read_bytes())
    t=dict(number=n,label=label,command=list(map(str,command)),inputs=hashes,rejection=rejection,
           started=now().isoformat(),log=rel(log),matched=False)
    l['trials'].append(t);save(l)
    start=time.monotonic()
    try:
        r=subprocess.run(command,cwd=ROOT,text=True,capture_output=True,timeout=min(90,2700-elapsed))
        output=r.stdout+r.stderr;code=r.returncode
    except subprocess.TimeoutExpired as e: output=str(e);code=124
    log.write_text(output)
    errors='\n'.join(x for x in output.splitlines() if 'error:' in x)
    matched=(code not in [0,124] and any(term in errors for term in rejection)) if rejection else code==0
    t.update(exit_code=code,matched=matched,seconds=round(time.monotonic()-start,3),log_hash=sha(log),
             outputs={rel(p):sha(p) for p in outputs if p.exists()})
    save(l);print(f'{n:02d} {label}: {"expected" if matched else "unexpected"} exit={code}',flush=True)
    if not matched: print(output[-10000:],flush=True);raise SystemExit(1)

def targets():
    flags=['-swift-version','6','-parse-as-library','-package-name','GiftUI','-Osize','-wmo',
           '-enable-experimental-feature','LifetimeDependence','-enable-experimental-feature','Lifetimes']
    sdk=json.loads(SDK.read_text())
    pi=sdk['extra-swiftc-flags']+[x for f in sdk['extra-cc-flags'] for x in ['-Xcc',f]]
    nrf=['-target','armv7em-none-none-eabi','-enable-experimental-feature','Embedded',
         '-Xcc','-mcpu=cortex-m4','-Xcc','-mthumb','-Xcc','-mabi=aapcs','-Xcc','-mfpu=fpv4-sp-d16','-Xcc','-mfloat-abi=hard']
    return [
      ('macos-dynamic',HOST,flags+['-target','arm64-apple-macosx15.0','-D','GIFTUI_DYNAMIC_PROFILE'],ROOT/'.build/spike-074/macos-dynamic'),
      ('macos-static',HOST,flags+['-target','arm64-apple-macosx15.0','-D','GIFTUI_STATIC_PROFILE'],ROOT/'.build/spike-074/macos-static'),
      ('pi-armv6',HOST,flags+pi+['-D','GIFTUI_DYNAMIC_PROFILE'],ROOT/'.build/raspberry-pi/spike-074'),
      ('nrf-embedded',NRF,flags+nrf+['-D','GIFTUI_STATIC_PROFILE'],ROOT/'.build/nrf52840/spike-074')]
MODULES=[
 ('GiftUI',[HERE/'Core.swift'],[]),
 ('SignalAnalyzerDomain',[ROOT/'Sources/SignalAnalyzerDomain'/s for s in ['SignalPrimitiveValues.swift','SignalAnalyzerDiagnostic.swift','AcquisitionState.swift']],[]),
 ('ApplicationSchema',[HERE/'Schema.swift'],['GiftUI','SignalAnalyzerDomain']),
 ('PortablePresentation',[HERE/'Presentation.swift'],['GiftUI','SignalAnalyzerDomain','ApplicationSchema']),
 ('HostBridge',[HERE/'Bridge.swift',ROOT/'Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureStorage.swift'],['GiftUI','SignalAnalyzerDomain','ApplicationSchema']),
 ('Driver',[HERE/'Driver.swift'],['GiftUI','SignalAnalyzerDomain','ApplicationSchema','PortablePresentation','HostBridge'])]
mode=sys.argv[1]
if mode=='repair':
    l=json.loads(LEDGER.read_text())
    if len(l['repairs'])>=2: raise SystemExit('STOP: repairs exhausted')
    l['repairs'].append(dict(at=now().isoformat(),reason=sys.argv[2]));save(l);raise SystemExit()
if mode not in ['positive','negative','inspect']:raise SystemExit('positive | negative | inspect | repair reason')
for name,compiler,flags,out in targets():
    out.mkdir(parents=True,exist_ok=True)
    flags=flags+['-module-cache-path',str(out/'cache'),'-I',str(out)]
    if mode=='positive':
        for module,sources,deps in MODULES:
            obj=out/(module+'.o'); swiftmodule=out/(module+'.swiftmodule')
            command=[compiler,*flags,'-module-name',module,'-emit-module','-emit-module-path',swiftmodule,'-c',*sources,'-o',obj]
            trial(name+'-'+module,command,sources+[HERE/'run.py']+[out/(d+'.swiftmodule') for d in deps],[obj,swiftmodule])
        if name.startswith('macos'):
            exe=out/'fixture';objects=[out/(m+'.o') for m,_,_ in MODULES]
            trial(name+'-link',[compiler,*flags,'-module-name','App',HERE/'Main.swift',*objects,'-o',exe],
                  [HERE/'Main.swift',HERE/'run.py',*objects,out/'Driver.swiftmodule'],[exe])
            trial(name+'-run',[exe],[exe,HERE/'run.py'])
    elif mode=='negative':
        for case,terms in [('ESCAPE',['non-escapable','nonescapable','Escapable']),('OVERLAP',['overlapping accesses','lifetime-dependent value escapes'])]:
            trial(name+'-'+case,[compiler,*flags,'-module-name','Negative','-D','NEG_'+case,'-c',HERE/'Negative.swift','-o',out/'negative.o'],
                  [HERE/'Negative.swift',HERE/'run.py']+[out/(m+'.swiftmodule') for m,_,_ in MODULES],rejection=terms)
    elif not name.startswith('macos'):
        for module,sources,deps in MODULES[-2:]:
            ir=out/(module+'.ll')
            trial(name+'-layout-'+module,[compiler,*flags,'-module-name',module,'-emit-ir',*sources,'-o',ir],
                  sources+[HERE/'run.py']+[out/(d+'.swiftmodule') for d in deps],[ir])
