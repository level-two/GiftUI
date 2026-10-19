"""Standalone offline probe; never imports/reads/executes the controller."""

import time
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

expected = {'LANG': 'C', 'LC_ALL': 'C', 'TZ': 'UTC',
            '__CF_USER_TEXT_ENCODING': '0x1F5:0x7:0x3D'}
actual = dict(os.environ)
report = {'expected_environment': expected, 'actual_environment': actual,
          'exact_match': actual == expected, 'executable': os.path.realpath(sys.executable),
          'version': sys.version, 'ssl_version': ssl.OPENSSL_VERSION,
          'flags': {'isolated': sys.flags.isolated, 'no_site': sys.flags.no_site,
                    'dont_write_bytecode': sys.flags.dont_write_bytecode},
          'controller_imports_or_executions': 0, 'network_operations': 0,
          'scope': 'standalone standard-library imports and environment observation only'}
print(json.dumps(report, sort_keys=True, indent=2))
sys.exit(0 if report['exact_match'] and all(report['flags'].values()) else 1)
