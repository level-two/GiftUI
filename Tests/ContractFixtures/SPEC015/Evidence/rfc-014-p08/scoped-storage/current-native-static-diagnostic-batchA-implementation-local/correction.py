from pathlib import Path
import json,re,hashlib,datetime
R=Path('/Users/eugene/work/GiftUI');B=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage';H=B/'current-native-static-diagnostic-batchA-implementation-local';D=B/'current-native-static-diagnostic-batchA-implementation-result';assert not H.exists();H.mkdir();D.mkdir();(H/'invocation').mkdir()
paths=[R/'Tests/ContractFixtures/SPEC015/RuntimeDerived'/x for x in ['CounterPipelineOwner.swift','CounterScopedStorage.swift','CounterCoordinatorProbe.swift']]
for p in paths:(H/('before-'+p.name)).write_bytes(p.read_bytes())
owner=paths[0].read_text();assert hashlib.sha256(owner.encode()).hexdigest()=='de2df6fd0730393aaa2aca89b2aca937d0b20b38817dc1d399b2dc0ea2252084'
# Parse only the already retained audit spelling into explicit field accesses.
# Runtime execution uses no parser, reflection, collections or generic formatter.
line=next(l.strip() for l in (R/'.build/contracts/p08-counter-wrapel2y/execute.log').open() if l.startswith('counter static audit '));text=line[len('counter static audit valid('):-1];at=0
class Node:
 def __init__(self,name,fields):self.name=name;self.fields=fields
def parse():
 global at
 start=at
 while at<len(text) and text[at] not in '(),':at+=1
 token=text[start:at]
 if at<len(text) and text[at]=='(':
  at+=1;fields=[]
  if token=='Optional':
   value=parse();assert text[at]==')';at+=1;return Node(token,[('',value)])
  while text[at]!=')':
   ix=text.index(': ',at);key=text[at:ix];at=ix+2;value=parse();fields.append((key,value))
   if text[at:at+2]==', ':at+=2
   else:break
  assert text[at]==')';at+=1;return Node(token,fields)
 return token
node=parse();assert at==len(text) and node.name=='GiftUIRuntimeCore.RuntimeStorageAudit'
lines=[]
def literal(s):lines.append('        counterTraceWrite('+json.dumps(s)+')')
def emit(value,expr):
 if isinstance(value,str):
  if re.fullmatch(r'-?[0-9]+',value):lines.append('        counterTraceWrite('+expr+')')
  elif value.startswith('GiftUIRuntimeCore.RuntimeProfileKind.'):
   literal('GiftUIRuntimeCore.RuntimeProfileKind.');lines.append('        switch '+expr+' {');lines.extend(['        case .static: counterTraceWrite("static")','        case .dynamic: counterTraceWrite("dynamic")','        }'])
  else:raise RuntimeError('unsupported audit scalar '+value)
 elif value.name=='Optional':
  lines.append('        if let canvas = '+expr+' {');literal('Optional(');emit(value.fields[0][1],'canvas');literal(')');lines.append('        } else { counterTraceWrite("nil") }')
 else:
  literal(value.name+'(')
  for i,(field,child) in enumerate(value.fields):
   literal((', ' if i else '')+field+': ');emit(child,expr+'.'+field)
  literal(')')
