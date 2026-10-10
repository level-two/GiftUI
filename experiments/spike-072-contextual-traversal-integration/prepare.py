#!/usr/bin/env python3
"""Reproducible disposable adaptations; never edits Sources/. Not an authoring parser."""
from pathlib import Path
import re, json, hashlib, difflib
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
OUT=HERE/'adapted'
OUT.mkdir(exist_ok=True)
records=[]
def put(path, transform=lambda s:s):
    original=(ROOT/path).read_text()
    result=transform(original)
    result=re.sub(r'^import \w+\n', '', result, flags=re.M)
    target=OUT/(Path(path).parent.name+'_'+Path(path).name)
    target.write_text(result)
    records.append({'source':path,'sha256':hashlib.sha256(original.encode()).hexdigest(),'output':target.name,'output_sha256':hashlib.sha256(result.encode()).hexdigest()})
    (HERE/'evidence'/ (target.stem+'.diff')).write_text(''.join(difflib.unified_diff(original.splitlines(True),result.splitlines(True),fromfile=path,tofile=str(target.relative_to(ROOT)))))

def end(s,start,left='(',right=')'):
    depth=1; i=start+1
    while depth:
        if s[i]==left: depth+=1
        if s[i]==right: depth-=1
        i+=1
    return i-1

def threaded(s,names,parameter='session: inout Session',generic='Session: EvaluationSession & ~Copyable',argument='session: &session'):
    # Both signatures and direct calls; process insertions backwards.
    edits=[]
    for match in re.finditer(r'\b('+ '|'.join(names)+r')\b\s*(?:<|\()',s):
        start=match.start(); name=match[1]
        p=start+len(name)
        while s[p].isspace(): p+=1
        g=None
        if s[p]=='<':
            g=end(s,p,'<','>'); p=g+1
            while s[p].isspace(): p+=1
        if s[p]!='(': continue
        q=end(s,p)
        decl=bool(re.search(r'func\s+$',s[max(0,start-12):start]))
        addition=parameter if decl else argument
        edits.append((q,(', ' if s[p+1:q].strip() else '')+addition))
        if decl:
            if g is None: edits.append((start+len(name),'<'+generic+'>'))
            else: edits.append((g,', '+generic))
    for p,t in sorted(edits,reverse=True): s=s[:p]+t+s[p:]
    return s

visits=['visitCustomView','visitStatefulCustomView','visitEmpty','visitFixed','visitConditionalFirst','visitConditionalSecond','visitOptionalAbsent','visitOptionalPresent','visitPrimitive','visitActionPrimitive','visitModifier']
def gift(s):
    s=s.replace(',\n        body: () -> Declaration.Body','').replace(',\n        body: (borrowing Declaration) -> Declaration.Body','')
    s=s.replace('    @ViewBuilder\n    var body: Body { get }','    func _evaluate<Reads: FrozenAccess & ~Escapable>(read: borrowing Reads) throws(AccessFailure) -> Body')
    s=s.replace('visitor.visitCustomView(self) { body }','visitor.visitCustomView(self)')
    # Existing leaf body properties remain, but are no longer protocol witnesses.
    s=s.replace('extension Never: View {','public protocol _GiftUILeaf: View where Body == Never {}\n\nextension _GiftUILeaf {\n    public func _evaluate<Reads: FrozenAccess & ~Escapable>(read: borrowing Reads) throws(AccessFailure) -> Never {\n        throw .invalidField\n    }\n}\n\nextension Never: View {')
    s=re.sub(r'(struct \w+(?:<[^>]+>)?:)\s+View',r'\1 _GiftUILeaf',s)
    s=s.replace('extension Never: View {','extension Never: _GiftUILeaf {')
    return threaded(s,visits+['_giftUITraverse'])
for p in sorted((ROOT/'Sources/GiftUI').glob('*.swift')):
    if p.name not in ('Canvas.swift','ObservableState.swift'):
        put(str(p.relative_to(ROOT)),gift)

