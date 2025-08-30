// Tengoku Yoitoko
// #ID = 4011

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")

// --- MEMORY -------------------------------------------------------------------

// $2020: Room ID [8 bit]
//        0x00 = Title Screen
//        0x01 = Starting Church
//        
//        0x03 = Town Leftmost Screen
//        0x04 = Town: Shop (0x2a), Dungeon (0x1f), Church (0x24)
//        0x05 = Town: House (0x2e)
//        0x06 = Town: Key (0x2c), Dungeon (0x20)
//        0x07 = Town: Dungeon (0x21)
//        0x08 = Town: Church (0x23)
//        0x09 = Town: Angel Wings Room (0x30)
//        0x0a = Town: Boarded Door (0x33)
//        0x0b = Town: Shop (0x29)
//        0x0c = Town: House (0x2f)
//        0x0d = Town: Shop (0x2b)
//        0x0e = Town: Dungeon (0x22)
//        0x0f = Town: Shop (0x2d)
//        0x10 = Town: Cloud Crossing
//        0x11 = Town
//        0x12 = Town: Hidden Door (0x38)
//        0x13 = Town: Red Heart Tower (0x3d)
//        0x14 = Town: Silver Heart Tower (0x3f)
//        0x15 = Town: Gold Heart Tower (0x42)
//        
//        0x1f = Witch Dungeon #1: Pincushion Hell
//        0x20 = Witch Dungeon #2: Eight Cold Hells
//        0x21 = Witch Dungeon #3: Eight Hot Hells
//        0x22 = Witch Dungeon #4: River of Three Crossings
//        0x23 = Church ("raise your virtue")
//        0x24 = Church (empowers Halo)
//        
//        0x25 = Clock Tower Castle Room 1
//        0x26 = Clock Tower Castle Room 2
//        0x27 = Clock Tower Castle Boss
//        
//        0x29 = Shop Elephant: Halo (200), Pincers (200)
//        0x2a = Shop Panda: Gourd (100), Demon's Sandals (100)
//        0x2b = Shop Giraffe: Gourd (200), Angel Boots (200)
//        0x2c = Key Shop: Blue Key (100), Heart Key (100)
//        0x2d = Shop Cool Dino: Cotton Shoes (100), Angel's Robe (200)
//        0x2e = House ("find white cotton shoes")
//        0x2f = House ("can't enter clock tower without pincers")
//        0x30 = Angel Wings room
//        
//        0x31 = (some newgame loading state, transitions to 0x01)
//        
//        0x33 = Clock Tower in Sky
//        0x34 = Boarded Door in Sky (locked unless Souls=3)
//        
//        0x38 = Hidden Tower Room 1
//        0x39 = Hidden Tower Room 2
//        0x3a = Hidden Tower Room 3
//        0x3b = Hidden Tower Death God
//        
//        0x3d = Red Tower Room 1
//        0x3e = Red Tower Boss
//        0x3f = Silver Tower Room 1
//        0x40 = Silver Tower Room 2
//        0x41 = Silver Tower Boss
//        0x42 = Gold Tower Room 1
//        0x43 = Gold Tower Room 2
//        0x44 = Gold Tower Room 3
//        0x45 = Gold Tower Boss
//        
//        0x47 = Atma's Room, Mirror Fight
//        0x49 = Ending (1st frame)
//        0x4a = Ending (2nd frame)
//        0x4b = Ending (3rd frame)
//        
//        0x51-0x6f: Pincushion Hell
//        0x55 = Ogre
//        0x59 = Tall
//        0x5a = Mid Exit
//        0x63 = Winged Demon
//        0x67 = 2x Tall
//        0x6c = Tall
//        0x6f = Boss
//        
//        0x79-0x98: Eight Cold Hells
//        0x7c = Winged Demon
//        0x80 = Tall
//        0x86 = Red Ogre
//        0x88 = Tall
//        0x89 = Mid Exit
//        0x8e = Blue Devil
//        0x93 = 2x Tall
//        0x98 = Blue Devil
//        
//        0xa1-0xc6: Eight Hot Hells
//        0xa6 = Poverty Wizard
//        0xac = Winged Demon
//        0xad = Mid Exit
//        0xaf = 2x Tall
//        0xb4 = Red Ogre
//        0xb7 = Blue Devil
//        0xc1 = Death God
//        0xc6 = Winged Demon
//        
//        0xc9-0xe1: River of Three Crossings
//        0xd5 = Poverty Wizard, Exit
//        0xd8 = Broom Lady, Door (0xda)
//        0xda = Start of 2nd zone
//        0xe1 = Broom Lady, Door (0x47)
function room() => byte(0x002020)

// $2029: Has High Jump [8 bit] (0/1)
//        tied to angel robe
function has_high_jump() => byte(0x002029)

// $202B: Halo [8 bit]
//        0 = No Halo
//        1 = Halo Owned
//        2 = Halo Empowered (0x24)
function halo_state() => byte(0x00202B)

// $202D: Has Water Demon's Bowl [8 bit] (0/1)
//        screen=0x3b
function has_water_demons_bowl() => byte(0x00202D)

