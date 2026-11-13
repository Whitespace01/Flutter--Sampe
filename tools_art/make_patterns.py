from PIL import Image, ImageDraw
import math, os
S = 1200; W = 7
out = os.path.expanduser('~/workspace/coloria/assets/pages')
os.makedirs(out, exist_ok=True)

def base():
    img = Image.new('RGB', (S, S), 'white')
    return img, ImageDraw.Draw(img)

def mandala1():
    img, d = base(); cx = cy = S//2
    for r in (560, 470, 380, 300, 210, 130):
        d.ellipse([cx-r, cy-r, cx+r, cy+r], outline='black', width=W)
    for n, r1, r2, rr in ((12, 380, 470, 42), (12, 210, 300, 34), (24, 470, 560, 30)):
        for i in range(n):
            a = 2*math.pi*i/n + (math.pi/n if rr == 42 else 0)
            x, y = cx + (r1+r2)/2*math.cos(a), cy + (r1+r2)/2*math.sin(a)
            d.ellipse([x-rr, y-rr, x+rr, y+rr], outline='black', width=W)
    for i in range(12):
        a = 2*math.pi*i/12
        x1, y1 = cx + 130*math.cos(a), cy + 130*math.sin(a)
        x2, y2 = cx + 210*math.cos(a), cy + 210*math.sin(a)
        d.line([x1, y1, x2, y2], fill='black', width=W)
    d.ellipse([cx-60, cy-60, cx+60, cy+60], outline='black', width=W)
    img.save(f'{out}/mandala_1.png')

def mandala2():
    img, d = base(); cx = cy = S//2
    d.ellipse([cx-560, cy-560, cx+560, cy+560], outline='black', width=W)
    for i in range(16):
        a = 2*math.pi*i/16
        x1, y1 = cx + 90*math.cos(a), cy + 90*math.sin(a)
        x2, y2 = cx + 540*math.cos(a), cy + 540*math.sin(a)
        d.line([x1, y1, x2, y2], fill='black', width=W)
    for r in (540, 430, 320, 210, 90):
        d.ellipse([cx-r, cy-r, cx+r, cy+r], outline='black', width=W)
    for i in range(8):
        a = 2*math.pi*i/8 + math.pi/8
        x, y = cx + 375*math.cos(a), cy + 375*math.sin(a)
        d.regular_polygon((x, y, 55), 4, outline='black', width=W)
    img.save(f'{out}/mandala_2.png')

def geo():
    img, d = base(); step = 150
    for y in range(0, S, step):
        for x in range(0, S, step):
            d.rectangle([x, y, x+step, y+step], outline='black', width=W)
            d.ellipse([x+25, y+25, x+step-25, y+step-25], outline='black', width=W)
            d.line([x, y, x+step, y+step], fill='black', width=W)
            d.line([x+step, y, x, y+step], fill='black', width=W)
    img.save(f'{out}/pattern_geo.png')

mandala1(); mandala2(); geo()
print('patterns done:', sorted(os.listdir(out)))
