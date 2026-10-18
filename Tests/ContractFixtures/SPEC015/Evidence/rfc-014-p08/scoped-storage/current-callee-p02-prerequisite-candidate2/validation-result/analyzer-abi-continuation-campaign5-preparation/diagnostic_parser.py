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


A7_POLICY = {'id': 'macos-static-negative-A7-AnalyzerPresentation-display-only-v1',
 'profile': 'macos-static',
 'module': 'AnalyzerPresentation',
 'control_id': 'negative-A7',
 'kind': 'abi-negative',
 'category': 'serialized-ABI-access',
 'remove_only': 'A7',
 'required_symbol': 'model',
 'input_sha256': '3e3429824b630c383408b3a9d8cf9bca4b614f19ac61fa333a2b6eb5c8521dd2',
 'primary_message': "property 'model' is package and cannot be referenced from an '@inlinable' "
                    'function',
 'primaries': [{'line': 21,
                'column': 42,
                'source': '        let state = (try AnalyzerRead<D>(model, read: read)).state()'},
               {'line': 23,
                'column': 56,
                'source': '        Text<D>(BoundedText(Int32((try AnalyzerRead<D>(model, read: '
                          'read)).state().capture().count)))'},
               {'line': 24,
                'column': 33,
                'source': '        if (try AnalyzerRead<D>(model, read: '
                          'read)).state().capture().count > 0 {'},
               {'line': 25,
                'column': 64,
                'source': '            Text<D>(BoundedText(Int32(try (try AnalyzerRead<D>(model, '
                          'read: '
                          'read)).state().capture().transition(index).channelID.rawValue)))'}],
 'excerpt_line': 11,
 'excerpt_text': '    package let model:_GiftUIModelKey<AnalyzerModelSchema>',
 'gutter': "   |                 `- note: property 'model' is not '@usableFromInline' or public",
 'maximum_per_primary': 1,
 'required_stream': 'stderr',
 'required_primary_count': 4}


A8_POLICY = {'id': 'macos-static-negative-A8-AnalyzerPresentation-display-only-v1',
 'profile': 'macos-static',
 'module': 'AnalyzerPresentation',
 'control_id': 'negative-A8',
 'kind': 'abi-negative',
 'category': 'serialized-ABI-access',
 'remove_only': 'A8',
 'required_symbol': 'index',
 'input_sha256': '1085b6e5c6126cc31dabf25b65234143fb2292400b4fd45e6d6246e3d8879b1c',
 'primary_message': "property 'index' is package and cannot be referenced from "
                    "an '@inlinable' function",
 'primaries': [{'line': 25,
                'column': 113,
                'source': '            Text<D>(BoundedText(Int32(try (try '
                          'AnalyzerRead<D>(model, read: '
                          'read)).state().capture().transition(index).channelID.rawValue)))'}],
 'excerpt_line': 13,
 'excerpt_text': '    package let index: Int',
 'gutter': "   |                 `- note: property 'index' is not "
           "'@usableFromInline' or public",
 'maximum_per_primary': 1,
 'required_stream': 'stderr',
 'required_primary_count': 1}

