#!/usr/bin/env python3
"""List files in a paper replication folder, grouped by subfolder and type, with line counts for code.

Usage: inventory.py <paper_dir>
"""
import os, sys
from collections import defaultdict

CODE = {'.do', '.ado', '.m', '.r', '.R', '.py', '.jl', '.f90', '.f', '.c', '.cpp', '.sas', '.gms', '.mod', '.ipynb'}
SKIP = {'.DS_Store'}

def main(root):
    groups = defaultdict(list)
    for d, _, files in os.walk(root):
        for f in files:
            if f in SKIP:
                continue
            p = os.path.join(d, f)
            rel = os.path.relpath(p, root)
            top = rel.split(os.sep)[0] if os.sep in rel else '.'
            ext = os.path.splitext(f)[1]
            size = os.path.getsize(p)
            lines = ''
            if ext in CODE:
                try:
                    with open(p, 'rb') as fh:
                        lines = sum(1 for _ in fh)
                except OSError:
                    pass
            groups[top].append((rel, ext or '(none)', size, lines))
    for top in sorted(groups):
        items = sorted(groups[top])
        print(f"\n## {top}  ({len(items)} files)")
        by_ext = defaultdict(int)
        for _, e, _, _ in items:
            by_ext[e] += 1
        print("   types: " + ", ".join(f"{e}×{n}" for e, n in sorted(by_ext.items())))
        for rel, e, size, lines in items:
            tag = f"{lines} lines" if lines != '' else f"{size/1024:.0f} KB"
            print(f"   {rel}  [{tag}]")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