// $2034: Has Gold Heart Key [8 bit] (0/1)
//        screen=0x41
function has_gold_heart_key() => byte(0x002034)

// $2035: Has Glasses [8 bit] (0/1)
//        screen=0x45
function has_glasses() => byte(0x002035)

// $2038: Vitality [16 bit BCD]
// $203A: Virtue [16 bit BCD]
// $203C: Attack [16 bit BCD]
// $203E: Gold [16 bit BCD]
function vitality() => bcd(word(0x002038))
function virtue() => bcd(word(0x00203A))
function attack() => bcd(word(0x00203C))
function gold() => bcd(word(0x00203E))

// $2040: Item Slots [14 bytes]
//        0x01 = Angel Wings
//        0x02 = Angel Robe
//        0x03 = Cotton Shoes
//        0x04 = Halo
//        0x05 =
//        0x06 = Water Demon's Bowl
//        0x07 = Angel's Shoes
//        0x08 = Demon Sandals
//        0x09 = Pincers
//        0x0a = Blue Key
//        0x0b = Red Heart Key
//        0x0c = Silver Heart Key
//        0x0d = Gold Heart Key
//        0x0e = Glasses
function item_slot(i) => byte(0x002040+i)

// $204F: Number of Items [8 bit]
function item_count() => byte(0x00204F)

// $206F: Number of Saved Souls [8 bit]
//        0->1 = completed Pincushion Hell
//        1->2 = completed Eight Cold Hells
//        2->3 = completed Eight Hot Hells
//        3->4 = completed clock tower
function soul_count() => byte(0x00206F)

// $2080: Has Angel Wings [8 bit] (0/1)
//        screen=0x2c
function has_angel_wings() => byte(0x002080)

// $2081: Has Halo [8 bit] (0/1)
//        screen=0x29
function has_halo() => byte(0x002081)

// $2082: Has Pincers [8 bit] (0/1)
//        screen=0x29
function has_pincers() => byte(0x002082)

// $2084: Has Demon Sandals [8 bit] (0/1)
//        screen=0x2a
function has_demon_sandals() => byte(0x002084)

// $2085: Has Blue Key [8 bit] (0/1)
//        screen=0x2c
function has_blue_key() => byte(0x002085)

// $2086: Has Red Heart Key [8 bit] (0/1)
//        screen=0x2c
function has_red_heart_key() => byte(0x002086)

// $2088: Has Angel Boots [8 bit] (0/1)
//        screen=0x2b
function has_angel_boots() => byte(0x002088)

// $2089: Has Cotton Shoes [8 bit] (0/1)
//        screen=0x2d
function has_cotton_shoes() => byte(0x002089)

// $208A: Has Angel's Robe [8 bit] (0/1)
//        screen=0x2d
function has_angels_robe() => byte(0x00208A)

// $2183: Death Indicator [8 bit]
//        briefly goes to 1 when the player dies
function dead() => byte(0x002183)

// --- MAIN DATA -------------------------------------------------------------------

LOCATIONS = {
	0x00: "Title Screen",
	0x01: "Church",
	0x1f: "Dungeon #1 Entrance",
	0x20: "Dungeon #2 Entrance",
	0x21: "Dungeon #3 Entrance",
	0x22: "Dungeon #4 Entrance",
	0x23: "Church",
	0x24: "Church",
	0x47: "Atma's Room",
}

for x in range(0x03, 0x15) LOCATIONS[x] = "Heaven"
for x in range(0x25, 0x27) LOCATIONS[x] = "Clock Tower"
for x in range(0x29, 0x2d) LOCATIONS[x] = "Shopping"
for x in range(0x2e, 0x30) LOCATIONS[x] = "House"
for x in range(0x33, 0x34) LOCATIONS[x] = "Heaven"
for x in range(0x38, 0x3b) LOCATIONS[x] = "Hidden Tower"
for x in range(0x3d, 0x3e) LOCATIONS[x] = "Red Heart Tower"
for x in range(0x3f, 0x41) LOCATIONS[x] = "Silver Heart Tower"
for x in range(0x42, 0x45) LOCATIONS[x] = "Gold Heart Tower"
for x in range(0x49, 0x4b) LOCATIONS[x] = "Ending"
for x in range(0x51, 0x6f) LOCATIONS[x] = "#1 Pincushion Hell"
for x in range(0x79, 0x98) LOCATIONS[x] = "#2 Eight Cold Hells"
for x in range(0xa1, 0xc6) LOCATIONS[x] = "#3 Eight Hot Hells"
for x in range(0xc9, 0xe1) LOCATIONS[x] = "#4 River of Three Crossings"

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function on_title_screen() => room() == 0x00

function new_game() => prev(room()) == 0x31 && room() == 0x01

function beat_the_game() => prev(room()) == 0x47 && room() == 0x49

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(room() == 0x00 || word(0x002038) == 0xFFFF,
	"[Title Screen] ⛩️ Tengoku Yoitoko | © Taito 1987"
)

