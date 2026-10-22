from pathlib import Path
import json,subprocess,datetime,sys
C=Path(__file__).parent; a=json.loads((C/'argv.json').read_text()); now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
(C/'start.json').write_text(json.dumps({'utc':now(),'argv':a},indent=2)+'\n')
with (C/'stdout').open('wb') as o,(C/'stderr').open('wb') as e:p=subprocess.run(a,stdout=o,stderr=e)
(C/'exit.json').write_text(json.dumps({'utc':now(),'exit':p.returncode})+'\n');print('SIL_TERMINAL',p.returncode,flush=True);sys.exit(p.returncode)
