# Exact unchanged-function comparison

`unchanged-transfer-check.json` records the executed comparison. This is an ordinary read-only projection with the existing pure object reader; no decoder, recorder, compiler or guard was changed. The following Python was executed from the repository root. `obj` reads the named old/current object with the existing `parse` function extracted by AST from `current-native-static-batchA59-local/selected-current.py`; that file's entry point was never run.

```python
import ast, struct, json, hashlib
from pathlib import Path
root = Path.cwd()
base = root / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage'
t = ast.parse((base / 'current-native-static-batchA59-local/selected-current.py').read_text())
ns = {'struct': struct, 'charge': lambda n: None, 'check': lambda *a: None}
node = next(x for x in t.body if isinstance(x, ast.FunctionDef) and x.name == 'parse')
exec(compile(ast.Module(body=[node], type_ignores=[]), 'retained-parse', 'exec'), ns)
cache = {}
def obj(p):
    p = Path(p)
    if str(p) not in cache:
        b = p.read_bytes()
        ss, rr = ns['parse'](b)
        cache[str(p)] = (b, ss, rr, {q['symbol']: q for q in rr})
    return cache[str(p)]
def fp(p, name, seen=()):
    b, ss, rr, by = obj(p)
    r = by.get(name)
    if not r or not r['section']:
        return ['external', name]
    if name in seen:
        return ['cycle', len(seen) - seen.index(name)]
    s = ss[r['section'] - 1]
    lo = r['address']
    hi = min([q['address'] for q in rr if q['section'] == r['section']
              and q['address'] > lo] + [s['addr'] + s['bytes']])
    raw = (bytes(hi-lo) if s['name'] in ['__bss', '__common'] else
           b[s['file']+lo-s['addr']:s['file']+hi-s['addr']])
    rels = []
    for i in range(s['nreloc']):
        a, n = struct.unpack_from('<iI', b, s['reloff'] + i*8)
        if lo-s['addr'] <= a < hi-s['addr']:
            target = rr[n & 0xffffff]['symbol'] if n & (1 << 27) else n & 0xffffff
            if isinstance(target, str) and target.startswith('_OUTLINED_FUNCTION_'):
                target = ['complete_outline', fp(p, target, seen + (name,))]
            rels.append([a-(lo-s['addr']), n >> 28, (n >> 24) & 15, target])
    return hashlib.sha256(json.dumps([s['name'], raw.hex(), rels],
                                     sort_keys=True).encode()).hexdigest()
```

Selection used complete named captures in the existing `canonical-supplied-sink-{owners,reached,captures,support,core-support,final-support,pending-init-target}.json` manifests. The old object is each capture's exact final `argv` input. The current object has the same filename under `traversal-realization1/artifacts`. Each output row records both object paths, exact symbol and both digests. Missing current symbols were not promoted; historical outline ordinals were not compared as identities. The 32 prior complete raw files are named by `raw_prior`, counted in the final semantic union and remain available in the accepted prior package.

Twenty-eight named complete functions match. Equality requires all machine bytes and all symbolic relocation rows, recursively including complete outline implementations; merely ignoring changed outline numbers would not suffice. The four nonmatching bodies are explicitly **not** accepted by this comparison. Their current complete captures are `changed-transfers.json`, with actual reached support in `last-joins.json` captures 0–9. Those bodies use fixed descriptor/scalar copies, bounded initialization, `memcpy`/`bzero` and a stack-corruption failure branch. No metadata/allocator call occurs in this small current constructor/Writer closure. Actual current backing VWT bytes and every symbolic target also match the prior projection; both destroy slots remain the checked Core no-op target.

This transfers only the already accepted scoped codec/lender/capture/transfer/backing effects with unchanged arguments, capacities and loans. It does not transfer unrelated global safety, loaded bindings, cold cache observations, or allocation-free eligibility of existing declaration/result/error dependencies.
