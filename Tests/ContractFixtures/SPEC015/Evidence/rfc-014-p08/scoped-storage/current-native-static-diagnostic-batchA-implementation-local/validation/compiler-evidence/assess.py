from pathlib import Path
import subprocess,json,re,hashlib,collections
cap=Path(__file__).parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
selected=[];callers=[];active=None;active_name=None;start=0;functions=[];raw=[];h=hashlib.sha256()
with (cap/'counter.sil').open('rb') as f:
 for n,line in enumerate(f,1):
  h.update(line)
  if line.startswith(b'sil ') and b'@' in line:
   active_name=line.split(b'@',1)[1].split(b' :',1)[0].split(b' ',1)[0].decode();active= b'counterTrace' in line or b'counterDiagnostic' in line;start=n
   if active:current={'symbol':active_name,'first_line':n,'alloc_ref_lines':[],'Any_array_lines':[],'print_refs':[]};raw.append(str(n)+': '+line.decode().rstrip())
  elif active:
   raw.append(str(n)+': '+line.decode().rstrip())
   if re.search(br'\balloc_ref(?:_dynamic)?\b',line) and not line.lstrip().startswith(b'//'):current['alloc_ref_lines'].append(n)
   if b'Array<Any>' in line or b'$_ContiguousArrayStorage<Any>' in line:current['Any_array_lines'].append(n)
   if b'function_ref' in line and (b'5print' in line or b'_print' in line):current['print_refs'].append(n)
  if b'function_ref @$s17P08CounterRuntime12counterTrace' in line:callers.append({'line':n,'caller':active_name,'instruction':line.decode().strip()})
  if active and line.startswith(b'}'):current['last_line']=n;functions.append(current);active=False
assert functions and not any(c['alloc_ref_lines'] or c['Any_array_lines'] or c['print_refs'] for c in functions)
assert not any('12counterTraceyys12StaticStringV_xtlF' in c['symbol'] for c in functions)
(cap/'selected-trace-functions.sil.txt').write_text('\n'.join(raw)+'\n')
sil={'path':str(cap/'counter.sil'),'sha256':h.hexdigest(),'bytes':(cap/'counter.sil').stat().st_size,'functions':functions,'caller_function_refs':callers,'selected_functions':len(functions),'generic_NativeStatic_fallback_present':False,'selected_alloc_ref_Any_array_print_refs':0,'scope':'Exact selected finite counterTrace/Diagnostic/write/name compiled functions only; no transitive provider or other diagnostics claim'};(cap/'sil-assessment.json').write_text(json.dumps(sil,indent=2)+'\n')
tool='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/llvm-objdump';summary={}
for label,folder in [('before','.build/contracts/p08-counter-wrapel2y'),('after','.build/contracts/p08-counter-va__8qip')]:
 obj=Path(folder)/'P08CounterRuntime.o';cmd=[tool,'--disassemble','--reloc','--no-show-raw-insn',str(obj.resolve())];p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE);bodies=[];body=None;hh=hashlib.sha256();size=0
 for n,line in enumerate(p.stdout,1):
  hh.update(line);size+=len(line);m=re.match(br'^\s*([0-9a-fA-F]+) <([^>]+)>:',line)
  if m:body={'address':hex(int(m[1],16)),'symbol':m[2].decode(),'header_line':n,'allocator_calls':{},'raw':[]};bodies.append(body)
  if body is not None:
   if 'counterTrace' in body['symbol'] or 'counterDiagnostic' in body['symbol']:body['raw'].append((n,line.decode().rstrip()))
   if b'_swift_allocObject' in line:
    m=re.match(br'^\s*([0-9a-fA-F]+):\s+(?:bl\b|ARM64_RELOC_BRANCH26\b)',line)
    if m:body['allocator_calls'].setdefault(hex(int(m[1],16)),[]).append({'line':n,'instruction':line.decode().strip()})
 err=p.stderr.read();rc=p.wait();assert rc==0 and not err
 traces=[b for b in bodies if 'counterTrace' in b['symbol'] or 'counterDiagnostic' in b['symbol']];allocs=[{'caller':b['symbol'],'caller_address':b['address'],'caller_header_line':b['header_line'],'site':site,'evidence':lines} for b in bodies for site,lines in b['allocator_calls'].items()]
 excerpt='\n'.join(str(n)+': '+line for b in traces for n,line in b['raw'])+'\n';(cap/(label+'-trace-disassembly.txt')).write_text(excerpt)
 summary[label]={'object':str(obj),'object_sha256':sha(obj),'argv':cmd,'tool_exit':rc,'disassembly_sha256':hh.hexdigest(),'disassembly_bytes':size,'trace_functions':[{'symbol':b['symbol'],'address':b['address'],'line':b['header_line'],'allocator_sites':list(b['allocator_calls'])} for b in traces],'trace_allocator_sites':[a for a in allocs if 'counterTrace' in a['caller'] or 'counterDiagnostic' in a['caller']],'other_allocator_sites':[a for a in allocs if 'counterTrace' not in a['caller'] and 'counterDiagnostic' not in a['caller']],'trace_excerpt_sha256':hashlib.sha256(excerpt.encode()).hexdigest()}
assert not summary['after']['trace_allocator_sites']
summary['reconciliation']={'removed_selected_trace_allocator_calls':len(summary['before']['trace_allocator_sites']), 'removed_whole_module_allocator_sites':len(summary['before']['other_allocator_sites'])-len(summary['after']['other_allocator_sites']),'new_trace_allocator_calls':0,'other_before':len(summary['before']['other_allocator_sites']),'other_after':len(summary['after']['other_allocator_sites']),'old_frozen_universe':'Preserved56groups/1892sites; current object sites are not substituted into old tuples','nontrace_identity_limit':'Other current addresses/counts retained as reconciliation context only; no feasibility/provider equivalence inferred','scope':'Finite reached reuse/role/audit compiler construction replacement; selected trace/writer functions remain construction-free, ordinary implementation assessment; failed U02 proof remains STOP'}
(cap/'machine-reconciliation.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({'selected_SIL_functions':len(functions),'caller_function_refs':len(callers),'SIL_bytes':sil['bytes'],'SIL_sha256':sil['sha256'],'reconciliation':summary['reconciliation']}))
