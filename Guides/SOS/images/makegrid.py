from PIL import Image, ImageDraw, ImageFont
import os
import sys

LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
MAINCOLOR = (255, 255, 255, 255) # (255, 0, 255, 255)
SPACING = 171 * 3 // 2 + 1
fsettings = {
	'fill': MAINCOLOR,
	'font': ImageFont.truetype("Basic-Regular.ttf", 100),
	'stroke_width': 12, 
	'stroke_fill': 'black',
}

img1 = Image.open('crithania-upright.png')
bg = img1.crop((0, 0, SPACING, SPACING))
result1 = Image.new('RGBA', (img1.width + SPACING, img1.height + SPACING))
result1.paste(im=img1, box=(SPACING, SPACING))
y = 0
while y < result1.height:
	result1.paste(im=bg, box=(0, y))
	y += SPACING
x = 0
while x < result1.width:
	result1.paste(im=bg, box=(x, 0))
	x += SPACING

drawing1 = ImageDraw.Draw(result1)

img2 = Image.open('crithania-capsized.png')
result2 = Image.new('RGBA', (img2.width + SPACING, img2.height + SPACING))
result2.paste(im=img2, box=(SPACING, SPACING))
drawing2 = ImageDraw.Draw(result2)
drawing2.rectangle((0, 0, SPACING, result2.height), fill='black')
drawing2.rectangle((0, 0, result2.width, SPACING), fill='black')

m = SPACING // 2
y = SPACING
i = 1
while y < result1.height:
	drawing1.line([(0, y), (result1.width, y)], fill=MAINCOLOR, width=5)
	drawing1.text((m, y + m), str(7-i), anchor="mm", **fsettings)
	drawing2.line([(0, result2.height-y), (result2.width, result2.height-y)], fill=MAINCOLOR, width=5)
	drawing2.text((m, result2.height-y + m), str(7-i), anchor="mm", **fsettings)
	y += SPACING
	i += 1

x = SPACING
i = 0
while x < result1.width:
	drawing1.line([(x, 0), (x, result1.height)], fill=MAINCOLOR, width=5)
	drawing1.text((x + m, m), LETTERS[11-i], anchor="mm", **fsettings)
	drawing2.line([(result2.width-x, 0), (result2.width-x, result2.height)], fill=MAINCOLOR, width=5)
	drawing2.text((result2.width-x + m, m), LETTERS[11-i], anchor="mm", **fsettings)
	x += SPACING
	i += 1

result1.save('crithania-upright-grid.png')
result2.save('crithania-capsized-grid.png')
