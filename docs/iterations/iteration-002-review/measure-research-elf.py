"""Capture paired linked-image sizes, ABI, heap configuration and source identity."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys

root = Path.cwd()
prefix = root / ".toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-"
record = {"revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
          "limits": "Linked size and configured stack reservation; no physical timing or stack high-water measurement",
          "images": {}}
for name, directory in zip(("baseline", "candidate"), sys.argv[2:4]):
    build = root / directory
    elf = build / "zephyr/zephyr.elf"
    headers = subprocess.check_output([str(prefix) + "readelf", "-lW", str(elf)], text=True)
    attrs = subprocess.check_output([str(prefix) + "readelf", "-A", str(elf)], text=True)
    symbols = subprocess.check_output([str(prefix) + "nm", "-S", str(elf)], text=True)
    config = (build / "zephyr/.config").read_text()
    loads = [line.split() for line in headers.splitlines() if line.strip().startswith("LOAD ")]
    entry = {"elf": str(elf.relative_to(root)), "sha256": hashlib.sha256(elf.read_bytes()).hexdigest(),
             "flash_bytes": sum(int(line[4], 16) for line in loads),
             "ram_bytes": sum(int(line[5], 16) for line in loads if line[2].startswith("0x2")),
             "v7em": "Tag_CPU_arch: v7E-M" in attrs,
             "hard_float": "Tag_ABI_VFP_args: VFP registers" in attrs,
             "zero_zephyr_heap": "CONFIG_HEAP_MEM_POOL_SIZE=0" in config,
             "zero_libc_heap": "CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0" in config,
             "stack_config": [line for line in config.splitlines() if "STACK_SIZE=" in line],
             "allocator_entries": [line for line in symbols.splitlines()
                                    if line.split()[-1] in {"malloc", "calloc", "realloc", "aligned_alloc", "swift_allocObject"}],
             "refusing_allocation_stub": subprocess.check_output(
                 [str(prefix) + "objdump", "-d", "--disassemble=posix_memalign", str(elf)], text=True),
             "startup_text_symbols": [line for line in symbols.splitlines()
                                      if any(token in line for token in ("EmbeddedTextMeasure", "EmbeddedTextPlace", "layout_text_valid"))]}
    assert entry["v7em"] and entry["hard_float"] and entry["zero_zephyr_heap"] and entry["zero_libc_heap"]
    assert not entry["allocator_entries"]
    assert "movs" in entry["refusing_allocation_stub"] and "#12" in entry["refusing_allocation_stub"]
    record["images"][name] = entry
b, c = (record["images"][name] for name in ("baseline", "candidate"))
record["delta"] = {key: c[key] - b[key] for key in ("flash_bytes", "ram_bytes")}
(root / sys.argv[1]).write_text(json.dumps(record, indent=2) + "\n")
print({name: {key: value[key] for key in ("flash_bytes", "ram_bytes")} for name, value in record["images"].items()}, record["delta"])
