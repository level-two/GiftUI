"""Summarize preserved connected logs; no hardware access or acceptance claims."""
from pathlib import Path
import datetime,hashlib,json,re,statistics,struct,tarfile
root=Path.cwd();nr=root/'.build/nrf52840/iteration-002-connected';piroot=root/'.build/raspberry-pi/iteration-002-connected'
pi=[json.loads(l) for l in (piroot/'baseline.jsonl').read_text().splitlines()]
frames=[r for r in pi if r['kind']=='trace' and r['line'].startswith('pi-frame-duration-us ')]
costs=[int(r['line'].split()[-1]) for r in frames];times=[datetime.datetime.fromisoformat(r['utc']) for r in frames]
rss=[s['rss_kib'] for r in pi for s in r.get('samples',[])]
summary={'revision':__import__('subprocess').check_output(['git','rev-parse','HEAD'],text=True).strip(),
 'authorization':'Maintainer authorized hardware measurements and experiments after hardware-free completion on 2026-10-04; no services restarted; physical touch not supplied.',
 'pi':{'identity':pi[0],'frames':len(frames),'frame_us_min':min(costs),'frame_us_median':statistics.median(costs),
 'frame_us_max':max(costs),'observed_frames_per_second':(len(times)-1)/(times[-1]-times[0]).total_seconds(),
 'peak_sampled_rss_kib':max(rss),'exit':pi[-1],'application_completed':any(r.get('line')=='status=completed' for r in pi),
 'scope':'45-second idle full-frame run; no physical/synthetic input; not the 80 events/s acceptance workload'}}
observations={}
for label in ('baseline-idle','ready-acquisition','ready-stop','painted-baseline-startup','painted-baseline-ready'):
 log=(nr/label/'monitor.log').read_text().splitlines();changes=[];faults=[];cpu=[];samples=0
 for line in log:
  match=re.search(r'200009C0 = ([0-9A-F ]+)',line)
  if match:
   samples+=1;revision=int(match[1].split()[2],16)
   if not changes or changes[-1]['revision']!=revision:changes.append(dict(utc=line.split()[0],revision=revision))
  if '20027300 = ' in line or '20027310 = ' in line:faults.extend(int(w,16) for w in line.split(' = ')[1].split())
  if 'E000ED28 = ' in line:cpu.extend(int(w,16) for w in line.split(' = ')[1].split()[:2])
 observations[label]={'identity':json.loads((nr/label/'identity.json').read_text()),'samples':samples,'presentation_changes':changes,
  'driver_fault_values':sorted(set(faults)),'cfsr_hfsr_values':sorted(set(cpu))}
changes=observations['ready-acquisition']['presentation_changes']
gaps=[(datetime.datetime.fromisoformat(b['utc'])-datetime.datetime.fromisoformat(a['utc'])).total_seconds()
      for a,b in zip(changes[1:],changes[2:])]
capture=(nr/'acquisition-prefix.bin').read_bytes();records=[]
for i in range(9):
 seconds,packed=struct.unpack_from('<qQ',capture,i*16)
 records.append(dict(milliseconds=seconds*1000+(packed&((1<<60)-1))//10**15,channel=(packed>>60)&7,level=packed>>63))
expected=[dict(milliseconds=0,channel=c,level=0) for c in range(1,5)]+[
 dict(milliseconds=t,channel=c,level=level) for t,c,level in ((80,3,1),(160,3,0),(240,3,1),(250,1,1),(400,2,1))]
assert records==expected
stack=(nr/'painted-baseline-stack.bin').read_bytes();untouched=next((i for i,b in enumerate(stack) if b!=0xaa),len(stack))
paintlog=(nr/'baseline-stack-paint.log').read_text()
assert paintlog.count('E000EDF0 = 00030003')==2
assert '0002473C' in paintlog and 'SP(R13)= 2002EA40' in paintlog
summary['nrf']={'observations':observations,'steady_publication_gaps_seconds':gaps,'median_gap_seconds':statistics.median(gaps),
 'live_prefix':records,'expected_prefix':expected,'prefix_matches':True,
 'start':'Ready revision1, pending pair2; subsequent running state1, capture9 and drawing40 observed.',
 'stop':'Pair admitted at revision6 while halted mid-frame; later snapshot at revision13 remained state1/capture16. Stop outcome not established; no physical Stop claimed.',
 'painted_startup':{'stack_range':['0x20027e80','0x2002ea80'],'sentinel':170,'bytes':len(stack),
 'untouched_prefix_bytes':untouched,'observed_sentinel_extent_bytes':len(stack)-untouched,
 'scope':'Fresh verified reset/halt/loadbin paint, no debugger function calls before capture; ready idle revision1, CFSR/HFSR0. Observed startup/idle extent, not whole-control-flow bound.'},
 'excluded_attempts':['paint.gdb / idle-stack.bin / start.gdb','start-valid.gdb (CPU registers initialized at attach)',
 'baseline-acquisition (revision0 after unintended register initialization)','painted-startup (not final independent baseline)'],
 'limits':'Host timestamped SWD observations include probe overhead; no 80event/s/30s workload, complete pixel corpus, physical contact or failure/recovery corpus.'}
archive=root/'docs/iterations/iteration-002-review/evidence/22-connected-logs.tar.gz'
manifest={}
with tarfile.open(archive,'w:gz') as tar:
 for directory in (piroot,nr):
  for path in sorted(directory.rglob('*')):
   if path.is_file():
    name=str(path.relative_to(root/'.build'))
    manifest[name]=hashlib.sha256(path.read_bytes()).hexdigest();tar.add(path,arcname=name)
summary['archive']={'path':str(archive.relative_to(root)),'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'files':manifest}
(root/'docs/iterations/iteration-002-review/evidence/22-connected-baseline.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k=='pi'},indent=2));print('nrf median publication gap',summary['nrf']['median_gap_seconds'],'stack extent',len(stack)-untouched)
