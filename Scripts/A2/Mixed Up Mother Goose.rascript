// Mixed Up Mother Goose
// #ID = 18954
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function rich_presence_number(x) => rich_presence_value("_Number", x, "VALUE")

// --- MEMORY -------------------------------------------------------------------

// $FDD4: Player Name [ASCII] (10 bytes)
function player_name_ascii_10_bytes() => byte(0x00FDD4)

// $FF00: Current Screen ID [8 bit]
//        
//        Act 1:
//        0x01 | jack and jill's well
//        0x02 | west wall
//        0x09 | tuffet beneath the tree
//        0x0F | crooked house
//        0x10 | footpath to west wall
//        0x16 | south of crooked house
//        0x17 | bo peep
//        0x1d | by the river
//        0x1e | west of mary
//        0x1f | mary, mary quite contrary
//        0x20 | mother goose house
//        0x28 | inside crooked house
//        
//        Act 2:
//        0x06 | east wall (by forest)
//        0x07 | cow, cat, dog, and moon
//        0x0D | east wall (outside schoolhouse)
//        0x0E | forest ridge
//        0x14 | east wall (south of school)
//        0x15 | outside old woman's shoe
//        0x1B | east wall (crying man)
//        0x1C | south of old woman's shoe
//        0x21 | jack be nimble
//        0x22 | along the river
//        0x23 | along the river
//        0x27 | inside mary's schoolhouse
//        0x2C | inside old woman's shoe
//        
//        Act 3:
//        0x03 | west of castle
//        0x04 | outside castle
//        0x05 | east of castle
//        0x0a | outside jack sprat's house
//        0x0b | path to castle
//        0x0c | outside peter pumpkin-eater's house
//        0x11 | west of town (south of jack sprat's house)
//        0x12 | banbury cross (center of town)
//        0x13 | east of town (south of peter pumpkin-eater's house)
//        0x18 | outside clock house
//        0x19 | south wall
//        0x1a | outside jack horner's house
//        0x24 | Jack Sprat's house
//        0x25 | inside old king cole's castle
//        0x29 | inside hickory dickory dock house
//        0x2b | inside jack horner's house
//        
//        Setup:
//        0x00 | init & setup
//        0x60 | title screen
//        0x66 | congrats you win
//        0xC8 | character select
//        0xC9 | bedroom intro
//        0xCA | title credits
//        0xCB | flying in intro
//        0xCC | load game?
function screen() => byte(0x00FF00)

// $FF01: Prev Screen ID [8 bit]
function prev_screen() => byte(0x00FF01)

// $FF03: Current Score [8 bit]
function score() => byte(0x00FF03)

// $FF1F: Current Item [8 bit]
//        0x00 = No Item
//        
//        Act 1:
//        0x0c = Miss Muffet
//        0x0f = sheep
//        0x1a = water pail
//        0x1b = watering can
//        0x1c = crooked sixpence
//        
//        Act 2:
//        0x10 = dog
//        0x11 = lamb
//        0x12 = cat's fiddle
//        0x18 = broth
//        0x19 = candlestick
//        
//        Act 3:
//        0x0b = Peter Pumpkin-Eater's wife
//        0x0d = mouse
//        0x0e = king's fiddlers three
//        0x13 = Christmas pie
//        0x14 = bread knife
//        0x15 = ribeye steak
//        0x16 = king's pipe
//        0x17 = king's bowl
//        0x1d = ladder
//        0x1e = cockhorse
function held_item() => byte(0x00FF1F)

// $FF31: Selected Character [8 bit]
//        0 = white blond boy
//        1 = white black-haired boy
//        2 = white brown-haired boy
//        3 = black boy
//        4 = white blonde girl
//        5 = white black-haired girl
//        6 = white brown-haired girl
//        7 = black girl
function character() => byte(0x00FF31)

// --- MAIN DATA -------------------------------------------------------------------

ACT_1_POINTS = 5
ACT_2_POINTS = 10
ACT_3_POINTS = 18