lines.append('    private func counterTraceWrite(_ audit: RuntimeStorageAudit) {');emit(node,'audit');lines.append('    }')
audit='\n'.join(lines)
errors=['invalidLimits','incompatibleLimits','missingStorage','insufficientStorage','arithmeticOverflow','staticCanvasTableInvalid','invariantViolation']
new='''    // Additional reached Native Static observations use the same finite writer.
    // Values remain live field reads; spelling mirrors the pinned print oracle.
    func counterDiagnosticReuse(_ route: StaticString, _ suffix: StaticString) {
        counterTraceWrite("so06-reuse-"); counterTraceWrite(route)
        counterTraceWrite("-"); counterTraceWrite(suffix); counterTraceWrite("\\n")
    }

    func counterDiagnosticRole(_ bank: UInt8, _ leftID: UInt8, _ leftAddress: UInt,
        _ leftCount: Int, _ leftBytes: Int, _ rightID: UInt8, _ rightAddress: UInt,
        _ rightCount: Int, _ rightBytes: Int, _ leftAfter: UInt8, _ rightAfter: UInt8) {
        counterTraceWrite("SO06 role "); counterTraceWrite(bank); counterTraceWrite(" ")
        counterTraceWrite(leftID); counterTraceWrite(" "); counterTraceWriteUnsigned(leftAddress)
        counterTraceWrite(" "); counterTraceWrite(leftCount); counterTraceWrite(" ")
        counterTraceWrite(leftBytes); counterTraceWrite(" "); counterTraceWrite(rightID)
        counterTraceWrite(" "); counterTraceWriteUnsigned(rightAddress); counterTraceWrite(" ")
        counterTraceWrite(rightCount); counterTraceWrite(" "); counterTraceWrite(rightBytes)
        counterTraceWrite(" => "); counterTraceWrite(leftAfter); counterTraceWrite(" ")
        counterTraceWrite(rightAfter); counterTraceWrite("\\n")
    }

    func counterDiagnosticAudit(_ label: StaticString, _ result: RuntimeProfileValidationResult) {
        counterTraceWrite(label); counterTraceWrite(" ")
        switch result {
        case .valid(let audit):
            counterTraceWrite("valid("); counterTraceWrite(audit); counterTraceWrite(")")
        case .invalid(let error):
            counterTraceWrite("invalid(GiftUIRuntimeCore.RuntimeProfileValidationError.")
            switch error {
'''
new+='\n'.join('            case .'+e+': counterTraceWrite("'+e+'")' for e in errors)
new+='''
            }
            counterTraceWrite(")")
        }
        counterTraceWrite("\\n")
    }

'''+audit+'\n\n'
anchor='    private func counterTraceWrite(_ text: StaticString) {';assert owner.count(anchor)==1;paths[0].write_text(owner.replace(anchor,new+anchor))
p=paths[1];s=p.read_text();old='''    #if !hasFeature(Embedded)
    print("so06-reuse-\\(route)-\\(suffix)")
    #endif''';replacement='''    #if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)
    counterDiagnosticReuse(route, suffix)
    #elseif !hasFeature(Embedded)
    print("so06-reuse-\\(route)-\\(suffix)")
    #endif''';assert s.count(old)==1;s=s.replace(old,replacement)
old='''        #if !hasFeature(Embedded)
        print("SO06 role", event.bankKind, event.leftBefore.id.rawValue, event.leftBefore.address, event.leftCount, event.leftBefore.retainedBytes, event.rightBefore.id.rawValue, event.rightBefore.address, event.rightCount, event.rightBefore.retainedBytes, "=>", event.leftAfter.id.rawValue, event.rightAfter.id.rawValue)
        #endif''';replacement='''        #if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)
        counterDiagnosticRole(event.bankKind, event.leftBefore.id.rawValue, event.leftBefore.address, event.leftCount, event.leftBefore.retainedBytes, event.rightBefore.id.rawValue, event.rightBefore.address, event.rightCount, event.rightBefore.retainedBytes, event.leftAfter.id.rawValue, event.rightAfter.id.rawValue)
        #elseif !hasFeature(Embedded)
        print("SO06 role", event.bankKind, event.leftBefore.id.rawValue, event.leftBefore.address, event.leftCount, event.leftBefore.retainedBytes, event.rightBefore.id.rawValue, event.rightBefore.address, event.rightCount, event.rightBefore.retainedBytes, "=>", event.leftAfter.id.rawValue, event.rightAfter.id.rawValue)
        #endif''';assert s.count(old)==1;p.write_text(s.replace(old,replacement))
p=paths[2];s=p.read_text()
for kind in ['static','dynamic']:
 old='#if !hasFeature(Embedded)\n        print("counter '+kind+' audit", '+kind+'Audit)\n        #endif';replacement='#if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)\n        counterDiagnosticAudit("counter '+kind+' audit", '+kind+'Audit)\n        #elseif !hasFeature(Embedded)\n        print("counter '+kind+' audit", '+kind+'Audit)\n        #endif';assert s.count(old)==1;s=s.replace(old,replacement)
p.write_text(s)
(H/'correction-source.json').write_text(json.dumps({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Three fixture files only; NativeStaticfour reached diagnostic classes; existing putchar transport unchanged','added_owner_lines':len(new.splitlines()),'source':{str(p.relative_to(R)):{'before_sha256':hashlib.sha256((H/('before-'+p.name)).read_bytes()).hexdigest(),'after_sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in paths},'audit_generation':'Finite explicit field reads, static spelling only, no runtime reflection/generic collections; independentSwiftprint controls required'},indent=2)+'\n')
print(json.dumps({'modified':[p.name for p in paths],'new_owner_lines':len(new.splitlines()),'transport':'unchanged putchar','all_other_profile_print_text':'preserved underpriorconditional'}))
