from PIL import Image
import os

ROWS = 5
COLS = 12

X1 = 8
Y1 = 24
WIDTH = 256
HEIGHT = 168

# map = Image.new('RGBA', (COLS * WIDTH, ROWS * HEIGHT))
map = Image.new('RGBA', (10 * WIDTH, ROWS * HEIGHT)) # actual map doesnt use last 2 columns
map.paste((0,0,0), box=(0, 0, map.width, map.height))

for r in range(ROWS):
	for c in range(COLS):
		i = r * COLS + c + 1
		fn = f"images/{i:02x}.png"
		if os.path.exists(fn):
			pic = Image.open(fn).crop((X1, Y1, X1+WIDTH, Y1+HEIGHT))
			map.paste(pic, box=(c * WIDTH, r * HEIGHT))

map.save('map.png')