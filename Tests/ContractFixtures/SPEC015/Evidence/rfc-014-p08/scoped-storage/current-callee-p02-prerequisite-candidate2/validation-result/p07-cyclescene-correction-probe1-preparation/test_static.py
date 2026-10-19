"""Compiler-free adversarial readiness checks. Never launch run.py."""
from pathlib import Path
import copy
import json
import tempfile
import unittest
from unittest.mock import patch
import readiness as v

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent
RECIPE = json.loads((PACKET / 'recipe.json').read_text())

class StaticTests(unittest.TestCase):
    def context(self, recipe=None):
        v.verify_context(ROOT, PACKET, recipe or RECIPE)

    def test_real_context_and_fresh_root(self):
        self.context()
        self.assertFalse(Path(RECIPE['output_root']).exists())
        self.assertFalse(Path(RECIPE['output_root']).is_symlink())

    def changed_file_rejects(self, original, replacement):
        # Mutate real temporary files, redirect only that authenticated read.
        original = Path(original)
        real_actual = v.actual
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp).resolve() / 'mutated'
            target.write_bytes(replacement)
            def changed(path):
                return real_actual(target if Path(path) == original else path)
            with patch.object(v, 'actual', changed):
                with self.assertRaises((ValueError, AssertionError, json.JSONDecodeError)):
                    self.context()

    def test_source_correction_mutation(self):
        source = ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/Cycle.swift'
        self.changed_file_rejects(source, source.read_bytes().replace(b'@usableFromInline ', b'', 1))

    def test_recipe_profile_core_operand_and_budget(self):
        for field, value in [('argv', RECIPE['argv'][:-1] + ['/wrong/core']),
                             ('automatic_repairs', 1), ('producer', dict(RECIPE['producer'], sha256='0'*64))]:
            recipe = copy.deepcopy(RECIPE)
            recipe[field] = value
            with self.subTest(field=field), self.assertRaises((ValueError, AssertionError)):
                self.context(recipe)

    def test_core_provenance_and_script_bytes(self):
        paths = [Path(RECIPE['campaign_result']), Path(RECIPE['producer']['path']),
                 Path(RECIPE['producer']['copy']), Path(RECIPE['producer']['path']).parent / 'GiftUI.o',
                 Path(RECIPE['producer']['path']).parent / 'commands.txt',
                 ROOT / 'scripts/contracts/check-spec-013-runtime-cycle.py']
        for target in paths:
            with self.subTest(path=str(target)):
                self.changed_file_rejects(target, target.read_bytes() + b'\nchanged')

    def test_external_commit_tree_pins(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp).resolve()
            packet = root / 'packet'
            packet.mkdir()
            (packet / 'run.py').write_text('original')
            v.git(root, 'init', '-q')
            v.git(root, 'add', 'packet')
            v.git(root, '-c', 'user.name=Static Test', '-c', 'user.email=test@example.invalid', 'commit', '-qm', 'fixture')
            commit = v.git(root, 'rev-parse', 'HEAD').decode().strip()
            tree = v.git(root, 'rev-parse', 'HEAD^{tree}').decode().strip()
            subtree = v.git(root, 'rev-parse', 'HEAD:packet').decode().strip()
            v.verify_reviewed_packet(root, packet, commit, tree, subtree)
            for pins in [('0'*40,tree,subtree),(commit,'0'*40,subtree),(commit,tree,'0'*40)]:
                with self.assertRaises(Exception):
                    v.verify_reviewed_packet(root, packet, *pins)
            (packet / 'run.py').write_text('resealed replacement')
            with self.assertRaises(ValueError):
                v.verify_reviewed_packet(root, packet, commit, tree, subtree)

    def test_discovery_added_file_and_alias(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp).resolve()
            (root/'source').mkdir()
            (root/'source/a.swift').write_text('a')
            rules = [{'base':'source','recursive':True,'suffix':'.swift'}]
            definition = {'rules':rules,'files':v.inventory(root,rules)}
            (root/'source/b.swift').write_text('b')
            with self.assertRaises(ValueError):v.verify_inventory(root, definition)
            (root/'source/b.swift').unlink()
            (root/'source/b.swift').symlink_to(root/'source/a.swift')
            with self.assertRaises(ValueError):v.verify_inventory(root, definition)

if __name__ == '__main__':
    unittest.main(verbosity=2, failfast=True)