ITEMS = {
//	Act 1:
	0x0c: "Miss Muffet",
	0x0f: "two sheep",
	0x1a: "a water pail",
	0x1b: "a watering can",
	0x1c: "a crooked sixpence",

//	Act 2:
	0x10: "a dog",
	0x11: "a little lamb",
	0x12: "a fiddle",
	0x18: "a bowl of broth",
	0x19: "a candlestick",

//	Act 3:
	0x0b: "Peter's wife",
	0x0d: "a mouse",
	0x0e: "three fiddlers",
	0x13: "a Christmas pie",
	0x14: "a bread knife",
	0x15: "a steak dinner",
	0x16: "a pipe",
	0x17: "a bowl",
	0x1d: "a ladder",
	0x1e: "a cock-horse",
}

LOCATIONS = {
//	Act 1:
	0x01: "Jack and Jill's well",
	0x02: "west town wall",
	0x08: "south of the well",
	0x09: "tuffet beneath the tree",
	0x0F: "crooked house",
	0x10: "footpath to west town wall",
	0x16: "south of crooked house",
	0x17: "Bo Peep's field",
	0x1d: "by the river",
	0x1e: "west of Mary's garden",
	0x1f: "Mary's garden",
	0x20: "Mother Goose's house",
	0x28: "inside the crooked house",

//	Act 2:
	0x06: "east town wall",
	0x07: "the cow and the moon",
	0x0D: "outside the schoolhouse",
	0x0E: "forest ridge",
	0x14: "east town wall",
	0x15: "outside the old woman's shoe",
	0x1B: "east town wall",
	0x1C: "south of the old woman's shoe",
	0x21: "Jack-be-Nimble",
	0x22: "along the river",
	0x23: "along the river",
	0x27: "inside the schoolhouse",
	0x2C: "inside the old woman's shoe",

//	Act 3:
	0x03: "west of the castle",
	0x04: "outside the castle",
	0x05: "east of the castle",
	0x0a: "outside Jack Sprat's house",
	0x0b: "path to castle",
	0x0c: "outside Peter Pumpkin-Eater's house",
	0x11: "south of Jack Sprat's house",
	0x12: "Banbury Cross in the center of town",
	0x13: "south of Peter Pumpkin-Eater's house",
	0x18: "outside the clock shop",
	0x19: "south town gate",
	0x1a: "outside Jack Horner's house",
	0x24: "inside Jack Sprat's house",
	0x25: "inside Old King Cole's castle",
	0x29: "inside the clock shop",
	0x2b: "inside Jack Horner's house",
}

ACTS = {
//	Act 1:
	0x01: "I",
	0x02: "I",
	0x08: "I",
	0x09: "I",
	0x0F: "I",
	0x10: "I",
	0x16: "I",
	0x17: "I",
	0x1d: "I",
	0x1e: "I",
	0x1f: "I",
	0x20: "I",
	0x28: "I",

//	Act 2:
	0x06: "II",
	0x07: "II",
	0x0D: "II",
	0x0E: "II",
	0x14: "II",
	0x15: "II",
	0x1B: "II",
	0x1C: "II",
	0x21: "II",
	0x22: "II",
	0x23: "II",
	0x27: "II",
	0x2C: "II",

//	Act 3:
	0x03: "III",
	0x04: "III",
	0x05: "III",
	0x0a: "III",
	0x0b: "III",
	0x0c: "III",
	0x11: "III",
	0x12: "III",
	0x13: "III",
	0x18: "III",
	0x19: "III",
	0x1a: "III",
	0x24: "III",
	0x25: "III",
	0x29: "III",
	0x2b: "III",
}

