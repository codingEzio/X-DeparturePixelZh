"""Compare two font files after an intended metadata-only identity migration."""

import argparse
import hashlib
import json
from pathlib import Path

from fontTools.ttLib import TTFont


def glyph_hash(font, glyph_name):
    return hashlib.sha256(font["glyf"][glyph_name].compile(font["glyf"])).hexdigest()


def compare(before_path, after_path):
    before, after = TTFont(before_path), TTFont(after_path)
    old_map, new_map = before.getBestCmap(), after.getBestCmap()
    if set(old_map) != set(new_map):
        raise ValueError("Unicode coverage differs")
    changed = []
    for codepoint in sorted(old_map):
        old_name, new_name = old_map[codepoint], new_map[codepoint]
        if before["hmtx"].metrics[old_name][0] != after["hmtx"].metrics[new_name][0]:
            changed.append(f"U+{codepoint:04X}: advance")
        if glyph_hash(before, old_name) != glyph_hash(after, new_name):
            changed.append(f"U+{codepoint:04X}: outline")
    if changed:
        raise ValueError("Unexpected visual compatibility change: " + ", ".join(changed[:10]))
    return {"coverage": len(old_map), "outlines_and_advances": "identical"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--before", type=Path, required=True)
    parser.add_argument("--after", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(compare(args.before, args.after), indent=2))


if __name__ == "__main__":
    main()
