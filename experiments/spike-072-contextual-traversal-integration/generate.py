#!/usr/bin/env python3
"""Finite checked authoring grammar. Not a general Swift parser or compiler."""
from pathlib import Path
import re,json,hashlib
HERE=Path(__file__).resolve().parent
class Unsupported(ValueError): pass
class Parser:
    def __init__(self,s):
        rx=r'\s+|//[^\n]*|->|&&|[A-Za-z_][A-Za-z_0-9]*|[0-9]+|[{}():.,=@&<>]'
        self.t=[]; pos=0
        for m in re.finditer(rx,s):
            if m.start()!=pos: raise Unsupported('unsupported token '+s[pos:pos+20])
            pos=m.end()
            if not m[0].isspace() and not m[0].startswith('//'): self.t.append(m[0])
        if pos!=len(s): raise Unsupported('trailing source')
        self.i=0
    def peek(self): return self.t[self.i] if self.i<len(self.t) else None
    def take(self,x=None):
        n=self.peek()
        if n is None or x is not None and n!=x: raise Unsupported(f'expected {x}, got {n}')
        self.i+=1; return n
    def name(self):
        n=self.take()
        if not re.fullmatch('[A-Za-z_][A-Za-z_0-9]*',n): raise Unsupported('identifier required')
        return n
    def expr(self,prec=0):
        if self.peek()=='&': self.take(); lhs=['address',self.expr(3)]
        else:
            n=self.take()
            if not re.fullmatch('[A-Za-z_][A-Za-z_0-9]*|[0-9]+',n): raise Unsupported('atom required')
            lhs=['atom',n]
        while True:
            op=self.peek()
            if op=='.': self.take(); lhs=['member',lhs,self.name()]
            elif op=='(':
                self.take(); args=[]
                while self.peek()!=')':
                    label=None
                    if self.i+1<len(self.t) and self.t[self.i+1]==':': label=self.name(); self.take(':')
                    args.append([label,self.expr()])
                    if self.peek()!=')': self.take(',')
                self.take(')'); lhs=['call',lhs,args]
            elif op in ('>','&&') and {'>':2,'&&':1}[op]>prec:
                self.take(); lhs=[op,lhs,self.expr({'>':2,'&&':1}[op])]
            else: return lhs
    def body(self):
        if self.peek()=='if':
            self.take(); cond=self.expr(); self.take('{'); a=self.expr(); self.take('}')
            self.take('else'); self.take('{'); b=self.expr(); self.take('}')
            return ['if',cond,a,b]
        expr=self.expr()
        if self.peek()=='{':
            self.take(); children=[]
            while self.peek()!='}': children.append(self.expr())
            self.take('}'); return ['builder',expr,children]
        return expr
    def program(self):
        self.take('@'); self.take('ObservableModel'); self.take('final'); self.take('class'); model=self.name(); self.take('{'); fields=[]
        while self.peek()!='}':
            for t in ['@','Published','var']: self.take(t)
            n=self.name(); self.take(':'); self.take('UInt32'); self.take('='); v=self.take()
            if not v.isdigit(): raise Unsupported('literal seed only')
            fields.append([n,int(v)])
        self.take('}'); views={}
        while self.peek()=='@':
            self.take('@'); self.take('ObservableStateHost'); self.take('struct'); n=self.name(); self.take(':'); self.take('View'); self.take('{')
            for t in ['@','State','var']: self.take(t)
            state=self.name(); self.take(':'); self.take(model)
            for t in ['var','body',':','some','View','{']: self.take(t)
            b=self.body(); self.take('}'); self.take('}'); views[n]=[state,b]
        for t in ['struct']: self.take(t)
        canvas=self.name(); self.take(':'); self.take('Canvas'); self.take('{'); cfields=[]
        while self.peek()=='let':
            self.take(); n=self.name(); self.take(':'); cfields.append([n,self.name()])
        for t in ['func','draw','(','in','bounds',':','Rect',',','context',':','inout','GraphicsContext',')','throws','(','DrawingError',')','{']: self.take(t)
        draw=self.expr(); self.take('}'); self.take('}')
        self.take('func'); helper=self.name()
        for t in ['(','model',':',model,')','->','Bool','{']: self.take(t)
        h=self.expr(); self.take('}')
        if self.peek() is not None: raise Unsupported('extra declaration')
        if [f[1] for f in fields]!=[0,7] or len(views)!=2 or cfields!=[['model',model],['offset','UInt32']]: raise Unsupported('finite schema exceeded')
        return dict(model=model,fields=fields,views=views,canvas=canvas,draw=draw,helper=helper,helper_body=h)
