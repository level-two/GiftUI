"""Authentication and durable records for the reviewed current-callee collection."""
from pathlib import Path
import fcntl
import hashlib
import json
import os
import re
import subprocess
import sys
import types

ROOT = Path('/Users/eugene/work/GiftUI')
RELATIVE = 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-readiness1-preparation'
PACKET = ROOT / RELATIVE
OUT = ROOT / '.build/contracts/p08-current-callee-collection1'
LOCK = ROOT / '.build/validation.lock'


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(path):
    value = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            value.update(block)
    return value.hexdigest()


def read_json(path):
    return json.loads(Path(path).read_bytes())


def git(*args):
    require(args and args[0] in ('cat-file', 'rev-parse', 'ls-tree', 'status'), 'read-only Git builtin')
    environment = dict(HOME='/Users/eugene', TMPDIR='/private/tmp',
                       PATH='/usr/bin:/bin:/usr/sbin:/sbin', LC_CTYPE='C.UTF-8',
                       GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_SYSTEM='/dev/null',
                       GIT_CONFIG_GLOBAL='/dev/null', GIT_TERMINAL_PROMPT='0',
                       GIT_NO_LAZY_FETCH='1', GIT_ALLOW_PROTOCOL='')
    prefix = ['/usr/bin/git', '--no-replace-objects', '--no-pager', '--no-optional-locks',
              '-c', 'core.fsmonitor=false', '-c', 'core.hooksPath=/dev/null',
              '-c', 'diff.external=', '-c', 'credential.helper=',
              '-c', 'core.sshCommand=/usr/bin/false', '-c', 'submodule.recurse=false']
    configuration = subprocess.check_output([*prefix, 'config', '--no-includes', '--null', '--list'],
                                            cwd=ROOT, env=environment, stdin=subprocess.DEVNULL)
    for entry in configuration.split(b'\0'):
        name = entry.split(b'\n', 1)[0].lower()
        require(not (name == b'include.path' or name.startswith(b'includeif.')), 'Git include forbidden')
    arguments = list(args)
    if arguments[0] == 'status':
        arguments[1:1] = ['--ignore-submodules=all']
    return subprocess.check_output([*prefix, *arguments], cwd=ROOT, env=environment,
                                   stdin=subprocess.DEVNULL)


def git_object(kind, oid):
    require(type(oid) is str and re.fullmatch('[0-9a-f]{40}', oid) is not None, 'full external Git object ID')
    payload = git('cat-file', kind, oid)
    require(hashlib.sha1(kind.encode() + b' ' + str(len(payload)).encode() + b'\0' + payload).hexdigest() == oid,
            'Git object authentication')
    return payload


def verify_packet(pins):
    require(len(pins) == 3, 'independent commit/repository/packet pins required')
    commit, tree, packet_tree = pins
    for kind, oid in [('commit', commit), ('tree', tree), ('tree', packet_tree)]:
        git_object(kind, oid)
    require(git('rev-parse', 'HEAD').decode().strip() == commit, 'reviewed HEAD drift')
    require(git('rev-parse', commit + '^{tree}').decode().strip() == tree, 'reviewed repository tree')
    require(git('rev-parse', commit + ':' + RELATIVE).decode().strip() == packet_tree, 'reviewed packet tree')
    expected = {}
    for record in git('ls-tree', '-rz', packet_tree).split(b'\0'):
        if record:
            header, name = record.split(b'\t', 1)
            mode, kind, oid = header.split()
            require(mode in (b'100644', b'100755') and kind == b'blob', 'packet file type')
            expected[name.decode()] = git_object('blob', oid.decode())
    actual = {}
    require(PACKET.resolve() == PACKET and PACKET.is_dir(), 'canonical packet directory')
    for path in PACKET.rglob('*'):
        require(not path.is_symlink() and path.is_file(), 'packet contains only regular flat files')
        actual[str(path.relative_to(PACKET))] = path.read_bytes()
    require(actual == expected, 'reviewed packet membership or bytes drift')


def reviewed_source(name, pins):
    require(name in ('controller_common', 'controller_launch', 'controller_worker'), 'fixed reviewed code set')
    oid = git('rev-parse', pins[2] + ':' + name + '.py').decode().strip()
    return git_object('blob', oid).decode()


