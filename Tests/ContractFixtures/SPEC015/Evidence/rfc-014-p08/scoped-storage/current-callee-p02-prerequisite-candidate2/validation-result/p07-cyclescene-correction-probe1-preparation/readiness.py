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


def verify_receipt(path, expected_hash, root):
    """Verify sealed receipt and every artifact, never trusting output-selected identity."""
    path = Path(path)
    payload = actual(path)
    require(sha(payload) == expected_hash, 'receipt identity')
    data = json.loads(payload)
    verify_files(root, data.get('inputs', {}))
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



def verify_context(root, packet, recipe):
    """Compiler-free complete immutable-input and authenticated retained-core checks."""
    require(git(root, 'merge-base', '--is-ancestor', recipe['source_commit'], 'HEAD') == b'', 'source correction ancestry')
    correction = 'Tests/ContractFixtures/SPEC013/RuntimeDerived/Cycle.swift'
    require(actual(root / correction) == git(root, 'show', recipe['source_commit'] + ':' + correction), 'correction commit source')
    require(b'@usableFromInline package let show: Bool' in actual(root / correction), 'corrected declaration')
    verify_files(root, json.loads(actual(packet / 'source-freeze.json')), json.loads(actual(packet / 'frozen-links.json')))
    verify_inventory(root, json.loads(actual(packet / 'source-inventory.json')))
    verify_tools(root, json.loads(actual(packet / 'tools.json')))
    campaign = json.loads(actual(recipe['campaign_result']))
    require(sha(actual(recipe['campaign_result'])) == recipe['campaign_result_sha256'], 'campaign result identity')
    require(campaign['status'] == 'STOP_first_material_failure_dependents_unrun_no_retry_zero_repairs', 'campaign terminal status')
    require(campaign['producer_receipts'][0] == recipe['producer'], 'producer index provenance')
    stage = next(s for s in campaign['stages'] if s['name'] == 'P07')
    require(stage['exit'] == 1 and stage['argv'] == recipe['argv'] and stage['environment_overrides'] == recipe['environment_overrides'], 'exact stopped recipe')
    prod = recipe['producer']
    require(sha(actual(prod['copy'])) == prod['sha256'], 'retained receipt copy')
    core = verify_receipt(prod['path'], prod['sha256'], root)
    require(core['package'] == 'P02' and core['profile'] == 'macos-static', 'retained core profile')
    require(sha(actual(Path(prod['path']).parent / 'commands.txt')) == recipe['core_commands_sha256'], 'core recipe identity')
    require(recipe['argv'] == ['python3', 'scripts/contracts/check-spec-013-runtime-cycle.py', '--profile', 'macos-static', '--giftui-build', str(Path(prod['path']).parent)], 'exact core operand')
    require(recipe['source_candidates'] == 1 and recipe['retries'] == recipe['automatic_repairs'] == 0, 'bounded allowance')
