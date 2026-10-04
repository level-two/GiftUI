"""Decode a completed Pi measurement; no device access or pixel-conformance claim."""
from pathlib import Path
import hashlib,json,statistics,sys,tarfile
root=Path.cwd();base=root/'.build/raspberry-pi/spike-013';mode=sys.argv[1] if len(sys.argv)>1 else 'verbose';assert mode in ('verbose','aggregate')
out=base/'aggregate' if mode=='aggregate' else base;evidence=root/'experiments/spike-013-connected-host-followup/evidence'
prefix='pi-aggregate' if mode=='aggregate' else 'pi'
records=[json.loads(line) for line in (out/'measurement.jsonl').read_text().splitlines()]
identity=next(r for r in records if r['kind']=='identity')
assert identity['architecture']=='armv6l' and identity['binary_digest']==json.loads((evidence/(prefix+'-identities.json')).read_text())['binary_sha256']
assert records[-1]['kind']=='exit' and records[-1]['wrapper_exit_code']==124
lines=[r['line'] for r in records if r['kind']=='trace'];assert any('status=completed' in line for line in lines)
frames=[];source=[];current=None
for line in lines:
 fields=line.split()
 if not fields:continue
 if fields[0]=='pi-research-begin':
  assert current is None;current={'ordinal':int(fields[1]),'mmap_microseconds':0,'mmap_calls':0,'payload_bytes':0}
 elif fields[0]=='pi-research-mmap':
  assert current is not None;current['mmap_microseconds']+=int(fields[1]);current['mmap_calls']+=1;current['payload_bytes']+=int(fields[2])
 elif fields[0]=='pi-research-mmap-total':
  assert current is not None and current['mmap_calls']==0
  current.update(mmap_microseconds=int(fields[1]),mmap_calls=int(fields[2]),payload_bytes=int(fields[3]))
 elif fields[0]=='pi-research-end':
  assert current is not None and current['ordinal']==int(fields[1]);stages=list(map(int,fields[4].split(',')))
  assert len(stages)==11 and sum(stages)<=int(fields[2]) and current['mmap_microseconds']<=stages[-1]
  current.update(microseconds=int(fields[2]),capture_count=int(fields[3]),stage_microseconds=stages);frames.append(current);current=None
 elif fields[0]=='pi-research-source':
  assert fields[2]=='true';source.append(int(fields[1]))
assert current is None and len(frames)>=3 and len(source)>0
stages=json.loads((evidence/'pi-preparation.json').read_text())['stages']
for f in frames:f['stage_microseconds']=dict(zip(stages,f['stage_microseconds']))
samples=[sample for record in records if record['kind']=='process' for sample in record['samples']]
summary=dict(trace_mode=mode,pixel_producing_cycles=sum(f['mmap_calls']>0 for f in frames),identity=identity,frames=frames,source_deliveries=len(source),source_timestamps_microseconds=source,median_source_spacing_seconds=statistics.median([(b-a)/1e6 for a,b in zip(source,source[1:])]) if len(source)>1 else None,median_frame_microseconds=statistics.median(f['microseconds'] for f in frames),stage_medians_microseconds={s:statistics.median(f['stage_microseconds'][s] for f in frames) for s in stages},peak_sampled_rss_kib=max(s['rss_kib'] for s in samples),median_mmap_microseconds=statistics.median(f['mmap_microseconds'] for f in frames),limits='Instrumented copy and bounded automatic acquisition. mmap completion is not panel scanout; no physical contacts, independent full pixels, sustained 80-event/s proof or production optimization.')
archive=evidence/(prefix+'-logs.tar.gz');assert not archive.exists(),'Preserve accepted archive before another decode'
paths=[out/'measurement.jsonl',out/'preflight.log',out/'target-identity.log',out/'build.log']
with tarfile.open(archive,'w:gz') as tar:
 for p in paths:tar.add(p,arcname=p.name)
summary['archive']={'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'files':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}}
(evidence/(prefix+'.json')).write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps({k:summary[k] for k in ('source_deliveries','median_frame_microseconds','stage_medians_microseconds','peak_sampled_rss_kib')},indent=2))
