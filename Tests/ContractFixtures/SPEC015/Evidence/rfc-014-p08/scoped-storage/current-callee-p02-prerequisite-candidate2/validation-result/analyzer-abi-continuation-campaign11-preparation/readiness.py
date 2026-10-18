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


def verify_files(root, expected):
    for name, identity in expected.items():
        require(sha(actual(Path(root) / name)) == identity, 'file identity: ' + name)


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
    return subprocess.check_output(['git', *args], cwd=root)


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
        expected[name.decode()] = git(root,'cat-file','blob',oid.decode())
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