def tree_entries(root):
    root = Path(root)
    require(root.is_dir(), 'frozen directory missing: ' + str(root))
    result = {}
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in dirs + files:
            path = Path(directory) / name
            key = str(path.relative_to(root))
            if path.is_symlink():
                result[key] = dict(kind='symlink', target=os.readlink(path))
            elif path.is_dir():
                result[key] = dict(kind='directory')
            else:
                require(path.is_file(), 'nonregular frozen tree entry')
                result[key] = dict(kind='file', bytes=path.stat().st_size, sha256=sha(path))
    return result


def verify_trees(definitions):
    for root, expected in definitions.items():
        require(tree_entries(root) == expected, 'frozen tree membership/bytes drift: ' + root)


def path_at_root(name):
    path = Path(name)
    return path if path.is_absolute() else ROOT / path


def verify_context():
    for name, expected in read_json(PACKET / 'input-freeze.json').items():
        path = path_at_root(name)
        require(path.is_file() and sha(path) == expected, 'direct frozen input drift: ' + name)
    policy = read_json(PACKET / 'controller-context-policy.json')
    inherited = ROOT / policy['inherited_packet']
    require(sha(inherited / 'retained-trees.json') == policy['inherited_tree_manifest_sha256'], 'inherited tree manifest')
    trees = read_json(inherited / 'retained-trees.json')
    verify_trees({name: trees[name] for name in policy['inherited_tree_roots']})
    require(sha(inherited / 'frozen-links.json') == policy['source_links_manifest_sha256'], 'source link manifest')
    links = read_json(inherited / 'frozen-links.json')
    for name, expected in read_json(inherited / policy['source_freeze']).items():
        path = path_at_root(name)
        if name in links:
            row = links[name]
            require(path.is_symlink() and os.readlink(path) == row['target'] and
                    str(path.resolve()) == row['resolved'] and expected == row['sha256'], 'source tool link drift')
        else:
            require(path.resolve() == path, 'source alias drift')
        require(path.is_file() and sha(path) == expected, 'source-freeze drift: ' + name)
    discovery = read_json(inherited / policy['source_discovery'])
    found = {}
    for rule in discovery['rules']:
        base = ROOT / rule['base']
        paths = base.rglob('*') if rule['recursive'] else base.iterdir()
        for path in paths:
            if path.is_dir() and not path.is_symlink():
                continue
            if rule['suffix'] and not path.name.endswith(rule['suffix']):
                continue
            require(path.resolve() == path and path.is_file(), 'source discovery alias')
            found[str(path.relative_to(ROOT))] = sha(path)
    require(found == discovery['files'], 'complete source discovery membership drift')
    for name, row in read_json(inherited / policy['tools']).items():
        path = path_at_root(name)
        require(str(path.resolve()) == row['resolved'], 'tool/SDK resolution drift: ' + name)
        if row.get('kind') == 'directory':
            require(path.is_dir(), 'tool directory missing')
        else:
            require(path.is_file() and sha(path) == row['sha256'], 'tool bytes drift')
    verify_trees(read_json(PACKET / policy['current_import_trees']))
    verify_trees(read_json(PACKET / policy['loader_trees']))
    decoder = read_json(PACKET / policy['decoder_libraries'])
    verify_trees({decoder['root']: decoder['entries']})
    for name, row in read_json(PACKET / policy['loader_aliases']).items():
        path = Path(name)
        require(path.is_symlink() and os.readlink(path) == row['target'] and str(path.resolve()) == row['resolved'], 'loader alias drift')
        if row['kind'] == 'file':
            require(path.is_file() and path.stat().st_size == row['bytes'] and sha(path) == row['sha256'], 'loader alias endpoint bytes')
        else:
            require(row['kind'] == 'directory' and path.is_dir(), 'loader alias directory')
    preserved = read_json(PACKET / 'preserved-dirty-files.json')
    for name, expected in preserved['files'].items():
        require(sha(ROOT / name) == expected, 'preexisting dirty file drift')


