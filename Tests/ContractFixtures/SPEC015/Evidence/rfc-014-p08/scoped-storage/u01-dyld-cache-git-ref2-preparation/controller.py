"""Unexecuted one-shot metadata controller. Read request.md before any launch.

Only the fixed main entry can perform I/O; no Git, subprocess or HTTP library.
The response-body limit is an application acceptance limit, never a wire limit.
"""

import time

START = time.monotonic()

import hashlib
import json
import os
from pathlib import Path
import re
import resource
import signal
import socket
import ssl
import sys

ROOT = Path('/Users/eugene/work/GiftUI')
PREP = ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/u01-dyld-cache-git-ref2-preparation'
RESULT = PREP.parent / 'u01-dyld-cache-git-ref2-result'
HOST = 'github.com'
BASE = '/apple-oss-distributions/distribution-macOS.git'
REF = b'refs/tags/macos-2662'
CAP = 1048576
HEADER_CAP = 65536
FRAMING_CAP = 65536
ENV = {'LANG': 'C', 'LC_ALL': 'C', 'TZ': 'UTC'}
PYTHON = '/opt/homebrew/Cellar/python@3.14/3.14.6/bin/python3.14'
CA = '/etc/ssl/cert.pem'


class Stop(Exception):
    pass


def require(condition, reason):
    if not condition:
        raise Stop(reason)


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def sync_dir(path):
    fd = os.open(path, os.O_RDONLY | os.O_DIRECTORY)
    try:
        os.fsync(fd)
    finally:
        os.close(fd)


