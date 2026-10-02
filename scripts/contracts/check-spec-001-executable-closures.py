#!/usr/bin/env python3
"""Check the actual package closures of the independent macOS executables."""
import json
import sys

package = json.load(sys.stdin)
graph = {
    target['name']: [next(iter(edge.values()))[0] for edge in target['dependencies']]
    for target in package['targets']
}


def closure(start, edges):
    visited = set()
    pending = [start]
    while pending:
        owner = pending.pop()
        if owner not in visited:
            visited.add(owner)
            pending.extend(edges.get(owner, []))
    return visited


for executable, forbidden in [
    ('SignalAnalyzerMacOSDynamic', 'GiftUIRuntimeStatic'),
    ('SignalAnalyzerMacOSStatic', 'GiftUIRuntimeDynamic'),
]:
    selected = closure(executable, graph)
    required = 'GiftUIRuntimeDynamic' if executable.endswith('Dynamic') else 'GiftUIRuntimeStatic'
    if required not in selected:
        raise SystemExit(f'{executable}: selected runtime is absent: {required}')
    removed = dict(graph)
    removed[executable] = [edge for edge in graph[executable] if edge != required]
    if required in closure(executable, removed):
        raise SystemExit(f'{executable}: missing-profile negative fixture is ineffective')
    prohibited = {forbidden, 'SignalAnalyzerTargetHost'}
    if executable.endswith('Static'):
        prohibited.add('GiftUIDynamicConveniences')
    leaked = selected & prohibited
    if leaked:
        raise SystemExit(f'{executable}: prohibited dependency closure: {sorted(leaked)}')
    # A mixed-composition dependency must fail the same closure predicate.
    negative = dict(graph)
    negative['SignalAnalyzerHost'] = graph['SignalAnalyzerHost'] + [forbidden]
    if not closure(executable, negative) & prohibited:
        raise SystemExit(f'{executable}: negative closure fixture did not fail')
    print(f'executable={executable}; closure={",".join(sorted(selected))}; status=pass')
print('negative-opposite-profile-edges=pass; firmware-isolation=separate-check')
