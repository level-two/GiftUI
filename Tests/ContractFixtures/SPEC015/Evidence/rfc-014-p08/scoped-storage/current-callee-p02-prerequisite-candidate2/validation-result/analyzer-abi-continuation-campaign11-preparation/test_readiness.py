#!/usr/bin/env python3
"""Actual filesystem mutation tests; no compiler or campaign execution."""
from pathlib import Path
import ast
import copy
import hashlib
import json
import os
import subprocess
import tempfile
import unittest
import readiness as r

PACKET = Path(__file__).resolve().parent


def write(path, data):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_bytes(data)
    return r.sha(data)


def nested(name):
    tree=ast.parse((PACKET/'execute-proposal.py').read_text())
    main=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='main')
    return ast.Module(body=[next(n for n in main.body if isinstance(n,ast.FunctionDef) and n.name==name)],type_ignores=[])


class ReadinessTests(unittest.TestCase):
    def test_external_git_pin_rejects_resealed_packet_and_head(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory).resolve();packet=root/'packet';packet.mkdir()
            write(packet/'runner.py',b'reviewed')
            def git(*args):return subprocess.check_output(['git',*args],cwd=root,stderr=subprocess.DEVNULL).decode().strip()
            git('init');git('add','packet');git('-c','user.name=Test','-c','user.email=test@example.invalid','commit','-m','reviewed')
            commit=git('rev-parse','HEAD');tree=git('rev-parse','HEAD^{tree}');pt=git('rev-parse','HEAD:packet')
            r.verify_reviewed_packet(root,packet,commit,tree,pt)
            write(packet/'runner.py',b'changed');write(packet/'packet-hashes.json',json.dumps({'runner.py':r.sha(b'changed')}).encode())
            with self.assertRaises(ValueError):r.verify_reviewed_packet(root,packet,commit,tree,pt)
            (packet/'packet-hashes.json').unlink();write(packet/'runner.py',b'reviewed')
            write(root/'new',b'next');git('add','new');git('-c','user.name=Test','-c','user.email=test@example.invalid','commit','-m','next')
            with self.assertRaises(ValueError):r.verify_reviewed_packet(root,packet,commit,tree,pt)

    def test_all_541_files_compiler_and_added_glob_input(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory).resolve()
            expected={f'inputs/{i}.swift':write(root/f'inputs/{i}.swift',str(i).encode()) for i in range(541)}
            compiler={'compiler':{'sha256':write(root/'compiler',b'compiler'),'resolved':str(root/'compiler')}}
            definition={'rules':[{'base':'inputs','recursive':True,'suffix':'.swift'}],'files':dict(expected)}
            r.verify_files(root,expected);r.verify_tools(root,compiler);r.verify_inventory(root,definition)
            write(root/'inputs/540.swift',b'changed')
            with self.assertRaises(ValueError):r.verify_files(root,expected)
            write(root/'inputs/540.swift',b'540');write(root/'inputs/extra.swift',b'extra')
            with self.assertRaises(ValueError):r.verify_inventory(root,definition)
            (root/'inputs/extra.swift').unlink();write(root/'compiler',b'changed')
            with self.assertRaises(ValueError):r.verify_tools(root,compiler)
            (root/'inputs/0.swift').unlink();(root/'inputs/0.swift').symlink_to(root/'inputs/1.swift')
            with self.assertRaises(ValueError):r.verify_inventory(root,definition)

    def test_actual_sdk_file_inventory_and_symlink_mutations(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory).resolve();sdk=root/'sdk';sdk.mkdir();write(sdk/'library',b'good')
            archive=root/'archive';write(archive,b'archive');provenance=root/'install';write(provenance,b'install')
            inventory={'root':str(sdk),'entries':[{'path':'library','kind':'file','bytes':4,'sha256':r.sha(b'good')}],
                'archive':{'path':str(archive),'bytes':7,'sha256':r.sha(b'archive')},'install_provenance':{'path':str(provenance),'sha256':r.sha(b'install')}}
            write(root/'sdk.json',json.dumps(inventory).encode())
            def read(name):return inventory if name=='sdk.json' else {'precompile_identity':{'sdk':{'path':str(sdk/'sysroot')}}}
            scope={'read':read,'plan':{'armv6_sdk_inventory':'sdk.json'},'Path':Path,'os':os,'PACKET':root,
                   'digest':lambda path:r.sha(Path(path).read_bytes()),'stream_digest':lambda path:r.sha(Path(path).read_bytes())}
            exec(compile(nested('authenticate_armv6_sdk'),'<actual SDK authenticator>','exec'),scope)
            check=scope['authenticate_armv6_sdk'];check()
            write(sdk/'library',b'evil')
            with self.assertRaises(AssertionError):check()
            write(sdk/'library',b'good');write(sdk/'added',b'extra')
            with self.assertRaises(AssertionError):check()
            (sdk/'added').unlink();(sdk/'library').unlink();(sdk/'library').symlink_to(archive)
            with self.assertRaises(AssertionError):check()

    def test_actual_80_receipt_gate_and_transitive_mutations(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory).resolve();profiles=['macos-static','raspberry-pi-armv6','nrf52840-embedded','macos-dynamic']
            controls=[{'id':str(i)} for i in range(20)]
            state={'control_receipts':[],'producer_receipts':[],'stages':[],'armv6_sdk_preflight':{}}
            refs={}
            for profile in profiles:
                core=root/profile/'core';payload=b'core';write(core/'GiftUI.o',payload)
                write(core/'macro-tool',b'macro')
                data={'package':'P02','profile':profile,'source_commit':'reviewed','macro_tool':str((core/'macro-tool').relative_to(root)),'macro_tool_sha256':r.sha(b'macro'),'artifacts':{'GiftUI.o':{'bytes':4,'sha256':r.sha(payload)}}}
                receipt=core/'result.json';identity=write(receipt,json.dumps(data).encode());copy_path=core/'copy.json';write(copy_path,receipt.read_bytes())
                refs[profile]={'path':str(receipt),'sha256':identity}
                state['producer_receipts'].append({'path':str(receipt),'sha256':identity,'copy':str(copy_path)})
                positive=root/profile/'positive';write(positive/'Domain.o',b'domain')
                for control in controls:
                    cell=root/profile/control['id'];write(cell/'input.swift',b'input')
                    data={'passed':True,'profile':profile,'control':control['id'],'core_receipt_sha256':identity,
                        'transitive_imports':{'core':refs[profile],'positive_scratch':{'Domain.o':r.sha(b'domain')}},
                        'positive_cell':str(positive),'artifacts':{'input.swift':{'bytes':5,'sha256':r.sha(b'input')}}}
                    path=cell/('control-'+control['id']+'.json');h=write(path,json.dumps(data).encode())
                    state['control_receipts'].append({'profile':profile,'control':control['id'],'path':str(path),'sha256':h})
            scope={'verify':lambda:None,'state':state,'plan':{'profile_order':profiles},'controls':{'controls':controls},
                   'readiness':r,'ROOT':root,'Path':Path,'refs':refs,'actual_bytes':r.actual,'json':json,'hashlib':hashlib,
                   'producer_snapshots':{},'current_commit':'reviewed','authenticate_armv6_sdk':lambda:{},
                   'exact_identity':lambda a,b:a==b,'read':lambda name:{p:{} for p in profiles}}
            exec(compile(nested('authenticate_campaign_receipts'),'<actual 80 receipt gate>','exec'),scope)
            check=scope['authenticate_campaign_receipts'];check()
            for index in (0,79):
                path=Path(state['control_receipts'][index]['path']);old=path.read_bytes();write(path,b'{}')
                with self.assertRaises(ValueError):check()
                write(path,old)
            target=root/profiles[0]/'core/GiftUI.o';write(target,b'evil')
            with self.assertRaises(ValueError):check()
            write(target,b'core');tool=root/profiles[0]/'core/macro-tool';write(tool,b'changed')
            with self.assertRaises(ValueError):check()
            write(tool,b'macro');write(root/profiles[-1]/'positive/Domain.o',b'changed')
            with self.assertRaises(ValueError):check()
            write(root/profiles[-1]/'positive/Domain.o',b'domain');write(root/profiles[0]/'core/Injected.o',b'new')
            with self.assertRaises(AssertionError):check()


if __name__=='__main__':unittest.main()
