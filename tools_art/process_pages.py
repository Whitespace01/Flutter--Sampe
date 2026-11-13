from PIL import Image, ImageFilter
import os
src = os.path.expanduser('~/workspace/coloria/tools_art')
out = os.path.expanduser('~/workspace/coloria/assets/pages')
jobs = {
 'media-generation-page-cat-0-df721e3f-40a4-4bf1-b11a-034b096722fe.png': 'kids_cat.png',
 'media-generation-page-butterfly-0-84ec0f35-93fa-454f-9a6a-85d4a38d6b16.png': 'kids_butterfly.png',
 'media-generation-page-fish-0-06a4c872-2620-4e83-9443-d40efb8424dd.png': 'kids_fish.png',
 'media-generation-page-owl-0-55bca2b2-4389-400c-84fe-30ea876e2033.png': 'kids_owl.png',
 'media-generation-page-flower-0-6c578f22-82c3-40e0-b37a-10afeb5a297e.png': 'nature_flower.png',
 'media-generation-page-rickshaw-0-a5e5a27e-4d81-403c-a14a-ce7a9bc2cbdf.png': 'bd_rickshaw.png',
 'media-generation-page-boat-0-ec3c9ee8-c9d2-4be5-8f96-c64692ee0e4c.png': 'bd_boat.png',
 'media-generation-page-shapla-0-580af854-cbd4-4328-8a5f-1923fd70a643.png': 'bd_shapla.png',
}
for s, d in jobs.items():
    im = Image.open(os.path.join(src, s)).convert('L')
    im = im.resize((1024, 1024), Image.LANCZOS)
    im = im.point(lambda p: 0 if p < 170 else 255)          # hard threshold to pure B/W
    im = im.filter(ImageFilter.MinFilter(3))                 # thicken lines, close tiny gaps
    im.convert('RGB').save(os.path.join(out, d), optimize=True)
    print(d, os.path.getsize(os.path.join(out, d))//1024, 'KB')
print('total pages:', len(os.listdir(out)))
