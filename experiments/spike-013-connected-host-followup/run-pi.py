"""Authorized connected run only; verify ARMv6 before isolated deployment."""
from pathlib import Path
import hashlib,json,subprocess,sys
root=Path.cwd();out=root/'.build/raspberry-pi/spike-013';out.mkdir(parents=True,exist_ok=True)
peer=sys.argv[1] if len(sys.argv)>1 else 'giftui@giftui-pi.local'
assert not peer.startswith('-') and not any(c.isspace() for c in peer)
ssh=['ssh','-4','-o','BatchMode=yes','-o','ConnectTimeout=10','-o','ServerAliveInterval=5','-o','ServerAliveCountMax=1']
preflight=subprocess.run(ssh+[peer,'uname -m'],capture_output=True,text=True,timeout=20)
(out/'preflight.log').write_text(preflight.stdout+preflight.stderr)
assert preflight.returncode==0 and preflight.stdout.strip()=='armv6l','Pi must report armv6l before deployment'
remote='giftui/experiments/iteration-002-spike-013/SignalAnalyzerPiResearch'
binary=root/'.build/raspberry-pi/artifacts/SignalAnalyzerPiResearch'
identities=json.loads((root/'experiments/spike-013-connected-host-followup/evidence/pi-identities.json').read_text())
assert hashlib.sha256(binary.read_bytes()).hexdigest()==identities['binary_sha256']
subprocess.run(ssh+[peer,'mkdir -p giftui/experiments/iteration-002-spike-013'],check=True,timeout=20)
# Fixed remote path and explicit named peer; no remote shell interpolation of source data.
subprocess.run(['scp','-4','-C','-q','-o','BatchMode=yes','-o','ConnectTimeout=10','-o','ServerAliveInterval=5','-o','ServerAliveCountMax=1',str(binary),peer+':'+remote],check=True,timeout=120)
with (root/'experiments/spike-013-connected-host-followup/collect-pi.py').open('rb') as source, (out/'measurement.jsonl').open('wb') as output:
 result=subprocess.run(ssh+[peer,'python3 - '+identities['binary_sha256']],stdin=source,stdout=output,stderr=subprocess.STDOUT,timeout=85)
assert result.returncode==0,'Check preserved measurement log before retrying'
subprocess.run(['python3','experiments/spike-013-connected-host-followup/summarize-pi.py'],check=True)
