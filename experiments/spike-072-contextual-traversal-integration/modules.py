#!/usr/bin/env python3
"""Compile adapted framework modules separately; no Runtime module is supplied."""
from pathlib import Path
import json,sys
import run
H=run.HERE
M=H/'modules'
M.mkdir(exist_ok=True)
access=(H/'Access.swift').read_text()
portable=access[:access.index('struct Entry')]+access[access.index('extension FrozenAccess'):]
host=access[access.index('struct Entry'):access.index('extension FrozenAccess')]
# Explicit exported initializer/helper needed by generated application modules.
portable=portable.replace('    public let epoch: UInt32\n}', '    public let epoch: UInt32\n    public init(index: UInt16, epoch: UInt32) { self.index=index; self.epoch=epoch }\n}')
portable=portable.replace('    func drawScalar(', '    public func drawScalar(')
(M/'PortableAccess.swift').write_text(portable)
(M/'HostAccess.swift').write_text('import GiftUI\nimport GiftUISemanticCore\n'+host)
groups={}
imports={
 'GiftUI':[],
 'GiftUISemanticCore':['GiftUI'],
 'GiftUIRenderCore':['GiftUI'],
 'GiftUITextResources':['GiftUI'],
 'GiftUILayout':['GiftUI','GiftUITextResources'],
 'GiftUIExecution':['GiftUI','GiftUIRenderCore'],
 'GiftUIDrawing':['GiftUI','GiftUIExecution','GiftUILayout','GiftUIRenderCore']}
for module,dependencies in imports.items():
    groups[module]=[]
    for p in sorted((H/'adapted').glob(module+'_*.swift')):
        dest=M/p.name
        dest.write_text(''.join('import '+d+'\n' for d in dependencies)+p.read_text())
        groups[module].append(dest)
    if module=='GiftUI': groups[module].append(M/'PortableAccess.swift')
app=[]
for name in ['Generated','Fixtures','GraphicsRecorder','Driver','Main']:
    p=M/(name+'.swift')
    p.write_text(''.join('import '+m+'\n' for m in imports)+(H/(name+'.swift')).read_text())
    app.append(p)
app.append(M/'HostAccess.swift')
(H/'evidence/module-boundary.json').write_text(json.dumps(dict(imports=imports,notes=[
 'No GiftUIRuntimeDynamic/Static module is built or available on the module search path.',
 'Finite portable access initializer/helper explicitly exported; exact split in modules.py.',
 'One package-name GiftUI allows existing package APIs. External package delivery is not tested.',
 'Original unrelated modules are reduced to their actual required declarations; no type stubs.'
]),indent=2)+'\n')
for target in run.targets():
    name,compiler,flags,out=target
    out=out/'modules';out.mkdir(exist_ok=True)
    flags=flags.copy(); flags[flags.index('-module-name')+1]='GiftUI'
    flags += ['-module-cache-path',str(out/'module-cache'),'-I',str(out),'-enable-experimental-feature','LifetimeDependence','-enable-experimental-feature','Lifetimes']
    objects=[]
    for module,inputs in groups.items():
        flags[flags.index('-module-name')+1]=module
        obj=out/(module+'.o'); objects.append(obj)
        if '--app-only' in sys.argv:
            assert obj.exists() and (out/(module+'.swiftmodule')).exists()
            continue
        run.trial('module-'+name+'-'+module,[str(compiler),*flags,'-emit-module','-emit-module-path',str(out/(module+'.swiftmodule')),'-c',*[str(p) for p in inputs],'-o',str(obj)],inputs)
    flags[flags.index('-module-name')+1]='Spike072App'
    native=name.startswith('macos')
    inputs=[p for p in app if native or p.name!='Main.swift']
    artifact=out/('integration' if native else 'integration.o')
    command=[str(compiler),*flags,*[str(p) for p in inputs]]+([str(p) for p in objects] if native else ['-c'])+['-o',str(artifact)]
    run.trial('module-'+name+'-application',command,inputs+objects)
    if native: run.trial('module-execute-'+name,[str(artifact)],inputs+objects)
