"""Evidence collection and exact reuse for the existing finite P08 counter driver."""
import hashlib
import json
import pathlib
import re
import shlex
import shutil
import subprocess


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def family(label):
    if label.startswith('so06-erasure-'):
        return 'so06-erasure-' + label.rsplit('-', 2)[-2]
    if label.startswith(('so06-union-', 'so06-carrier-')):
        return '-'.join(label.split('-')[:2])
    if label.startswith('so06-native-exclusivity-'):
        return 'so06-native-exclusivity'
    if label.startswith('so06-reuse-') or label in ('link', 'execute', 'runtime-summary'):
        return 'runtime'
    return re.sub(r'-(positive|negative)$', '', label)


def diagnostic_matches(diagnostic, output, exit_code):
    """Legacy tuples stay exact; structured compiler oracles constrain alternatives and error sites."""
    if diagnostic is None:
        return exit_code == 0
    if not isinstance(diagnostic, dict):
        return exit_code != 0 and all(value in output for value in diagnostic)
    if set(diagnostic) != {'any_of', 'error_site'}:
        raise ValueError('structured oracle requires any_of and error_site only')
    alternatives, site = diagnostic['any_of'], diagnostic['error_site']
    if (not alternatives or not all(isinstance(row, list) and row and all(isinstance(value, str) and value for value in row) for row in alternatives)
            or set(site) != {'filename', 'first_line'} or pathlib.Path(site['filename']).name != site['filename']
            or not isinstance(site['first_line'], int) or site['first_line'] < 1):
        raise ValueError('invalid structured diagnostic oracle')
    if exit_code is None or exit_code <= 0 or any(value in output.lower() for value in ('stack dump', 'please submit a bug report', 'compiler crash')):
        return False
    errors = re.findall(r'^(.+?):(\d+):\d+: error: (.*)$', output, re.MULTILINE)
    if not errors or output.count('error:') != len(errors):
        return False
    if any(pathlib.Path(path).name != site['filename'] or int(line) < site['first_line'] for path, line, _ in errors):
        return False
    return all(any(all(value in message for value in alternative) for alternative in alternatives) for _, _, message in errors)


