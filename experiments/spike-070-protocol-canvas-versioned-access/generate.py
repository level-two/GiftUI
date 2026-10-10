#!/usr/bin/env python3
"""Strict finite Swift-shaped corpus parser and typed context lowering.
Not a Swift parser, macro implementation, or production compiler.
"""
import hashlib
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
class Unsupported(ValueError): pass


def tokens(source):
    pattern = re.compile(r'\s+|//[^\n]*|"[^"\n]*"|->|[A-Za-z_][A-Za-z_0-9]*|[0-9]+|[{}():.,=@&<>]')
    result, cursor = [], 0
    for item in pattern.finditer(source):
        if item.start() != cursor: raise Unsupported('unsupported token at ' + str(cursor))
        cursor = item.end()
        if not item[0].isspace() and not item[0].startswith('//'): result.append(item[0])
    if cursor != len(source): raise Unsupported('unsupported trailing token')
    return result


class Parser:
    def __init__(self, source): self.items, self.i = tokens(source), 0
    def peek(self): return self.items[self.i] if self.i < len(self.items) else None
    def take(self, expected=None):
        got = self.peek()
        if got is None or (expected is not None and got != expected):
            raise Unsupported(f'expected {expected}, found {got} at token {self.i}')
        self.i += 1
        return got
    def name(self):
        result = self.take()
        if not re.fullmatch('[A-Za-z_][A-Za-z_0-9]*', result): raise Unsupported('identifier required')
        return result
    def expr(self):
        if self.peek() in ('try', 'return'): self.take()
        if self.peek() == '&': self.take(); node = ('address', self.expr()); return node
        item = self.take()
        if not (re.fullmatch('[A-Za-z_][A-Za-z_0-9]*|[0-9]+',item) or item.startswith('"')):
            raise Unsupported('unsupported expression ' + item)
        node = ('atom', item)
        while self.peek() in ('.','('):
            if self.peek() == '.': self.take(); node = ('member', node, self.name())
            else:
                self.take('('); args = []
                while self.peek() != ')':
                    label = None
                    if self.i + 1 < len(self.items) and self.items[self.i + 1] == ':':
                        label = self.name(); self.take(':')
                    args.append((label, self.expr()))
                    if self.peek() != ')': self.take(',')
                self.take(')'); node = ('call', node, args)
        if self.peek() == '{':
            self.take(); children=[]
            while self.peek() != '}': children.append(self.expr())
            self.take('}'); node=('builder',node,children)
        return node
    def field(self, state=False):
        if state: self.take('@'); self.take('State'); self.take('var')
        else: self.take('let')
        name=self.name(); self.take(':'); kind=self.name()
        return (name,kind)
    def function(self):
        self.take('func'); name=self.name(); self.take('('); params=[]
        while self.peek()!=')':
            label=self.name(); local=label
            if self.peek()!=':': local=self.name()
            self.take(':'); kind=self.name()
            if kind=='inout': kind += ' '+self.name()
            params.append((label,local,kind))
            if self.peek()!=')': self.take(',')
        self.take(')'); error=None; result=None
        if self.peek()=='throws':
            self.take(); self.take('('); error=self.name(); self.take(')')
        if self.peek()=='->': self.take(); result=self.name()
        self.take('{'); expr=self.expr(); self.take('}')
        return dict(name=name,params=params,error=error,result=result,expr=expr)
    def program(self):
        models={}; views={}; canvases={}; helpers={}
        while self.peek() is not None:
            annotation=None
            if self.peek()=='@': self.take(); annotation=self.name()
            if self.peek()=='final':
                if annotation!='ObservableModel': raise Unsupported('model annotation required')
                self.take(); self.take('class'); name=self.name(); self.take('{'); fields=[]
                while self.peek()!='}':
                    self.take('@'); self.take('Published'); self.take('var'); field=self.name()
                    self.take(':'); kind=self.name(); self.take('='); initial=self.expr()
                    if kind not in ('UInt32','Capture'): raise Unsupported('unsupported property type '+kind)
                    if kind=='UInt32' and not (initial[0]=='atom' and initial[1].isdigit()):
                        raise Unsupported('scalar literal initializer required')
                    if kind=='Capture' and initial!=('call',('atom','Capture'),[]):
                        raise Unsupported('empty capture initializer required')
                    fields.append((field,kind,initial))
                self.take('}')
                if name in models or len({f[0] for f in fields})!=len(fields): raise Unsupported('duplicate model/field')
                models[name]=fields
            elif self.peek()=='struct':
                self.take(); name=self.name(); self.take(':'); role=self.name(); self.take('{')
                if role=='View' and annotation=='ObservableStateHost':
                    fields=[self.field(state=True)]
                    self.take('var'); self.take('body'); self.take(':'); self.take('some'); self.take('View'); self.take('{')
                    expr=self.expr(); self.take('}'); views[name]=dict(fields=fields,expr=expr)
                elif role=='Canvas' and annotation is None:
                    fields=[]
                    while self.peek()=='let': fields.append(self.field())
                    fn=self.function()
                    if fn['name']!='draw' or fn['params']!=[('in','bounds','Rect'),('context','context','inout GraphicsContext')] or fn['error']!='DrawingError' or fn['result'] is not None:
                        raise Unsupported('unsupported draw signature')
                    canvases[name]=dict(fields=fields,fn=fn)
                else: raise Unsupported('unsupported declaration role '+role)
                self.take('}')
            elif self.peek()=='func' and annotation is None:
                fn=self.function()
                if fn['error'] is not None or fn['result']!='UInt32': raise Unsupported('unsupported helper signature')
                helpers[fn['name']]=fn
            else: raise Unsupported('unsupported declaration')
        if set(models)!= {'CounterModel','AnalyzerModel'}: raise Unsupported('fixture requires its two named schemas')
        if [f[1] for f in models['CounterModel']] != ['UInt32','UInt32'] or [f[1] for f in models['AnalyzerModel']] != ['Capture']:
            raise Unsupported('unsupported fixture schema layout')
        if len(views)!=1 or len(canvases)!=2 or len(helpers)!=1: raise Unsupported('finite declaration count exceeded')
        return dict(models=models, views=views, canvases=canvases, helpers=helpers)


