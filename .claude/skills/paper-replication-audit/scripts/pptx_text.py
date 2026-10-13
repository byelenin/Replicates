#!/usr/bin/env python3
"""Extract slide text from a .pptx in presentation order, with counts of pictures,
tables and native equations per slide (equation images are NOT extracted — export the
deck to PDF and view the pages to read them).

Usage: pptx_text.py deck.pptx
"""
import re, sys, zipfile

def main(path):
    z = zipfile.ZipFile(path)
    pres = z.read('ppt/presentation.xml').decode('utf-8')
    rels = z.read('ppt/_rels/presentation.xml.rels').decode('utf-8')
    rid2t = {}
    for rel in re.findall(r'<Relationship [^>]*/>', rels):
        rid = re.search(r'Id="([^"]+)"', rel)
        tgt = re.search(r'Target="([^"]+)"', rel)
        if rid and tgt and 'slides/slide' in tgt.group(1):
            rid2t[rid.group(1)] = tgt.group(1).lstrip('/').replace('ppt/', '')
    order = re.findall(r'<p:sldId [^>]*r:id="([^"]+)"', pres)
    for n, rid in enumerate(order, 1):
        x = z.read('ppt/' + rid2t[rid]).decode('utf-8')
        pics = len(re.findall(r'<p:pic>', x))
        tbls = len(re.findall(r'<a:tbl>', x))
        math = len(re.findall(r'<m:oMath', x))
        print(f"=== Slide {n} [pictures={pics} tables={tbls} equations={math}]")
        for p in re.findall(r'<a:p>.*?</a:p>|<a:p .*?</a:p>', x, flags=re.S):
            t = ''.join(re.findall(r'<a:t>([^<]*)</a:t>', p))
            if t.strip():
                print('   ' + t)
        notes = [k for k in z.namelist() if k == f"ppt/notesSlides/notesSlide{n}.xml"]
        if notes:
            nt = ' '.join(re.findall(r'<a:t>([^<]*)</a:t>', z.read(notes[0]).decode('utf-8'))).strip()
            if nt:
                print('   [notes] ' + nt)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