def save(name, data):
    """Exclusive, bounded, fsynced file. Never replace an earlier receipt."""
    require(len(data) <= CAP, 'retained stream cap')
    fd = os.open(RESULT / name, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
    finally:
        sync_dir(RESULT)


def record(name, data):
    save(name, (json.dumps(data, sort_keys=True, indent=2) + '\n').encode())


def pkt(data):
    require(0 < len(data) <= 65516, 'invalid outgoing packet length')
    return ('%04x' % (len(data) + 4)).encode('ascii') + data


POST = (pkt(b'command=ls-refs\n') + pkt(b'object-format=sha1\n') + b'0001'
        + pkt(b'peel\n') + pkt(b'ref-prefix ' + REF + b'\n') + b'0000')


def request_bytes(number):
    if number == 1:
        method, path, body = 'GET', BASE + '/info/refs?service=git-upload-pack', b''
        media = 'application/x-git-upload-pack-advertisement'
    elif number == 2:
        method, path, body = 'POST', BASE + '/git-upload-pack', POST
        media = 'application/x-git-upload-pack-result'
    else:
        raise Stop('request budget')
    lines = [f'{method} {path} HTTP/1.1', 'Host: github.com',
             'Git-Protocol: version=2', 'Accept: ' + media,
             'Accept-Encoding: identity', 'Connection: close',
             'User-Agent: GiftUI-U01-ref2/1']
    if number == 2:
        lines += ['Content-Type: application/x-git-upload-pack-request',
                  'Content-Length: ' + str(len(body))]
    return ('\r\n'.join(lines) + '\r\n\r\n').encode('ascii') + body


def packets(body):
    """Only data packets followed by exactly one terminal flush are allowed."""
    pos, result = 0, []
    while pos < len(body):
        prefix = body[pos:pos + 4]
        require(len(prefix) == 4 and re.fullmatch(b'[0-9a-f]{4}', prefix),
                'malformed pkt-line length')
        length = int(prefix, 16)
        pos += 4
        if length == 0:
            require(pos == len(body), 'bytes after terminal flush')
            return result
        require(5 <= length <= 65520 and pos + length - 4 <= len(body),
                'invalid/truncated/control pkt-line')
        line = body[pos:pos + length - 4]
        require(line.endswith(b'\n') and b'\n' not in line[:-1]
                and all(32 <= c <= 126 for c in line[:-1]), 'non-ASCII protocol line')
        result.append(line[:-1])
        pos += length - 4
    raise Stop('missing terminal flush')


def capabilities(body):
    # Recognize only the exact smart-HTTP service envelope, if supplied.
    envelope = pkt(b'# service=git-upload-pack\n') + b'0000'
    if body.startswith(envelope):
        body = body[len(envelope):]
    lines = packets(body)
    require(lines and lines[0] == b'version 2', 'not protocol v2')
    seen = {}
    for line in lines[1:]:
        key, _, value = line.partition(b'=')
        require(re.fullmatch(b'[a-z][a-z0-9-]*', key) and key not in seen,
                'malformed/duplicate capability')
        seen[key] = value
    require(b'ls-refs' in seen, 'ls-refs unavailable')
    require(seen.get(b'object-format') == b'sha1', 'unadvertised/non-sha1 format')
    require(set(seen[b'ls-refs'].split()) <= {b'unborn'}, 'unknown ls-refs capability')
    return [line.decode('ascii') for line in lines]


def refs(body):
    lines = packets(body)
    require(len(lines) <= 1, 'unexpected/duplicate ref record')
    if not lines:
        return {'observation': 'no exact candidate advertised', 'refs': []}
    fields = lines[0].split(b' ')
    require(len(fields) in (2, 3) and re.fullmatch(b'[0-9a-f]{40}', fields[0])
            and fields[0] != b'0' * 40 and fields[1] == REF,
            'malformed/unexpected ref or object id')
    output = [{'ref': REF.decode(), 'oid': fields[0].decode()}]
    if len(fields) == 3:
        require(re.fullmatch(b'peeled:[0-9a-f]{40}', fields[2])
                and fields[2][7:] != b'0' * 40, 'unexpected/malformed ref attribute')
        output.append({'ref': (REF + b'^{}').decode(), 'oid': fields[2][7:].decode()})
    return {'observation': 'exact candidate advertised', 'refs': output}


class Session:
    def __init__(self, deadline):
        self.deadline = deadline
        self.requests = 0
        self.body_bytes = 0
        self.responses = []

    def remaining(self):
        value = self.deadline - time.monotonic()
        require(value > 0, 'whole-session deadline')
        return value

    def receive(self, conn, count):
        conn.settimeout(self.remaining())
        value = conn.recv(count)
        require(value, 'unexpected EOF')
        return value

    def exchange(self, number):
        require(number == self.requests + 1 and number <= 2, 'request budget/order')
        raw = request_bytes(number)
        # Receipt precedes even DNS/connect; failure conservatively consumes slot.
        save(f'{number}-request.http', raw)
        self.requests += 1
        record(f'{number}-intent.json', {'request_number': number,
               'monotonic': time.monotonic(), 'request_sha256': hashlib.sha256(raw).hexdigest()})
        conn = None
        body = bytearray()
        headers = bytearray()
        framing = bytearray()
        complete = False
        status = None
        error = None
        retained = {}
        for kind in ('headers', 'body', 'framing'):
            retained[kind] = os.open(RESULT / f'{number}-response.{kind}',
                                     os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        sync_dir(RESULT)

        def append(kind, value):
            # Write as received so supervisor termination leaves partial streams.
            pending = memoryview(value)
            while pending:
                written = os.write(retained[kind], pending)
                require(written > 0, 'partial stream write')
                pending = pending[written:]

        try:
            self.remaining()
            addresses = socket.getaddrinfo(HOST, 443, type=socket.SOCK_STREAM)
            require(addresses, 'no address')
            family, kind, proto, _, address = addresses[0]
            conn = socket.socket(family, kind, proto)
            conn.settimeout(self.remaining())
            conn.connect(address)  # one address; no fallback
            context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
            context.minimum_version = ssl.TLSVersion.TLSv1_2
            context.load_verify_locations(cafile=CA)
            require(context.check_hostname and context.verify_mode == ssl.CERT_REQUIRED,
                    'TLS verification disabled')
            conn.settimeout(self.remaining())
            conn = context.wrap_socket(conn, server_hostname=HOST)
            record(f'{number}-tls.json', {'peer': conn.getpeername(),
                   'version': conn.version(), 'cipher': conn.cipher(),
                   'peer_certificate_sha256': hashlib.sha256(conn.getpeercert(binary_form=True)).hexdigest()})
            conn.settimeout(self.remaining())
            conn.sendall(raw)  # called exactly once; never replay on partial failure
            while not headers.endswith(b'\r\n\r\n'):
                require(len(headers) < HEADER_CAP, 'HTTP header cap')
                value = self.receive(conn, 1)
                append('headers', value)
                headers += value
            lines = bytes(headers[:-4]).split(b'\r\n')
            match = re.fullmatch(b'HTTP/1\\.1 ([1-5][0-9]{2}) [\\x20-\\x7e]*', lines[0])
            require(match, 'HTTP status/version malformed')
            status = int(match[1])
            values = {}
            for line in lines[1:]:
                key, colon, value = line.partition(b':')
                require(colon and re.fullmatch(b"[!#$%&'*+.^_`|~0-9A-Za-z-]+", key)
                        and all(c == 9 or 32 <= c <= 126 for c in value), 'HTTP header malformed')
                key = key.lower()
                require(key not in values, 'duplicate HTTP header')
                values[key] = value.strip(b' \t')
            require(b'content-encoding' not in values or values[b'content-encoding'] == b'identity',
                    'content decoding disallowed')
            length = values.get(b'content-length')
            transfer = values.get(b'transfer-encoding')
            require((length is not None) != (transfer is not None), 'unknown/ambiguous framing')

            def take(count):
                require(count <= CAP - self.body_bytes, 'aggregate accepted response-body cap')
                while count:
                    chunk = self.receive(conn, min(count, 16384))
                    append('body', chunk)
                    os.fsync(retained['body'])
                    body.extend(chunk)
                    self.body_bytes += len(chunk)
                    count -= len(chunk)

            def framing_line():
                start = len(framing)
                while not framing[start:].endswith(b'\r\n'):
                    require(len(framing) < FRAMING_CAP, 'HTTP framing cap')
                    value = self.receive(conn, 1)
                    append('framing', value)
                    framing.extend(value)
                return bytes(framing[start:-2])

            if length is not None:
                require(re.fullmatch(b'0|[1-9][0-9]*', length), 'malformed content length')
                take(int(length))
            else:
                require(transfer == b'chunked', 'unsupported transfer encoding')
                while True:
                    size = framing_line()
                    require(re.fullmatch(b'[0-9A-Fa-f]{1,8}', size), 'chunk syntax/extensions')
                    count = int(size, 16)
                    if count == 0:
                        require(framing_line() == b'', 'HTTP trailers disallowed')
                        break
                    take(count)
                    require(framing_line() == b'', 'missing chunk CRLF')
            complete = True
            require(status == 200, 'HTTP failure/redirect/auth status')
            expected = (b'application/x-git-upload-pack-advertisement' if number == 1
                        else b'application/x-git-upload-pack-result')
            require(values.get(b'content-type') == expected, 'unexpected content type')
            return bytes(body)
        except BaseException as failure:
            error = type(failure).__name__ + ': ' + str(failure)[:1000]
            raise
        finally:
            if conn is not None:
                conn.close()
            for fd in retained.values():
                os.fsync(fd)
                os.close(fd)
            sync_dir(RESULT)
            item = {'request_number': number, 'status': status, 'body_bytes': len(body),
                    'aggregate_body_bytes': self.body_bytes, 'framing_complete': complete,
                    'headers_bytes': len(headers), 'framing_bytes': len(framing), 'error': error}
            self.responses.append(item)
            record(f'{number}-accounting.json', item)


def verify_identity(expected_lock, expected_controller):
    require(digest(__file__) == expected_controller, 'controller identity mismatch')
    require(digest(PREP / 'runtime-lock.json') == expected_lock, 'runtime lock mismatch')
    lock = json.loads((PREP / 'runtime-lock.json').read_text())
    require(os.path.realpath(sys.executable) == lock['executable'], 'Python executable mismatch')
    require(sys.version == lock['version'] and ssl.OPENSSL_VERSION == lock['ssl_version'], 'runtime version')
    require(sys.flags.isolated and sys.flags.no_site and sys.flags.dont_write_bytecode,
            'require -I -S -B')
    require(dict(os.environ) == ENV, 'require exact clean environment')
    require(os.uname().release == lock['os_release'] and os.uname().version == lock['os_version'], 'OS identity')
    for path, sha in lock['files'].items():
        require(digest(path) == sha, 'runtime dependency identity mismatch: ' + path)


def child(deadline):
    session = Session(deadline)
    result = {'status': 'STOP', 'accounting_complete': False}
    code = 1
    try:
        caps = capabilities(session.exchange(1))
        record('capabilities.json', caps)
        result.update(refs(session.exchange(2)))
        require(session.requests == 2 and len(session.responses) == 2
                and all(item['framing_complete'] for item in session.responses), 'incomplete accounting')
        session.remaining()
        result.update(status='OBSERVED', accounting_complete=True)
        code = 0
    except BaseException as failure:
        result['error'] = type(failure).__name__ + ': ' + str(failure)[:1000]
    result.update(request_intents=session.requests, accepted_body_bytes=session.body_bytes,
                  responses=session.responses, end_monotonic=time.monotonic())
    record('child-result.json', result)
    return code


def main():
    # External reviewed hashes are mandatory, never discovered from a mutable packet.
    require(len(sys.argv) == 3 and all(re.fullmatch('[0-9a-f]{64}', x) for x in sys.argv[1:]),
            'supply reviewed runtime-lock SHA256 and controller SHA256')
    require(Path.cwd() == ROOT and Path(__file__).resolve() == PREP / 'controller.py', 'fixed location')
    verify_identity(*sys.argv[1:])
    require(time.monotonic() < START + 30.0, 'startup exhausted deadline')
    os.umask(0o077)
    RESULT.mkdir(mode=0o700, exist_ok=False)  # permanent one-session consumed marker
    sync_dir(RESULT.parent)
    start = START
    deadline = start + 30.0
    record('launch.json', {'status': 'CONSUMED before emission', 'argv': sys.argv,
           'environment': dict(os.environ), 'pid': os.getpid(), 'start_monotonic': start,
           'deadline_monotonic': deadline, 'max_requests': 2, 'aggregate_body_cap': CAP,
           'controller_sha256': sys.argv[2], 'runtime_lock_sha256': sys.argv[1]})
    # No inherited stdio, sockets, file descriptors or unbounded traceback streams.
    for fd in (0, 1, 2):
        replacement = os.open('/dev/null', os.O_RDONLY if fd == 0 else os.O_WRONLY)
        os.dup2(replacement, fd)
        if replacement > 2:
            os.close(replacement)
    save('stdout', b'')
    save('stderr', b'')
    for fd in os.listdir('/dev/fd'):
        if fd.isdecimal() and int(fd) > 2:
            try:
                os.close(int(fd))
            except OSError:
                pass
    pid = None
    wait_status = None
    timed_out = False

    def interrupted(signum, frame):
        raise Stop('supervisor signal ' + str(signum))

    for signum in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
        signal.signal(signum, interrupted)
    try:
        pid = os.fork()
        if pid == 0:
            os.setsid()
            resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
            resource.setrlimit(resource.RLIMIT_FSIZE, (CAP, CAP))
            signal.signal(signal.SIGALRM, interrupted)
            signal.setitimer(signal.ITIMER_REAL, max(0.001, deadline - time.monotonic()))
            try:
                code = child(deadline)
            except BaseException:
                code = 1
            os._exit(code)
        while wait_status is None:
            observed, status = os.waitpid(pid, os.WNOHANG)
            if observed:
                wait_status = status
                break
            left = deadline - time.monotonic()
            if left <= 0:
                timed_out = True
                break
            time.sleep(min(0.01, left))
    finally:
        if pid and wait_status is None:
            for target in (-pid, pid):
                try:
                    os.kill(target, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            _, wait_status = os.waitpid(pid, 0)
        streams = {}
        for path in sorted(RESULT.iterdir()):
            require(path.is_file() and not path.is_symlink() and path.stat().st_size <= CAP,
                    'unexpected/oversized retained stream')
            streams[path.name] = {'bytes': path.stat().st_size, 'sha256': digest(path)}
        success = False
        child_path = RESULT / 'child-result.json'
        if child_path.is_file():
            report = json.loads(child_path.read_text())
            success = (wait_status == 0 and not timed_out and report.get('status') == 'OBSERVED'
                       and report.get('accounting_complete') is True
                       and report.get('end_monotonic', deadline) < deadline)
        record('terminal.json', {'status': 'OBSERVED' if success else 'STOP',
               'timed_out': timed_out, 'actual_wait_status': wait_status,
               'actual_exit': os.waitstatus_to_exitcode(wait_status) if wait_status is not None else None,
               'end_monotonic': time.monotonic(), 'streams': streams,
               'missing_child_result_is_incomplete_accounting': not child_path.is_file(),
               'wire_byte_limit_claimed': False})
    return 0 if success else 1


if __name__ == '__main__':
    try:
        outcome = main()
    except BaseException:
        # Partial/missing receipts always mean STOP, including abrupt interruption.
        os._exit(1)
    os._exit(outcome)