rich_presence_display(
	"🗺️ {0} · 👨 {1} friend{2} saved · ❤️ {3} vitality · ⛩️ {4} virtue · 💪 {5} attack · 💰 {6} gold",
	rich_presence_lookup("Location", room(), LOCATIONS, fallback="Heaven"),
	rich_presence_number(soul_count()), plural(soul_count()),
	rich_presence_number(vitality()),
	rich_presence_number(virtue()),
	rich_presence_number(attack()),
	rich_presence_number(gold())
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="How Many Angels Can Dance on the Head of a Pin?",
	description="Rescue a lost soul from Pincushion Hell",
	type="progression",
	points=10,
	trigger=room() == 0x6f && soul_count() > prev(soul_count())
)

achievement(
	title="When Hell Freezes Over",
	description="Rescue a lost soul from the Eight Cold Hells",
	type="progression",
	points=10,
	trigger=room() == 0x98 && soul_count() > prev(soul_count())
)

achievement(
	title="As Hot as the Hinges of Hell",
	description="Rescue a lost soul from the Eight Hot Hells",
	type="progression",
	points=10,
	trigger=room() == 0xc6 && soul_count() > prev(soul_count())
)

achievement(
	title="Poverty Is No Sin",
	description="Rescue a lost soul from the clock tower",
	type="progression",
	points=10,
	trigger=room() == 0x27 && soul_count() > prev(soul_count())
)

achievement(
	title="Like a Bat Outta Hell",
	description="Complete the River of Three Crossings and escape the afterlife with all of your friends",
	type="win_condition",
	points=25,
	trigger=soul_count() == 4 && prev(room()) == 0x47 && room() == 0x49
)

achievement(
	title="Burn-kenstocks",
	description="Buy the Demon's Sandals",
	points=2,
	trigger=room() == 0x2a && is_set(has_demon_sandals())
)

achievement(
	title="Halo, Is It Me You’re Looking For?",
	description="Buy the Halo",
	points=3,
	trigger=room() == 0x29 && is_set(has_halo())
)

achievement(
	title="Pincer Perfect",
	description="Buy the Pincers",
	points=3,
	trigger=room() == 0x29 && is_set(has_pincers())
)

achievement(
	title="Bless Your Sole",
	description="Buy the Angel Boots",
	points=3,
	trigger=room() == 0x2b && is_set(has_angel_boots())
)

achievement(
	title="Tiptoe Through the Cumulus",
	description="Buy the Cotton Shoes",
	points=2,
	trigger=room() == 0x2d && is_set(has_cotton_shoes())
)

achievement(
	title="Jump Robe",
	description="Buy the Angel's Robe",
	points=3,
	trigger=room() == 0x2d && is_set(has_angels_robe())
)

achievement(
	title="On a Wing and a Prayer",
	description="Find the Angel Wings",
	points=3,
	trigger=room() == 0x30 && is_set(has_angel_wings())
)

achievement(
	title="Spectacular Revelation",
	description="Find the Glasses",
	points=5,
	trigger=room() == 0x45 && is_set(has_glasses())
)

achievement(
	title="Water Under the Bridge",
	description="Find the Kappa's bowl",
	points=5,
	trigger=room() == 0x3b && is_set(has_water_demons_bowl())
)

// reach the boss of d2 cold hells without high jump
achievement(
	title="Fools Rush In Where Angels Fear to Tread",
	description="Reach the boss of Eight Cold Hells without the Angel's Robe",
	points=5,
	trigger=(
		// check if the player is in Eight Cold Hells without Angel's Robe
		room() >= 0x79 && room() <= 0x98 && has_angels_robe() == 0 &&
		// trigger achievement when walking into boss room
		trigger_when(prev(room()) == 0x97 && room() == 0x98)
	)
)

// reach the top of the clock tower without the pincers (0x24->0x25)
achievement(
	title="The Secret of the Rectory's Attic",
	description="Reach the top of the clock tower without buying the Pincers (not like it'll do you any good)",
	points=3,
	trigger=has_pincers() == 0 && prev(room()) == 0x24 && room() == 0x25
)

// lose virtue in heaven
achievement(
	title="Unvirtuous Mischief",
	description="Find a way to lose virtue in heaven",
	points=1,
	trigger=room() >= 0x03 && room() <= 0x15 && virtue() < prev(virtue())
)

achievement(
	title="Only Demons Die Twice",
	description="Complete the game and rescue your friends without dying",
	points=25,
	trigger=once(new_game()) && never(on_title_screen()) && never(dead() == 1) && trigger_when(beat_the_game())
)

// --- LEADERBOARDS -------------------------------------------------------------------

// lowest virtue
leaderboard(
	title="Least Virtuous",
	description="Lowest amount of virtue when completing the game. Isn't it good to be bad sometimes?",

	start=beat_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(virtue()),
	format="VALUE",
	lower_is_better=true
)

// speedrun
leaderboard(
	title="Fastest Escape",
	description="Fastest time to complete the game. Rushing through the game like a bat outta hell!",

	start=new_game(),
	cancel=room() == 0,
	submit=beat_the_game(),

	value=measured(tally(0, always_true())),
	format="FRAMES",
	lower_is_better=true
)
