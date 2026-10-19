"""Read only qualification of one exact retained collection; never invokes a compiler."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import tarfile

ROOT = Path('/Users/eugene/work/GiftUI')

def require(value, message):
    if not value:
        raise ValueError(message)

def sha(data):
    return hashlib.sha256(data).hexdigest()

def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':')).encode()

def actual(path):
    path = Path(path)
    require(path.is_absolute() and path.resolve() == path and path.is_file(), 'noncanonical regular input: ' + str(path))
    return path.read_bytes()

def read(path):
    return json.loads(actual(path))

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

def git(root, *args):
    return guarded_git(root, *args)

def verify_environment(environment):
    observed = dict(environment)
    for name, value in [('LC_CTYPE', 'C.UTF-8'), ('__CF_USER_TEXT_ENCODING', '0x1F5:0x7:0x3D')]:
        if name in observed:
            require(observed.pop(name) == value, 'fixed interpreter-added environment')
    require(observed == dict(HOME='/Users/eugene', TMPDIR='/private/tmp', PATH='/usr/bin:/bin:/usr/sbin:/sbin'), 'empty controlled qualification environment')

def object_bytes(root, kind, oid):
    require(type(oid) is str and re.fullmatch('[0-9a-f]{40}', oid), 'full external Git object ID')
    content = git(root, 'cat-file', kind, oid)
    require(hashlib.sha1(kind.encode() + b' ' + str(len(content)).encode() + b'\0' + content).hexdigest() == oid, 'Git object bytes')
    return content

def verify_packet(root, packet, commit, tree, packet_tree):
    for kind, oid in [('commit', commit), ('tree', tree), ('tree', packet_tree)]:
        object_bytes(root, kind, oid)
    require(git(root, 'rev-parse', 'HEAD').decode().strip() == commit, 'reviewed HEAD drift')
    require(git(root, 'rev-parse', commit + '^{tree}').decode().strip() == tree, 'reviewed repository tree')
    require(git(root, 'rev-parse', commit + ':' + str(packet.relative_to(root))).decode().strip() == packet_tree, 'reviewed packet tree')
    verify_committed_directory(root, packet, commit)

def verify_committed_directory(root, directory, commit):
    object_bytes(root, 'commit', commit)
    relative = str(directory.relative_to(root))
    records = git(root, 'ls-tree', '-rz', commit + ':' + relative).split(b'\0')
    expected = set()
    for record in records:
        if not record:
            continue
        header, name = record.split(b'\t', 1)
        mode, kind, oid = header.split()
        require(mode in (b'100644', b'100755') and kind == b'blob', 'Git directory type/mode')
        content = object_bytes(root, 'blob', oid.decode())
        expected.add(name.decode())
        require(actual(directory / name.decode()) == content, 'committed directory bytes: ' + name.decode())
    observed = {str(p.relative_to(directory)) for p in directory.rglob('*') if p.is_file() or p.is_symlink()}
    require(observed == expected, 'committed directory inventory')

def load_prior(root, packet, recipe):
    directory = root / recipe['prior_preparation']
    verify_committed_directory(root, directory, recipe['prior_preparation_commit'])
    relative = str(directory.relative_to(root)) + '/readiness.py'
    oid = git(root, 'rev-parse', recipe['prior_preparation_commit'] + ':' + relative).decode().strip()
    source = object_bytes(root, 'blob', oid)
    namespace = {}
    exec(compile(source, '<pinned prior read-only verifier>', 'exec'), namespace)
    # All prior functions resolve this global binding at call time. Preserve
    # pinned verifier bytes while removing its ambient Git process capability.
    namespace['git'] = git
    return directory, namespace

def verify_recipe(recipe):
    expected = dict(schema=1, prior_preparation_commit='065efeb6e52d57e3cf7e0c67f333c27ff7ac500f',
                    archive_commit='160154132e887e5d2076509c065540ce60719f95',
                    review_commit='e64a9e708cddbfa9f2f3ca0225ecc9746edf30ec',
                    compiler_launches=0, schema4_launches=0, counter_launches=0,
                    repairs=0, retries=0, qualification_attempts=1,
                    python_executable='/Applications/Xcode.app/Contents/Developer/usr/bin/python3')
    for name, value in expected.items():
        require(recipe.get(name) == value, 'fixed recipe: ' + name)
    base = 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/'
    for key, suffix in [('prior_preparation', 'retained-evidence-counter384-successor1-preparation'),
                        ('prior_result', 'retained-evidence-counter384-successor1-result')]:
        require(recipe.get(key) == base + suffix, 'fixed packet path')
    for key, value in [('driver_root', '.build/contracts/p08-counter-npoej3u2'),
                       ('wrapper_root', '.build/contracts/p08-retained-evidence-counter384-successor1'),
                       ('runtime_root', '.build/contracts/spec-013-runtime-cycle/tmpb3zdakko/macos-static'),
                       ('schema4_root', '.build/contracts/p08-scoped-host-7gj3vxnl'),
                       ('output_root', '.build/contracts/p08-retained-evidence-counter426-requalification1')]:
        require(recipe.get(key) == str(ROOT / value), 'fixed root: ' + key)
    require(set(recipe) == set(expected) | {'prior_preparation', 'prior_result', 'driver_root', 'wrapper_root', 'runtime_root', 'schema4_root', 'output_root'}, 'no extra recipe capability')

def verify_historical(terminal, frozen, recipe):
    require(terminal == frozen, 'historical terminal drift')
    require(terminal['status'] == 'STOP' and terminal['child_exit'] == 0, 'historical STOP/actual child exit')
    require(terminal['error'].endswith('ValueError: exact 384 unique labels\n'), 'historical erroneous aggregate gate')
    require(terminal['initial_launches'] == 1 and terminal['automatic_repairs'] == terminal['retries'] == terminal['schema4_launches'] == 0, 'historical allowance remains consumed')
    require(terminal['output_root'] == recipe['driver_root'] and terminal['reviewed_pins'][0] == recipe['prior_preparation_commit'], 'historical root/review join')
    require(list(terminal['observed_new_roots']) == [Path(recipe['driver_root']).name], 'sole fresh retained driver root')

def verify_archive(root, directory, prior):
    index = read(directory / 'receipt-index.json')
    manifest = read(directory / 'raw-file-manifest.json')
    archive = directory / index['archive']['path']
    require(len(manifest['files']) == index['archive']['files'] == 952, '952 original files')
    require(len(actual(archive)) == index['archive']['bytes'] and sha(actual(archive)) == index['archive']['sha256'], 'raw archive hash/size')
    expected = {i['archive_member']: i for i in manifest['files']}
    require(len(expected) == 952, 'unique raw inventory')
    expected_directories = set(index['archive']['root_members'])
    for name in expected:
        expected_directories.update(str(p) for p in Path(name).parents if str(p) != '.')
    with tarfile.open(archive, 'r:gz') as tar:
        members = tar.getmembers()
        require(len(members) == 957 and len({m.name for m in members}) == 957, 'exact unique archive inventory')
        require({m.name for m in members if m.isfile()} == set(expected), 'archive file membership')
        require({m.name for m in members if m.isdir()} == expected_directories, 'archive directory membership')
        for member in members:
            require(member.isfile() or member.isdir(), 'archive links/special files forbidden')
            if member.isdir():
                continue
            item = expected[member.name]
            content = actual(Path(item['original_path']))
            require(root / item['repository_path'] == Path(item['original_path']), 'archive original operand')
            require(len(content) == item['bytes'] == member.size and sha(content) == item['sha256'], 'raw original identity')
            require(tar.extractfile(member).read() == content, 'archive/live byte join')
    for item in index['extracted_receipts']:
        content = actual(directory / item['archived'])
        require(len(content) == item['bytes'] and sha(content) == item['sha256'] and content == actual(root / item['source']), 'all extracted receipts/logs join')
    require(index['status'] == 'STOP' and index['remaining_initial_launches'] == 0 and index['postflight_qualification_performed'] is False, 'archive STOP classification')

def verify_partitions(data, frozen_rows):
    from enumerate_labels import partitions
    expected = partitions()
    require({k: len(v) for k, v in expected.items()} == dict(scoped=384, supplemental=2, reuse=13, other=27), 'independent partition cardinalities')
    all_labels = [name for group in expected.values() for name in group]
    require(len(all_labels) == len(set(all_labels)) == 426, 'independent unique label inventory')
    names = [c['name'] for c in data['checks']]
    require(len(names) == len(set(names)) == 426 and set(names) == set(all_labels), 'exact 426 unique checks')
    require(data['planned_scoped_labels'] == expected['scoped'] and data['planned_supplemental_labels'] == expected['supplemental'] and data['registered_reuse_labels'] == expected['reuse'], 'actual driver partition joins')
    frozen_names = [c['name'] for c in frozen_rows]
    require(len(frozen_names) == len(set(frozen_names)) == 426 and set(frozen_names) == set(all_labels), 'frozen unique label inventory')
    require(all(r['partition'] in expected and r['name'] in expected[r['partition']] for r in frozen_rows), 'mispartitioned frozen label')
    for row in frozen_rows:
        name, partition = row['name'], row['partition']
        if partition in ('scoped', 'supplemental'):
            kind, code = ('compiler-negative', 1) if name.endswith('-negative') else ('positive', 0)
        elif partition == 'reuse' or name == 'runtime-summary':
            kind, code = 'observation', None
        elif name == 'so06-native-exclusivity-negative-execute':
            kind, code = 'runtime-negative', -6
        else:
            kind, code = 'positive', 0
        require((row['kind'], row['exit']) == (kind, code), 'independent label kind/exit classification')
    require(sum(n.endswith('-positive') for n in expected['scoped']) == sum(n.endswith('-negative') for n in expected['scoped']) == 192, '192 scoped positive/negative pairs')
    return expected

def verify_diagnostic(row, expected, log, read_bytes):
    require(sha(log) == expected['log_sha256'] == row['log_sha256'], 'exact raw log hash')
    if expected['kind'] == 'positive':
        require(row['exit'] == 0 and row['diagnostic'] is None and row['identity']['diagnostic'] is None, 'positive zero exit')
        return
    diagnostic = expected['qualified_diagnostic']
    require(diagnostic['name'], 'named qualified diagnostic')
    text = log.decode('utf-8')
    require(not any(term in text.lower() for term in ('stack dump', 'please submit a bug report', 'compiler crash')), 'compiler crash is not expected rejection') if expected['kind'] == 'compiler-negative' else None
    if expected['kind'] == 'runtime-negative':
        require(row['name'] == 'so06-native-exclusivity-negative-execute' and row['exit'] == -6, 'exact runtime fatal-access exit')
        require(diagnostic['name'] == 'native-runtime-exclusive-access-conflict' and len(diagnostic['required_exact_lines']) == 2, 'named runtime diagnostic')
        require(all(text.splitlines().count(line) == 1 for line in diagnostic['required_exact_lines']), 'exact fatal access diagnostic lines')
        return
    require(expected['kind'] == 'compiler-negative' and row['exit'] == 1, 'compiler negative exact exit 1')
    require(row['diagnostic'] is not None and row['identity']['diagnostic'] == row['diagnostic'], 'original driver oracle join')
    require(diagnostic['name'] == row['name'].removesuffix('-negative'), 'exact qualified control diagnostic name')
    source = diagnostic['source']
    require(row['identity']['sources'].get('${OUT}/' + row['name'] + '.swift') == diagnostic['source_sha256'], 'diagnostic source/actual command identity join')
    require(source.endswith('/' + row['name'] + '.swift'), 'qualified exact source operand')
    content = read_bytes(source)
    require(sha(content) == diagnostic['source_sha256'], 'qualified generated source hash')
    source_lines = content.decode().splitlines()
    observed = []
    for line in text.splitlines():
        match = re.fullmatch(r'(.+?):(\d+):(\d+): error: (.*)', line)
        if match:
            path, number, column, message = match.groups()
            number, column = int(number), int(column)
            require(path == source and 4023 <= number <= len(source_lines) and 1 <= column <= len(source_lines[number-1]) + 1, 'qualified exact diagnostic location')
            observed.append(dict(path=path, line=number, column=column, message=message, source_line=source_lines[number-1]))
    require(observed and observed == diagnostic['primary_errors'], 'exact named primary errors/source lines; no wildcard')
    # Every compiler rejection must have a separately reviewed finite primary
    # list. Hash equality additionally seals notes, source excerpts and repeats.
    require(all(error['message'] for error in observed), 'empty diagnostic message')

def verify_collection(data, checks, frozen_rows, identities, artifacts, driver, read_bytes=actual):
    verify_partitions(data, frozen_rows)
    require(data['collection_schema'] == 2 and data['collection_complete'] is True and data['passed'] is True and data['fresh_focused'] is False, 'complete actual driver aggregate')
    require(data['focused_passed'] is False and data['selected_families'] == [] and data['prior_collection'] is None and data['legacy_import'] is None and data['qualified_noncompiled_applicability'] == [], 'unfocused non-reused actual collection')
    require(checks == {k: data[k] for k in ('collection_complete', 'passed', 'fresh_focused', 'focused_passed', 'checks')}, 'checks/result exact receipt join')
    require({k: data[k] for k in identities} == identities and identities['profile'] == identities['selected_host_profile'] == 'macos-static', 'exact compiler/flags/profile/dependency identities')
    require(data['artifacts'] == artifacts and len(artifacts) == 904, 'all 904 artifact identities')
    expected_rows = {r['name']: r for r in frozen_rows}
    for row in data['checks']:
        expected = expected_rows[row['name']]
        require(row['passed'] is True and row['status'] == 'passed', 'passing row status')
        require(sha(canonical(row)) == expected['row_sha256'], 'exact actual row/command/source/oracle identity: ' + row['name'])
        require(row['exit'] == expected['exit'], 'frozen actual exit')
        if expected['kind'] == 'observation':
            require(row['exit'] is None and row['identity']['requires'] == ['execute'] and row['evidence'] == row['identity']['evidence'] == expected['evidence'] == 'execute.log', 'runtime observation dependency/evidence join')
            evidence = read_bytes(driver / row['evidence'])
            require(sha(evidence) == expected['evidence_sha256'] == row['evidence_sha256'], 'exact runtime observation log')
            observation = row['identity']['observation']
            if row['name'] == 'runtime-summary':
                require(observation == dict(kind='positive-counter-summary', failures=0) and evidence.decode().splitlines()[-1] == 'P08 counter components assertions=1736320 failures=0', 'actual runtime summary')
            else:
                require(observation == dict(kind='exact-line-count', line=row['name'], count=1) and evidence.decode().splitlines().count(row['name']) == 1, 'qualified reuse exact line count')
        else:
            verify_diagnostic(row, expected, read_bytes(driver / expected['log']), read_bytes)
        for source, identity in row['identity'].get('sources', {}).items():
            require(sha(read_bytes(source.replace('${OUT}', str(driver)))) == identity, 'actual per-command source identity')
    for name, identity in artifacts.items():
        require(not Path(name).is_absolute() and '..' not in Path(name).parts, 'artifact canonical relative operand')
        content = read_bytes(driver / name)
        require(dict(bytes=len(content), sha256=sha(content)) == identity, 'artifact bytes/size: ' + name)

def verify_context(root, packet):
    recipe = read(packet / 'recipe.json')
    verify_recipe(recipe)
    prior_packet, prior = load_prior(root, packet, recipe)
    prior_recipe = read(prior_packet / 'recipe.json')
    # Reuse all previously reviewed finite source, discovery, SDK/tool, P07,
    # schema4, producer/control, archive, and historical STOP applicability gates.
    # The erroneous old qualify_counter is never called or edited.
    prior['verify_context'](root, prior_packet, prior_recipe)
    archive = root / recipe['prior_result']
    verify_committed_directory(root, archive, recipe['review_commit'])
    require(git(root, 'merge-base', '--is-ancestor', recipe['archive_commit'], recipe['review_commit']) == b'', 'archive/review ancestry')
    verify_archive(root, archive, prior)
    prior['verify_trees'](read(packet / 'raw-roots.json'))
    driver, wrapper = Path(recipe['driver_root']), Path(recipe['wrapper_root'])
    terminal = read(wrapper / 'terminal.json')
    verify_historical(terminal, read(packet / 'historical-terminal.json'), recipe)
    require(terminal['files'] == prior['tree_entries'](driver) == terminal['observed_new_roots'][driver.name], 'actual wrapper captured driver root')
    for stream in ('stdout', 'stderr'):
        require(sha(actual(wrapper / ('counter384.' + stream))) == terminal['raw_logs'][stream], 'wrapper actual raw stream hash')
    require(actual(wrapper / 'counter384.stdout').decode().splitlines()[-1] == 'P08_COUNTER_EVIDENCE ' + str(driver), 'actual stdout driver operand')
    data = read(driver / 'result.json')
    for path, identity in read(packet / 'source-identities.json').items():
        require(sha(actual(path)) == identity, 'frozen source/invocation input identity')
    identities = read(packet / 'driver-identities.json')
    require(sha(actual((root / identities['compiler']).resolve())) == identities['compiler_sha256'], 'retained compiler identity; never execute')
    for field, receipt_field, root_field in [('runtime_build', 'runtime_receipt_sha256', 'runtime_root'), ('host_build', 'host_receipt_sha256', 'schema4_root')]:
        operand = root / data[field]
        require(str(operand) == recipe[root_field] and sha(actual(operand / 'result.json')) == data[receipt_field], 'actual operand/receipt join')
    verify_collection(data, read(driver / 'checks.json'), read(packet / 'labels.json'), identities, read(packet / 'artifacts.json'), driver)
    require(actual(driver / 'commands.txt').decode().splitlines() == data['commands'], 'actual commands transcript join')
    return dict(status='PASS_retained_macos_static_counter426_only', checks=426,
                partitions=dict(scoped=384, scoped_positive=192, scoped_negative=192, supplemental=2, reuse=13, other=27),
                compiler_negative_exit1=193, native_exclusivity_exit=-6, artifacts=904,
                assertions=1736320, failures=0, driver_result_sha256=sha(actual(driver / 'result.json')),
                checks_sha256=sha(actual(driver / 'checks.json')), historical_wrapper_status='STOP',
                historical_wrapper_terminal_sha256=sha(actual(wrapper / 'terminal.json')),
                historical_initial_launches=1, historical_remaining_initial_launches=0,
                compiler_launches=0, counter_launches=0, schema4_launches=0, repairs=0, retries=0,
                p08_closed=False, r07_closed=False, t8_1_closed=False)