class Emitter:
    def __init__(self,t): self.t=t; self.n=0; self.routes=[]
    def temp(self): self.n+=1; return '_r'+str(self.n)
    def expr(self,n,env,mode='read'):
        k=n[0]
        if k=='atom':
            if n[1].isdigit() or n[1] in env: return [],n[1]
            raise Unsupported('unknown value '+n[1])
        if k=='member':
            if n[1]!=['atom','model'] or env.get('model')!=self.t['model']: raise Unsupported('unchecked member')
            names=[f[0] for f in self.t['fields']]
            if n[2] not in names: raise Unsupported('unknown property')
            i=names.index(n[2]); v=self.temp(); self.routes.append([mode,n[2]])
            return [f'let {v} = try read.{"drawScalar" if mode=="draw" else "scalar"}(model.key, field: {i})'],v
        if k=='address':
            if n!=['address',['atom','context']] or mode!='draw': raise Unsupported('unchecked inout')
            return [],'&context'
        if k in ('>','&&'):
            a,x=self.expr(n[1],env,mode); b,y=self.expr(n[2],env,mode)
            if k=='>': return a+b,f'({x} > {y})'
            v=self.temp()
            return a+[f'var {v} = false',f'if {x} {{']+['    '+l for l in b]+[f'    {v} = {y}','}'],v
        if k!='call' or n[1][0]!='atom': raise Unsupported('unsupported expression')
        name=n[1][1]; sig={'HStack':['spacing'], 'drawBar':['value','scale','context'], self.t['canvas']:['model','offset'],self.t['helper']:['model']}
        for v in self.t['views']: sig[v]=['seed']
        if name not in sig or [a[0] for a in n[2]]!=sig[name]: raise Unsupported('unchecked helper/signature '+name)
        if name=='drawBar' and mode!='draw': raise Unsupported('draw outside draw')
        lines=[]; args=[]
        for label,expr in n[2]:
            ls,ex=self.expr(expr,env,mode); lines+=ls; args.append(label+': '+ex)
        if name==self.t['helper']:
            args.append('read: read'); name+='_read'; v=self.temp()
            return lines+[f'let {v} = try {name}('+', '.join(args)+')'],v
        return lines,('try ' if name=='drawBar' else '')+name+'('+', '.join(args)+')'
    def body(self,b,env):
        if b[0]=='if':
            c,x=self.expr(b[1],env); a,y=self.expr(b[2],env); d,z=self.expr(b[3],env)
            if b[2][0]!='call' or b[3][0]!='call': raise Unsupported('conditional view constructors only')
            typ=f'ConditionalContent<{b[2][1][1]}, {b[3][1][1]}>'
            return c+[f'let _result: {typ}',f'if {x} {{']+['    '+l for l in a]+[f'    _result = ConditionalContent(first: {y})','} else {']+['    '+l for l in d]+[f'    _result = ConditionalContent(second: {z})','}','return _result']
        if b[0]=='builder':
            lines,h=self.expr(b[1],env); children=[]
            for child in b[2]:
                ls,e=self.expr(child,env); lines+=ls; children.append(e)
            return lines+['return '+h+' {']+['    '+e for e in children]+['}']
        raise Unsupported('unsupported body')
    def shape(self,b):
        if b[0]=='if': return f'ConditionalContent<{self.shape(b[2])}, {self.shape(b[3])}>'
        if b[0]=='builder':
            children=[self.shape(c) for c in b[2]]
            if len(children)!=3 or b[1][1]!=['atom','HStack']: raise Unsupported('finite builder shape')
            return 'HStack<TupleView3<'+', '.join(children)+'>>'
        if b[0]=='call' and b[1][0]=='atom' and b[1][1] in [*self.t['views'],self.t['canvas']]: return b[1][1]
        raise Unsupported('body shape cannot be established')
    def generate(self):
        t=self.t
        out=['// Generated finite contextual authoring output.',f'struct {t["model"]} {{ let key: ModelKey }}']
        for name,(state,b) in t['views'].items():
            if state!='model': raise Unsupported('fixture state binding name')
            out += [f'struct {name}: View, _GiftUIObservableStateHost {{', f'    typealias Body = {self.shape(b)}', '    let seed: UInt32',f'    private var model = {t["model"]}(key: ModelKey(index: UInt16.max, epoch: 0))',
                '    init(seed: UInt32) { self.seed=seed }',
                '    mutating func _bind<S: EvaluationSession & ~Copyable>(location: UInt64, session: inout S) throws(AccessFailure) {',
                f'        model = {t["model"]}(key: try session.bind(location: location, ordinal: 0, seed: seed))','    }',
                '    func _giftUITraverse<V: _GiftUISemanticTraversalVisitor,S: EvaluationSession & ~Copyable>(_ visitor: inout V, session: inout S) {',
                '        visitor.visitStatefulCustomView(self, session: &session)','    }',
                '    func _evaluate<R: FrozenAccess & ~Escapable>(read: borrowing R) throws(AccessFailure) -> Body {']
            out+=['        '+l for l in self.body(b,{'model':t['model']})]+['    }','}']
        ls,x=self.expr(t['draw'],{'model':t['model'],'offset':'UInt32','context':'GraphicsContext'},'draw')
        out += [f'struct {t["canvas"]}: Canvas {{',f'    let model: {t["model"]}','    let offset: UInt32',
                '    func draw<R: FrozenAccess & ~Escapable>(in bounds: Rect, context: inout GraphicsContext, read: borrowing R) throws(DrawingError) {']
        out += ['        '+l for l in ls]+['        '+x,'    }','}']
        ls,x=self.expr(t['helper_body'],{'model':t['model']})
        out += [f'func {t["helper"]}_read<R: FrozenAccess & ~Escapable>(model: {t["model"]}, read: borrowing R) throws(AccessFailure) -> Bool {{']+['    '+l for l in ls]+['    return '+x,'}']
        return '\n'.join(out)+'\n'
