#!/usr/bin/env python3
"""Measure actual amended declarations under macOS and pinned Embedded Swift."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import subprocess

root = Path(__file__).resolve().parents[2]
os.chdir(root)
output = root / '.build/contract-reports/spec-013/amended-carriers'
output.mkdir(parents=True, exist_ok=True)
compiler = subprocess.check_output(['bash', '-c',
    'source scripts/nrf52840/common.sh; printf "%s" "$GIFTUI_NRF_SWIFTC"'], text=True)
parser = argparse.ArgumentParser()
parser.add_argument('--profile', choices=['macos-dynamic', 'macos-static', 'raspberry-pi-armv6', 'nrf52840-embedded'])
args = parser.parse_args()
pi_destination = subprocess.check_output(['bash', '-c',
    'source scripts/raspberry-pi/common.sh; printf "%s" "$GIFTUI_PI_STATIC_DESTINATION"'], text=True)
pi = json.loads(Path(pi_destination).read_text())
modules = ['GiftUI' , 'GiftUITextResources', 'GiftUISemanticCore', 'GiftUILayout',
    'GiftUIRenderCore', 'GiftUIRenderLowering', 'GiftUIExecution', 'GiftUIDrawing',
    'GiftUIObservableState', 'GiftUIInteraction', 'GiftUIRuntimeCore',
    'SignalAnalyzerPresentation']
sources = {name: sorted((root / 'Sources' / name).rglob('*.swift')) for name in modules}
# The production rejection declarations are in this owner file. Desktop class
# realization is irrelevant to the finite Embedded carrier measurement.
sources['SignalAnalyzerPresentation'] = [root / 'Sources/SignalAnalyzerPresentation/SignalAnalyzerRuntimeCondition.swift']
deps = {name: set().union(*(set(re.findall(r'^import (\w+)$', p.read_text(), re.M))
    for p in paths)) & set(modules) for name, paths in sources.items()}
probe = output / 'CarrierProbe.swift'
header = """import GiftUIExecution
import GiftUIRuntimeCore
import SignalAnalyzerPresentation
"""
owner = root / 'Sources/SignalAnalyzerTargetHost/SignalAnalyzerCycleOwnerFailure.swift'
shapes = [
    ('framework_owner', 'RuntimeOwnerFailure', 2),
    ('application_owner', 'SignalAnalyzerCycleOwnerFailure', 4),
    ('framework_failure', 'RunCycleFailure<RuntimeOwnerFailure>', 8),
    ('application_failure', 'RunCycleFailure<SignalAnalyzerCycleOwnerFailure>', 8),
    ('framework_cycle', 'RunCycleResult<RuntimeOwnerFailure>', 72),
    ('application_cycle', 'RunCycleResult<SignalAnalyzerCycleOwnerFailure>', 72),
    ('mutation_result', 'RuntimePipelineMutationResult<SignalAnalyzerCycleOwnerFailure>', None),
    ('pipeline_result', 'RuntimeCompletePipelineResult<SignalAnalyzerCycleOwnerFailure>', None),
    ('framework_first_failure', 'RuntimeFocusedFailureState<RuntimeOwnerFailure>', None),
    ('first_failure', 'RuntimeFocusedFailureState<SignalAnalyzerCycleOwnerFailure>', None),
]
exercise = """
private struct InlineMutationOwner: RuntimeCompletePipelineOwner {
    typealias OwnerFailure = SignalAnalyzerCycleOwnerFailure
    let applied: Bool
    var finalizations: UInt32 = 0
    mutating func admitAndSeal() -> RuntimePipelineStepResult<OwnerFailure> { .advanced }
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<OwnerFailure> {
        .failure(.focusedOwner(.application(.captureRevisionMismatch)), mutationApplied: applied)
    }
    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<OwnerFailure> { .advanced }
    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<OwnerFailure> { .advanced }
    mutating func resolveLayout() -> RuntimePipelineStepResult<OwnerFailure> { .advanced }
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<OwnerFailure> { .advanced }
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult<OwnerFailure> { .advanced }
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<OwnerFailure> { .advanced }
    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult<OwnerFailure> {
        .published(RuntimePipelinePublication(semanticRevision: SemanticRevision(rawValue: 1), changed: true))
    }
    mutating func allocateCandidate() -> RuntimePipelineStepResult<OwnerFailure> { .advanced }
    mutating func offerAndProduce() -> RuntimePipelineOfferResult<OwnerFailure> { .backpressured }
    mutating func cleanup(_: RuntimeCleanupAction) {}
    mutating func applyDisposition(_: RuntimePipelineDisposition) {}
    mutating func finalizePipeline() { finalizations += 1 }
}

