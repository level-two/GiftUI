"""Pure static diagnostic policy candidate. No filesystem, process or campaign API.

Trusted input bytes and exact resolved paths are supplied by the packet caller;
diagnostic output never selects a file to read. Importing this module runs no
classification. Assertions require an interpreter without optimization.
"""
import hashlib
import json
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


def _classify_historical_diagnostics(control, exit_code, stdout, stderr,
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


PRIVATE_STORAGE_POLICY = {'artifacts': {'domain_primitives': {'bytes': 1582, 'path': '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/inputs/SignalPrimitiveValues.swift', 'sha256': '421b32bb5ceafe40ffd41322650f8c4f905854525a9880f63c5c2bcada69373c'}, 'domain_source': {'bytes': 5671, 'path': '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/inputs/SignalAnalyzerDiagnostic.swift', 'sha256': '47c39490cf20470b653eacbc29473ce5f936e0d80111d42dec6e4942016458a7'}, 'domain_state': {'bytes': 243, 'path': '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/inputs/AcquisitionState.swift', 'sha256': 'c55975c2b7414eba721b7493300bdd47cdc32e2eb4e4023d1a70840457ab8425'}, 'imported_module': {'bytes': 47984, 'path': '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/SignalAnalyzerDomain.swiftmodule', 'role': 'observed-archive-provenance-only-not-active-hash-authority', 'sha256': '5cabd13f4e2b7a0ed2edb77f6cf21ecd46110cb96ab94c01b4165c78bbd32798'}}, 'campaign_root': '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5', 'client_sha256': '85376a27c29aa8f160bb38b73d316418b66d04f36bbc3719191cdf013615edaf', 'consumer': {'argv': ['/Users/eugene/work/GiftUI/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc', '-swift-version', '6', '-Osize', '-whole-module-optimization', '-enable-experimental-feature', 'LifetimeDependence', '-enable-experimental-feature', 'Lifetimes', '-package-name', 'giftui', '-module-cache-path', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/private-storage/cache', '-disable-sandbox', '-target', 'arm64-apple-macosx26.0', '-sdk', '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk', '-load-plugin-executable', '/Users/eugene/work/GiftUI/.build/rfc014-p02-swift64/tool/debug/GiftUIMacros-tool#GiftUIMacros', '-I', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering', '-I', '/Users/eugene/work/GiftUI/.build/contracts/spec-006-rfc-014-swift64/a8afb49da68a64d7-tcop19de/macos-static', '-parse-as-library', '-emit-object', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/private-storage/inputs/private-storage.swift', '-o', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/private-storage/negative.o'], 'environment_overrides': {'PYTHONDONTWRITEBYTECODE': '1'}, 'exit': 1, 'name': 'macos-static-private-storage-client-emit-object'}, 'context': {'module': 'SignalAnalyzerDomain', 'profile': 'macos-static', 'stage': 'client-emit-object'}, 'dependency_paths': ['/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/inputs/SignalAnalyzerDiagnostic.swift'], 'id': 'macos-static-private-storage-client-emit-object-virtual-display-v1', 'primary_block': "/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/private-storage/inputs/private-storage.swift:2:62: error: 'storage' is inaccessible due to 'private' protection level\n1 | import SignalAnalyzerDomain\n2 | package func rejected(_ d: SignalAnalyzerDiagnostic) { _ = d.storage }\n  |                                                              `- error: 'storage' is inaccessible due to 'private' protection level\n3 | \n\n", 'primary_column': 62, 'primary_line': 2, 'primary_message': "'storage' is inaccessible due to 'private' protection level", 'primary_path': '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/private-storage/inputs/private-storage.swift', 'primary_source': 'package func rejected(_ d: SignalAnalyzerDiagnostic) { _ = d.storage }', 'primary_suffix': '/macos-static/scratch/private-storage/inputs/private-storage.swift', 'producer': {'argv': ['/Users/eugene/work/GiftUI/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc', '-swift-version', '6', '-Osize', '-whole-module-optimization', '-enable-experimental-feature', 'LifetimeDependence', '-enable-experimental-feature', 'Lifetimes', '-package-name', 'giftui', '-module-cache-path', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/cache', '-disable-sandbox', '-target', 'arm64-apple-macosx26.0', '-sdk', '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk', '-load-plugin-executable', '/Users/eugene/work/GiftUI/.build/rfc014-p02-swift64/tool/debug/GiftUIMacros-tool#GiftUIMacros', '-I', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering', '-I', '/Users/eugene/work/GiftUI/.build/contracts/spec-006-rfc-014-swift64/a8afb49da68a64d7-tcop19de/macos-static', '-parse-as-library', '-module-name', 'SignalAnalyzerDomain', '-emit-module', '-emit-object', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/inputs/SignalPrimitiveValues.swift', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/inputs/AcquisitionState.swift', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/inputs/SignalAnalyzerDiagnostic.swift', '-emit-module-path', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/SignalAnalyzerDomain.swiftmodule', '-o', '/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/SignalAnalyzerDomain.o'], 'environment_overrides': {'PYTHONDONTWRITEBYTECODE': '1'}, 'exit': 0, 'name': 'macos-static-positive-actual-lowering-SignalAnalyzerDomain'}, 'virtual_block': "SignalAnalyzerDomain.SignalAnalyzerDiagnostic.storage:2:13: note: 'storage' declared here\n1 | struct SignalAnalyzerDiagnostic {\n2 | private var storage: SignalAnalyzerDomain.SignalAnalyzerDiagnosticStorage}\n  |             `- note: 'storage' declared here\n3 | \n", 'virtual_column': 13, 'virtual_label': 'SignalAnalyzerDomain.SignalAnalyzerDiagnostic.storage', 'virtual_line': 2, 'virtual_message': "'storage' declared here", 'core_policy': {'archived_root': '/Users/eugene/work/GiftUI/.build/contracts/spec-006-rfc-014-swift64/a8afb49da68a64d7-tcop19de/macos-static', 'parent': '/Users/eugene/work/GiftUI/.build/contracts/spec-006-rfc-014-swift64', 'profile_leaf': 'macos-static', 'receipt_leaf': 'result.json', 'artifact_leaf': 'GiftUI.swiftmodule', 'receipt_fields': {'package': 'P02', 'profile': 'macos-static', 'compiler': '.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc', 'compiler_sha256': '79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69', 'input_sha256': 'a8afb49da68a64d7968f6da072b705d887292dcf68a63594ba93653a448c7f8c', 'inputs': {'Package.resolved': 'e8bac048051bf38b3d064110cb165689b83d9e23c469d575a7e549b2d68efb00', 'Package.swift': '56ec87fe0f47ed4cd93900f4a9d6ee46db079e7ecb55979e07658c29812797bd', 'Sources/GiftUI/ActionHandler.swift': 'd36a53f45d18892c235c02355cbed0e6bf92a20b7c64bc7e84ac39a03fa34d01', 'Sources/GiftUI/BoundedText.swift': 'ff468d5e3f17bd2fa05a027a3d487a1db81b4639b60981fd91db3d91f93f68ce', 'Sources/GiftUI/Button.swift': 'bfef4dd797058b7c9c96e650f86ab9c068dffa5703200388c17631ad451af354', 'Sources/GiftUI/Canvas.swift': '2d71ef1d9bd7947fc358e5c286cebe79d51312cabdfe13d777da881432c3f91f', 'Sources/GiftUI/Color.swift': '60009e3d58dcdfe65ba39bf6d036047207707837d73db308a5a25e81fc2ee835', 'Sources/GiftUI/DeclarativeView.swift': '1451f910208735955fe7f188800d639f024ac1cb75fdb7dd49c5a3d835672c24', 'Sources/GiftUI/Disabled.swift': 'db9726d9b26fdf2c08b781791acc97a3d9359e148594f0291b0e66661524b755', 'Sources/GiftUI/DrawingStyles.swift': 'eb28147b2dd565006f9d6b97c7b98e5bcfc52f42e19ebfae1dad1f79b08d130a', 'Sources/GiftUI/DrawingSurface.swift': '185607ede17d3eb8e655e1dc7e24a60fba22225028f1b1ae25a470355daa7a48', 'Sources/GiftUI/GiftUI.swift': 'aef4b66eeec863c29068d1054535401707604f71eda3f740fc7e581b3066d6c6', 'Sources/GiftUI/LayoutContainers.swift': '5157a2cc20100ec15885d10d0da528202623901d885f6345d7dab89d07d49d20', 'Sources/GiftUI/LayoutModifiers.swift': '9df7df30a339bf4f6077581b108c855505ed6230d55d23e9fc55651f4fba877b', 'Sources/GiftUI/LayoutValues.swift': '70c7b34276f6f2d41382d14ee844fcf65d92c075f7caa0a12e79d17181c817f5', 'Sources/GiftUI/ObservableState.swift': '0b293757d79cfa7b5c5e78fe06b2d1897b592f0ef6938cc9b75791dd5126d3e7', 'Sources/GiftUI/StyleModifiers.swift': 'e0ddb0ff8d5edbcd9c737483abdf1c79e71f36770e09a440940d3cf5af8153aa', 'Sources/GiftUI/Text.swift': '5461073a644fa488103b5d6306647b9b4db3f332d421f64735100eba7b8b0efd', 'Sources/GiftUIMacros/CanvasWitnessLowering.swift': '735e4e9388a7d64f634975c8b46202335f94c1a8008afdc5b3fa2bc6356d22ba', 'Sources/GiftUIMacros/FiniteSourceLowering.swift': '1873e5f07d48ea3caeda3fa906e3b0936ca33d975db3813207c2603ce8a77a07', 'Sources/GiftUIMacros/GiftUIMacros.swift': 'db3c0786628995ad46879bb1af674eb94c1fb9fe33c8d702632ed9588f46161b', 'Sources/GiftUIMacros/ObservableStateHostMacro.swift': '1b1a0e91b1694c11ec02e56af35ee861decec7b4662a0a0eca65e51029e0ad3d', 'Sources/SignalAnalyzerDomain/AcquisitionState.swift': 'c55975c2b7414eba721b7493300bdd47cdc32e2eb4e4023d1a70840457ab8425', 'Sources/SignalAnalyzerDomain/ModuleBoundary.swift': '837099cf3d38228e94c4be34dc1cbca3d67b4e62f64a05862843e94186c08293', 'Sources/SignalAnalyzerDomain/SignalAcquisitionContracts.swift': '121a62d4a13b2da15865309dfb3e2e17ca90534c9fc0416521730c5a65201fa9', 'Sources/SignalAnalyzerDomain/SignalAnalyzerDiagnostic.swift': '47c39490cf20470b653eacbc29473ce5f936e0d80111d42dec6e4942016458a7', 'Sources/SignalAnalyzerDomain/SignalCaptureChange.swift': '22b797e24c32d8f4054e22ef2756b056c3d3601d061a02f9438ceb0c71cb6dbc', 'Sources/SignalAnalyzerDomain/SignalCapturePublication.swift': '2d2a648a49e96f6020eb8a55080bc14f24c2f3a9748dd12694bfefb14a940a1b', 'Sources/SignalAnalyzerDomain/SignalPrimitiveValues.swift': '421b32bb5ceafe40ffd41322650f8c4f905854525a9880f63c5c2bcada69373c', 'Sources/SignalAnalyzerDomain/SignalValues.swift': '4efb99632dc8b8a255e56daa257074b91041d6f20fdad71084a9da548588f493', 'Tests/ContractFixtures/SPEC006/RuntimeDerived/Analyzer.schema.json': '291cf667a93110a8a9dfbd68f7c67370f4b6f5e0d95f22acc92e5a67050c151a', 'Tests/ContractFixtures/SPEC006/RuntimeDerived/Analyzer.swift': '23236acaa231e084f6e4a9d6ba285e841ce077b58492bcfa00ab510f5f0a94e5', 'Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.schema.json': 'e092ddce53ab55b051c8489c81e3214ce6e294affaec69ee6cfb5cb16d38a0f1', 'Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.swift': '2abe29596021e08b6c64b909ee034ed4afc6875ee8fe749f00c05be3bb92d4d2', 'Tests/ContractFixtures/SPEC006/RuntimeDerived/DeclarationHost.swift': '5720a3b8fe8fc627fd569c7d3d3ed7818633dfb2194ff26340c192ccfb55674a', 'Tests/ContractFixtures/SPEC006/RuntimeDerived/MacroChecks.swift': '5cf1e61f1fda78faa192f6970173f8a7aad63f9feb1ed5b366bf11360d83c0f8', 'Tests/ContractFixtures/SPEC006/RuntimeDerived/Main.swift': '034acd228ec9476d5c5a6dc2dcd50287849a4fa8e5503d582adbf41d16afdb35', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Diagnostics/malformed.txt': '63ce323107e5693b768a96bbd5ff9a3af100ca0f2cb27708d11a3d1fb82e82ff', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Diagnostics/overflow-shaped.txt': '21cd52b66435643fd0f0e11197420ff1e1916806d69d6172192227a4b67ca2e4', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Expected/inherited.swift': 'e7dbe2eb6ca34da6119c857ed11570826db7939a87872542aa65b69986ff509b', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Expected/malformed.swift': 'f01d70ff8e2f8f2b0ddb61a5d2d9d89c3397cc1569ec390cc2ce9434096332f5', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Expected/portable-profile.swift': 'efdd1ac4b46d270de976b43361974c2fa80100b2b73e8291319c624de544af19', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Expected/private.swift': '5d504467451fad839dd9c06aa5cfcf6b855ee833546d14aa0041c2a75a2f2dd7', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Expected/several.swift': 'd158e2179e2e246cfc79c5a8f05ea6f70860a23ea6f4dc168cbc3a7a0fa13723', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Expected/zero.swift': '2c540683985890aef4349cb022ece9f2f867ae898c507d5864e2a660d4796af4', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Sources/inherited.swift': 'f0239bd82b47af56988f3edc9755b7378198f8513cc65cb6e215b240d1e36121', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Sources/malformed.swift': 'f0aa2738e7135492ef18f92c9335036f4b9f15d6e76f4a350108d04962c0864d', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Sources/overflow-shaped.txt': 'bb6447714f15d9cbaa6cd0acb3d4e3311e01b423dffdcb1f3ee1c3be0107698a', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Sources/portable-profile.swift': '0912b76bad6ece92ebd65fbc71bae9d89ad9e5d4355b486e66586220ae146885', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Sources/private.swift': 'dd3cfd8a7c22fe16cb8b971361b7b098f253a766ff37f9ed9b8d8e839906655d', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Sources/several.swift': '64785362f4bd461a2af41e1ef4720dba40b173fc3ed589bd863207f607f430e9', 'Tests/ContractFixtures/SPEC010/MacroExpansion/Sources/zero.swift': '8bd196ac4e88a076a96dad0b1fab0438d15f4253ad80394e886d0882e6f37c48', 'Tests/ContractFixtures/SPEC010/MacroExpansion/cases.tsv': 'd8d634f2fc01bcb8a903e2b194bf194bfea69017b53221aa687f3cfce966fb91', 'scripts/contracts/check-spec-006-typed-lowering.py': 'c5645b188daa539235fc1ac4d38d2a74fa3aa1822fef071652452de5e59ac5fb', 'scripts/contracts/compiler-baseline.sh': 'd1b1b075a337aa220a4694b4d22fd6da3f08a321f0ce06707f7496c7d62904c2', 'scripts/contracts/run-spec-006.sh': 'e0cabaa86298cedc08c966fb548ea9920db121ecdd7a3d5d8bc0b0efaa5af347', 'scripts/nrf52840/toolchain.env': '0fc9f2a6c4ee824c45bee2e6d1f88d12914950f0fe37a354ef4912a87dfd2e2e', 'scripts/raspberry-pi/toolchain.env': '839e5d565637012434f60ae107ff7dc10c809cff52ab28a3e39fcd0d6e72a007'}, 'macro_tool': '.build/rfc014-p02-swift64/tool/debug/GiftUIMacros-tool', 'macro_tool_sha256': '651cf63bd8c07d18d143fd09370427fdacf8c6967c38e14c71d2ea5f7d9b2814', 'swift_syntax_library': '.build/rfc014-p02-swift64/tool/prebuilts/swift-syntax/603.0.2/swift-6.4.0-RELEASE-macos_universal-MacroSupport/lib/libMacroSupport.a', 'swift_syntax_sha256': '63b1b2670bd94e946bf660aeeda8efccacfce666316cf205e3bbbe9bfbbda308', 'execution': 'checks=120 failures=0', 'checks': [{'check': 'compiler-version', 'exit': 0, 'pass': True}, {'check': 'required-features', 'exit': 0, 'pass': True}, {'check': 'host-macro-build', 'exit': 0, 'pass': True}, {'check': 'macro-check-build', 'exit': 0, 'pass': True}, {'check': 'macro-fixtures', 'exit': 0, 'pass': True}, {'check': 'GiftUI', 'exit': 0, 'pass': True}, {'check': 'counter-lowering', 'exit': 0, 'pass': True}, {'check': 'CounterSchema', 'exit': 0, 'pass': True}, {'check': 'CounterPresentation', 'exit': 0, 'pass': True}, {'check': 'SignalAnalyzerDomain', 'exit': 0, 'pass': True}, {'check': 'analyzer-lowering', 'exit': 0, 'pass': True}, {'check': 'AnalyzerSchema', 'exit': 0, 'pass': True}, {'check': 'AnalyzerPresentation', 'exit': 0, 'pass': True}, {'check': 'DeclarationHost', 'exit': 0, 'pass': True}, {'check': 'native-link', 'exit': 0, 'pass': True}, {'check': 'native-execution', 'exit': 0, 'pass': True}, {'check': 'owned-facade-escape', 'exit': 1, 'pass': True}, {'check': 'custom-body-domain', 'exit': 1, 'pass': True}, {'check': 'mixed-domains', 'exit': 1, 'pass': True}, {'check': 'missing-body', 'exit': 1, 'pass': True}, {'check': 'six-children', 'exit': 1, 'pass': True}, {'check': 'escaping-read', 'exit': 1, 'pass': True}, {'check': 'unknown-effect', 'exit': 1, 'pass': True}, {'check': 'unchecked-inout', 'exit': 1, 'pass': True}, {'check': 'disguised-effect', 'exit': 1, 'pass': True}, {'check': 'unknown-model-member', 'exit': 1, 'pass': True}, {'check': 'private-key-construction', 'exit': 1, 'pass': True}, {'check': 'private-read-construction', 'exit': 1, 'pass': True}]}, 'mode': 'No trusted_core: sealed historical core identity for preserved old oracles only. Current integration: mandatory authenticated trusted_core map supplied before compiling Domain/client.'}}

PRIVATE_STORAGE_CONTROL = {'category': 'private-member-access', 'dependency_note_sources': ['/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign5/macos-static/scratch/positive-actual-lowering/inputs/SignalAnalyzerDiagnostic.swift'], 'expected_nonzero': True, 'files': ['privacy/private-storage.swift'], 'first_expected_stage': 'client-emit-object', 'id': 'private-storage', 'kind': 'privacy-negative', 'package_name': 'giftui', 'positive_twin': 'positive-semantics', 'primary_message_patterns_all': ['(?i)inaccessible due to [\'"]private[\'"] protection level'], 'required_symbol': 'storage', 'virtual_display_note': {'policy_id': 'macos-static-private-storage-client-emit-object-virtual-display-v1'}}


def classify_negative_diagnostics(control, exit_code, stdout, stderr,
                                  expected_path, dependency_paths, *,
                                  context=None, trusted_input=None,
                                  trusted_provenance=None, trusted_core=None):
    """Paths come from the trusted caller; virtual labels never select files.

    Integration must authenticate the producer receipt before supplying this
    map. This pure classifier cannot authenticate an external producer itself.
    """
    opt = control.get('virtual_display_note')
    if opt is None:
        return _classify_historical_diagnostics(
            control, exit_code, stdout, stderr, expected_path, dependency_paths,
            context=context, trusted_input=trusted_input)
    p = PRIVATE_STORAGE_POLICY
    expected_path = str(expected_path)
    assert expected_path.endswith(p['primary_suffix']), 'private-storage primary suffix mismatch'
    root = expected_path[:-len(p['primary_suffix'])]
    assert root.startswith('/') and all(part not in ('', '.', '..') for part in root.split('/')[1:]), 'private-storage canonical declared root required'
    current_core = p['core_policy']['archived_root']
    if trusted_core is not None:
        cp = p['core_policy']
        assert set(trusted_core) == {'root', 'receipt_path', 'receipt_sha256', 'receipt_bytes', 'artifact_path', 'artifact_bytes'}, 'current core trusted map fields mismatch'
        current_core = trusted_core['root']
        assert type(current_core) is str and current_core.startswith('/') and all(part not in ('', '.', '..') for part in current_core.split('/')[1:]), 'current core canonical root required'
        assert current_core != cp['archived_root'], 'current core must be fresh, not archived'
        parts = current_core.split('/')
        assert '/'.join(parts[:-2]) == cp['parent'] and parts[-1] == cp['profile_leaf'], 'current core root/profile structure mismatch'
        assert trusted_core['receipt_path'] == current_core + '/' + cp['receipt_leaf'], 'current core receipt path mismatch'
        rb = trusted_core['receipt_bytes']
        assert type(rb) is bytes and hashlib.sha256(rb).hexdigest() == trusted_core['receipt_sha256'], 'current core receipt bytes/hash mismatch'
        try:
            cr = json.loads(rb)
        except (ValueError, UnicodeError):
            raise AssertionError('current core receipt must be UTF-8 JSON')
        assert type(cr) is dict and all(cr.get(key) == value for key, value in cp['receipt_fields'].items()), 'current core P02 receipt source/toolchain/profile/check identity mismatch'
        assert trusted_core['artifact_path'] == current_core + '/' + cp['artifact_leaf'], 'current core artifact path mismatch'
        ab = trusted_core['artifact_bytes']
        assert type(ab) is bytes and len(ab) > 0, 'current core artifact bytes required'
        assert type(cr.get('artifacts')) is dict and cr['artifacts'].get(cp['artifact_leaf']) == {'bytes': len(ab), 'sha256': hashlib.sha256(ab).hexdigest()}, 'current core artifact/receipt join mismatch'
    def remap(value):
        if isinstance(value, str):
            mapped = value.replace(p['campaign_root'] + '/', root + '/')
            return current_core if mapped == p['core_policy']['archived_root'] else mapped
        if isinstance(value, list):
            return [remap(item) for item in value]
        if isinstance(value, dict):
            return {key: remap(item) for key, item in value.items()}
        return value
    assert control == remap(PRIVATE_STORAGE_CONTROL), 'private-storage complete control mismatch'
    assert context == p['context'], 'private-storage profile/module/stage mismatch'
    assert type(exit_code) is int and exit_code == 1, 'private-storage exit mismatch'
    assert list(map(str, dependency_paths)) == remap(p['dependency_paths']), 'private-storage dependency paths mismatch'
    assert trusted_input is not None and trusted_input['path'] == expected_path, 'private-storage trusted client path mismatch'
    data = trusted_input['bytes']
    assert type(data) is bytes and hashlib.sha256(data).hexdigest() == p['client_sha256'], 'private-storage client bytes mismatch'
    assert data.decode('utf-8').splitlines()[p['primary_line'] - 1] == p['primary_source'], 'private-storage client row mismatch'
    assert trusted_provenance is not None, 'private-storage trusted provenance required'
    assert set(trusted_provenance) == {'artifacts', 'producer', 'consumer', 'module_receipt'}, 'private-storage provenance keys mismatch'
    assert trusted_provenance['producer'] == remap(p['producer']), 'private-storage producer identity mismatch'
    assert trusted_provenance['consumer'] == remap(p['consumer']), 'private-storage consumer identity mismatch'
    assert set(trusted_provenance['artifacts']) == set(p['artifacts']), 'private-storage artifact inventory mismatch'
    for key, identity in p['artifacts'].items():
        item = trusted_provenance['artifacts'][key]
        assert set(item) == {'path', 'bytes'} and item['path'] == remap(identity['path']), 'private-storage artifact path mismatch'
        assert type(item['bytes']) is bytes, 'private-storage artifact must be bytes'
        if key != 'imported_module':
            assert len(item['bytes']) == identity['bytes'] and hashlib.sha256(item['bytes']).hexdigest() == identity['sha256'], 'private-storage source bytes mismatch'
    module = trusted_provenance['artifacts']['imported_module']
    assert len(module['bytes']) > 0, 'private-storage empty module'
    module_hash = hashlib.sha256(module['bytes']).hexdigest()
    # This receipt is authenticated by the caller against its actual successful
    # producer stage and captured outputs, never inferred from diagnostic text.
    receipt = trusted_provenance['module_receipt']
    assert receipt == {
        'module_name': 'SignalAnalyzerDomain', 'module_path': module['path'],
        'module_sha256': module_hash, 'producer': remap(p['producer']),
        'source_inputs': {key: {'path': remap(identity['path']), 'sha256': identity['sha256']}
                          for key, identity in p['artifacts'].items() if key != 'imported_module'},
    }, 'private-storage authenticated module producer join mismatch'
    # Whole-sequence equality fixes stream, association, order, source and gutter
    # bytes and rejects every extra severity, malformed diagnostic or crash.
    assert stdout == '' and stderr == remap(p['primary_block']) + p['virtual_block'], 'private-storage exact stderr sequence required'
    records = _classify_historical_diagnostics(
        control, exit_code, '', remap(p['primary_block']), expected_path, dependency_paths)
    assert len(records) == 1 and records[0]['notes'] == [] and records[0]['display_notes'] == [], 'private-storage primary inventory mismatch'
    primary = records[0]['primary']
    assert (primary['file'], primary['line'], primary['column'], primary['message'], primary['source']) == (expected_path, p['primary_line'], p['primary_column'], p['primary_message'], [p['primary_source']]), 'private-storage primary mismatch'
    assert records[0]['dependency_evidence'] == p['primary_message'], 'private-storage evidence mismatch'
    records[0]['display_notes'].append({
        'stream': 'stderr',
        'enclosing_primary': {key: primary[key] for key in ('file', 'line', 'column', 'severity', 'message')},
        'virtual_label': p['virtual_label'], 'line': p['virtual_line'],
        'column': p['virtual_column'], 'message': p['virtual_message'],
        'raw_block': p['virtual_block'], 'filesystem_lookup': False,
        'has_located_note_header': True, 'contributes_dependency_evidence': False,
        'client_sha256': p['client_sha256'],
        'domain_source_sha256': p['artifacts']['domain_source']['sha256'],
        'imported_module_sha256': module_hash,
    })
    return records