PORTRAIT = {
	0: "👦🏼",
	1: "👦🏻",
	2: "👦🏻",
	3: "👦🏾",
	4: "👧🏼",
	5: "👧🏻",
	6: "👧🏻",
	7: "👧🏾",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => screen() > 0 && screen() < 0x30

function complete_task(item, location) => (
	screen() == location && 
	held_item() == 0 && prior(held_item()) == item &&
	score() == prev(score()) + 1
)

function complete_act(act, score, location)
{
	locations = []
	for key in ACTS if (ACTS[key] == act)
		array_push(locations, key)
	return (
		score() == score && prior(score()) == score - 1 &&
		__ornext(any_of(locations, x => prev(screen()) == x)) && 
		screen() == location
	)
}

// --- RICH PRESENCE -------------------------------------------------------------------

rp_character = rich_presence_lookup("Portrait", character(), PORTRAIT, fallback=PORTRAIT[0])
rp_location = rich_presence_lookup("Location", screen(), LOCATIONS, fallback="in a storybook tale")
rp_held_item = rich_presence_lookup("Item", held_item(), ITEMS, fallback="nothing")

rp_current_act = rich_presence_lookup("Act", screen(), ACTS, fallback="I")
rp_points = rich_presence_number(score())

rich_presence_conditional_display(in_game() && held_item() == 0,
	"{0} Act {1} | 🗺️ {2} | 💯 Score: {3} / 18",
	rp_character,
	rp_current_act,
	rp_location,
	rp_points
)

rich_presence_conditional_display(in_game(),
	"{0} Act {1} | 🗺️ {2} (with {3}) | 💯 Score: {4} / 18",
	rp_character,
	rp_current_act,
	rp_location,
	rp_held_item,
	rp_points
)

rich_presence_conditional_display(score() == 18,
	"📚 You've fixed all of Mother Goose's tales! 📚"
)

rich_presence_display(
	"🛌 Drifting off to sleep, 😴💤 dreaming about Mother Goose 😴💤"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Mary, Mary, Quite Contrary",
	description="How does your garden grow? One explanation is that Mary is a religious allegory of Catholicism, but is it for or against?",
	type="progression",
	points=2,
	trigger=complete_task(item=0x1b, location=0x1f)
)

achievement(
	title="Little Bo-Peep Has Lost Her Sheep",
	description="One theory is Bo-Peep is a reference to smugglers during the time of King Charles I. Just don't leave their tails behind!",
	type="progression",
	points=2,
	trigger=complete_task(item=0x0f, location=0x17)
)

achievement(
	title="Jack Fell Down and Broke His Crown",
	description="Jack and Jill is possibly a reference to a story in Gylfaginning, the first part of the Prose Edda. At least these kids weren't stolen by the moon",
	type="progression",
	points=2,
	trigger=complete_task(item=0x1a, location=0x01)
)

achievement(
	title="And Frightened Miss Muffet Away",
	description="Did you know a tuffet probably refers to just a hill, like a tuft of grass? A tuffet is not a chair, but you wouldn't be the first to make that mistake",
	type="progression",
	points=2,
	trigger=complete_task(item=0x0c, location=0x09)
)

achievement(
	title="There Was a Crooked Man, and He Went a Crooked Mile",
	description="Probably a bit rude to call the guy crooked, but this rhyme a possible reference to a shaky alliance between England and Scotland under King Charles I",
	type="progression",
	points=2,
	trigger=complete_task(item=0x1c, location=0x0f)
)

achievement(
	title="Ride Through the Air on a Very Fine Gander",
	description="Help all of the storybook characters on the west side of town",
	type="progression",
	points=5,
	trigger=complete_act(act="I", score=5, location=0x21)
)

achievement(
	title="Jack (Don't) Jump Over the Candlestick",
	description="Did you know that jumping candlesticks was a form of fortune telling? If the candle stays lit, you'll have good luck",
	type="progression",
	points=2,
	trigger=complete_task(item=0x19, location=0x21)
)

achievement(
	title="Where, O Where Has My Little Dog Gone?",
	description="This contemporary rhyme was taken from the first verse of Der Deitcher's Dog, a song written by Septimus Winner",
	type="progression",
	points=2,
	trigger=complete_task(item=0x10, location=0x1b)
)

achievement(
	title="There Was an Old Woman Who Lived in a Shoe",
	description="One Irish folklorist claims this rhyme is a play on the Old Irish word Sidhbhrog, where Brog can mean either shoe or house",
	type="progression",
	points=2,
	trigger=complete_task(item=0x18, location=0x15)
)

achievement(
	title="Mary Had a Little Lamb",
	description="Mary Had a Little Lamb was the first audio recorded by Thomas Edison on his newly-invented phonograph in 1877",
	type="progression",
	points=2,
	trigger=complete_task(item=0x11, location=0x0d)
)

achievement(
	title="Hey Diddle Diddle",
	description="A modern theory for Hey Diddle Diddle is that it refers to constellations such as Leo the cat, Lyra the fiddle, and Taurus the cow, which align with the moon around the winter solstice",
	type="progression",
	points=2,
	trigger=complete_task(item=0x12, location=0x07)
)

achievement(
	title="As Fair as the Lily, and Sweet as the May",
	description="Help all of the storybook characters on the east side of town",
	type="progression",
	points=5,
	trigger=complete_act(act="II", score=10, location=0x19)
)

achievement(
	title="Peter, Peter, Pumpkin Eater",
	description="Peter, Peter, Pumpkin Eater is somehow the least dark variation of a few other rhymes, all centering on a story about the main character killing his wife or lover",
	type="progression",
	points=2,
	trigger=complete_task(item=0x0b, location=0x0c)
)

achievement(
	title="Hickory Dickory Dock",
	description="Could Hickory Dickory Dock be a counting-out rhyme? Some commentators point out the name sounds similar to Hevera, Devera, and Dick -- the numbers 8, 9, and 10 in the language Cumbric",
	type="progression",
	points=2,
	trigger=complete_task(item=0x0d, location=0x29)
)

achievement(
	title="Old King Cole Was a Merry Old Soul",
	description="Who was Old King Cole? One theory is that he is a reference to a 12th-century clothier. Another is that he was Coel Hen, a 4th century Welsh king. None of these ideas fit perfectly, though",
	type="progression",
	points=5,
	trigger=complete_task(item=0x0e, location=0x25)
)

achievement(
	title="Little Jack Horner Sat in the Corner",
	description="Little Jack Horner's story is a general lesson about greed and opportunism, but some modern commentators suggest Jack might really be Thomas Horner, a steward to the last abbot of Glastonbury",
	type="progression",
	points=2,
	trigger=complete_task(item=0x13, location=0x2b)
)

achievement(
	title="Little Tommy Tucker",
	description="Tommy Tucker was an English term for orphans, and this one is singing for his supper, or begging. Maybe we should have brought him a sandwich instead",
	type="progression",
	points=2,
	trigger=complete_task(item=0x14, location=0x03)
)

achievement(
	title="Jack Spratt Could Eat No Fat",
	description="Most theories about the origins of Jack Sprat are royal. Jack could have been King Charles I and his wife Queen Henrietta Maria, or he could be King John and his wife Isabella, best known from the tales of Robin Hood",
	type="progression",
	points=2,
	trigger=complete_task(item=0x15, location=0x24)
)

achievement(
	title="Humpty Dumpty Sat on a Wall",
	description="Humpty Dumpty might have been an allegory for King Richard III of England, but have you ever noticed that the poem doesn't describe him as an egg? The first popular depiction of Humpty Dumpty as an egg was Lewis Carroll's \"Through the Looking Glass\"",
	type="progression",
	points=2,
	trigger=complete_task(item=0x1d, location=0x05)
)

achievement(
	title="Ride a Cock-Horse to Banbury Cross",
	description="The meaning of this rhyme is unclear, as is the identity of the fine lady upon a white horse from the verse, but the modern Banbury Cross does have a beautiful statue of a woman upon a horse sculpted in 2005 by Denise Dutton",
	type="progression",
	points=2,
	trigger=complete_task(item=0x1e, location=0x12)
)

achievement(
	title="And Mounting Its Back, Flew up to the Moon",
	description="Help all of the storybook characters in the castle town",
	type="win_condition",
	points=10,
	trigger=complete_act(act="III", score=18, location=0x66)
)

// --- LEADERBOARDS -------------------------------------------------------------------