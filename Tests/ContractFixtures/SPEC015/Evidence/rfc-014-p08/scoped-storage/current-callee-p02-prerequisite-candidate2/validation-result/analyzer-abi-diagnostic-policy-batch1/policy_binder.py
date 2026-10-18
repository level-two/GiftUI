"""Pure, archived-identity diagnostic policy. No filesystem or compiler access."""
from dataclasses import dataclass
import hashlib
import json

POLICY_SHA256 = 'b16415ab48830c7bed7ee94e9e653a8a75b76968e8b23aca758a2d6504594dca'


class Rejected(ValueError):
    pass


def digest(data):
    return hashlib.sha256(data).hexdigest()


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'),
                      ensure_ascii=True, allow_nan=False).encode('utf-8')


def _unique(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise Rejected('duplicate JSON key')
        result[key] = value
    return result


def _json(data):
    try:
        return json.loads(data, object_pairs_hook=_unique,
                          parse_constant=lambda value: (_ for _ in ()).throw(
                              Rejected('nonfinite JSON number')))
    except (ValueError, TypeError, UnicodeError) as error:
        raise Rejected('invalid JSON') from error


@dataclass(frozen=True)
class Binding:
    """Immutable byte capture; mutating caller dictionaries cannot rebind it."""
    key: str
    policy_sha256: str
    context: bytes
    source_hashes: bytes
    stdout_sha256: str
    stderr_sha256: str
    qualified: bool = False


def bind(policy_bytes, key, context_bytes, source_bytes, stdout, stderr,
         exit_code, launch_error=None):
    """All inputs are captures supplied by the caller, never diagnostic paths.

    This validates only the pinned archived form. It does not authenticate a
    future process, qualify a control, or grant a producer/SDK identity waiver.
    No path substitution, omitted note form, whitespace normalization, regex
    message matching, subprocess, or mutable parser state is used.
    """
    if type(policy_bytes) is not bytes or digest(policy_bytes) != POLICY_SHA256:
        raise Rejected('policy identity')
    policy = _json(policy_bytes)
    if type(key) is not str or key not in policy['cases']:
        raise Rejected('profile/control/stage identity')
    case = policy['cases'][key]
    if type(exit_code) is not int or exit_code != 1 or launch_error is not None:
        raise Rejected('exit or launch anomaly')
    if type(context_bytes) is not bytes:
        raise Rejected('context must be captured bytes')
    context = canonical(_json(context_bytes))
    if digest(context) != case['context_sha256']:
        raise Rejected('compiler/input/provenance context')
    if type(source_bytes) is not dict or set(source_bytes) != set(case['sources']):
        raise Rejected('source inventory')
    hashes = {}
    for path, identity in case['sources'].items():
        data = source_bytes[path]
        if type(data) is not bytes or len(data) != identity['bytes']:
            raise Rejected('source bytes')
        if digest(data) != identity['sha256']:
            raise Rejected('source identity')
        hashes[path] = digest(data)
    # Exact complete streams also bind header order, line/column/message,
    # displayed source rows, gutters, virtual declarations and terminal newline.
    if type(stdout) is not bytes or stdout != case['stdout'].encode('utf-8'):
        raise Rejected('stdout')
    if type(stderr) is not bytes or stderr != case['stderr'].encode('utf-8'):
        raise Rejected('stderr full stream')
    return Binding(key, POLICY_SHA256, context, canonical(hashes),
                   digest(stdout), digest(stderr))


@dataclass(frozen=True)
class Prelaunch:
    """Historical context authentication, captured independently of diagnostics."""
    key: str
    policy_sha256: str
    context: bytes
    source_hashes: bytes


def authenticate_prelaunch(policy_bytes, key, context_bytes, source_bytes):
    # Policy-owned streams are used only to share validation of the archived
    # context/source identities. This issues no diagnostic result or receipt.
    if type(policy_bytes) is not bytes or digest(policy_bytes) != POLICY_SHA256:
        raise Rejected('policy identity')
    policy = _json(policy_bytes)
    if type(key) is not str or key not in policy['cases']:
        raise Rejected('profile/control/stage identity')
    case = policy['cases'][key]
    snapshot = bind(policy_bytes, key, context_bytes, source_bytes,
                    case['stdout'].encode(), case['stderr'].encode(), 1)
    return Prelaunch(key, snapshot.policy_sha256, snapshot.context,
                     snapshot.source_hashes)


def finish(prelaunch, policy_bytes, context_bytes, source_bytes, stdout,
           stderr, exit_code, launch_error=None):
    if type(prelaunch) is not Prelaunch:
        raise Rejected('prelaunch authentication missing')
    result = bind(policy_bytes, prelaunch.key, context_bytes, source_bytes,
                  stdout, stderr, exit_code, launch_error)
    if (result.policy_sha256, result.context, result.source_hashes) != (
            prelaunch.policy_sha256, prelaunch.context, prelaunch.source_hashes):
        raise Rejected('prelaunch capture drift')
    return result
