#!/usr/bin/env python3
"""Single bounded language check; no production modules are compiled."""
from pathlib import Path
import datetime, hashlib, json, subprocess, sys, time

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
EVIDENCE = HERE / 'evidence'
LEDGER = EVIDENCE / 'ledger.json'
COMPILER = ROOT / '.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc'
NRF = ROOT / '.toolchains/nrf52840/swift/swift-6.3.2-RELEASE-osx/usr/bin/swiftc'
SDK = ROOT / '.toolchains/sdk/swift-6.3.2-RELEASE-raspios-bookworm-armv6/raspios-bookworm.json'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def rel(p): return str(p.relative_to(ROOT))
def now(): return datetime.datetime.now(datetime.timezone.utc)
def save(ledger): LEDGER.write_text(json.dumps(ledger, indent=2) + '\n')

def trial(label, command, inputs, rejection=None):
    if (EVIDENCE / 'result.json').exists(): raise SystemExit('STOP: terminal result exists')
    ledger = json.loads(LEDGER.read_text()) if LEDGER.exists() else {
        'started': now().isoformat(), 'invocation_limit': 16, 'minutes': 30,
        'repair_limit': 2, 'repairs': [], 'trials': [],
        'baseline': subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        'compiler_hashes': {rel(p): sha(p) for p in [COMPILER,NRF]}, 'sdk_hash': sha(SDK)}
    hashes = {rel(p): sha(p) for p in inputs}
    if any(t['label']==label and t['inputs']==hashes and t['matched'] for t in ledger['trials']):
        print('already recorded:', label, flush=True); return
    elapsed = (now()-datetime.datetime.fromisoformat(ledger['started'])).total_seconds()
    if len(ledger['trials']) >= 16 or elapsed >= 1800: raise SystemExit('STOP: fixed budget exhausted')
    number = len(ledger['trials']) + 1
    snapshots = EVIDENCE/'inputs'; snapshots.mkdir(exist_ok=True)
    for p in inputs:
        if p.suffix in ['.swift','.py']: (snapshots/(sha(p)+p.suffix+'.txt')).write_bytes(p.read_bytes())
    log = EVIDENCE/f'{number:02d}-{label}.log'
    record = dict(number=number,label=label,command=[str(c) for c in command],inputs=hashes,
                  started=now().isoformat(),matched=False,rejection=rejection,log=rel(log))
    ledger['trials'].append(record); save(ledger)
    start=time.monotonic()
    try:
        proc=subprocess.run(command,cwd=ROOT,text=True,capture_output=True,timeout=min(90,1800-elapsed))
        output=proc.stdout+proc.stderr; code=proc.returncode
    except subprocess.TimeoutExpired as error:
        output=str(error); code=124
    log.write_text(output)
    errors='\n'.join(line for line in output.splitlines() if 'error:' in line)
    matched=(code!=0 and code!=124 and any(term in errors for term in rejection)) if rejection else code==0
    record.update(exit_code=code,matched=matched,seconds=round(time.monotonic()-start,3),log_hash=sha(log))
    save(ledger); print(f'{number:02d} {label}: {"expected" if matched else "unexpected"} exit={code}',flush=True)
    if not matched: print(output[-6000:],flush=True); raise SystemExit(1)

def targets():
    common=['-swift-version','6','-parse-as-library','-module-name','Spike073','-Osize','-wmo',
            '-enable-experimental-feature','LifetimeDependence','-enable-experimental-feature','Lifetimes']
    sdk=json.loads(SDK.read_text())
    pi=sdk['extra-swiftc-flags']+[arg for f in sdk['extra-cc-flags'] for arg in ['-Xcc',f]]
    nrf=['-target','armv7em-none-none-eabi','-enable-experimental-feature','Embedded',
         '-Xcc','-mcpu=cortex-m4','-Xcc','-mthumb','-Xcc','-mabi=aapcs',
         '-Xcc','-mfpu=fpv4-sp-d16','-Xcc','-mfloat-abi=hard']
    return [
      ('macos-dynamic',COMPILER,common+['-target','arm64-apple-macosx15.0','-D','GIFTUI_DYNAMIC_PROFILE'],ROOT/'.build/spike-073/macos-dynamic'),
      ('macos-static',COMPILER,common+['-target','arm64-apple-macosx15.0','-D','GIFTUI_STATIC_PROFILE'],ROOT/'.build/spike-073/macos-static'),
      ('pi-armv6',COMPILER,common+pi+['-D','GIFTUI_DYNAMIC_PROFILE'],ROOT/'.build/raspberry-pi/spike-073'),
      ('nrf-embedded',NRF,common+nrf+['-D','GIFTUI_STATIC_PROFILE'],ROOT/'.build/nrf52840/spike-073')]

mode=sys.argv[1]
if mode=='repair':
    ledger=json.loads(LEDGER.read_text())
    if len(ledger['repairs'])>=2: raise SystemExit('STOP: repair limit')
    ledger['repairs'].append(dict(reason=sys.argv[2],at=now().isoformat()))
    save(ledger); raise SystemExit()
if mode not in ['positive','negative']: raise SystemExit('positive | negative | repair reason')
for name,compiler,flags,out in targets():
    out.mkdir(parents=True,exist_ok=True)
    flags+=['-module-cache-path',str(out/'module-cache')]
    if mode=='positive':
        native=name.startswith('macos')
        inputs=[HERE/'Fixture.swift']+([HERE/'Main.swift'] if native else [])
        artifact=out/('fixture' if native else 'fixture.o')
        command=[str(compiler),*flags,*map(str,inputs)]+([] if native else ['-c'])+['-o',str(artifact)]
        trial('positive-'+name,command,inputs+[HERE/'run.py'])
        if native: trial('execute-'+name,[str(artifact)],inputs+[artifact,HERE/'run.py'])
    else:
        for case,terms in [('OVERLAP',['overlapping accesses']),('ESCAPE',['non-escapable','nonescapable','Escapable'])]:
            artifact=out/('negative-'+case+'.o')
            command=[str(compiler),*flags,'-D','NEG_'+case,'-c',str(HERE/'Fixture.swift'),'-o',str(artifact)]
            trial('negative-'+case.lower()+'-'+name,command,[HERE/'Fixture.swift',HERE/'run.py'],terms)
