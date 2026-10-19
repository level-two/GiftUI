"""Filesystem authentication used at campaign11 producer/consumer boundaries."""
from pathlib import Path
import hashlib
import json
import subprocess


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def actual(path):
    path = Path(path)
    require(path.is_absolute() and path.resolve() == path and path.is_file(), 'noncanonical file')
    return path.read_bytes()


def verify_files(root, expected, links=None):
    links = links or {}
    require(set(links) <= set(expected), 'extra frozen link identity')
    for name, identity in expected.items():
        path = Path(root)/name
        if name in links:
            import os
            link = links[name]
            require(path.is_symlink() and os.readlink(path) == link['target'] and str(path.resolve()) == link['resolved'], 'frozen link identity')
            require(sha(path.read_bytes()) == identity == link['sha256'], 'frozen link bytes')
        else:
            require(sha(actual(path)) == identity, 'file identity: ' + name)


def verify_tools(root, identities):
    for name,identity in identities.items():
        path = Path(root)/name
        require(str(path.resolve()) == identity['resolved'], 'tool resolution drift')
        if identity.get('kind') == 'directory':
            require(path.is_dir(), 'tool directory drift')
        else:
            require(path.is_file() and sha(path.read_bytes()) == identity['sha256'], 'tool bytes drift')


def inventory(root, rules):
    result = {}
    for rule in rules:
        base = Path(root) / rule['base']
        paths = base.rglob('*') if rule['recursive'] else base.iterdir()
        for path in paths:
            if path.is_dir() and not path.is_symlink():
                continue
            if rule['suffix'] and not path.name.endswith(rule['suffix']):
                continue
            data = actual(path)
            result[str(path.relative_to(root))] = sha(data)
    return result


def verify_inventory(root, definition):
    require(inventory(root, definition['rules']) == definition['files'], 'producer discovery inventory drift')


def git(root, *args):
    return subprocess.check_output(['git', '--no-replace-objects', *args], cwd=root)


def verify_reviewed_packet(root, packet, commit, tree, packet_tree):
    # IDs are independent launch inputs issued by the review, not packet data.
    for value in (commit, tree, packet_tree):
        require(type(value) is str and len(value) == 40 and all(c in '0123456789abcdef' for c in value), 'external object ID')
    for kind, oid in [('commit',commit),('tree',tree),('tree',packet_tree)]:
        payload = git(root,'cat-file',kind,oid)
        object_bytes = kind.encode()+b' '+str(len(payload)).encode()+b'\0'+payload
        require(hashlib.sha1(object_bytes).hexdigest() == oid, 'Git object bytes')
    require(git(root,'rev-parse','HEAD').decode().strip() == commit, 'reviewed HEAD drift')
    require(git(root,'rev-parse',commit+'^{tree}').decode().strip() == tree, 'reviewed tree join')
    relative = str(Path(packet).relative_to(root))
    require(git(root,'rev-parse',commit+':'+relative).decode().strip() == packet_tree, 'reviewed packet tree join')
    records = git(root,'ls-tree','-rz',packet_tree).split(b'\0')
    expected = {}
    for record in records:
        if not record:
            continue
        header,name = record.split(b'\t',1)
        mode,kind,oid = header.split()
        require(mode in (b'100644',b'100755') and kind == b'blob', 'packet mode/type')
        data = git(root,'cat-file','blob',oid.decode())
        require(hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest() == oid.decode(), 'Git blob object bytes')
        expected[name.decode()] = data
    actual_names = {str(path.relative_to(packet)) for path in Path(packet).rglob('*') if path.is_file() or path.is_symlink()}
    require(actual_names == set(expected), 'reviewed packet inventory')
    for name,data in expected.items():
        require(actual(Path(packet)/name) == data, 'reviewed packet blob: '+name)