def generate(s):
    tree=Parser(s).program(); e=Emitter(tree); out=e.generate()
    return out,dict(ast=tree,routes=e.routes,source_sha256=hashlib.sha256(s.encode()).hexdigest(),output_sha256=hashlib.sha256(out.encode()).hexdigest())
if __name__=='__main__':
    source=(HERE/'Authoring.swift.txt').read_text(); out,meta=generate(source)
    (HERE/'Generated.swift').write_text(out); (HERE/'evidence/generation.json').write_text(json.dumps(meta,indent=2)+'\n')
    cases={'unsupported_initializer':source.replace('scale: UInt32 = 7','scale: UInt32 = 8'), 'unknown_helper':source.replace('enabled(model: model)','unknown(model: model)'), 'unknown_property':source.replace('model.scale > 0','model.missing > 0'), 'escape':source+'\nlet leak = model.value\n','closure':source.replace('model.scale > 0','{ model.scale }'), 'unsafe_schema':source.replace('scale: UInt32','scale: UnsafePointer')}
    results=[]
    for name,s in cases.items():
        try: generate(s)
        except Unsupported as e: results.append(dict(case=name,source=s,diagnostic=str(e)))
        else: raise AssertionError(name)
    changed=source.replace('model.value > 0','model.scale > 0')
    assert generate(changed)[0]!=out
    (HERE/'evidence/generator-controls.json').write_text(json.dumps(results,indent=2)+'\n')
    print('Generated root/nested conformers, conditional reads and Canvas; six negative controls')
