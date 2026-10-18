"""Pure static diagnostic policy candidate. No filesystem, process or campaign API.

Trusted input bytes and exact resolved paths are supplied by the packet caller;
diagnostic output never selects a file to read. Importing this module runs no
classification. Assertions require an interpreter without optimization.
"""
import hashlib
import re


A4_POLICY = {
    'id': 'macos-static-negative-A4-SignalAnalyzerDomain-display-only-v1',
    'profile': 'macos-static',
    'module': 'SignalAnalyzerDomain',
    'control_id': 'negative-A4',
    'kind': 'abi-negative',
    'category': 'serialized-ABI-access',
    'remove_only': 'A4',
    'required_symbol': 'SignalChannelID',
    'input_sha256': '9c19b9df952323041e6b0f4e7bce3bcfe73d3557af2e40c47719c19e55993e1d',
    'primary_line': 22,
    'primary_column': 17,
    'primary_message': "type referenced from a '@usableFromInline' property must be '@usableFromInline' or public",
    'primary_source': '    package let channelID: SignalChannelID',
    'excerpt_line': 1,
    'excerpt_text': 'package struct SignalChannelID: Hashable, Sendable {',
    'gutter': '   |                `- note: type declared here',
    'maximum_per_primary': 1,
}


def classify_negative_diagnostics(control, exit_code, stdout, stderr,
                                  expected_path, dependency_paths, *,
                                  context=None, trusted_input=None):
    """Every located primary independently qualifies; display notes add no evidence.

    Optional context is {profile, module}; trusted_input is {path, bytes}.
    Both come from predeclared packet metadata, never from parsed diagnostics.
    Without the exact opt-in all historical strict gutter rules still apply.
    """
    assert type(exit_code) is int and exit_code == 1, ('non-diagnostic exit', exit_code)
    expected_path = str(expected_path)
    allowed_notes = {expected_path, *map(str, dependency_paths)}
    header = re.compile(r'^(.*?):([1-9][0-9]*):([1-9][0-9]*): (error|note|warning|remark): (.*)$')
    source_line = re.compile(r'^\s*([0-9]+)\s*\| ?(.*)$')
    gutter = re.compile(r'^\s*\|.*?\b(error|note|warning):\s*(.*)$')
    diagnostic_like = re.compile(r'\b(?:fatal\s+error|error|note|warning|remark)\s*:', re.IGNORECASE)
    crash = re.compile(
        r'(?im)^.*(?:Stack dump:|Stack trace:|Please submit a bug report|'
        r'LLVM ERROR:|Assertion failed:|Segmentation fault|Illegal instruction|'
        r'Bus error|Abort trap|fatal error:|compiler crashed|failed due to signal|'
        r'command failed with signal).*$')
    # Scan both complete streams before parsing either one.
    for stream in (stdout, stderr):
        assert not crash.search(stream), 'crash/fatal marker in diagnostic output'
    records = []
    for stream_name, stream in (('stdout', stdout), ('stderr', stderr)):
        current = section = previous_excerpt = None
        for line in stream.splitlines():
            match = header.fullmatch(line)
            if match:
                previous_excerpt = None
                path, number, column, severity, message = match.groups()
                item = {'file': path, 'line': int(number), 'column': int(column),
                        'severity': severity, 'message': message, 'source': []}
                if severity == 'error':
                    assert path == expected_path, ('primary error in wrong file', path)
                    current = {'primary': item, 'notes': [], 'display_notes': []}
                    records.append(current)
                    section = item
                elif severity == 'note':
                    assert current is not None, 'orphan note has no associated primary'
                    assert path in allowed_notes, ('note outside declared dependency files', path)
                    current['notes'].append(item)
                    section = item
                else:
                    current = section = None
                continue
            match = source_line.fullmatch(line)
            if match:
                previous_excerpt = None
                if section is not None:
                    previous_excerpt = {'line': int(match.group(1)),
                                        'text': match.group(2), 'raw': line}
                    if previous_excerpt['line'] == section['line']:
                        section['source'].append(match.group(2))
                continue
            match = gutter.fullmatch(line)
            if match:
                excerpt = previous_excerpt
                previous_excerpt = None
                if (section is not None and match.group(1) == section['severity']
                        and match.group(2) == section['message']):
                    continue
                policy = A4_POLICY
                opt_in = control.get('display_only_note')
                assert opt_in == {'policy_id': policy['id'],
                                  'source_path': expected_path,
                                  'input_sha256': policy['input_sha256']}, (
                    'gutter is not an exact repeat or declared display-only form', line)
                assert context == {'profile': policy['profile'], 'module': policy['module']}, 'display policy context mismatch'
                for key in ('kind', 'category', 'remove_only', 'required_symbol'):
                    assert control.get(key) == policy[key], ('display policy control mismatch', key)
                assert control.get('id') == policy['control_id'], 'display policy control ID mismatch'
                assert control.get('first_expected_stage') == policy['module'], 'display policy module mismatch'
                assert current is not None and section is current['primary'], 'display note outside active primary'
                assert (section['file'], section['line'], section['column'], section['message']) == (
                    expected_path, policy['primary_line'], policy['primary_column'], policy['primary_message']), 'display policy primary mismatch'
                assert excerpt is not None and (excerpt['line'], excerpt['text']) == (
                    policy['excerpt_line'], policy['excerpt_text']), 'display excerpt identity mismatch'
                assert line == policy['gutter'], 'display gutter bytes mismatch'
                assert len(current['display_notes']) < policy['maximum_per_primary'], 'duplicate display note'
                assert trusted_input is not None and trusted_input['path'] == expected_path, 'trusted input path mismatch'
                source_bytes = trusted_input['bytes']
                assert type(source_bytes) is bytes, 'trusted input must contain bytes'
                assert hashlib.sha256(source_bytes).hexdigest() == policy['input_sha256'], 'trusted input hash mismatch'
                source_rows = source_bytes.decode('utf-8').splitlines()
                assert source_rows[policy['excerpt_line'] - 1] == excerpt['text'], 'display row differs from frozen source'
                assert source_rows[policy['primary_line'] - 1] == policy['primary_source'], 'primary row differs from frozen source'
                current['display_notes'].append({
                    'stream': stream_name,
                    'enclosing_primary': {key: section[key] for key in ('file', 'line', 'column', 'severity', 'message')},
                    'excerpt': excerpt,
                    'raw_gutter': line,
                    'declared_source_path': expected_path,
                    'input_sha256': policy['input_sha256'],
                    'has_located_note_header': False,
                    'contributes_dependency_evidence': False,
                })
                # Do not change section/current or append to primary source/notes.
                continue
            previous_excerpt = None
            if diagnostic_like.search(line):
                raise AssertionError(('unlocated/unparsed diagnostic record', line))
    assert records, 'no located primary Swift errors'
    symbol = control['required_symbol']
    symbol_pattern = r'\b' + re.escape(symbol) + r'\b'
    for record in records:
        primary = record['primary']
        message = primary['message']
        assert all(re.search(pattern, message) for pattern in control['primary_message_patterns_all']), (
            'unrelated primary error/category', message)
        if control['category'] == 'serialized-ABI-access':
            names = re.findall(r"\b(?:struct|enum|class|type|property|getter|setter|method|initializer|function) '([^']+)'", message)
            assert all(name == symbol for name in names), ('different named ABI dependency', names)
            evidence = '\n'.join([message, *primary['source'], *[
                part for note in record['notes'] for part in [note['message'], *note['source']]]])
            assert re.search(symbol_pattern, evidence), ('primary lacks declared ABI dependency', symbol)
        else:
            evidence = message
            assert re.search(symbol_pattern, message), ('primary does not name declared dependency', symbol)
        # Audit the actual evidence used above, without display context.
        record['dependency_evidence'] = evidence
        if record['display_notes']:
            assert primary['source'] == [A4_POLICY['primary_source']], 'display primary target evidence mismatch'
    return records