def verify_receipt(path, expected_hash, root, input_tools=None):
    """Verify sealed receipt and every artifact, never trusting output-selected identity."""
    path = Path(path)
    payload = actual(path)
    require(sha(payload) == expected_hash, 'receipt identity')
    data = json.loads(payload)
    input_tools = input_tools or {}
    for name, identity in data.get('inputs', {}).items():
        if name in input_tools:
            verify_tools(root, {name: input_tools[name]})
            require(stream_sha(Path(root) / name) == identity, 'aliased input bytes')
        else:
            verify_files(root, {name: identity})
    for field,hash_field in [('compiler','compiler_sha256'),('macro_tool','macro_tool_sha256'),('swift_syntax_library','swift_syntax_sha256')]:
        if field in data:
            tool = Path(root)/data[field]
            require(tool.resolve().is_relative_to(root) and tool.is_file(), 'receipt tool path')
            require(sha(tool.read_bytes()) == data[hash_field], 'receipt tool identity')
    for name,value in data.get('artifacts',{}).items():
        target = path.parent/name
        require(target.is_relative_to(path.parent) and '..' not in Path(name).parts, 'artifact traversal')
        content = actual(target)
        require({'sha256':sha(content),'bytes':len(content)} == value, 'receipt artifact identity')
    return data


def verify_stage_captures(data):
    for stage in data.get('stage_captures', []):
        for stream in ('stdout','stderr'):
            item = stage[stream]
            require(sha(actual(item['path'])) == item['sha256'], 'sealed stage stream drift')
        for path,identity in stage.get('source_provenance',{}).items():
            require(sha(actual(path)) == identity, 'sealed stage source drift')
    for audit in data.get('prelaunch_audits',[]):
        require(sha(actual(audit['path'])) == audit['sha256'], 'sealed prelaunch audit drift')


def stream_sha(path):
    digest = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def tree_entries(base):
    """Discover membership only; every allowable name and identity is frozen."""
    import os
    base = Path(base)
    require(base.is_dir() and base.resolve() == base, 'tree root alias')
    result = {}
    for directory, dirs, files in os.walk(base, followlinks=False):
        for name in dirs + files:
            path = Path(directory) / name
            key = str(path.relative_to(base))
            if path.is_symlink():
                result[key] = dict(kind='symlink', target=os.readlink(path))
            elif path.is_dir():
                result[key] = dict(kind='directory')
            else:
                require(path.is_file(), 'nonregular frozen entry')
                result[key] = dict(kind='file', bytes=path.stat().st_size, sha256=stream_sha(path))
    return result


def verify_trees(definitions):
    for base, expected in definitions.items():
        require(tree_entries(base) == expected, 'sealed tree membership/bytes: ' + base)


def receipt_checks(data, key='pass'):
    checks = data['checks']
    require(checks and len({c['name'] for c in checks}) == len(checks), 'duplicate/empty labels')
    require(all(c[key] is True for c in checks), 'failed check')