class Emitter:
    def __init__(self, tree): self.tree=tree; self.routes=[]; self.hoisted=[]
    def model_field(self, node, env):
        if node[0]!='member' or node[1][0]!='atom': return None
        variable=node[1][1]; typ=env.get(variable)
        if typ not in self.tree['models']: return None
        for ordinal, (field,kind,initial) in enumerate(self.tree['models'][typ]):
            if field==node[2]: return variable,typ,ordinal,kind
        raise Unsupported('unknown published field '+typ+'.'+node[2])
    def read(self, text, mode):
        if mode=='body':
            name=f'_read{len(self.hoisted)}'; self.hoisted.append(f'let {name} = try {text}'); return name
        return '(try '+text+')'
    def expr(self,node,env,mode):
        field=self.model_field(node,env)
        if field:
            var,typ,ordinal,kind=field
            if kind!='UInt32': raise Unsupported('capture may only be indexed, not returned/stored')
            self.routes.append(dict(model=typ,property=ordinal,mode=mode))
            method='drawScalar' if mode=='draw' else 'scalar'
            return self.read(f'read.{method}({var}.key, field: {ordinal})',mode)
        tag=node[0]
        if tag=='atom':
            value=node[1]
            if value in env or value.isdigit() or value.startswith('"'): return value
            raise Unsupported('unknown value '+value)
        if tag=='address':
            if node[1] != ('atom','context'): raise Unsupported('only graphics context may be inout')
            return '&context'
        if tag=='member': raise Unsupported('unchecked member access')
        if tag=='builder':
            if mode!='body': raise Unsupported('builder outside body')
            head=self.expr(node[1],env,mode)
            children=[self.expr(child,env,mode) for child in node[2]]
            return head+' {\n            '+'\n            '.join(children)+'\n        }'
        if tag!='call': raise Unsupported('unknown AST node')
        callee=node[1]; args=node[2]
        if callee[0]=='member' and callee[2]=='level':
            capture=self.model_field(callee[1],env)
            if not capture or capture[3]!='Capture' or len(args)!=1 or args[0][0]!='at': raise Unsupported('unsupported capture operation')
            var,typ,ordinal,_=capture
            self.routes.append(dict(model=typ,property=ordinal,mode=mode,indexed=True))
            method='drawLevel' if mode=='draw' else 'level'
            index=self.expr(args[0][1],env,mode)
            return self.read(f'read.{method}({var}.key, at: {index})',mode)
        if callee[0]!='atom': raise Unsupported('unchecked call target')
        name=callee[1]
        labels=[arg[0] for arg in args]
        signatures={'HStack':['spacing'],'VStack':['spacing'],'Text':[None],
                    'counterText':[None], 'drawBar':['value','scale','context']}
        if name in self.tree['canvases']:
            fields=self.tree['canvases'][name]['fields']
            if labels!=[f[0] for f in fields]: raise Unsupported('canvas field labels mismatch')
            for (_,expr),(_,typ) in zip(args,fields):
                if expr[0]!='atom' or env.get(expr[1])!=typ: raise Unsupported('canvas model field type mismatch')
        elif name in self.tree['helpers']:
            fn=self.tree['helpers'][name]
            if labels!=[p[0] for p in fn['params']]: raise Unsupported('helper labels mismatch')
            for (_,expr),(_,_,typ) in zip(args,fn['params']):
                if typ in self.tree['models'] and (expr[0]!='atom' or env.get(expr[1])!=typ): raise Unsupported('helper model type mismatch')
            rendered=[(label,self.expr(expr,env,mode)) for label,expr in args]
            rendered.append(('read','read'))
            suffix='_draw' if mode=='draw' else '_read'
            text=name+suffix+'('+', '.join((label+': ' if label else '')+value for label,value in rendered)+')'
            if mode=='body': return self.read(text,mode)
            return '(try '+text+')'
        elif name in signatures:
            if labels!=signatures[name]: raise Unsupported('unsupported call signature '+name)
            if name=='drawBar' and mode!='draw': raise Unsupported('drawing outside draw')
            if name in ('HStack','VStack','Text') and mode!='body': raise Unsupported('view construction outside body')
        else: raise Unsupported('unchecked helper '+name)
        rendered=[(label,self.expr(expr,env,mode)) for label,expr in args]
        call=name+'('+', '.join((label+': ' if label else '')+value for label,value in rendered)+')'
        return ('try ' if name=='drawBar' else '')+call
    def generate(self):
        out=['// Generated by the strict SPIKE-070 finite corpus transformer.']
        for name,fields in self.tree['models'].items():
            out += [f'struct {name} {{', '    let key: ModelKey']
            for i,(_,kind,initial) in enumerate(fields):
                if kind=='UInt32': out += [f'    static let initial{i}: UInt32 = {initial[1]}']
            out += ['}']
        for name,view in self.tree['views'].items():
            env=dict(view['fields']); self.hoisted=[]
            expression=self.expr(view['expr'],env,'body')
            out += [f'struct {name} {{']+[f'    let {n}: {t}' for n,t in view['fields']]
            out += ['    func evaluate(read: borrowing FrameRead) throws(AccessFailure) -> some View {']
            out += ['        '+line for line in self.hoisted]
            out += ['        return '+expression,'    }','}']
        for name,canvas in self.tree['canvases'].items():
            env=dict(canvas['fields']); env.update(bounds='Rect',context='GraphicsContext')
            expression=self.expr(canvas['fn']['expr'],env,'draw')
            out += [f'struct {name}: Canvas {{']+[f'    let {n}: {t}' for n,t in canvas['fields']]
            out += ['    func draw(in bounds: Rect, context: inout GraphicsContext,',
                    '              read: borrowing FrameRead) throws(DrawingError) {',
                    '        '+expression,'    }','}']
        for name,fn in self.tree['helpers'].items():
            for mode,err in [('read','AccessFailure'),('draw','DrawingError')]:
                env={local:typ for _,local,typ in fn['params']}
                params=', '.join(label+(': ' if label==local else ' '+local+': ')+typ for label,local,typ in fn['params'])
                expression=self.expr(fn['expr'],env,mode)
                out += [f'func {name}_{mode}({params}, read: borrowing FrameRead) throws({err}) -> UInt32 {{',
                        '    return '+expression,'}']
        return '\n'.join(out)+'\n'


