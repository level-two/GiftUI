"""Verify immutable connected Pi data and this round's source/document integrity."""
from pathlib import Path
import ast,datetime,hashlib,json,re,statistics,subprocess,tarfile
root=Path.cwd();review=root/'docs/iterations/iteration-002-review';evidence=root/'experiments/spike-013-connected-host-followup/evidence';base=root/'.build/raspberry-pi/spike-013'
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
record={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':{},'comparison':{}}
for prefix in ('pi','pi-aggregate'):
 r=json.loads((evidence/(prefix+'.json')).read_text());archive=evidence/(prefix+'-logs.tar.gz');assert digest(archive)==r['archive']['sha256']
 with tarfile.open(archive) as tar:
  for name,sha in r['archive']['files'].items():assert hashlib.sha256(tar.extractfile(name).read()).hexdigest()==sha
 assert len(r['frames'])>=3 and r['source_deliveries']==r['frames'][-1]['capture_count']-4
 for f in r['frames']:assert sum(f['stage_microseconds'].values())<=f['microseconds'] and f['mmap_microseconds']<=f['stage_microseconds']['offerAndProduce']
 pixels=[f for f in r['frames'] if f['mmap_calls']>0]
 record['comparison'][prefix]={'cycles':len(r['frames']),'pixel_producing_cycles':len(pixels),'median_pixel_producing_microseconds':statistics.median(f['microseconds'] for f in pixels),'median_all_pipeline_microseconds':r['median_frame_microseconds'],'median_offer_microseconds':r['stage_medians_microseconds']['offerAndProduce'],'median_mmap_microseconds':r['median_mmap_microseconds'],'source_deliveries':r['source_deliveries'],'final_capture_count':r['frames'][-1]['capture_count'],'median_source_spacing_seconds':r['median_source_spacing_seconds'],'peak_sampled_rss_kib':r['peak_sampled_rss_kib'],'archive_sha256':digest(archive)}
for name in ('pi-preparation.json','pi-aggregate-preparation.json'):
 data=json.loads((evidence/name).read_text())
 for path,sha in data['inputs'].items():assert digest(root/path)==sha,path
record['checks']['preparation_inputs_verified']=True
binaries={}
for prefix,product in (('pi','SignalAnalyzerPiResearch'),('pi-aggregate','SignalAnalyzerPiAggregateResearch')):
 identity=json.loads((evidence/(prefix+'-identities.json')).read_text());assert digest(root/'.build/raspberry-pi/artifacts'/product)==identity['binary_sha256'];binaries[product]=identity['binary_sha256']
binaries['SignalAnalyzerRaspberryPiARMv6']='acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e'
assert digest(root/'.build/raspberry-pi/artifacts/SignalAnalyzerRaspberryPiARMv6')==binaries['SignalAnalyzerRaspberryPiARMv6']
text=(base/'aggregate/final-state.log').read_text().splitlines();assert text[0]=='armv6l' and len(text)==4
for line in text[1:]:
 sha,path=line.split();assert binaries[Path(path).name]==sha
record['device']={'architecture':'armv6l','final_remote_binary_hashes':binaries,'remaining_analyzer_processes':[],'services_changed':False}
assert not subprocess.check_output(['git','diff','--name-only','6cf31f26','--','Sources','Tests','firmware','scripts','Package.swift','demo','.agents','skills'],text=True).strip()
record['checks']['maintained_inputs_unchanged']=True
assert digest(review/'evidence/11-validation-logs.tar.gz')=='b97efdfec757fdeaed82e542a12edde021fa47b49f16d9ea156c36857a1c60d8'
record['checks']['original_72_check_archive_unchanged']=True
# Historical closeout and both nRF result archives retain their exact committed bytes.
prior=['docs/iterations/iteration-002-review/evidence/28-host-followup-validation.json','docs/iterations/iteration-002-review/evidence/28-host-restoration-logs.tar.gz','experiments/spike-013-connected-host-followup/evidence/normal-logs.tar.gz','experiments/spike-013-connected-host-followup/evidence/refusal-logs.tar.gz']
for name in prior:assert hashlib.sha256(subprocess.check_output(['git','show','807933dd:'+name])).hexdigest()==digest(root/name)
record['checks']['historical_closeout_nrf_archives_unchanged']=prior
python=list((root/'experiments/spike-013-connected-host-followup').glob('*.py'))+[Path(__file__)]
for p in python:ast.parse(p.read_text())
record['checks']['python_syntax_files']=len(python)
changed=subprocess.check_output(['git','diff','--name-only','807933dd','--','docs'],text=True).splitlines()+subprocess.check_output(['git','ls-files','--others','--exclude-standard'],text=True).splitlines()
links=0;pending={review/'evidence/30-pi-measurement-validation.json',review/'evidence/30-pi-verification-logs.tar.gz'}
for name in sorted(set(changed)):
 p=root/name
 if p.suffix!='.md':continue
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  target=target.strip('<>').split('#')[0]
  if not target or re.match(r'[a-z]+:',target):continue
  path=(p.parent/target).resolve();assert path.exists() or path in pending,(name,target);links+=1
record['checks']['local_links_checked']=links
for label,command in [('shell',['bash','-n','experiments/spike-013-connected-host-followup/build-pi-aggregate.sh']),('whitespace',['git','diff','--check']),('formatter',['scripts/format-swift.sh']),('governance',['ruby','scripts/governance/build-authority-graph.rb'])]:
 result=subprocess.run(command,capture_output=True,text=True);assert result.returncode==0,result.stdout+result.stderr;record['checks'][label]={'exit_code':result.returncode,'output':result.stdout+result.stderr}
assert not (base/'aggregate/local-final-processes.log').read_text().strip()
record['checks']['local_ssh_upload_processes']=[]
files=[base/'aggregate/local-final-processes.log',base/'resumed-doctor.log',base/'resumed-target-identity.log',base/'resumed-final-state.log',base/'resumed-run.log',base/'aggregate/final-state.log',base/'aggregate/run.log']
archive=review/'evidence/30-pi-verification-logs.tar.gz'
with tarfile.open(archive,'w:gz') as tar:
 for p in files:tar.add(p,arcname=str(p.relative_to(base)))
record['verification_archive']={'sha256':digest(archive),'files':{str(p.relative_to(base)):digest(p) for p in files}}
(review/'evidence/30-pi-measurement-validation.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'device':record['device'],'comparison':record['comparison'],'checks':list(record['checks'])},indent=2))
