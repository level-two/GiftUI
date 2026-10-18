#!/usr/bin/env python3
import hashlib, json
from pathlib import Path
root = Path(__file__).resolve().parents[7]
base = Path(__file__).resolve().parent
receipt = json.loads((base / "receipt.json").read_text())
for item in receipt["inputs"]:
    path = root / item["path"]
    assert path.stat().st_size == item["bytes"], path
    assert hashlib.sha256(path.read_bytes()).hexdigest() == item["sha256"], path
for item in json.loads((base / "manifest.json").read_text())["members"]:
    path = base / item["path"]
    assert hashlib.sha256(path.read_bytes()).hexdigest() == item["sha256"], path
print("read-only packet inputs and members verified")
