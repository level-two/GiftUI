"""Bootstrap only reviewed Git code under the exact isolated Xcode interpreter."""
import os
import sys

if not (sys.flags.isolated and sys.flags.no_site and sys.flags.dont_write_bytecode and
        sys.pycache_prefix == '/dev/null'):
    raise SystemExit('isolated -I -S -B -X pycache_prefix=/dev/null startup required')
if sys.executable != '/Applications/Xcode.app/Contents/Developer/usr/bin/python3':
    raise SystemExit('absolute Xcode interpreter required')
environment = dict(os.environ)
for name, value in [('LC_CTYPE', 'C.UTF-8'), ('__CF_USER_TEXT_ENCODING', '0x1F5:0x7:0x3D')]:
    if name in environment and environment.pop(name) != value:
        raise SystemExit('unexpected interpreter-added environment')
if environment != dict(HOME='/Users/eugene', TMPDIR='/private/tmp', PATH='/usr/bin:/bin:/usr/sbin:/sbin'):
    raise SystemExit('env-i bootstrap environment required')

from pathlib import Path
import hashlib
import subprocess
import types

root = Path('/Users/eugene/work/GiftUI')
relative = 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-readiness1-preparation'
if len(sys.argv) != 4:
    raise SystemExit('external full reviewed commit/repository/packet tree pins required')
commit, tree, packet_tree = sys.argv[1:]


def git(*args):
    if not args or args[0] not in ('cat-file', 'rev-parse'):
        raise SystemExit('read-only bootstrap Git builtin')
    env = dict(HOME='/Users/eugene', TMPDIR='/private/tmp', PATH='/usr/bin:/bin:/usr/sbin:/sbin',
               LC_CTYPE='C.UTF-8', GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_SYSTEM='/dev/null',
               GIT_CONFIG_GLOBAL='/dev/null', GIT_TERMINAL_PROMPT='0',
               GIT_NO_LAZY_FETCH='1', GIT_ALLOW_PROTOCOL='')
    prefix = ['/usr/bin/git', '--no-replace-objects', '--no-pager', '--no-optional-locks',
              '-c', 'core.fsmonitor=false', '-c', 'core.hooksPath=/dev/null',
              '-c', 'diff.external=', '-c', 'credential.helper=',
              '-c', 'core.sshCommand=/usr/bin/false', '-c', 'submodule.recurse=false']
    configuration = subprocess.check_output([*prefix, 'config', '--no-includes', '--null', '--list'],
                                            cwd=root, env=env, stdin=subprocess.DEVNULL)
    for entry in configuration.split(b'\0'):
        name = entry.split(b'\n', 1)[0].lower()
        if name == b'include.path' or name.startswith(b'includeif.'):
            raise SystemExit('Git includes forbidden')
    return subprocess.check_output([*prefix, *args], cwd=root, env=env, stdin=subprocess.DEVNULL)


def content(kind, oid):
    if len(oid) != 40 or any(c not in '0123456789abcdef' for c in oid):
        raise SystemExit('full finite independent object ID required')
    payload = git('cat-file', kind, oid)
    if hashlib.sha1(kind.encode() + b' ' + str(len(payload)).encode() + b'\0' + payload).hexdigest() != oid:
        raise SystemExit('Git object bytes mismatch')
    return payload


for kind, oid in [('commit', commit), ('tree', tree), ('tree', packet_tree)]:
    content(kind, oid)
if git('rev-parse', 'HEAD').decode().strip() != commit:
    raise SystemExit('reviewed HEAD drift')
if git('rev-parse', commit + '^{tree}').decode().strip() != tree:
    raise SystemExit('repository tree pin mismatch')
if git('rev-parse', commit + ':' + relative).decode().strip() != packet_tree:
    raise SystemExit('packet tree pin mismatch')


def module(name):
    if name not in ('controller_common', 'controller_launch'):
        raise SystemExit('fixed bootstrap module set')
    oid = git('rev-parse', packet_tree + ':' + name + '.py').decode().strip()
    source = content('blob', oid)
    result = types.ModuleType(name)
    result.__dict__['__file__'] = str(root / relative / (name + '.py'))
    exec(compile(source, '<independently reviewed ' + name + ' Git blob>', 'exec'), result.__dict__)
    return result


common = module('controller_common')
common.verify_packet([commit, tree, packet_tree])
sys.modules['controller_common'] = common
launcher = module('controller_launch')
raise SystemExit(launcher.main())