class Collector:
    def __init__(self, root, out, collect=False, resume=None, selected=(), legacy=None):
        self.root, self.out = root, out
        self.collect = collect or resume is not None or legacy is not None
        self.selected = set(selected)
        if bool(resume) != bool(selected):
            raise ValueError('--resume-from and at least one --select-family are required together')
        if resume and legacy:
            raise ValueError('focused and legacy imports are mutually exclusive')
        self.checks, self.commands, self.previous = [], [], {}
        self.complete, self.overall_passed = False, False
        self.seen_families = set()
        self.resume = pathlib.Path(resume).resolve() if resume else None
        self.prior = None
        if self.resume:
            self.prior = json.loads((self.resume / 'result.json').read_text())
            if self.prior.get('collection_schema') != 2 or not self.prior.get('collection_complete'):
                raise ValueError('focused reuse requires a complete schema-2 collection receipt')
            for name, expected in self.prior['artifacts'].items():
                if digest(self.resume / name) != expected['sha256']:
                    raise ValueError('prior artifact drift: ' + name)
            self.previous = {check['name']: check for check in self.prior['checks']}
            if len(self.previous) != len(self.prior['checks']):
                raise ValueError('duplicate prior check labels')
            for check in self.previous.values():
                if 'identity' not in check or 'observation' in check['identity'] or check['status'] == 'blocked':
                    continue
                log = self.resume / (check['name'] + '.log')
                if not log.is_file() or digest(log) != check.get('log_sha256'):
                    raise ValueError('prior check log drift: ' + check['name'])
                code = check.get('exit')
                exit_class = check.get('exit_class')
                if code is None and exit_class not in ('zero', 'nonzero'):
                    raise ValueError('prior check lacks numeric exit or preserved historical exit class')
                diagnostic = check['identity']['diagnostic']
                accepted = diagnostic_matches(diagnostic, log.read_text(), code if code is not None else 0 if exit_class == 'zero' else 1)
                if accepted != check['passed']:
                    raise ValueError('prior check classifier/status contradiction: ' + check['name'])
            # Copy verified outputs into a fresh directory; never mutate predecessor evidence.
            for path in self.resume.iterdir():
                if path.is_file() and path.name not in ('result.json', 'commands.txt', 'checks.json'):
                    shutil.copy2(path, out / path.name)
        self.legacy, self.legacy_commands, self.legacy_out = {}, [], None
        self.legacy_verified_sources = set()
        self.legacy_inputs_qualified = False
        self.legacy_preparation_labels = []
        if legacy:
            packet = pathlib.Path(legacy).resolve()
            manifest_path = packet / 'manifest.json'
            if digest(manifest_path) != '7f4e7a2569d5ed9263444373e46710fb45d00af2fcfbb97294229d059b19f2bb':
                raise ValueError('only the immutable compatibility2 partial packet is qualified')
            manifest = json.loads(manifest_path.read_text())
            for name, expected in manifest['files'].items():
                if digest(packet / name) != expected:
                    raise ValueError('legacy packet drift: ' + name)
            self.legacy_out = root / manifest['driver_output']
            self.legacy_commands = (packet / 'commands.txt').read_text().splitlines()
            for check in json.loads((packet / 'control-statuses.json').read_text()):
                check['packet'] = str(packet)
                self.legacy[check['label']] = check
            self.legacy_identity = dict(packet=str(packet.relative_to(root)), manifest_sha256=digest(manifest_path),
                                        source_revision=manifest['source_revision'], available_controls=192,
                                        numeric_negative_exits_recorded=False, preparation_rebuilt=True)
        self.flush()

    def verify_inputs(self, inputs, identity):
        if self.legacy:
            expected = dict(profile='macos-dynamic', selected_host_profile='macos-dynamic', raster_realization='full-surface',
                            runtime_receipt_sha256='ec640f13aedd202725ad02e52a5e56e56357b5d3e034b3792788fe95feae4446',
                            host_receipt_sha256='8ccd2c004117f31f1843584fb157b5a0b5f93669505db88166eafe83f871c64d',
                            core_receipt_sha256='05f06a2eb45db2a196b7a76bdfbd5ee1429a802640dd00aa1ce251020b699402',
                            compiler_sha256='79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69',
                            macro_tool_sha256='6bb5eae9d0b726905f893b0f1fa4c0739fee61830f33404aa5cdb8321212c691',
                            swift_syntax_sha256='63b1b2670bd94e946bf660aeeda8efccacfce666316cf205e3bbbe9bfbbda308')
            for key, value in expected.items():
                if identity.get(key) != value:
                    raise ValueError('legacy dependency/recipe identity drift: ' + key)
            for name in inputs:
                if name.endswith(('.swift', '.schema.json')):
                    self.verify_legacy_source(self.root / name)
            self.legacy_inputs_qualified = True
            self.legacy_identity['qualified_dependencies'] = expected
        if self.prior:
            for key, value in identity.items():
                if self.prior.get(key) != value:
                    raise ValueError('focused recipe identity drift: ' + key)
            # Driver matcher edits are permitted; the collector and every compiled input stay exact.
            old = self.prior['inputs']
            for name, value in inputs.items():
                if name != 'scripts/contracts/check-spec-015-counter.py' and old.get(name) != value:
                    raise ValueError('focused compiled input drift; collect full suite: ' + name)
            if set(old) != set(inputs):
                raise ValueError('focused input inventory drift')

    def verify_legacy_source(self, path):
        if path in self.legacy_verified_sources:
            return
        original = subprocess.run(['git', 'show', 'cab1c415:' + str(path.relative_to(self.root))],
                                  cwd=self.root, capture_output=True, check=True).stdout
        if hashlib.sha256(original).hexdigest() != digest(path):
            raise ValueError('legacy compiled/generation input drift: ' + str(path))
        self.legacy_verified_sources.add(path)

    def legacy_preparation(self, label, command):
        if not self.legacy:
            return
        index = len(self.legacy_preparation_labels)
        if (not self.legacy_inputs_qualified or index >= 19
                or self.normalize(shlex.split(self.legacy_commands[index]), self.legacy_out) != self.normalize(map(str, command))):
            raise ValueError('legacy preparation command/qualification drift: ' + label)
        for token in command:
            path = pathlib.Path(token)
            if str(path).endswith(('.swift', '.schema.json')) and path.is_file() and not path.is_relative_to(self.out):
                self.verify_legacy_source(path)
        self.legacy_preparation_labels.append(label)

    def normalize(self, command, directory=None):
        directory = directory or self.out
        return [str(value).replace(str(directory), '${OUT}') for value in command]

    def identity(self, command, diagnostic):
        sources = {}
        for token in command:
            path = pathlib.Path(token)
            if path.suffix in ('.swift', '.json') and path.is_file():
                sources[str(path).replace(str(self.out), '${OUT}')] = digest(path)
        return dict(command=self.normalize(command), diagnostic=diagnostic if isinstance(diagnostic, dict) else list(diagnostic) if diagnostic else None, sources=sources)

    def flush(self):
        (self.out / 'commands.txt').write_text('\n'.join(self.commands) + ('\n' if self.commands else ''))
        path = self.out / 'checks.json'
        temporary = self.out / 'checks.json.tmp'
        temporary.write_text(json.dumps(dict(collection_complete=self.complete, passed=self.overall_passed, checks=self.checks), indent=2) + '\n')
        temporary.replace(path)

    def record(self, check):
        self.checks.append(check)
        self.flush()
        if not check['passed'] and not self.collect:
            raise SystemExit(check['name'] + ': ' + str(self.out))
        return check

    def passed(self, label):
        return any(check['name'] == label and check['passed'] for check in self.checks)

    def run(self, label, command, diagnostic=None, requires=()):
        command = list(map(str, command))
        group = family(label)
        self.seen_families.add(group)
        identity = self.identity(command, diagnostic)
        check = dict(name=label, family=group, exit=None, passed=False, diagnostic=identity['diagnostic'], identity=identity)
        if self.prior and group not in self.selected:
            old = self.previous.get(label)
            if old is None or old.get('identity') != identity:
                raise ValueError('changed or missing check requires complete --select-family ' + group)
        missing = [name for name in requires if not self.passed(name)]
        if missing:
            self.record(check | dict(status='blocked', prerequisites=missing))
            return ''
        if self.prior and group not in self.selected:
            old = self.previous[label]
            log = self.out / (label + '.log')
            self.record(check | dict(status='reused', passed=old['passed'], exit=old.get('exit'),
                                     exit_class=old.get('exit_class'), exit_basis=old.get('exit_basis'),
                                     prior_status=old['status'], provenance=str(self.resume / 'result.json'),
                                     log_sha256=digest(log) if log.exists() else None))
            return log.read_text() if log.exists() else ''
        if label in self.legacy:
            if (not self.legacy_inputs_qualified or len(self.legacy_preparation_labels) != 19
                    or not all(self.passed(name) for name in self.legacy_preparation_labels)):
                raise ValueError('legacy controls require exact successful historical-equivalent preparation')
            old = self.legacy[label]
            expected_command = shlex.split(self.legacy_commands[old['command_index'] - 1])
            if self.normalize(expected_command, self.legacy_out) != identity['command']:
                raise ValueError('legacy command drift: ' + label)
            variant = self.out / (label + '.swift')
            if digest(variant) != old['source_sha256']:
                raise ValueError('legacy generated source drift: ' + label)
            for token in command:
                path = pathlib.Path(token)
                if path.suffix == '.swift' and path.is_file() and not path.is_relative_to(self.out) and path not in self.legacy_verified_sources:
                    self.verify_legacy_source(path)
            log = pathlib.Path(old['packet']) / old['log']
            shutil.copy2(log, self.out / (label + '.log'))
            accepted = old['driver_status'] == 'accepted'
            if accepted and not diagnostic_matches(diagnostic, log.read_text(), 0 if old['compiler_exit_class'] == 'zero' else 1):
                raise ValueError('legacy classifier drift: ' + label)
            self.record(check | dict(status='legacy-imported', passed=accepted, exit=old['compiler_exit_code'],
                                     exit_class=old['compiler_exit_class'], exit_basis=old['exit_basis'],
                                     provenance=old['packet'], log_sha256=digest(log)))
            return log.read_text()
        self.commands.append(shlex.join(command))
        self.checks.append(check | dict(status='running'))
        self.flush()
        result = subprocess.run(command, cwd=self.root, capture_output=True, text=True)
        output = result.stdout + result.stderr
        log = self.out / (label + '.log')
        log.write_text(output)
        okay = diagnostic_matches(diagnostic, output, result.returncode)
        self.checks.pop()
        self.record(check | dict(status='passed' if okay else 'failed', exit=result.returncode,
                                 passed=okay, log_sha256=digest(log)))
        return output

    def observation(self, label, oracle, requires=(), evidence=None):
        group = family(label)
        self.seen_families.add(group)
        identity = dict(observation=oracle, requires=list(requires), evidence=evidence)
        old = self.previous.get(label)
        if self.prior and group not in self.selected and (old is None or old.get('identity') != identity):
            raise ValueError('changed or missing observation requires complete --select-family ' + group)
        missing = [name for name in requires if not self.passed(name)]
        path = self.out / evidence if evidence else None
        output = path.read_text() if path and path.is_file() else ''
        if (set(oracle) == {'kind', 'line', 'count'} and oracle['kind'] == 'exact-line-count'
                and isinstance(oracle['line'], str) and oracle['line'] and oracle['count'] == 1):
            okay = output.splitlines().count(oracle['line']) == oracle['count']
        elif oracle == {'kind': 'positive-counter-summary', 'failures': 0}:
            okay = any(re.fullmatch(r'P08 counter components assertions=[1-9][0-9]* failures=0', line) for line in output.splitlines())
        else:
            raise ValueError('unsupported finite observation oracle')
        if self.prior and group not in self.selected and okay and not missing and not old['passed']:
            raise ValueError('unselected failed observation cannot upgrade using reused evidence')
        self.record(dict(name=label, family=group, identity=identity, exit=None, passed=okay and not missing,
                         status='blocked' if missing else 'passed' if okay else 'failed',
                         prerequisites=missing, evidence=evidence, evidence_sha256=digest(path) if path and path.is_file() else None))

    def target_compilation(self, required, objects):
        path = self.out / 'objects.list'
        if path.exists():
            path.unlink()
        if not all(self.passed(name) for name in required) or not all(object_path.is_file() for object_path in objects):
            return 'selected target counter compilation evidence unavailable; required preparation/module failed, blocked or missing'
        path.write_text('\n'.join(map(str, objects)) + '\n')
        return 'cross-compiled current selected counter host only; no target execution or linked-image claim'

    def finish(self):
        if self.selected - self.seen_families:
            raise ValueError('unknown selected families: ' + ', '.join(sorted(self.selected - self.seen_families)))
        if self.prior and set(self.previous) != {check['name'] for check in self.checks}:
            raise ValueError('focused coverage inventory drift')
        self.complete = True
        self.overall_passed = all(check['passed'] for check in self.checks)
        if self.legacy:
            self.legacy_identity['imported_controls'] = sum(check['status'] == 'legacy-imported' for check in self.checks)
        self.flush()
        return self.overall_passed
