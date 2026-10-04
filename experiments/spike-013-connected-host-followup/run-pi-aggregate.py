"""Explicitly authorized accumulated-counter run; fixed isolated remote filename."""
from pathlib import Path
import gzip,hashlib,json,subprocess
root=Path.cwd();out=root/'.build/raspberry-pi/spike-013/aggregate'
peer='giftui@giftui-pi.local'
ssh=['ssh','-4','-o','BatchMode=yes','-o','ConnectTimeout=10','-o','ServerAliveInterval=5','-o','ServerAliveCountMax=1']
result=subprocess.run(ssh+[peer,'uname -m; sha256sum giftui/bin/SignalAnalyzerRaspberryPiARMv6; ps -eo pid,comm | awk \'$2 ~ /^SignalAnalyzer/ {print}\''],capture_output=True,text=True,timeout=30)
(out/'target-identity.log').write_text(result.stdout+result.stderr)
assert result.returncode==0 and result.stdout.splitlines()[0]=='armv6l'
assert result.stdout.splitlines()[1].split()[0]=='acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e' and len(result.stdout.splitlines())==2
(out/'preflight.log').write_text('armv6l\n')
binary=root/'.build/raspberry-pi/artifacts/SignalAnalyzerPiAggregateResearch'
sha=hashlib.sha256(binary.read_bytes()).hexdigest()
identities={'binary_sha256':sha,'production_sha256':'acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e'}
(root/'experiments/spike-013-connected-host-followup/evidence/pi-aggregate-identities.json').write_text(json.dumps(identities,indent=2)+'\n')
payload=out/'binary.gz';payload.write_bytes(gzip.compress(binary.read_bytes(),compresslevel=6,mtime=0))
print(f'ARMv6 verified; transferring {payload.stat().st_size} compressed bytes',flush=True)
# Fixed paths only; stage atomically and verify the complete SHA in the collector.
command='gzip -dc > giftui/experiments/iteration-002-spike-013/SignalAnalyzerPiAggregateResearch.tmp && chmod 755 giftui/experiments/iteration-002-spike-013/SignalAnalyzerPiAggregateResearch.tmp && mv giftui/experiments/iteration-002-spike-013/SignalAnalyzerPiAggregateResearch.tmp giftui/experiments/iteration-002-spike-013/SignalAnalyzerPiAggregateResearch'
with payload.open('rb') as source:subprocess.run(ssh+[peer,command],stdin=source,check=True,timeout=180)
print('Upload complete; running bounded45s measurement',flush=True)
with (root/'experiments/spike-013-connected-host-followup/collect-pi.py').open('rb') as source, (out/'measurement.jsonl').open('wb') as output:
 result=subprocess.run(ssh+[peer,'python3 - '+sha+' aggregate'],stdin=source,stdout=output,stderr=subprocess.STDOUT,timeout=85)
assert result.returncode==0
subprocess.run(['python3','experiments/spike-013-connected-host-followup/summarize-pi.py','aggregate'],check=True)
