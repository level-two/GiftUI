from pathlib import Path
import ast, bisect, hashlib, json, struct, subprocess

R = Path('/Users/eugene/work/GiftUI')
S = R / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage'
H = Path(__file__).parent
OLD = S / 'current-native-static-remaining-batchA37-local/provider-slices.json'
old = json.loads(OLD.read_bytes())
sha = lambda b: hashlib.sha256(b).hexdigest()
extents = []

def vm(address, count, role):
    matches = [(p, m, c['header']) for p, c in old['cache_files'].items() for m in c['rows']
               if m['address'] <= address and address + count <= m['address'] + m['size']]
    if len(matches) != 1: raise RuntimeError(('exact mapped extent', hex(address), count))
    path, mapping, identity = matches[0]
    p = Path(path); st = p.stat()
    if [st.st_size,st.st_dev,st.st_ino,st.st_mtime_ns] != [identity[k] for k in ['file_bytes','device','inode','mtime_ns']]:
        raise RuntimeError('cache file identity drift')
    offset = mapping['file_offset'] + address - mapping['address']
    with p.open('rb') as f: f.seek(offset); b = f.read(count)
    if len(b) != count: raise RuntimeError('short extent')
    d = {'path':path,'offset':offset,'bytes':count,'vmaddr':hex(address),'role':role,'sha256':sha(b)}
    extents.append(d)
    return b, d

ns = {'charge':lambda n:None}
tree = ast.parse((S/'current-native-static-batchA59-local/decode-swift-group.py').read_text())
exec(compile(ast.Module(body=[x for x in tree.body if isinstance(x,ast.FunctionDef) and x.name in ['uleb','trie']],type_ignores=[]),'existing-pure-ULEB-trie','exec'),ns)

def image(name, base):
    header,_ = vm(base,32,'image-header'); sizeofcmd = struct.unpack_from('<I',header,20)[0]
    if sizeofcmd > 65536: raise RuntimeError('load commands extent')
    raw, hd = vm(base,32+sizeofcmd,'image-load-commands'); at=32; segments=[]; deps=[]; uuid=None; identity=None; text=None; exports=None; starts=None
    for _ in range(struct.unpack_from('<I',raw,16)[0]):
        cmd,size=struct.unpack_from('<II',raw,at)
        if cmd==0x19:
            n=raw[at+8:at+24].split(b'\0')[0].decode();va,vs,fo,fs=struct.unpack_from('<QQQQ',raw,at+24);segments.append({'name':n,'vmaddr':va,'vmsize':vs,'fileoff':fo,'filesize':fs})
            for j in range(struct.unpack_from('<I',raw,at+64)[0]):
                q=at+72+80*j
                if raw[q:q+16].split(b'\0')[0]==b'__text':text=struct.unpack_from('<QQ',raw,q+32)
        elif cmd==0x1b:uuid=raw[at+8:at+24].hex()
        elif cmd in [13,12,0x80000018,0x8000001f,0x80000023]:
            no,ts,cv,compat=struct.unpack_from('<IIII',raw,at+8);d={'name':raw[at+no:at+size].split(b'\0')[0].decode(),'command':cmd,'current_version':cv,'compatibility_version':compat}
            if cmd==13:identity=d
            else:deps.append(d)
        elif cmd==0x80000033:exports=struct.unpack_from('<II',raw,at+8)
        elif cmd==0x26:starts=struct.unpack_from('<II',raw,at+8)
        elif cmd==0x80000022:
            eo,es=struct.unpack_from('<II',raw,at+40)
            if es:exports=(eo,es)
        at+=size
    if identity['name']!=name or not all([uuid,text,exports,starts]):raise RuntimeError('exact provider metadata')
    link=next(x for x in segments if x['name']=='__LINKEDIT')
    eb,ed=vm(link['vmaddr']+exports[0]-link['fileoff'],exports[1],'exports-trie')
    sb,sd=vm(link['vmaddr']+starts[0]-link['fileoff'],starts[1],'function-starts')
    return {'base':base,'uuid':uuid,'identity':identity,'dependencies':deps,'segments':segments,'text':text,'load_commands':hd,'exports_extent':ed,'starts_extent':sd},ns['trie'](eb,base),sb

providers={}; captures=[]; tool='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/llvm-objdump'
for name,base,selection in [('/usr/lib/system/libdispatch.dylib',0x180342000,['_dispatch_once_f']),('/usr/lib/system/libsystem_malloc.dylib',0x1802f1000,['_malloc_type_zone_malloc_with_options'])]:
    p,exports,sb=image(name,base); providers[name]=p; starts=[];i=0;pc=base
    while i<len(sb):
        delta,i=ns['uleb'](sb,i)
        if not delta:break
        pc+=delta;starts.append(pc)
    for symbol in selection:
        row=exports[symbol]
        if row['flags']!=0:raise RuntimeError(('nonregular export',symbol,row))
        address=row['address'];idx=bisect.bisect_right(starts,address)-1;lo,hi=starts[idx:idx+2]
        body,extent=vm(lo,hi-lo,symbol)
        header=struct.pack('<IiiIIIII',0xfeedfacf,0x100000c,2,1,1,152,0,0);seg=struct.pack('<II16sQQQQiiII',0x19,152,b'__TEXT',lo,len(body),4096,len(body),7,5,1,0);sec=struct.pack('<16s16sQQIIIIIIII',b'__text',b'__TEXT',lo,len(body),4096,2,0,0,0x80000400,0,0,0);projection=(header+seg+sec).ljust(4096,b'\0')+body
        filename=symbol.lstrip('_');path=H/(filename+'.o');path.write_bytes(projection);argv=[tool,'--disassemble','--no-show-raw-insn',str(path)];result=subprocess.run(argv,capture_output=True);(H/(filename+'.stdout')).write_bytes(result.stdout);(H/(filename+'.stderr')).write_bytes(result.stderr)
        record={'symbol':symbol,'export':row,'range':[hex(lo),hex(hi)],'extent':extent,'projection':str(path.relative_to(R)),'projection_sha256':sha(projection),'argv':argv,'exit':result.returncode,'stdout_bytes':len(result.stdout),'stdout_sha256':sha(result.stdout),'stderr':result.stderr.decode()};captures.append(record)
        if result.returncode:raise RuntimeError(record)
(H/'selected-provider-metadata.json').write_text(json.dumps({'descriptor_origin':str(OLD.relative_to(R)),'descriptor_sha256':sha(OLD.read_bytes()),'providers':providers,'extents':extents,'captures':captures},indent=2)+'\n')
print(json.dumps({'captures':captures},indent=2))
for c in captures:print((H/(c['symbol'].lstrip('_')+'.stdout')).read_text())
