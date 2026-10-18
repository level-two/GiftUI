"""Finite campaign11 diagnostic matcher. No filesystem/process access or qualification."""
from dataclasses import dataclass
import hashlib
import json

ROOT = '/Users/eugene/work/GiftUI'
TEMPLATES_SHA = '3119d2c72126e10b4a6c25da876b4e95a0ce796e249ee85c23d703213615b6ff'
POLICY_SHA = 'b16415ab48830c7bed7ee94e9e653a8a75b76968e8b23aca758a2d6504594dca'


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'), allow_nan=False).encode()


def digest(data):
    return hashlib.sha256(data).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def path(value):
    require(type(value) is str and value.startswith('/') and
            all(p not in ('', '.', '..') for p in value.split('/')[1:]), 'canonical path')
    return value


# Literal campaign roots only. Core substitution is a separate exact operand.
MAP = tuple((ROOT + prefix + old, ROOT + prefix + 'p08-analyzer-abi-continuation-campaign11')
            for prefix in ('/.build/contracts/', '/.build/raspberry-pi/contracts/',
                           '/.build/nrf52840/contracts/')
            for old in ('p08-analyzer-abi-diagnostic-discovery-sweep',
                        'p08-analyzer-abi-continuation-campaign10'))


def relocate(value):
    """Path-component anchored, one pass, no diagnostic-selected lookup."""
    path(value)
    matches = [(old, new) for old, new in MAP if value == old or value.startswith(old + '/')]
    require(len(matches) <= 1, 'overlapping root map')
    if not matches:
        return value
    old, new = matches[0]
    return new + value[len(old):]


def mapped_stream(data):
    # Roots are policy literals; exact occurrence followed by slash is required.
    for old, new in MAP:
        data = data.replace((old + '/').encode(), (new + '/').encode())
    return data


@dataclass(frozen=True)
class Capture:
    key: str
    context: bytes
    stdout: bytes
    stderr: bytes
    sources: bytes
    qualified: bool = False


def prepare(policy_bytes, context, source_bytes, argv, core_root, template_bytes):
    require(type(policy_bytes) is bytes and digest(policy_bytes) == POLICY_SHA, 'policy pin')
    policy = json.loads(policy_bytes)
    key = context['key']
    require(key in policy['cases'], 'finite policy key')
    case = policy['cases'][key]
    require(type(template_bytes) is bytes and digest(template_bytes) == TEMPLATES_SHA, 'template pin')
    template = json.loads(template_bytes)[key]
    require(context['profile'] == case['profile'] and context['control']['id'] == case['control']
            and context['stage'] == case['stage'], 'cell identity')
    require(context['control'] == template['control'], 'complete control identity')
    expected_sources = {relocate(p): v for p, v in case['sources'].items()}
    require(type(source_bytes) is dict and set(source_bytes) == set(expected_sources), 'source inventory')
    for p, identity in expected_sources.items():
        require(type(source_bytes[p]) is bytes and
                {'bytes': len(source_bytes[p]), 'sha256': digest(source_bytes[p])} == identity,
                'source snapshot')
    # Only this exact archived -I core operand may change to the authenticated P02 root.
    old_argv = template['argv']
    old_core = template['core']
    path(core_root)
    require(context['p02']['root'] == core_root, 'current P02 core join')
    expected_argv = [core_root if token == old_core else relocate(token)
                     if token.startswith('/') else token for token in old_argv]
    require(type(argv) is list and argv == expected_argv, 'exact planned argv')
    require(context['argv'] == argv and context['cwd'] == ROOT, 'launch identity')
    require(context['policy_sha256'] == POLICY_SHA, 'context policy')
    return Capture(key, canonical(context), mapped_stream(case['stdout'].encode()),
                   mapped_stream(case['stderr'].encode()), canonical(expected_sources))


def finish(capture, context, source_bytes, stdout, stderr, exit_code, launch_error=None):
    require(type(capture) is Capture, 'prelaunch capture')
    require(canonical(context) == capture.context, 'prelaunch provenance drift')
    require(canonical({p: {'bytes': len(v), 'sha256': digest(v)}
                       for p, v in source_bytes.items()}) == capture.sources, 'source drift')
    require(type(exit_code) is int and exit_code == 1 and launch_error is None, 'qualified exit')
    require(type(stdout) is bytes and stdout == capture.stdout, 'complete stdout')
    require(type(stderr) is bytes and stderr == capture.stderr, 'complete stderr')
    return {'key': capture.key, 'policy_sha256': POLICY_SHA,
            'context_sha256': digest(capture.context), 'qualified': False}
