from PIL import Image, ImageDraw, ImageFont
import os
import sys

LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
MAINCOLOR = (255, 255, 255, 255) # (255, 0, 255, 255)
SPACING = 171 * 3 // 2 + 1
fsettings = {
	'fill': MAINCOLOR,
	'font': ImageFont.truetype("Basic-Regular.ttf", 32),
	'stroke_width': 4, 
	'stroke_fill': 'black',
}

img1 = Image.open('crithania-upright.png')
result1 = Image.new('RGBA', (img1.width, img1.height))
result1.paste(im=img1, box=(0, 0))
drawing1 = ImageDraw.Draw(result1)

img2 = Image.open('crithania-capsized.png')
result2 = Image.new('RGBA', (img2.width, img2.height))
result2.paste(im=img2, box=(0, 0))
drawing2 = ImageDraw.Draw(result2)

y = SPACING
i = 1
while y < img1.height:
	drawing1.line([(0, y), (img1.width, y)], fill=MAINCOLOR, width=5)
	drawing1.text((10, y - 10), str(i), anchor="ls", **fsettings)
	drawing2.line([(0, img1.height-y), (img2.width, img1.height-y)], fill=MAINCOLOR, width=5)
	drawing2.text((10, img1.height-y - 10), str(i+1), anchor="ls", **fsettings)
	y += SPACING
	i += 1
drawing1.text((10, img1.height - 10), str(i), anchor="ls", **fsettings)
drawing2.text((10, img1.height - 10), str(1), anchor="ls", **fsettings)

x = SPACING
i = 0
while x < img1.width:
	drawing1.line([(x, 0), (x, img1.height)], fill=MAINCOLOR, width=5)
	drawing1.text((x - 10, 10), LETTERS[i], anchor="rt", **fsettings)
	drawing2.line([(img1.width-x, 0), (img1.width-x, img2.height)], fill=MAINCOLOR, width=5)
	drawing2.text((img1.width-x - 10, 10), LETTERS[i+1], anchor="rt", **fsettings)
	x += SPACING
	i += 1
drawing1.text((img1.width - 10, 10), LETTERS[i], anchor="rt", **fsettings)
drawing2.text((img1.width - 10, 10), LETTERS[0], anchor="rt", **fsettings)

result1.save('crithania-upright-grid.png')
result2.save('crithania-capsized-grid.png')
