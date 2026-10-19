"""Pipe only the independently reviewed Git blob into the frozen isolated Python."""
import sys
import os
if not (sys.flags.isolated and sys.flags.no_site and sys.flags.dont_write_bytecode and sys.pycache_prefix == '/dev/null'):
    raise SystemExit('isolated -I -S -B -X pycache_prefix=/dev/null startup required')
if sys.executable != '/Applications/Xcode.app/Contents/Developer/usr/bin/python3':
    raise SystemExit('absolute frozen Xcode Python required')
environment = dict(os.environ)
for name, value in [('LC_CTYPE', 'C.UTF-8'), ('__CF_USER_TEXT_ENCODING', '0x1F5:0x7:0x3D')]:
    if name in environment and environment.pop(name) != value:
        raise SystemExit('fixed interpreter-added environment required')
if environment != dict(HOME='/Users/eugene', TMPDIR='/private/tmp', PATH='/usr/bin:/bin:/usr/sbin:/sbin'):
    raise SystemExit('empty controlled qualification environment required')
from pathlib import Path
import hashlib
import subprocess
import types

root = Path('/Users/eugene/work/GiftUI')
relative = 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/retained-evidence-counter426-requalification1-preparation'
if len(sys.argv) != 4:
    raise SystemExit('external independent reviewed commit, repository tree and packet tree required')
commit, tree, packet_tree = sys.argv[1:]

def require(value, message):
    if not value:
        raise ValueError(message)

def git_environment():
    return dict(HOME='/Users/eugene', TMPDIR='/private/tmp',
                PATH='/usr/bin:/bin:/usr/sbin:/sbin', LC_CTYPE='C.UTF-8',
                GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_SYSTEM='/dev/null',
                GIT_CONFIG_GLOBAL='/dev/null', GIT_TERMINAL_PROMPT='0',
                GIT_NO_LAZY_FETCH='1', GIT_ALLOW_PROTOCOL='')

def git_prefix():
    return ['/usr/bin/git', '--no-replace-objects', '--no-pager', '--no-optional-locks',
            '-c', 'core.fsmonitor=false', '-c', 'core.hooksPath=/dev/null',
            '-c', 'diff.external=', '-c', 'credential.helper=',
            '-c', 'core.sshCommand=/usr/bin/false', '-c', 'submodule.recurse=false']

def guarded_git(root, *args):
    # Only these builtins are reachable, so configured aliases, transports,
    # filters, editors and signing tools cannot become command capabilities.
    require(args and args[0] in ('cat-file', 'rev-parse', 'ls-tree', 'merge-base',
                                'diff', 'show', 'status'), 'read-only Git builtin required')
    prefix, environment = git_prefix(), git_environment()
    configuration = subprocess.check_output(
        [*prefix, 'config', '--no-includes', '--null', '--list'],
        cwd=root, env=environment, stdin=subprocess.DEVNULL)
    for entry in configuration.split(b'\0'):
        name = entry.split(b'\n', 1)[0].lower()
        require(not (name == b'include.path' or name.startswith(b'includeif.')),
                'Git configuration includes forbidden')
    arguments = list(args)
    if arguments[0] in ('diff', 'show'):
        arguments[1:1] = ['--no-ext-diff', '--no-textconv']
    elif arguments[0] == 'status':
        arguments[1:1] = ['--ignore-submodules=all']
    return subprocess.check_output([*prefix, *arguments], cwd=root,
                                   env=environment, stdin=subprocess.DEVNULL)

def git(*args):
    return guarded_git(root, *args)

def content(kind, oid):
    if len(oid) != 40 or any(c not in '0123456789abcdef' for c in oid):
        raise SystemExit('full finite external Git object ID required')
    payload = git('cat-file', kind, oid)
    if hashlib.sha1(kind.encode() + b' ' + str(len(payload)).encode() + b'\0' + payload).hexdigest() != oid:
        raise SystemExit('external Git object bytes mismatch')
    return payload

for kind, oid in [('commit', commit), ('tree', tree), ('tree', packet_tree)]:
    content(kind, oid)
if git('rev-parse', commit + '^{tree}').decode().strip() != tree:
    raise SystemExit('external repository tree mismatch')
if git('rev-parse', commit + ':' + relative).decode().strip() != packet_tree:
    raise SystemExit('external packet tree mismatch')

def module(name):
    oid = git('rev-parse', packet_tree + ':' + name + '.py').decode().strip()
    source = content('blob', oid)
    result = types.ModuleType(name)
    result.__dict__['__file__'] = str(root / relative / (name + '.py'))
    exec(compile(source, '<independently reviewed ' + name + ' Git blob>', 'exec'), result.__dict__)
    return result

qualifier = module('qualify')
qualifier.verify_packet(root, root / relative, commit, tree, packet_tree)
sys.modules['qualify'] = qualifier
sys.modules['enumerate_labels'] = module('enumerate_labels')
runner = module('run')
raise SystemExit(runner.main())
