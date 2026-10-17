#!/usr/bin/env python3
"""Interpret the single frozen bcanalyzer dump; never runs a decoder/compiler."""

import codecs
import json
from pathlib import Path
import re
import struct
import sys


def interpret(dump, module):
    lines = dump.splitlines()

    def record(name):
        return next(line for line in lines if line.strip().startswith("<" + name + " "))

    def operands(name):
        return list(map(int, re.findall(r"op\d+=(\d+)", record(name))))

    def blob(name):
        escaped = record(name).split("blob data = '", 1)[1][:-1]
        return codecs.decode(escaped, "unicode_escape").encode("latin1")

    # ModuleFormat.h: six SpecialIdentifierIDs precede ordinary identifier IDs.
    strings = blob("IDENTIFIER_DATA")
    names = {index + 6: strings[offset:strings.index(0, offset)].decode()
             for index, offset in enumerate(operands("IDENTIFIER_OFFSETS"))}
    table_blob = blob("SIL_FUNC_NAMES")
    table_offset = operands("SIL_FUNC_NAMES")[0]
    bucket_count, entry_count = struct.unpack_from("<II", table_blob, table_offset)
    buckets = struct.unpack_from("<" + "I" * bucket_count, table_blob, table_offset + 8)
    entries = []
    for offset in buckets:
        if offset == 0:
            continue
        count = struct.unpack_from("<H", table_blob, offset)[0]
        offset += 2
        for _ in range(count):
            # SerializeSIL.cpp FuncTableInfo: hash32, IdentifierID32, FunctionID32.
            hash_value, key, value = struct.unpack_from("<III", table_blob, offset)
            expected_hash = 5381
            for byte in names[key].encode():
                expected_hash = (expected_hash * 33 + byte) & 0xFFFFFFFF
            assert hash_value == expected_hash
            entries.append({"identifier_id": key, "function_id": value,
                            "hash": hash_value, "name": names[key]})
            offset += 12
    assert len(entries) == entry_count == 31
    assert sorted(row["function_id"] for row in entries) == list(range(1, 32))
    offsets = operands("SIL_FUNC_OFFSETS")
    records = [(i, line) for i, line in enumerate(lines)
               if line.strip().startswith("<SIL_FUNCTION ")]
    assert len(offsets) == len(records) == entry_count
    selected = []
    for row in entries:
        name = row["name"]
        if not any(term in name for term in ("0B6ScreenV15_giftUITraverse",
                                              "0B6ScreenV15_giftUIEvaluate",
                                              "0B6ScreenV39_giftUIVisit")):
            continue
        function_id = row["function_id"]
        start, header = records[function_id - 1]
        stop = records[function_id][0] if function_id < entry_count else next(
            i for i in range(start + 1, len(lines)) if "</SIL_BLOCK>" in lines[i])
        body = lines[start + 1:stop]
        values = list(map(int, re.findall(r"op\d+=(\d+)", header)))
        bit_offset = offsets[function_id - 1]
        # Directly corroborate index offsets against original module bytes.
        position = bit_offset
        prefix = []
        for width in (6, 4, 1, 2, 3, 1, 3, 2):
            value = sum(((module[(position + i) // 8] >> ((position + i) % 8)) & 1) << i
                        for i in range(width))
            prefix.append(value)
            position += width
        assert prefix == [4] + values[:7]
        selected.append(dict(row, offset_bits=bit_offset,
                             next_function_offset_bits=offsets[function_id],
                             linkage=values[0], serialized_kind=values[2],
                             inline_strategy=values[6], trailing_records=values[13],
                             basic_blocks=sum("<SIL_BASIC_BLOCK " in line for line in body),
                             following_records=body, raw_prefix=prefix,
                             function_record=header.strip()))
    exact = next(row for row in selected if row["identifier_id"] == 26)
    assert exact["function_id"] == 28 and exact["offset_bits"] == 167594
    assert (exact["linkage"], exact["serialized_kind"], exact["basic_blocks"]) == (7, 0, 0)
    assert len(exact["following_records"]) == exact["trailing_records"] == 2
    assert all("<SIL_ARG_EFFECTS_ATTR " in line for line in exact["following_records"])
    control = next(row for row in selected if row["identifier_id"] == 24)
    assert (control["serialized_kind"], control["basic_blocks"]) == (1, 1)
    evaluate = next(row for row in selected if row["identifier_id"] == 30)
    assert (evaluate["serialized_kind"], evaluate["basic_blocks"]) == (0, 0)
    return {"metadata_version": operands("METADATA")[:2],
            "function_index_bucket_count": bucket_count,
            "complete_function_index_entry_count": entry_count,
            "complete_function_index": sorted(entries, key=lambda row: row["function_id"]),
            "selected_functions": sorted(selected, key=lambda row: row["function_id"]),
            "result": "exact traversal body absent from physical serialized SIL"}


if __name__ == "__main__":
    root = Path(sys.argv[1])
    print(json.dumps(interpret((root / "decode.stdout").read_text(),
                               (root / "P08CounterPresentation.swiftmodule").read_bytes()), indent=2))
