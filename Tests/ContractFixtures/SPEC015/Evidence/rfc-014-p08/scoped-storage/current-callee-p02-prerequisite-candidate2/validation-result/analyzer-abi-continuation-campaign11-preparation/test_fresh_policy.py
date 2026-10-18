#!/usr/bin/env python3
"""Compiler-free finite matcher accepts and adversarial mutations."""
from pathlib import Path
import ast
import copy
import hashlib
import json
import unittest
import fresh_policy as f

PACKET = Path(__file__).resolve().parent
POLICY = (PACKET / 'batch1-policy.json').read_bytes()
TEMPLATES = (PACKET / 'fresh-templates.json').read_bytes()
P = json.loads(POLICY)
T = json.loads(TEMPLATES)


def inputs(key):
    case, template = P['cases'][key], T[key]
    core = '/Users/eugene/work/GiftUI/.build/authenticated-test-only/' + case['profile']
    argv = [core if t == template['core'] else f.relocate(t) if t.startswith('/') else t
            for t in template['argv']]
    context = {'key': key, 'profile': case['profile'], 'stage': case['stage'],
               'control': template['control'], 'policy_sha256': f.POLICY_SHA,
               'p02': {'root': core}, 'argv': argv, 'cwd': f.ROOT,
               'preceding_producers': {'synthetic': True}, 'current_commit': 'a' * 40}
    sources = {f.relocate(p): P['source_pool'][v['sha256']].encode()
               for p, v in case['sources'].items()}
    return context, sources, argv, core


class FreshPolicyTests(unittest.TestCase):
    def test_exact_finite_forms_and_mutations(self):
        self.assertEqual(len(P['cases']), 45)
        for key in P['cases']:
            with self.subTest(key=key):
                context, sources, argv, core = inputs(key)
                cap = f.prepare(POLICY, context, sources, argv, core, TEMPLATES)
                self.assertFalse(f.finish(cap, context, sources, cap.stdout, cap.stderr, 1)['qualified'])
                for exit_code in [0, 2, -9, True, 1.0, None]:
                    with self.assertRaises(ValueError):
                        f.finish(cap, context, sources, cap.stdout, cap.stderr, exit_code)
                for stdout, stderr in [(cap.stdout+b'x',cap.stderr), (cap.stdout,cap.stderr+b'\n'),
                                       (cap.stdout,cap.stderr[:-1]), (cap.stdout,cap.stderr.replace(b'error:',b'warning:'))]:
                    with self.assertRaises(ValueError):
                        f.finish(cap, context, sources, stdout, stderr, 1)
                for field in ['current_commit', 'p02', 'preceding_producers']:
                    changed = copy.deepcopy(context);changed[field] = 'drift'
                    with self.assertRaises(ValueError):
                        f.finish(cap, changed, sources, cap.stdout, cap.stderr, 1)
                changed = dict(sources); path = next(iter(changed));changed[path] += b' '
                with self.assertRaises(ValueError):
                    f.prepare(POLICY, context, changed, argv, core, TEMPLATES)
                changed_argv = list(argv);changed_argv[0] += '-other'
                with self.assertRaises(ValueError):
                    f.prepare(POLICY, context, sources, changed_argv, core, TEMPLATES)
                changed_context = copy.deepcopy(context);changed_context['control']['id'] = 'wrong'
                with self.assertRaises(ValueError):
                    f.prepare(POLICY, changed_context, sources, argv, core, TEMPLATES)
                with self.assertRaises(ValueError):
                    f.prepare(POLICY, context, sources, argv, core+'-other', TEMPLATES)
                with self.assertRaises(ValueError):
                    f.prepare(POLICY, context, sources, argv, core, TEMPLATES+b' ')

    def test_exact_runner_planned_argv(self):
        plan = json.loads((PACKET/'recipe.json').read_text())
        tree = ast.parse((PACKET/'execute-proposal.py').read_text())
        main = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'main')
        functions = [n for n in main.body if isinstance(n, ast.FunctionDef) and n.name in ('expand','module_argv')]
        scope = {'plan': plan}
        exec(compile(ast.Module(body=functions,type_ignores=[]), '<pure planned argv>', 'exec'), scope)
        for key, case in P['cases'].items():
            context, sources, argv, core = inputs(key)
            profile = case['profile'];control=T[key]['control']
            root = Path(f.ROOT)/plan['output_roots'][profile]
            cell = root/'scratch'/control['id']
            if control['kind'] == 'abi-negative':
                planned = scope['module_argv'](case['stage'],profile,cell,Path(core))
            else:
                negative = cell/'inputs'/Path(control['files'][0]).name
                planned = scope['expand'](plan['scratch_negative_argv'],profile,cell,Path(core),
                    root/'scratch/positive-actual-lowering', negative=negative, outside=control['package_name'] is None)
            self.assertEqual(planned, argv, key)

    def test_literal_path_components(self):
        for old, new in f.MAP:
            self.assertEqual(f.relocate(old+'/file'), new+'/file')
            self.assertEqual(f.relocate(old+'-alias/file'), old+'-alias/file')
            for suffix in ['/../file','//file','/./file']:
                with self.assertRaises(ValueError):f.relocate(old+suffix)
        self.assertEqual(len(set(new for old,new in f.MAP)),3)

    def test_runner_structure(self):
        source = (PACKET/'execute-proposal.py').read_text()
        ast.parse(source)
        for text in ['fresh_context(label, argv, env) == fresh',
                     'fresh_context(label, argv, env) == prior',
                     'remember_producer(row)', 'fresh_policy.prepare(', 'fresh_policy.finish(',
                     "len(state['control_receipts']) == len(controls['controls']) * 4 == 80",
                     "'STOP_first_material_failure_dependents_unrun_no_retry_zero_repairs'"]:
            self.assertIn(text, source)
        plan = json.loads((PACKET/'recipe.json').read_text())
        self.assertEqual(plan['profile_order'], ['macos-static','raspberry-pi-armv6','nrf52840-embedded','macos-dynamic'])
        self.assertEqual(plan['automatic_repairs'],0)
        self.assertEqual(plan['retries'],0)
        self.assertTrue(all(not (Path(f.ROOT)/p).exists() for p in plan['output_roots'].values()))


if __name__ == '__main__':
    unittest.main()