def generate(source):
    tree=Parser(source).program(); emitter=Emitter(tree); output=emitter.generate()
    return output,dict(source_sha256=hashlib.sha256(source.encode()).hexdigest(),
                       output_sha256=hashlib.sha256(output.encode()).hexdigest(),
                       ast=tree, routes=emitter.routes,
                       adaptations=['Canvas target draw receives explicit FrameRead',
                                    'root View body becomes a throwing evaluate method on an owned root descriptor',
                                    'actual child View/Canvas traversal uses a disposable visitor, not Semantic Core'])


def check():
    source=(HERE/'Authoring.swift.txt').read_text(); original,_=generate(source)
    cases={
      'unknown_field':source.replace('counterText(model.value)','counterText(model.missing)'),
      'unchecked_helper':source.replace('traceLevel(model: model, index: 17)','unreviewed(model: model, index: 17)'),
      'outside_entrypoint':source+'\nlet escaped = model.value\n',
      'capture_stored':source.replace('model.capture.level(at: index)','model.capture'),
      'raw_pointer_schema':source.replace('value: UInt32','value: UnsafeRawPointer'),
      'escaping_closure':source.replace('return model.capture.level(at: index)','return { model.capture.level(at: index) }'),
      'wrong_model_type':source.replace('traceLevel(model: model, index: 17)','traceLevel(model: bounds, index: 17)'),
    }
    records=[]
    for name,mutated in cases.items():
        try: generate(mutated)
        except Unsupported as error: records.append(dict(case=name,result='rejected',diagnostic=str(error),source=mutated))
        else: raise AssertionError('accepted '+name)
    mutations={'property_selection':source.replace('counterText(model.value)','counterText(model.scale)'),
               'initializer':source.replace('scale: UInt32 = 7','scale: UInt32 = 11'),
               'body_topology':source.replace('HStack(spacing: 0)','VStack(spacing: 0)')}
    for name,mutated in mutations.items():
        output,manifest=generate(mutated)
        assert output!=original
        records.append(dict(case=name,result='source-dependent output',source=mutated,output=output,manifest=manifest))
    (HERE/'evidence/generator-controls.json').write_text(json.dumps(records,indent=2)+'\n')
    print(f'generator: {len(cases)} rejections, {len(mutations)} source-dependency controls')

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='check': check()
    else:
        output,manifest=generate((HERE/'Authoring.swift.txt').read_text())
        (HERE/'Generated.swift').write_text(output)
        (HERE/'evidence/generation.json').write_text(json.dumps(manifest,indent=2)+'\n')
        print('Generated.swift written from checked corpus')
