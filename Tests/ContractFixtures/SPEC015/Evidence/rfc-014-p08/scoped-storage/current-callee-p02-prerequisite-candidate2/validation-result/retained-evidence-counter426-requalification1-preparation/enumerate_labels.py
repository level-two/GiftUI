"""Independent finite enumeration, transcribed from the frozen maintained driver loops.

This module never imports or executes the driver or its collector. Counts are
consequences of explicit membership; a receipt cannot introduce a new label.
"""

def partitions():
    origins = ('geometry', 'candidateRecords', 'candidateHitRegions',
               'candidateCommittedRecords', 'committedRecords', 'committedHitRegions',
               'models', 'root', 'semantic', 'values', 'control', 'activationSpan')
    scoped = []
    def pair(stem):
        scoped.extend([stem + '-positive', stem + '-negative'])
    for route in ('static', 'dynamic'):
        for mode in ('direct', 'generic'):
            for origin in origins:
                pair('so06-union-' + route + '-' + mode + '-' + origin)
    for route in ('static', 'dynamic'):
        for mode in ('direct', 'generic'):
            for phase in ('active-host', 'retired-optional'):
                for origin in origins:
                    pair('so06-carrier-' + route + '-' + mode + '-' + phase + '-' + origin)
                for kind in ('optional', 'tuple', 'generic', 'closure'):
                    pair('so06-erasure-' + route + '-' + mode + '-' + phase + '-' + kind)
    for stem in ('counter-host-copy', 'counter-host-backing', 'so06-use-after-consume',
                 'so06-owned-return', 'so06-private-construction', 'so06-private-extraction',
                 'so06-arbitrary-factory', 'so06-optional-erasure', 'so06-tuple-erasure',
                 'so06-generic-erasure', 'so06-closure-erasure', 'so06-sendable',
                 'so06-static-overlap', 'counter-dynamic-host-backing', 'so06-task', 'so06-async'):
        pair(stem)
    reuse = ['so06-reuse-static-' + suffix for suffix in
             ('inventory-two-hosts', 'control-same-address', 'terminal-old-host',
              'raw-namespace-collision', 'action-stale', 'action-current', 'input-stale',
              'input-current', 'admission-stale', 'admission-current', 'source-stale',
              'source-current', 'cleanup-backing-last')]
    other = ['GiftUISemanticCore', 'GiftUITextResources', 'GiftUIReferenceTextResources',
             'GiftUILayout', 'GiftUIRenderCore', 'GiftUIExecution', 'GiftUIInteraction',
             'GiftUIObservableState', 'GiftUIRenderLowering', 'GiftUIDrawing',
             'GiftUIRuntimeCore', 'GiftUIRuntimeStatic', 'GiftUIRuntimeDynamic',
             'GiftUIHostConfiguration', 'counter-lowering', 'P08CounterSchema',
             'P08CounterPresentation', 'P08CounterTable', 'counter-model', 'link',
             'execute', 'runtime-summary', 'so06-native-exclusivity-module',
             'so06-native-exclusivity-positive-link', 'so06-native-exclusivity-positive-execute',
             'so06-native-exclusivity-negative-link', 'so06-native-exclusivity-negative-execute']
    return dict(scoped=scoped,
                supplemental=['control-resident-projection-positive', 'control-resident-projection-negative'],
                reuse=reuse, other=other)