A8_CONTROL_FIELDS = {'category': 'serialized-ABI-access',
 'diagnostic_rules': 'diagnostic at the dependency use/declaration with '
                     '@usableFromInline or @inlinable ABI/access restriction; '
                     'unrelated compile failure is failure',
 'expected_nonzero': True,
 'files': ['negative-A8/Analyzer.swift'],
 'first_expected_stage': 'AnalyzerPresentation',
 'id': 'negative-A8',
 'inherit': 'positive copies for every other input; isolated module/cache '
            'directory; regenerate via actual lowerer, never patch generated '
            'output',
 'kind': 'abi-negative',
 'later_stages': 'unrun after expected first diagnostic',
 'primary_message_patterns_all': ['(?i)@(?:usableFromInline|inlinable)',
                                  '(?i)(?:cannot be referenced from|must be '
                                  '[\'"]?@usableFromInline[\'"]? or public|is '
                                  'not [\'"]?@usableFromInline[\'"]? or '
                                  'public)'],
 'remove_only': 'A8',
 'required_symbol': 'index'}


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
    if control.get('display_only_note', {}).get('policy_id') == A8_POLICY['id']:
        assert list(map(str, dependency_paths)) == [expected_path.rsplit('/', 1)[0] + '/inputs/Analyzer.swift'], 'A8 declared dependency paths mismatch'
        assert control == dict(A8_CONTROL_FIELDS,
                               diagnostic_source=expected_path,
                               dependency_note_sources=list(map(str, dependency_paths)),
                               display_only_note={'policy_id': A8_POLICY['id'],
                                                  'source_path': expected_path,
                                                  'input_sha256': A8_POLICY['input_sha256']}), 'A8 control fields mismatch'
        assert context == {'profile': A8_POLICY['profile'], 'module': A8_POLICY['module']}, 'A8 context mismatch'

    header = re.compile(r'^(.*?):([1-9][0-9]*):([1-9][0-9]*): (error|note|warning|remark): (.*)$')
    source_line = re.compile(r'^\s*([0-9]+)\s*\| ?(.*)$')
    gutter = re.compile(r'^\s*\|.*?\b(error|note|warning):\s*(.*)$')
    malformed_located = re.compile(
        r'^.*?:[0-9]+:[0-9]+:\s*(?:fatal\s+error|error|note|warning|remark)\b',
        re.IGNORECASE)
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
                    if control.get('display_only_note', {}).get('policy_id') == A8_POLICY['id']:
                        raise AssertionError(('A8 forbids located warning/remark', severity, line))
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
                opt_in = control.get('display_only_note')
                policy = next((p for p in (A4_POLICY, A7_POLICY, A8_POLICY) if isinstance(opt_in, dict) and opt_in.get('policy_id') == p['id']), A4_POLICY)
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
                if policy is A7_POLICY or policy is A8_POLICY:
                    assert stream_name == policy['required_stream'], 'A7 display stream mismatch'
                    choices = policy['primaries']
                else:
                    choices = [{'line': policy['primary_line'], 'column': policy['primary_column'], 'source': policy['primary_source']}]
                primary_policy = next((p for p in choices if (section['line'], section['column']) == (p['line'], p['column'])), None)
                assert primary_policy is not None and section['file'] == expected_path and section['message'] == policy['primary_message'], 'display policy primary mismatch'
                assert excerpt is not None and (excerpt['line'], excerpt['text']) == (
                    policy['excerpt_line'], policy['excerpt_text']), 'display excerpt identity mismatch'
                if policy is A7_POLICY or policy is A8_POLICY:
                    assert excerpt['raw'] == str(policy['excerpt_line']) + ' | ' + policy['excerpt_text'], 'display raw excerpt mismatch'
                assert line == policy['gutter'], 'display gutter bytes mismatch'
                assert len(current['display_notes']) < policy['maximum_per_primary'], 'duplicate display note'
                assert trusted_input is not None and trusted_input['path'] == expected_path, 'trusted input path mismatch'
                source_bytes = trusted_input['bytes']
                assert type(source_bytes) is bytes, 'trusted input must contain bytes'
                assert hashlib.sha256(source_bytes).hexdigest() == policy['input_sha256'], 'trusted input hash mismatch'
                source_rows = source_bytes.decode('utf-8').splitlines()
                assert source_rows[policy['excerpt_line'] - 1] == excerpt['text'], 'display row differs from frozen source'
                assert source_rows[primary_policy['line'] - 1] == primary_policy['source'], 'primary row differs from frozen source'
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
            if malformed_located.match(line):
                raise AssertionError(('malformed located diagnostic record', line))
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
            policy = next((p for p in (A4_POLICY, A7_POLICY, A8_POLICY) if control.get('display_only_note', {}).get('policy_id') == p['id']), A4_POLICY)
            choices = policy['primaries'] if policy is A7_POLICY or policy is A8_POLICY else [{'line': policy['primary_line'], 'column': policy['primary_column'], 'source': policy['primary_source']}]
            target = next(p for p in choices if (primary['line'], primary['column']) == (p['line'], p['column']))
            assert primary['source'] == [target['source']], 'display primary target evidence mismatch'
    if control.get('display_only_note', {}).get('policy_id') == A7_POLICY['id']:
        assert len(records) == A7_POLICY['required_primary_count'], 'A7 primary count mismatch'
        assert [(r['primary']['line'], r['primary']['column']) for r in records] == [(p['line'], p['column']) for p in A7_POLICY['primaries']], 'A7 primary order/location mismatch'
        assert all(len(r['display_notes']) == 1 and r['notes'] == [] for r in records), 'A7 display inventory mismatch'
    if control.get('display_only_note', {}).get('policy_id') == A8_POLICY['id']:
        assert len(records) == A8_POLICY['required_primary_count'], 'A8 primary count mismatch'
        assert [(r['primary']['line'], r['primary']['column']) for r in records] == [(p['line'], p['column']) for p in A8_POLICY['primaries']], 'A8 primary order/location mismatch'
        assert all(len(r['display_notes']) == 1 and r['notes'] == [] for r in records), 'A8 display inventory mismatch'
    return records
