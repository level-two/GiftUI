#!/usr/bin/env python3
"""Map preserved candidate-1 cold observations to source owners; no compilation/execution.

The nearest non-compiler frame is a navigational rule, not heap attribution.
All original frames remain in the hash-pinned immutable input archive.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]
FIX = 'Tests/ContractFixtures/SPEC015/RuntimeDerived/'
S = 'Sources/'
RULES = [
    ('physicalFacts()', FIX+'CounterScopedStorage.swift'),
    ('TextResourceValidator.validate', S+'GiftUITextResources/GiftUITextResources.swift'),
    ('GeneratedBitmapPayload.withRecordBytes', S+'GiftUIReferenceTextResources/Generated/ReferenceBitmapPayload.generated.swift'),
    ('GeneratedOutlinePayload.withRecordBytes', S+'GiftUIReferenceTextResources/Generated/ReferenceOutlinePayload.generated.swift'),
    ('CounterHostAssembly.validate', FIX+'CounterHostAssembly.swift'),
    ('counterOwnedSchedulerCompatibility', FIX+'CounterHostProbe.swift'),
    ('HostScheduledOpportunity', S+'GiftUIHostConfiguration/HostScheduledOpportunityController.swift'),
    ('HostOpportunityResult', S+'GiftUIHostConfiguration/HostConfigurationResults.swift'),
    ('counterForeignJoinScope', FIX+'CounterHostProbe.swift'),
    ('withSemanticRecordStore', S+'GiftUISemanticCore/SemanticRecordStore.swift'),
    ('withCanvasStagedValues', S+'GiftUIDrawing/CanvasStagedValues.swift'),
    ('InteractionOwnedKeyState', S+'GiftUIInteraction/InteractionOwnedKeyState.swift'),
    ('InteractionState', S+'GiftUIInteraction/InteractionState.swift'),
    ('P08StorageSession', FIX+'CounterScopedStorage.swift'),
    ('HostActivationStepResult', S+'GiftUIHostConfiguration/HostActivationController.swift'),
    ('p08ConstructStaticHost', FIX+'CounterScopedStorage.swift'),
    ('SignalAnalyzerPresetHostInstance', S+'GiftUIHostConfiguration/SignalAnalyzerPresetHostInstance.swift'),
    ('p08RunStaticSessionPhase', FIX+'CounterScopedStorage.swift'),
    ('MVPHostActivationController', S+'GiftUIHostConfiguration/HostActivationController.swift'),
    ('CounterHostState', FIX+'CounterHostOwner.swift'),
    ('FullSurfaceRGBA8888Buffer', S+'GiftUIRasterCore/FullSurfaceRGBA8888Buffer.swift'),
    ('OneShotRasterBackendEndpoint', S+'GiftUIBackendIntegration/OneShotRasterBackendEndpoint.swift'),
    ('CounterPipelineOwner', FIX+'CounterPipelineOwner.swift'),
    ('RuntimeCompletePipeline.run', S+'GiftUIRuntimeCore/RuntimeCompletePipeline.swift'),
    ('ObservableModelScope', S+'GiftUIObservableState/ObservableModelScope.swift'),
    ('GiftUI.State.init', S+'GiftUI/ObservableState.swift'),
    ('SemanticRecordStore.expand', S+'GiftUISemanticCore/SemanticRecordExpansion.swift'),
    ('SemanticRecordStore', S+'GiftUISemanticCore/SemanticRecordStore.swift'),
    ('SemanticExpansion', S+'GiftUISemanticCore/GiftUISemanticCore.swift'),
    ('expandSemanticTree', S+'GiftUISemanticCore/GiftUISemanticCore.swift'),
    ('CounterRoles.role', FIX+'CounterSemantic.swift'),
    ('ScopedObservableDeclarationVisitor', S+'GiftUIObservableState/ObservableStateRootScope.swift'),
    ('ObservableStateRootScope', S+'GiftUIObservableState/ObservableStateRootScope.swift'),
    ('Swift.InlineArray', S+'GiftUIObservableState/ObservableModelScope.swift'),
    ('CounterScreen._giftUIEvaluate', FIX+'Counter.swift'),
    ('SemanticStandardPayloadCodec', S+'GiftUISemanticCore/SemanticStandardPayload.swift'),
    ('GiftUI.Button', S+'GiftUI/DeclarativeView.swift'),
    ('CanvasStagedValues', S+'GiftUIDrawing/CanvasStagedValues.swift'),
    ('CounterSemanticSnapshot', FIX+'CounterHostCorpus.swift'),
    ('LocalSemantic', FIX+'CounterStaticGeometry.swift'),
    ('LayoutSemanticValidation', S+'GiftUILayout/LayoutSemanticValidation.swift'),
    ('LayoutEngine', S+'GiftUILayout/LayoutEngine.swift'),
    ('publishLayout', S+'GiftUILayout/LayoutPublication.swift'),
    ('P08GeometryAccess', FIX+'CounterScopedStorage.swift'),
    ('ObservableCanvasInvocationSource', S+'GiftUIRuntimeCore/ObservableCanvasInvocationSource.swift'),
    ('CanvasRenderProducer', S+'GiftUIDrawing/CanvasRenderProducer.swift'),
    ('RuntimeRecordInteractionBridge', S+'GiftUIRuntimeCore/RuntimeRecordInteractionBridge.swift'),
    ('CounterEndpoint.offerAndObserve', FIX+'CounterNativeRaster.swift'),
    ('CounterAdmission', FIX+'CounterAdmission.swift'),
    ('RasterFillCoverage', S+'GiftUIRasterCore/RasterFillCoverage.swift'),
    ('CanvasStreamingExtension', S+'GiftUIDrawing/CanvasRenderProducer.swift'),
    ('RasterGlyphCoverage', S+'GiftUIRasterCore/RasterGlyphCoverage.swift'),
    ('CounterRGBAStorage', FIX+'CounterNativeRaster.swift'),
    ('HostActivationResult', S+'GiftUIHostConfiguration/HostConfigurationResults.swift'),
    ('ExecutionGestureAdapter', S+'GiftUIInteraction/ExecutionGestureAdapter.swift'),
    ('staticCounterMovePath', FIX+'StaticCounterDrawingWorkspace.swift'),
    ('RunCycleFailure', S+'GiftUIExecution/RunCycleValues.swift'),
]
SKIP = ('__swift_', 'OUTLINED_', 'type metadata', 'merged type metadata',
        'get_witness_table', 'merged lazy', 'lazy protocol', 'instantiation function',
        'protocol witness', 'specialized ', 'merged generic specialization',
        'generic specialization', 'closure #', 'partial apply')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def derive():
    archive = HERE.parent/'native-cold-static-candidate1-result/observations.tar.gz'
    manifest = json.loads((archive.parent/'manifest.json').read_text())
    assert sha(archive.read_bytes()) == manifest['archive_sha256']
    label = 'candidate-silent-host-first'
    with tarfile.open(archive) as tar:
        data = {}
        for name in (f'run/{label}-1-groups.json.gz', f'symbols/{label}-pcs.json.gz'):
            data[name] = tar.extractfile(name).read()
            assert sha(data[name]) == manifest['members'][name]['sha256']
    groups = json.loads(gzip.decompress(data[f'run/{label}-1-groups.json.gz']))['groups']
    pcs = json.loads(gzip.decompress(data[f'symbols/{label}-pcs.json.gz']))
    rows = []
    source_paths = set()
    for i, group in enumerate(groups):
        if group['cohort'] != 1:
            continue
        frames = [pcs[pc] for pc in group['pcs'] if pcs[pc]['image'].endswith('/'+label)]
        frame = next((f for f in frames if not f['name'].startswith(SKIP)), frames[0])
        matches = [path for marker, path in RULES if marker in frame['name']]
        assert matches, (i, frame['name'])
        source_paths.add(matches[0])
        runtime = [pcs[pc]['name'] for pc in group['pcs'] if not pcs[pc]['image'].endswith('/'+label)]
        rows.append({'group': i, 'count': group['count'], 'requested': group['requested'],
                     'usable': group['reserved'], 'caller_return_offset': frame['offset'],
                     'caller': frame['name'], 'source': matches[0],
                     'allocation_route': group['route'],
                     'runtime_categories': [tag for tag, test in (
                         ('exclusivity_TLS', any('SwiftTLSContext' in n or n == 'swift_beginAccess' for n in runtime)),
                         ('metadata_or_demangle', any('Metadata' in n or 'Demangle' in n or 'WitnessTable' in n for n in runtime)),
                         ('objc_initialization', any('initializeNonMetaClass' in n or 'objc_' in n for n in runtime))) if test],
                     'attribution': 'source navigation only; no exemption or full attributable bound'})
    assert len(rows) == 1015 and sum(r['count'] for r in rows) == 1465
    source_hashes = {}
    for path in sorted(source_paths):
        source_hashes[path] = {commit: sha(subprocess.check_output(['git', 'show', f'{commit}:{path}'], cwd=ROOT))
                               for commit in ('93f6ecc7', '9c19a879')}
    return {'kind': 'complete observed cold caller navigation, not complete reachable allocation proof',
            'baseline': '93f6ecc7', 'candidate': '9c19a879',
            'input_archive_sha256': manifest['archive_sha256'],
            'cold_group_count': len(rows), 'cold_observed_allocation_count': 1465,
            'source_hashes': source_hashes, 'rows': rows}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    payload = gzip.compress((json.dumps(derive(), sort_keys=True, separators=(',', ':'))+'\n').encode(), mtime=0)
    dest = HERE/'emitted-map.json.gz'
    if args.write:
        dest.write_bytes(payload)
    else:
        assert dest.read_bytes() == payload
    print(f'PASS: 1015 cold groups / 1465 observations mapped; {len(payload)} bytes; sha256 {sha(payload)}; no conformance inference')


if __name__ == '__main__':
    main()