def semantic(s):
    s=s.replace('    case bindingFailure(BindingFailure)','    case bindingFailure(BindingFailure)\n    case accessFailure(AccessFailure)')
    s=s.replace('body: (borrowing Declaration) -> Void','session: inout Session,\n        body: (borrowing Declaration, inout Session) -> Void')
    s=s.replace('func bind<Declaration>','func bind<Declaration, Session: EvaluationSession & ~Copyable>')
    s=s.replace('    private(set) var bindingFailure: StateBinding.Failure?','    private(set) var bindingFailure: StateBinding.Failure?\n    private(set) var accessFailure: AccessFailure?')
    s=s.replace(',\n        body: () -> Declaration.Body','').replace(',\n        body: (borrowing Declaration) -> Declaration.Body','')
    s=s.replace('        let evaluatedBody = body()','''        let evaluatedBody: Declaration.Body
        do { evaluatedBody = try session.evaluate(declaration) }
        catch { accessFailure = error; return }''')
    s=s.replace('structuralIdentity: bodyIdentity\n        ) { boundDeclaration in','structuralIdentity: bodyIdentity, session: &session\n        ) { boundDeclaration, scopedSession in')
    s=s.replace('            evaluatedBody = body(boundDeclaration)','''            do throws(AccessFailure) { evaluatedBody = try scopedSession.evaluate(boundDeclaration) }
            catch { accessFailure = error }''')
    s=s.replace('        if let bodyFailure {','        guard accessFailure == nil else { return }\n        if let bodyFailure {')
    # Every traversal early-out must respect all failure arms.
    a=s.index('private struct SemanticExpansionTraversal')
    b=s.index('private enum UnsupportedStateBindingFailure')
    segment=s[a:b].replace('failure == nil','failure == nil, bindingFailure == nil, accessFailure == nil')
    s=s[:a]+segment+s[b:]
    s=s.replace('    case .bindingFailure:\n', '    case .bindingFailure, .accessFailure:\n')
    s=s.replace('    if let bindingFailure = traversal.bindingFailure {','''    if let accessFailure = traversal.accessFailure {
        attempt.discardForOwnerFailure(workspace: &workspace, sink: &sink)
        return .accessFailure(accessFailure)
    }
    if let bindingFailure = traversal.bindingFailure {''')
    return threaded(s,visits+['_giftUITraverse','expandRoot','expandDeclaration','expandFixedChild','expandConditionalChild','expandSemanticTree','expandSemanticTreeWithStateBinding'])
put('Sources/GiftUISemanticCore/GiftUISemanticCore.swift',semantic)
put('Sources/GiftUI/ObservableState.swift',lambda s:s[s.index('public enum _GiftUIObservableChangeReportOutcome'):s.index('public protocol _GiftUIObservableStateDeclarationVisitor')])
for name in ['CanvasInvocationSource','CanvasPlanProducer']:
    def drawing(s):
        s=s.replace(') { (context) throws(DrawingError) in', ') { [read = copy read] (context) throws(DrawingError) in')
        return threaded(s,['derive','invokeCanvas'], 'read: borrowing Reads','Reads: FrozenAccess & ~Escapable','read: read')
    put(f'Sources/GiftUIDrawing/{name}.swift',drawing)
for name in ['DrawingLimits','DrawingPlan','DrawingValues']:
    put(f'Sources/GiftUIDrawing/{name}.swift')
put('Sources/GiftUIExecution/ExecutionValues.swift')
put('Sources/GiftUIRenderCore/DrawingOperationSink.swift',lambda s:s[:s.index('package protocol DrawingOperationSink')])
put('Sources/GiftUITextResources/GiftUITextResources.swift',lambda s:s[:s.index('package struct RasterRealizationID')])
put('Sources/GiftUILayout/ResolvedRenderLayoutView.swift',lambda s:s[:s.index('package protocol ResolvedRenderLayoutResultStorage')])
(HERE/'evidence/adaptations.json').write_text(json.dumps(records,indent=2)+'\n')
print(f'{len(records)} source copies prepared; exact diffs recorded')