@_cdecl("carrier_mutation_probe")
public func carrierMutationProbe(_ applied: UInt8) -> UInt32 {
    var owner = InlineMutationOwner(applied: applied != 0)
    guard case .failed(let record) = RuntimeCompletePipeline.run(owner: &owner),
        record.failure == .focusedOwner(.application(.captureRevisionMismatch)) else { return 0 }
    return owner.finalizations + (record.disposition.semanticDisposition == .dirty ? 2 : 0)
}
"""
probe.write_text(header + ''.join(f'@_cdecl("size_{name}")\npublic func size_{name}() -> UInt32 {{ UInt32(MemoryLayout<{shape}>.stride) }}\n'
    for name, shape, limit in shapes) + exercise)
rows = ['profile\tshape\tstride\tceiling\n']
for profile, swiftc, extra in [
    ('macos', 'swiftc', []),
    ('raspberry-pi-armv6', str(Path(pi['toolchain-bin-dir']) / 'swiftc'), pi['extra-swiftc-flags'] + [item for flag in pi['extra-cc-flags'] for item in ['-Xcc', flag]]),
    ('nrf52840-embedded', compiler, ['-target', 'armv7em-none-none-eabi',
        '-enable-experimental-feature', 'Embedded', '-DGIFTUI_NRF_EMBEDDED',
        '-Xcc', '-mfloat-abi=hard', '-Xcc', '-mcpu=cortex-m4', '-Xcc', '-mfpu=fpv4-sp-d16'])]:
    selected_profile = 'macos' if args.profile and args.profile.startswith('macos-') else args.profile
    if selected_profile and selected_profile != profile: continue
    directory = output / profile
    directory.mkdir(exist_ok=True)
    flags = ['-Osize', '-whole-module-optimization', '-package-name', 'GiftUI',
        '-parse-as-library', '-I', str(directory), *extra]
    pending = set(modules)
    with (directory / 'compile.log').open('w') as log:
        subprocess.run([swiftc, '--version'], stdout=log, stderr=log, check=True)
        while pending:
            ready = sorted(n for n in pending if not deps[n] & pending)
            if not ready: raise SystemExit('cyclic module selection')
            for name in ready:
                command = [swiftc, *flags, '-emit-module', '-module-name', name,
                    '-emit-module-path', str(directory / f'{name}.swiftmodule'),
                    *map(str, sources[name])]
                result = subprocess.run(command, stdout=log, stderr=log)
                if result.returncode: raise SystemExit(f'{profile} {name} failed: {directory / "compile.log"}')
                pending.remove(name)
        ir = directory / 'carriers.ll'
        subprocess.run([swiftc, *flags, '-module-name', 'SignalAnalyzerTargetHost',
            '-emit-ir', '-o', str(ir), str(owner), str(probe)], stdout=log, stderr=log, check=True)
    object_path = directory / 'carriers.o'
    with (directory / 'compile.log').open('a') as log:
        subprocess.run([swiftc, *flags, '-module-name', 'SignalAnalyzerTargetHost',
            '-emit-object', '-o', str(object_path), str(owner), str(probe)],
            stdout=log, stderr=log, check=True)
    undefined = subprocess.check_output(['nm', '-u', str(object_path)], text=True)
    (directory / 'undefined-symbols.txt').write_text(undefined)
    if re.search(r'\b_?(malloc|calloc|realloc|swift_allocObject|swift_slowAlloc)\b', undefined):
        raise SystemExit(f'{profile}: allocating mutation carrier probe')
    content = ir.read_text()
    if profile == 'nrf52840-embedded':
        functions = dict(re.findall(r'define[^\n]*@("[^"\n]+"|[\w.$]+)\([^\n]*\)[^{]*\{(.*?)^}', content, re.M | re.S))
        pending_functions = ['carrier_mutation_probe']
        reachable = set()
        while pending_functions:
            name = pending_functions.pop()
            if name in reachable: continue
            reachable.add(name)
            body = functions.get(name, '')
            for line in body.splitlines():
                if re.search(r'\b(call|invoke)\b', line):
                    targets = re.findall(r'@("[^"\n]+"|[\w.$]+)\(', line)
                    if not targets: raise SystemExit('unresolved indirect call in Embedded mutation probe')
                    pending_functions.extend(targets)
        (directory / 'reachable-symbols.txt').write_text('\n'.join(sorted(reachable)) + '\n')
        if any(re.search(r'(malloc|calloc|realloc|posix_memalign|swift_alloc|swift_slowAlloc)', n) for n in reachable):
            raise SystemExit('allocating reachable Embedded mutation carrier path')

    for name, shape, ceiling in shapes:
        match = re.search(r'define[^\n]*@size_' + name + r'\([^)]*\)[^{]*\{[^}]*ret i32 (\d+)', content)
        if not match: raise SystemExit(f'missing folded layout for {profile} {name}')
        size = int(match.group(1))
        if ceiling is not None and size > ceiling: raise SystemExit(f'{profile} {name} exceeds {ceiling}: {size}')
        rows.append(f'{profile}\t{name}\t{size}\t{ceiling if ceiling is not None else "measured"}\n')
        print(rows[-1].strip())
(output / (f'layouts-{args.profile}.tsv' if args.profile else 'layouts.tsv')).write_text(''.join(rows))
paths = sorted({owner, *[p for paths in sources.values() for p in paths]})
(output / 'source-hashes.tsv').write_text('source\tsha256\n' + ''.join(
    f'{p.relative_to(root)}\t{hashlib.sha256(p.read_bytes()).hexdigest()}\n' for p in paths))
print('Carrier declaration/layout proof passed; assembled resources remain downstream.')
