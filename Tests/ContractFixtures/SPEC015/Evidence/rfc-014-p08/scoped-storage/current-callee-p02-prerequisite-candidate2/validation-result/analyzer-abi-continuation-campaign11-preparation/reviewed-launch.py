"""Run only via externally pinned `git show COMMIT:path/reviewed-launch.py | python3 - ...`."""
from pathlib import Path
import json
import subprocess
import sys

root = Path('/Users/eugene/work/GiftUI')
relative = 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/analyzer-abi-continuation-campaign11-preparation'
if len(sys.argv) != 4:
    raise SystemExit('reviewed commit, repository tree and packet tree required')
commit, tree, packet_tree = sys.argv[1:]
# This bootstrap and its verifier are obtained from the externally reviewed Git
# object, before any packet-local Python or JSON is loaded.
source = subprocess.check_output(['git','--no-replace-objects','show',commit+':'+relative+'/readiness.py'],cwd=root)
import hashlib
blob = subprocess.check_output(['git','--no-replace-objects','rev-parse',commit+':'+relative+'/readiness.py'],cwd=root).decode().strip()
if hashlib.sha1(b'blob '+str(len(source)).encode()+b'\0'+source).hexdigest() != blob:
    raise SystemExit('reviewed verifier blob object mismatch')
namespace = {}
exec(compile(source,'<reviewed readiness Git blob>','exec'),namespace)
namespace['verify_reviewed_packet'](root,root/relative,commit,tree,packet_tree)
recipe = json.loads((root/relative/'recipe.json').read_bytes())
argv = recipe['execution_argv'] + ['--reviewed-commit',commit,'--reviewed-tree',tree,'--reviewed-packet-tree',packet_tree]
raise SystemExit(subprocess.call(argv,cwd=root))
