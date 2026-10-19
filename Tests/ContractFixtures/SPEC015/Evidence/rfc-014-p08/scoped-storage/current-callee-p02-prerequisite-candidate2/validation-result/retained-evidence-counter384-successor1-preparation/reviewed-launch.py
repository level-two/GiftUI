"""Use only git show EXTERNALLY_REVIEWED_COMMIT:this/path | python3 - ... ."""
import sys
if not (sys.flags.isolated and sys.flags.no_site and sys.flags.dont_write_bytecode and sys.pycache_prefix == '/dev/null'):
    raise SystemExit('isolated -I -S -B -X pycache_prefix=/dev/null startup required')
if sys.executable != '/Applications/Xcode.app/Contents/Developer/usr/bin/python3':
    raise SystemExit('absolute frozen Xcode Python required')
from pathlib import Path
import hashlib
import subprocess

root = Path('/Users/eugene/work/GiftUI')
relative = 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/retained-evidence-counter384-successor1-preparation'
if len(sys.argv) != 4:
    raise SystemExit('external reviewed commit, repository tree and packet tree required')
commit, tree, packet_tree = sys.argv[1:]

def git(*args):
    return subprocess.check_output(['git', '--no-replace-objects', *args], cwd=root)

# Authenticate every external object before loading even the verifier code.
for kind, identity in [('commit', commit), ('tree', tree), ('tree', packet_tree)]:
    if len(identity) != 40 or any(c not in '0123456789abcdef' for c in identity):
        raise SystemExit('full finite external object ID required')
    payload = git('cat-file', kind, identity)
    if hashlib.sha1(kind.encode()+b' '+str(len(payload)).encode()+b'\0'+payload).hexdigest() != identity:
        raise SystemExit('external Git object bytes mismatch')
if git('rev-parse', commit+'^{tree}').decode().strip() != tree:
    raise SystemExit('external repository tree mismatch')
if git('rev-parse', commit+':'+relative).decode().strip() != packet_tree:
    raise SystemExit('external packet tree mismatch')
source = git('show', packet_tree+':readiness.py')
blob = git('rev-parse', packet_tree+':readiness.py').decode().strip()
if hashlib.sha1(b'blob '+str(len(source)).encode()+b'\0'+source).hexdigest() != blob:
    raise SystemExit('reviewed verifier blob object mismatch')
namespace = {}
exec(compile(source, '<externally reviewed readiness Git blob>', 'exec'), namespace)
namespace['verify_reviewed_packet'](root, root/relative, commit, tree, packet_tree)
# Load the runner and its readiness import from reviewed Git bytes as well.
# No mutable local Python file is executed after the filesystem check.
import types
module = types.ModuleType('readiness')
module.__dict__.update(namespace)
sys.modules['readiness'] = module
supervisor_source = git('show', packet_tree+':supervisor.py')
supervisor_blob = git('rev-parse', packet_tree+':supervisor.py').decode().strip()
if hashlib.sha1(b'blob '+str(len(supervisor_source)).encode()+b'\0'+supervisor_source).hexdigest() != supervisor_blob:
    raise SystemExit('reviewed supervisor blob object mismatch')
supervisor_module = types.ModuleType('supervisor')
supervisor_module.__dict__['__file__'] = str(root/relative/'supervisor.py')
exec(compile(supervisor_source, '<externally reviewed supervisor Git blob>', 'exec'), supervisor_module.__dict__)
sys.modules['supervisor'] = supervisor_module
runner = git('show', packet_tree+':run.py')
runner_blob = git('rev-parse', packet_tree+':run.py').decode().strip()
if hashlib.sha1(b'blob '+str(len(runner)).encode()+b'\0'+runner).hexdigest() != runner_blob:
    raise SystemExit('reviewed runner blob object mismatch')
exec(compile(runner, '<externally reviewed runner Git blob>', 'exec'),
     {'__file__': str(root/relative/'run.py'), '__name__': '__main__'})
