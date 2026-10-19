"""Real filesystem adversarial checks; no runner, compiler or driver invocation."""
from pathlib import Path
import copy
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parent))
from readiness import (actual, sha, tree_entries, verify_trees, verify_receipt,
                       verify_stage_captures, verify_reviewed_packet,
                       verify_context, qualify_schema4, qualify_counter, verify_archive)

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent


class FilesystemTests(unittest.TestCase):
    def test_real_complete_applicability(self):
        verify_context(ROOT, PACKET, json.loads(actual(PACKET / 'recipe.json')))
        out = Path(json.loads(actual(PACKET / 'recipe.json'))['output_root'])
        self.assertFalse(out.exists() or out.is_symlink())

    def test_tree_bytes_additions_deletions_aliases(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root = Path(temp)
            (root / 'producer.o').write_bytes(b'object')
            (root / 'module.swiftmodule').write_bytes(b'module')
            expected = {str(root): tree_entries(root)}
            verify_trees(expected)
            for name in ('extra.o', 'extra.swiftmodule', 'cache-extra'):
                (root / name).write_bytes(b'new')
                with self.assertRaises(ValueError): verify_trees(expected)
                (root / name).unlink()
            (root / 'producer.o').write_bytes(b'changed')
            with self.assertRaises(ValueError): verify_trees(expected)
            (root / 'producer.o').unlink()
            (root / 'producer.o').symlink_to(root / 'module.swiftmodule')
            with self.assertRaises(ValueError): verify_trees(expected)

    def test_tree_directory_and_link_identity(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root = Path(temp)
            (root / 'target').mkdir()
            (root / 'alias').symlink_to('target')
            expected = {str(root): tree_entries(root)}
            (root / 'alias').unlink()
            (root / 'alias').symlink_to('./target')
            with self.assertRaises(ValueError): verify_trees(expected)
            with self.assertRaises(ValueError): tree_entries(root / 'alias')

    def test_receipt_source_artifact_and_traversal(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root = Path(temp); source = root / 'Source.swift'; source.write_bytes(b'source')
            producer = root / 'producer'; producer.mkdir(); artifact = producer / 'a.o'; artifact.write_bytes(b'object')
            receipt = producer / 'result.json'
            data = dict(inputs={'Source.swift': sha(source.read_bytes())}, artifacts={'a.o': dict(bytes=6, sha256=sha(b'object'))})
            def write(value): receipt.write_text(json.dumps(value)); return sha(receipt.read_bytes())
            identity = write(data); verify_receipt(receipt, identity, root)
            source.write_bytes(b'mutant')
            with self.assertRaises(ValueError): verify_receipt(receipt, identity, root)
            source.write_bytes(b'source'); artifact.write_bytes(b'mutant')
            with self.assertRaises(ValueError): verify_receipt(receipt, identity, root)
            artifact.write_bytes(b'object'); bad=copy.deepcopy(data);bad['artifacts']['../escape.o']=bad['artifacts'].pop('a.o')
            identity=write(bad)
            with self.assertRaises(ValueError): verify_receipt(receipt, identity, root)
            with self.assertRaises(ValueError): verify_receipt(receipt, '0'*64, root)

    def test_raw_stage_and_audit_mutation(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root=Path(temp); stream=root/'stderr';audit=root/'audit.json'
            stream.write_bytes(b'first error');audit.write_bytes(b'audit')
            data=dict(stage_captures=[dict(stdout=dict(path=str(stream),sha256=sha(stream.read_bytes())),stderr=dict(path=str(stream),sha256=sha(stream.read_bytes())))],prelaunch_audits=[dict(path=str(audit),sha256=sha(audit.read_bytes()))])
            verify_stage_captures(data)
            for path in (stream,audit):
                saved=path.read_bytes();path.write_bytes(b'changed')
                with self.assertRaises(ValueError):verify_stage_captures(data)
                path.write_bytes(saved)

    def test_schema4_required_joins_and_provenance(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root=Path(temp);runtime=root/'runtime';runtime.mkdir();(runtime/'result.json').write_bytes(b'runtime')
            out=root/'host';out.mkdir();receipt=out/'result.json'
            labels=['activation-join','activation-copy','activation-callback','activation-constant-callback','activation-backing','execute']
            data=dict(profile='macos-static',runtime_build='runtime',runtime_receipt_sha256=sha(b'runtime'),checks=[dict(name=n,passed=True) for n in labels],execution='assertions=42 failures=0')
            def write(d):receipt.write_text(json.dumps(d))
            write(data);qualify_schema4(root,runtime,out)
            for label in labels:
                bad=copy.deepcopy(data);bad['checks']=[x for x in bad['checks'] if x['name']!=label];write(bad)
                with self.assertRaises(ValueError):qualify_schema4(root,runtime,out)
            for key,value in [('runtime_receipt_sha256','0'*64),('runtime_build','wrong'),('profile','macos-dynamic')]:
                bad=copy.deepcopy(data);bad[key]=value;write(bad)
                with self.assertRaises(ValueError):qualify_schema4(root,runtime,out)

    def test_counter_384_aggregate_and_exact_dependencies(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root=Path(temp)
            for n in ('runtime','host','counter'):(root/n).mkdir()
            for n in ('runtime','host'):(root/n/'result.json').write_bytes(n.encode())
            data=dict(collection_complete=True,passed=True,fresh_focused=False,profile='macos-static',selected_host_profile='macos-static',runtime_build='runtime',host_build='host',runtime_receipt_sha256=sha(b'runtime'),host_receipt_sha256=sha(b'host'),checks=[dict(name=str(n),passed=True,status='passed') for n in range(384)])
            receipt=root/'counter/result.json'
            def check(d):
                receipt.write_text(json.dumps(d));qualify_counter(root,root/'runtime',root/'host',root/'counter')
            check(data)
            for key,value in [('collection_complete',False),('passed',False),('fresh_focused',True),('host_receipt_sha256','0'*64),('runtime_receipt_sha256','0'*64),('host_build','other')]:
                bad=copy.deepcopy(data);bad[key]=value
                with self.assertRaises(ValueError):check(bad)
            for mutation in ('duplicate','missing','failed'):
                bad=copy.deepcopy(data)
                if mutation=='duplicate':bad['checks'][-1]['name']='0'
                if mutation=='missing':bad['checks'].pop()
                if mutation=='failed':bad['checks'][-1]['passed']=False
                with self.assertRaises(ValueError):check(bad)

    def test_external_git_pins_and_packet_substitution(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root=Path(temp);packet=root/'packet';packet.mkdir();(packet/'run.py').write_text('original')
            def git(*args):return subprocess.check_output(['git','--no-replace-objects',*args],cwd=root,stderr=subprocess.DEVNULL).decode().strip()
            git('init');git('add','packet');git('-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','-m','fixture')
            commit=git('rev-parse','HEAD');tree=git('rev-parse','HEAD^{tree}');ptree=git('rev-parse','HEAD:packet')
            verify_reviewed_packet(root,packet,commit,tree,ptree)
            verify_archive(root,packet,commit)
            for pins in [('0'*40,tree,ptree),(commit,'0'*40,ptree),(commit,tree,'0'*40),('*',tree,ptree)]:
                with self.assertRaises((ValueError,subprocess.CalledProcessError)):verify_reviewed_packet(root,packet,*pins)
            (packet/'run.py').write_text('substituted')
            with self.assertRaises(ValueError):verify_reviewed_packet(root,packet,commit,tree,ptree)
            (packet/'run.py').write_text('original');(packet/'extra.py').write_text('extra')
            with self.assertRaises(ValueError):verify_reviewed_packet(root,packet,commit,tree,ptree)


    def test_git_bootstrap_uses_frozen_code_and_rejects_substitution(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root=Path(temp);packet=root/'packet';packet.mkdir();marker=root/'launched'
            (packet/'readiness.py').write_bytes(actual(PACKET/'readiness.py'))
            (packet/'run.py').write_text("from pathlib import Path\nPath("+repr(str(marker))+").write_text('reviewed fixture only')\n")
            def git(*args):return subprocess.check_output(['git','--no-replace-objects',*args],cwd=root,stderr=subprocess.DEVNULL).decode().strip()
            git('init');git('add','packet');git('-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','-m','fixture')
            pins=[git('rev-parse','HEAD'),git('rev-parse','HEAD^{tree}'),git('rev-parse','HEAD:packet')]
            # Only fixture-location constants differ from the real bootstrap.
            bootstrap=actual(PACKET/'reviewed-launch.py').decode().replace("root = Path('/Users/eugene/work/GiftUI')",'root = Path('+repr(str(root))+')')
            relative=str(PACKET.relative_to(ROOT));bootstrap=bootstrap.replace('relative = '+repr(relative),"relative = 'packet'")
            def launch(values):return subprocess.run(['/Applications/Xcode.app/Contents/Developer/usr/bin/python3','-I','-S','-B','-X','pycache_prefix=/dev/null','-',*values],input=bootstrap.encode(),cwd=root,capture_output=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'))
            result=launch(pins);self.assertEqual(result.returncode,0,result.stderr.decode());self.assertEqual(marker.read_text(),'reviewed fixture only');marker.unlink()
            saved=(packet/'run.py').read_bytes();(packet/'run.py').write_text("raise SystemExit('mutable runner executed')")
            self.assertNotEqual(launch(pins).returncode,0);self.assertFalse(marker.exists());(packet/'run.py').write_bytes(saved)
            (packet/'readiness.py').write_text("raise SystemExit('mutable verifier executed')")
            self.assertNotEqual(launch(pins).returncode,0);self.assertFalse(marker.exists())
            self.assertNotEqual(launch([pins[0],'0'*40,pins[2]]).returncode,0)


    def test_valid_helper_bytecode_is_rejected_by_exact_driver_environment(self):
        import importlib.util
        import py_compile
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root=Path(temp);scripts=root/'scripts/contracts';scripts.mkdir(parents=True);poison_prefix=root/'poison-cache'
            for module in ('p08_check_collection','p08_layout_facts'):
                source=scripts/(module+'.py');source.write_bytes(actual(ROOT/'scripts/contracts'/(module+'.py')))
                payload=("print('SUBSTITUTED_BYTECODE_"+module+"')\n").encode()
                poison=root/(module+'-poison.py');poison.write_bytes(payload+b'#'*(source.stat().st_size-len(payload)))
                os.utime(poison,ns=(source.stat().st_atime_ns,source.stat().st_mtime_ns))
                cache=poison_prefix/str(source.parent).lstrip('/')/(module+'.cpython-39.pyc');cache.parent.mkdir(parents=True,exist_ok=True)
                py_compile.compile(str(poison),cfile=str(cache),dfile=str(source),doraise=True)
            driver=scripts/'import_helpers.py';driver.write_text("import p08_check_collection\nimport p08_layout_facts\nprint('IMPORTS_COMPLETE')\n")
            recipe=json.loads(actual(PACKET/'recipe.json'));safe=dict(recipe['environment']);unsafe=dict(safe);unsafe['PYTHONPYCACHEPREFIX']=str(poison_prefix)
            command=['python3',str(driver)]
            before={str(x):sha(x.read_bytes()) for x in poison_prefix.rglob('*.pyc')}
            baseline=subprocess.run(command,executable=recipe['python_executable'],cwd=root,env=unsafe,capture_output=True)
            self.assertEqual(baseline.returncode,0,baseline.stderr.decode());self.assertEqual(baseline.stdout.count(b'SUBSTITUTED_BYTECODE_'),2)
            protected=subprocess.run(command,executable=recipe['python_executable'],cwd=root,env=safe,capture_output=True)
            self.assertEqual(protected.returncode,0,protected.stderr.decode());self.assertNotIn(b'SUBSTITUTED_BYTECODE_',protected.stdout);self.assertIn(b'IMPORTS_COMPLETE',protected.stdout)
            self.assertEqual(before,{str(x):sha(x.read_bytes()) for x in poison_prefix.rglob('*.pyc')})

    def test_ambient_pathlib_is_rejected_by_exact_bootstrap_startup(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            root=Path(temp);marker=root/'ambient-imported'
            (root/'pathlib.py').write_text("open("+repr(str(marker))+",'w').write('ambient pathlib executed')\n")
            interpreter='/Applications/Xcode.app/Contents/Developer/usr/bin/python3'
            poison=dict(os.environ,PYTHONPATH=str(root),PYTHONDONTWRITEBYTECODE='1')
            baseline=subprocess.run([interpreter,'-B','-c','import pathlib'],cwd=root,env=poison,capture_output=True)
            self.assertEqual(baseline.returncode,0);self.assertTrue(marker.exists());marker.unlink()
            # Same env -i/absolute interpreter/flags as the reviewed launch form.
            command=['/usr/bin/env','-i','HOME=/Users/eugene','TMPDIR=/private/tmp','PATH=/usr/bin:/bin:/usr/sbin:/sbin',interpreter,'-I','-S','-B','-X','pycache_prefix=/dev/null','-','0'*40,'0'*40,'0'*40]
            protected=subprocess.run(command,input=actual(PACKET/'reviewed-launch.py'),cwd=root,env=poison,capture_output=True)
            self.assertNotEqual(protected.returncode,0);self.assertFalse(marker.exists());self.assertIn(b'bad file',protected.stderr)
            identity=subprocess.run(command[:-4]+['-c',"import pathlib,sys,json;print(json.dumps(dict(executable=sys.executable,prefix=sys.prefix,path=sys.path,isolated=sys.flags.isolated,no_site=sys.flags.no_site,cache=sys.pycache_prefix)))"],cwd=root,env=poison,capture_output=True)
            self.assertEqual(identity.returncode,0,identity.stderr.decode());facts=json.loads(identity.stdout)
            self.assertEqual(facts['executable'],interpreter);self.assertEqual(facts['isolated'],1);self.assertEqual(facts['no_site'],1);self.assertEqual(facts['cache'],'/dev/null');self.assertNotIn(str(root),facts['path'])


if __name__=='__main__':
    unittest.main(verbosity=2)