def verify_context(root, packet, recipe):
    freeze = json.loads(actual(packet / 'source-freeze.json'))
    verify_files(root, freeze, json.loads(actual(packet / 'frozen-links.json')))
    verify_inventory(root, json.loads(actual(packet / 'source-inventory.json')))
    verify_tools(root, json.loads(actual(packet / 'tools.json')))
    # Full roots include caches and prevent extra imported *.o / *.swiftmodule.
    # SDK roots include links, directories, headers, overlays and module bytes.
    verify_trees(json.loads(actual(packet / 'retained-trees.json')))
    verify_files(root, json.loads(actual(packet / 'retained-files.json')))
    archive_base = packet.parent
    verify_archive(root, archive_base / 'analyzer-abi-continuation-campaign11-result', recipe['campaign_archive'])
    verify_archive(root, archive_base / 'p07-cyclescene-correction-probe1-result', recipe['p07_archive'])
    delta = json.loads(actual(packet / 'source-differences.json'))
    require(git(root, 'merge-base', '--is-ancestor', delta['baseline_commit'], 'HEAD') == b'', 'baseline ancestry')
    require(git(root, 'merge-base', '--is-ancestor', recipe['source_commit'], 'HEAD') == b'', 'correction ancestry')
    require(git(root, 'merge-base', '--is-ancestor', delta['comparison_head'], 'HEAD') == b'', 'comparison HEAD ancestry')
    require(git(root, 'diff', '--name-only', delta['baseline_commit'], delta['comparison_head']).decode().splitlines() == delta['committed_paths'], 'complete committed change inventory')
    baseline = json.loads(actual(Path(delta['baseline_freeze'])))
    differences = {name: dict(before=identity, after=freeze.get(name)) for name, identity in baseline.items() if freeze.get(name) != identity}
    require(differences == delta['freeze_differences'], 'complete baseline difference inventory')
    require(set(differences) == {'Tests/ContractFixtures/SPEC013/RuntimeDerived/Cycle.swift'}, 'unexpected relevant source change')
    corrected = next(iter(differences))
    require(actual(root / corrected) == git(root, 'show', recipe['source_commit'] + ':' + corrected), 'correction commit bytes')
    require(b'@usableFromInline package let show: Bool' in actual(root / corrected), 'corrected field')
    # Dirty work outside the finite invocation input lists is retained as exact
    # discovery bytes. It grants no changed-source applicability by exclusion.
    verify_files(root, delta['excluded_dirty_sha256'])
    for name in delta['excluded_dirty_files']:
        require(name not in freeze, 'dirty file enters relevant invocation')
    campaign_root = Path(recipe['campaign_root'])
    campaign = json.loads(actual(campaign_root / 'result.json'))
    require(campaign['status'] == 'STOP_first_material_failure_dependents_unrun_no_retry_zero_repairs', 'historical STOP changed')
    require(campaign['retries'] == campaign['automatic_repairs'] == 0, 'historical bounds')
    require(campaign['stages'][-1]['name'] == 'P07' and campaign['stages'][-1]['exit'] == 1, 'historical terminal P07')
    core_refs = {}
    require(len(campaign['producer_receipts']) == 8, 'eight producer gate')
    for item in campaign['producer_receipts']:
        data = verify_receipt(item['path'], item['sha256'], root)
        require(actual(item['copy']) == actual(item['path']), 'producer copy join')
        require(data['package'] in ('P02', 'P04'), 'producer package')
        require(data['source_commit'] == campaign['authenticated_current_commit'], 'historical producer commit')
        if data['package'] == 'P02':
            core_refs[data['profile']] = item
    require(len(core_refs) == 4, 'four core profiles')
    require(len(campaign['control_receipts']) == 80, '80 controls gate')
    seen = set()
    for item in campaign['control_receipts']:
        identity = (item['profile'], item['control'])
        require(identity not in seen, 'duplicate historical control')
        seen.add(identity)
        data = verify_receipt(item['path'], item['sha256'], root)
        verify_stage_captures(data)
        require(data['passed'] is True and (data['profile'], data['control']) == identity, 'control classification')
        core = core_refs[item['profile']]
        require(data['core_receipt_sha256'] == core['sha256'], 'control core digest')
        require(data['transitive_imports']['core'] == dict(path=core['path'], sha256=core['sha256']), 'transitive core join')
        verify_files(Path(data['positive_cell']), data['transitive_imports']['positive_scratch'])
    expected = json.loads(actual(packet / 'control-classifications.json'))
    actual_classes = [{**item, 'category': json.loads(actual(item['path']))['category']} for item in campaign['control_receipts']]
    require(actual_classes == expected, 'classification inventory')
    for profile in core_refs:
        require(sum(p == profile for p, _ in seen) == 20, 'profile control count')
    macro = next(s for s in campaign['stages'] if s['name'] == 'macro-tests')
    require(macro['exit'] == 0, 'macro exit')
    for stage in campaign['stages']:
        for stream in ('stdout', 'stderr'):
            require(stream_sha(campaign_root / 'logs' / (stage['name'] + '.' + stream)) == stage[stream + '_sha256'], 'first-stage raw stream')
    macro_text = actual(campaign_root / 'logs/macro-tests.stdout').decode()
    require(macro_text.strip() == 'executions=19 failures=0 skips=0', 'macro 19/0/0 transcript')
    require(macro_text == json.loads(actual(packet / 'macro-result.json'))['stdout'], 'macro 19/0/0 exact transcript')
    terminal = json.loads(actual(recipe['p07_terminal']))
    require(terminal['status'] == 'PASS_isolated_P07_only_no_dependent_release', 'isolated terminal')
    require(terminal['exit'] == terminal['retries'] == terminal['automatic_repairs'] == 0 and terminal['source_candidates'] == 1, 'isolated bounds')
    require(terminal['driver_output_root'] == recipe['p07_root'], 'isolated root join')
    verify_files(Path(recipe['p07_root']), terminal['driver_files'])
    p07 = verify_receipt(Path(recipe['p07_root']) / 'result.json', terminal['driver_files']['result.json'], root, json.loads(actual(packet / 'tools.json')))
    receipt_checks(p07)
    require(len(p07['checks']) == 33 and p07['execution'] == 'P07 values assertions=5904 failures=0', 'isolated terminal result')
    require(p07['profile'] == 'macos-static' and p07['package'] == 'P07', 'isolated profile')
    require(p07['core_receipt_sha256'] == core_refs['macos-static']['sha256'], 'isolated core provenance')
    require(str(root / p07['core_receipt']) == core_refs['macos-static']['path'], 'isolated core operand')
    require(recipe['source_candidates'] == 1 and recipe['retries'] == recipe['automatic_repairs'] == 0, 'new packet bounds')


