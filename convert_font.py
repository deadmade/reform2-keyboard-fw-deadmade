#!/usr/bin/env python3
# Converts a 5x8 BDF bitmap font to the 6-bytes-per-character column format
# used by the MNT Reform 2 keyboard firmware OLED renderer.
# Usage: python3 convert_font.py <input.bdf> > gfx/font.c

import sys

def parse_bdf(filename):
    glyphs = {}
    in_bitmap = False
    bitmap_rows = []
    encoding = None
    with open(filename) as f:
        for line in f:
            line = line.strip()
            if line.startswith('ENCODING'):
                encoding = int(line.split()[1])
            elif line == 'BITMAP':
                in_bitmap, bitmap_rows = True, []
            elif line == 'ENDCHAR':
                if encoding is not None:
                    glyphs[encoding] = bitmap_rows
                in_bitmap, encoding = False, None
            elif in_bitmap:
                bitmap_rows.append(int(line, 16))
    return glyphs

def to_columns(rows, width=6, height=8):
    rows = (rows[:height] + [0] * height)[:height]
    cols = []
    for col in range(width):
        byte = 0
        for row, val in enumerate(rows):
            bit = (val >> (7 - col)) & 1
            byte |= bit << row
        cols.append(byte)
    return cols

glyphs = parse_bdf(sys.argv[1])

print("/*")
print("  MNT Reform 2.0 Keyboard Firmware")
print("  Spleen 5x8 bitmap font by Frederic Cambus")
print("  https://github.com/fcambus/spleen")
print("  SPDX-License-Identifier: BSD-2-Clause")
print("*/")
print("")
print("#include <avr/pgmspace.h>")
print("")
print("const unsigned char font[] PROGMEM = {")
for code in range(256):
    cols = to_columns(glyphs.get(code, []))
    hex_bytes = ', '.join(f'0x{b:02x}' for b in cols)
    suffix = f'  // 0x{code:02x}'
    if 0x20 <= code <= 0x7e:
        suffix += f" '{chr(code)}'"
    print(hex_bytes + ',' + suffix)
print("};")
