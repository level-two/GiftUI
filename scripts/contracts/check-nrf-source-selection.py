#!/usr/bin/env python3
"""Verify the approved Embedded-only selection across package and native inputs."""
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]


def validate(selected, excluded, cmake_sources):
    if len(selected) != 15 or len(set(selected)) != 15:
        raise ValueError('expected exactly the 15 approved Embedded-only sources')
    if set(selected) != set(excluded):
        raise ValueError('SwiftPM exclusion differs from Embedded-only inventory')
    if not set(selected) <= set(cmake_sources):
        raise ValueError('nRF/native closure omits an Embedded-only source')


def main():
    selected = json.loads((ROOT / 'scripts/contracts/nrf-embedded-only-sources.json').read_text())
    package = (ROOT / 'Package.swift').read_text().split('name: "SignalAnalyzerTargetHost"', 1)[1].split('.target(', 1)[0]
    exclusions = re.search(r'exclude:\s*\[(.*?)\]', package, re.S)
    if not exclusions:
        raise ValueError('SwiftPM exclusions missing')
    excluded = re.findall(r'"([^"]+)"', exclusions[1])
    cmake = (ROOT / 'firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt').read_text()
    cmake_sources = re.findall(r'Sources/SignalAnalyzerTargetHost/([^"/]+\.swift)', cmake)
    validate(selected, excluded, cmake_sources)
    for name in selected:
        source = (ROOT / 'Sources/SignalAnalyzerTargetHost' / name).read_text()
        if source.lstrip().startswith('#if GIFTUI_NRF_EMBEDDED'):
            raise ValueError(f'{name}: outer guard was not retired')
    shell = 'StaticSignalAnalyzerNRFEmbeddedFontRaster.swift'
    if (ROOT / 'Sources/SignalAnalyzerTargetHost' / shell).exists() or shell in cmake:
        raise ValueError('empty compatibility shell remains selected')
    # Native owner compilation uses the generated CMake source manifest;
    # native host compilation uses CMake's complete amalgamation.
    owner = (ROOT / 'scripts/contracts/compile-spec-001-nrf-native-owners.py').read_text()
    native = (ROOT / 'scripts/contracts/check-spec-001-nrf-full-layout-native.sh').read_text()
    if 'swift-owner-sources.tsv' not in owner or 'SignalAnalyzerStatic.swift' not in native:
        raise ValueError('native rehearsal no longer consumes CMake selection')
    for label, excluded_bad, cmake_bad in [
        ('SwiftPM leak', excluded[1:], cmake_sources),
        ('wrong firmware closure', excluded, [name for name in cmake_sources if name != selected[0]]),
        ('unexpected exclusion', excluded + ['Other.swift'], cmake_sources),
    ]:
        try:
            validate(selected, excluded_bad, cmake_bad)
        except ValueError:
            pass
        else:
            raise ValueError(f'wrong-selection negative accepted: {label}')
    print('Embedded source selection passed: 15 exclusions, coherent CMake/native inputs, three wrong-selection refusals.')


if __name__ == '__main__':
    main()