def qualify_schema4(root, runtime, out, input_tools=None):
    data = json.loads(actual(out / 'result.json'))
    data = verify_receipt(out / 'result.json', sha(actual(out / 'result.json')), root, input_tools)
    receipt_checks(data, 'passed')
    required = {'activation-join', 'activation-copy', 'activation-callback', 'activation-constant-callback', 'activation-backing', 'execute'}
    require(required <= {c['name'] for c in data['checks']}, 'complete activation joins')
    require(data['profile'] == 'macos-static' and root / data['runtime_build'] == runtime, 'schema runtime operand')
    require(data['runtime_receipt_sha256'] == sha(actual(runtime / 'result.json')), 'schema runtime receipt')
    require('failures=0' in data['execution'], 'schema execution')
    return data


def qualify_counter(root, runtime, host, out, input_tools=None):
    data = verify_receipt(out / 'result.json', sha(actual(out / 'result.json')), root, input_tools)
    require(data['collection_complete'] is True and data['passed'] is True and data['fresh_focused'] is False, 'counter aggregate gate')
    require(data['profile'] == data['selected_host_profile'] == 'macos-static', 'counter profile')
    require(root / data['runtime_build'] == runtime and root / data['host_build'] == host, 'counter dependency operands')
    require(data['runtime_receipt_sha256'] == sha(actual(runtime / 'result.json')) and data['host_receipt_sha256'] == sha(actual(host / 'result.json')), 'counter dependency receipts')
    labels = [c['name'] for c in data['checks']]
    require(len(labels) == len(set(labels)) == 384, 'exact 384 unique labels')
    # Collector uses status for aggregate checks, not schema4's passed Boolean.
    require(all(c.get('passed') is True for c in data['checks']), 'counter labels failed')
    return data


def verify_archive(root, directory, commit):
    require(len(commit) == 40 and all(c in '0123456789abcdef' for c in commit), 'finite archive commit')
    payload = git(root, 'cat-file', 'commit', commit)
    require(hashlib.sha1(b'commit '+str(len(payload)).encode()+b'\0'+payload).hexdigest() == commit, 'archive commit object')
    require(git(root, 'merge-base', '--is-ancestor', commit, 'HEAD') == b'', 'archive ancestry')
    relative = str(directory.relative_to(root))
    expected = set()
    for record in git(root, 'ls-tree', '-rz', commit+':'+relative).split(b'\0'):
        if not record: continue
        header, name = record.split(b'\t',1)
        mode, kind, oid = header.split()
        require(mode in (b'100644', b'100755') and kind == b'blob', 'archive Git entry')
        content = actual(directory / name.decode())
        require(hashlib.sha1(b'blob '+str(len(content)).encode()+b'\0'+content).hexdigest() == oid.decode(), 'archived byte identity')
        expected.add(name.decode())
    require({str(p.relative_to(directory)) for p in directory.rglob('*') if p.is_file() or p.is_symlink()} == expected, 'archive membership')
