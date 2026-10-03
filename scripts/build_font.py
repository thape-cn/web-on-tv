#!/usr/bin/env python3
"""Rebuild the bundled OFL display font after changing Chinese or English copy.
Requires fonttools and the locally installed Noto CJK font; never downloads fonts.
"""
from pathlib import Path
import argparse
from fontTools.ttLib import TTFont
from fontTools import subset

parser = argparse.ArgumentParser()
parser.add_argument('--source', default='/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc')
parser.add_argument('--font-number', type=int, default=2, help='Simplified Chinese face in the TTC')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
font = TTFont(args.source, fontNumber=args.font_number)
text = ''.join(p.read_text() for p in (root / 'app').glob('*.rb'))
text += ''.join(chr(i) for i in range(32, 127))
subsetter = subset.Subsetter()
subsetter.populate(text=text)
subsetter.subset(font)
for record in font['name'].names:
    if record.nameID in (1, 3, 4, 6):
        record.string = 'TianhuaDisplaySans'.encode(record.getEncoding())
font.save(root / 'assets/fonts/TianhuaDisplaySans.otf')
print('Rebuilt assets/fonts/TianhuaDisplaySans.otf; retain LICENSE-Noto.txt')