def verify_recipe():
    import shlex
    recipe = read_json(PACKET / 'collection-recipe.json')
    require(recipe['output'] == str(OUT) and recipe['collection_attempts_used'] == 0 and
            recipe['collection_attempts_max_after_review'] == 1 and recipe['max_swiftc_invocations'] == 94,
            'fixed collection budget')
    require(all(recipe[name] == 0 for name in ('source_candidate_attempts', 'automatic_source_repairs', 'automatic_tooling_repairs', 'retries')), 'no repair/source budget')
    retained = read_json(ROOT / recipe['retained_counter']['path'])
    require(sha(ROOT / recipe['retained_counter']['path']) == recipe['retained_counter']['sha256'], 'retained counter receipt')
    require(retained['passed'] is True and retained['collection_complete'] is True and retained['fresh_focused'] is False and retained['profile'] == 'macos-static', 'retained complete Static qualification')
    original = shlex.split(retained['commands'][18])
    require(original == recipe['retained_command'], 'retained runtime argv identity')
    expected = []
    i = 0
    while i < len(original):
        token = original[i]
        if token in ('-emit-module', '-emit-object'):
            i += 1
        elif token == '-emit-module-path':
            i += 2
        elif token == '-o':
            expected += ['-o', str(OUT / 'actual-host.sil')]
            i += 2
        elif token == '-module-cache-path':
            expected += [token, str(OUT / 'cache')]
            i += 2
        else:
            expected.append(token)
            i += 1
    expected += ['-diagnostic-style', 'llvm', '-emit-sil']
    require(recipe['fresh_sil_command'] == expected, 'exact fresh SIL argv')
    require(len(recipe['consumer_sources']) == 42 and [x for x in original if x.endswith('.swift')] == recipe['consumer_sources'], '42 ordered source operands')
    old = read_json(PACKET.parent / 'ef-resolution-candidate1/qualification/prepared.json')
    require(len(recipe['privacy_controls']) == 93 and len({x['name'] for x in recipe['privacy_controls']}) == 93, '93 unique privacy controls')
    imports = [original[i + 1] for i, token in enumerate(original) if token == '-I']
    plugin = original[original.index('-load-plugin-executable') + 1]
    for control, prior in zip(recipe['privacy_controls'], old['privacy_controls']):
        require({k: v for k, v in control.items() if k != 'command'} == {k: v for k, v in prior.items() if k != 'command'}, 'unchanged privacy classifiers')
        command = []
        i = 0
        while i < len(prior['command']):
            token = prior['command'][i]
            if token == '-I':
                for directory in imports:
                    command += ['-I', directory]
                i += 2
            elif token in ('-module-cache-path', '-load-plugin-executable'):
                command += [token, str(OUT / 'cache') if token == '-module-cache-path' else plugin]
                i += 2
            else:
                command.append(token)
                i += 1
        require(command == control['command'] and '-typecheck' in command, 'fixed privacy argv')
    require(len(recipe['serialized_module_captures']) == 11 and len(recipe['object_captures']) == 50, 'fixed capture inventory')
    targets = read_json(recipe['required_body_targets'])
    require(len(targets) == 92 and sum('name' in t for t in targets) == 91 and sum('demangled_exact' in t for t in targets) == 1, 'exact body target identity forms')
    return recipe


def verify_python(environment_name):
    environment = read_json(PACKET / 'process-environment.json')
    require(sys.executable == environment['python_executable'], 'absolute isolated interpreter')
    require(sys.flags.isolated and sys.flags.no_site and sys.flags.dont_write_bytecode and sys.pycache_prefix == '/dev/null', 'isolated Python flags')
    observed = dict(os.environ)
    for name, value in environment['interpreter_added_environment'].items():
        if name not in environment[environment_name] and name in observed:
            require(observed.pop(name) == value, 'unexpected interpreter-added environment')
    require(observed == environment[environment_name], 'complete isolated process environment')


def check_lock(fd):
    require(LOCK.resolve() == LOCK and LOCK.is_file() and not LOCK.is_symlink(), 'canonical permanent validation lock')
    value = os.fstat(fd)
    require((value.st_dev, value.st_ino) == (LOCK.stat().st_dev, LOCK.stat().st_ino), 'validation lock inode drift')
    fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)


def fsync_directory(path):
    fd = os.open(str(path), os.O_RDONLY)
    try:
        os.fsync(fd)
    finally:
        os.close(fd)


def atomic_json(path, data):
    temporary = path.with_name(path.name + '.writing-' + str(os.getpid()))
    with temporary.open('x') as stream:
        json.dump(data, stream, indent=2, sort_keys=True)
        stream.write('\n')
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)
    fsync_directory(path.parent)


def permanent_claim(path, data):
    with path.open('x') as stream:
        json.dump(data, stream, sort_keys=True)
        stream.write('\n')
        stream.flush()
        os.fsync(stream.fileno())
    fsync_directory(path.parent)
