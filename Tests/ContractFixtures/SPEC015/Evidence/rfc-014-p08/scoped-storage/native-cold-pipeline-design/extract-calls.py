#!/usr/bin/env python3
"""Read a hash-pinned existing Mach-O; never compile or execute the profile."""
import argparse
import hashlib
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]
IMAGE_SHA = '77a11a4bf23a055d027369edd712888c5884d4d970d37d8747417bed20ed1152'
SITES = {'physicalFacts': 0x1138ec, 'textValidator': 0xe09d4,
         'bitmapPayload': 0x8e194, 'outlinePayload': 0x8f858,
         'recordFactory': 0xd6608, 'hostActivation': 0x4618c,
         'semanticRole': 0xe6cbc, 'semanticTraversal': 0xd3a30,
         'modelReadSlots': 0x836b0, 'layoutValidation': 0x7bfc8,
         'renderProduction': 0x27884, 'rasterIntersection': 0x20540,
         'glyphPayload': 0x210a0, 'rgbaBytes': 0x1523a4, 'teardown': 0x148288}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('image', nargs='?', type=Path,
                        default=ROOT/'.build/contracts/p08-native-cold-static-screen-candidate1-current/candidate-silent-host-first')
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    assert hashlib.sha256(args.image.read_bytes()).hexdigest() == IMAGE_SHA
    proc = subprocess.Popen(['xcrun', 'otool', '-tvV', str(args.image)], stdout=subprocess.PIPE, text=True)
    rows = {key: [] for key in SITES}
    for line in proc.stdout:
        match = re.match(r'^([0-9a-f]{16})\s', line)
        if match:
            offset = int(match[1], 16)-0x100000000
            for key, pc in SITES.items():
                if pc-24 <= offset < pc+12:
                    rows[key].append(line.rstrip())
    assert proc.wait() == 0 and all(rows.values())
    text = (f'Frozen silent executable SHA256 {IMAGE_SHA}\n'
            'Command: xcrun otool -tvV <frozen candidate-silent-host-first>\n'
            'Return offsets are observed stack PCs; preceding BL is the emitted call.\n')
    text += '\n'.join('\n'+key+' return '+hex(SITES[key])+'\n'+'\n'.join(value)
                      for key, value in rows.items())+'\n'
    dest = HERE/'emitted-instructions.txt'
    if args.write:
        dest.write_text(text)
    else:
        assert dest.read_text() == text
    print('PASS: 15 bounded emitted-call slices match the hash-pinned existing image')


if __name__ == '__main__':
    main()
