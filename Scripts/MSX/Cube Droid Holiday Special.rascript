// ~Homebrew~ Cube Droid Holiday Special
// #ID = 34127

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

// --- MEMORY -------------------------------------------------------------------

// $000000: MSX Boot State [8 bit]
//          0x55 = MSX boot screen
//          0x0d = otherwise
function boot_state() => byte(0x000000)

// $000016: Game State [8 bit]
//          0x07 = in-level, moving
//          0x10 = in-level, stopped
//          0x22 = select starting level
//          0x9b = write password
function game_state() => byte(0x000016)

// $00001D: Title Screen Mode [8 bit]
//          1 = Title Card
//          2 = Story
//          3 = Credits
function title_screen_mode() => byte(0x00001D)

// $0001E7: Sound Effect Playing [8 bit]
//          1 = sound effect active
//          0 = otherwise
function sound_effect_playing() => byte(0x0001E7)

// $0001E8: Sound Sequence [16 bit]
//          0xD017 = Collect Battery
//          0xD094 = Alarm
//          0xD0D6 = Blue Teleport Crate Disappeared
//          0xD154 = Zapped
//          0xD269 = Stage Starting
function sound_sequence() => word(0x0001E8)
function play_sound(x) => prev(sound_effect_playing()) == 0 && sound_effect_playing() == 1 && sound_sequence() == x

// $0001F0: Current Level [8 bit]
//          0 indexed, 0 = 1-1
function current_level() => byte(0x0001F0)

// $0001F1: Remaining Batteries [8 bit]
function remaining_batteries() => byte(0x0001F1)

// $0001F4: Victory [8 bit]
//          1 = Level Ended
//          0 = Otherwise
//          flickers during gameplay
function victory() => byte(0x0001F4)

// $00035A: Round Active [8 bit]
//          0x00 = Round Starting
//          0x01 = In Game
//          0xFF = Out of Game (victory, loading)
function round_active() => byte(0x00035A)

// $00036F: Board Layout [256 bytes]
//          12x12 layout with a 2-wide border all the way around
//          
//          0x00 = Empty
//          0x01 = Pushable
//          0x02 = Player
//          0x03 = Battery
//          0x04 = Exit
//          0x05 = Rolling Robot
//          0x06 = Teleport Crates
//          0x07 = Enemy - Guardian (Awake)
//          0x08 = Enemy - Laser Tower
//          0x0a = Red Teleport Crate (Disappears at Alarm)
//          0x0b = Enemy - Roller Saw
//          0x0c = Wall
//          0x0f = Vat/Tank
//          0x10 = Enemy - Guardian (Asleep)
//          0x34 = Enemy - Cannon Shooter
BOARD_LAYOUT = 0x00036F
function tile_at(x, y) => byte(BOARD_LAYOUT + (y + 2) * 16 + (x + 2))

// $00063F: Personal Bests (Step Count) [24 bytes]
//          setting a level to non-zero unlocks the next level
PERSONAL_BESTS = 0x00063F

// $0007B7: Step Counter [8 bit]
//          max 0xff = 255
function step_counter() => byte(0x0007B7)

// --- MAIN DATA -------------------------------------------------------------------

// Passwords:
// 1-1 FROST
// 1-2 BLIZZARD
// 1-3 ICICLE
// 1-4 SNOWMAN
// 1-5 FREEZING
// 1-6 ARCTIC
// 2-1 HIBERNATE
// 2-2 SNOWFLAKE
// 2-3 COLD
// 2-4 GLACIER
// 2-5 AVALANCHE
// 2-6 POLAR
// 3-1 SNOWBOARD
// 3-2 MITTENS
// 3-3 FIREPLACE
// 3-4 ICEBERG
// 3-5 FROZEN
// 3-6 FROSTBITE
// 4-1 SUBZERO
// 4-2 SOLSTICE
// 4-3 IGLOO
// 4-4 SNOWDRIFT
// 4-5 PENGUIN
// 4-6 ENDDEMOGAMITAINA

STAGE_COUNT = 24

SOUND_TELEPORT_CRATE_DISAPPEAR = 0xD0D6

POINTS_MEDIUM = 3
POINTS_TRICKY = 5
POINTS_HARD = 5

/*
Filler names:
- Hark the Herald
- Ornaments
- Eggnog
- Nutcracker
- Snowball
- Evergreen
- Tannenbaum
- Candlelight
- Advent Calendar
- Humbug
- Christmas Cracker
- Glad Tidings
- Wassail
- Holly Wreath (The Holly and the Ivy)
- Magi

- Feliz Natal
- Feliz Navidad
- Joyeux Noel
*/

/*
"challenge": {
	"trigger": always_false(),
	"desc": "",
	"points": 0,
},
*/
STAGE_INFO = [
	{
		"name": "1-1",
		"planet": "Noelion",
		"password": "FROST",
		"title": "Yuletide Greetings",
	},
	{
		"name": "1-2",
		"planet": "Noelion",
		"password": "BLIZZARD",
		"title": "Glad Tidings",
	},
	{
		"name": "1-3",
		"planet": "Noelion",
		"password": "ICICLE",
		"title": "Workshop",
		"challenge": {
			"trigger": disable_when(all_of(range(7,10), x => tile_at(x, 8) != 0x01), until=step_counter() == 0),
			"desc": "without moving more than three boxes",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "1-4",
		"planet": "Noelion",
		"password": "SNOWMAN",
		"title": "Gift Wrapped",
	},
	{
		"name": "1-5",
		"planet": "Noelion",
		"password": "FREEZING",
		"title": "Reindeer Games",
		// a cool challenge would be "don't grab center battery last"
	},
	{
		"name": "1-6",
		"planet": "Noelion",
		"password": "ARCTIC",
		"title": "Deck the Halls",
		// possible to grab the top 2 batteries first?
	},
	
	{
		"name": "2-1",
		"planet": "Hollytis",
		"password": "HIBERNATE",
		"title": "Sleigh Bells",
		// without blocking any of the alcoves?
	},
	{
		"name": "2-2",
		"planet": "Hollytis",
		"password": "SNOWFLAKE",
		"title": "Gingerbread House", // Candy Cane would fit here
		// collecting top battery first
	},
	{
		"name": "2-3",
		"planet": "Hollytis",
		"password": "COLD",
		"title": "Up the Chimney",
	},
	{
		"name": "2-4",
		"planet": "Hollytis",
		"password": "GLACIER",
		"title": "",
	},
	{
		"name": "2-5",
		"planet": "Hollytis",
		"password": "AVALANCHE",
		"title": "White Elephant",
	},
	{
		"name": "2-6",
		"planet": "Hollytis",
		"password": "POLAR",
		"title": "Wassail", // got kind of a Pac-Man vibe
	},
	
	{
		"name": "3-1",
		"planet": "Yulethra",
		"password": "SNOWBOARD",
		"title": "Star of Bethlehem",
	},
	{
		"name": "3-2",
		"planet": "Yulethra",
		"password": "MITTENS",
		"title": "Nutcracker",
	},
	{
		"name": "3-3",
		"planet": "Yulethra",
		"password": "FIREPLACE",
		"title": "",
	},
	{
		"name": "3-4",
		"planet": "Yulethra",
		"password": "ICEBERG",
		"title": "",
	},
	{
		"name": "3-5",
		"planet": "Yulethra",
		"password": "FROZEN",
		"title": "",
	},
	{
		"name": "3-6",
		"planet": "Yulethra",
		"password": "FROSTBITE",
		"title": "",
	},
	
	{
		"name": "4-1",
		"planet": "Tinselar",
		"password": "SUBZERO",
		"title": "",
	},
	{
		"name": "4-2",
		"planet": "Tinselar",
		"password": "SOLSTICE",
		"title": "",
	},
	{
		"name": "4-3",
		"planet": "Tinselar",
		"password": "IGLOO",
		"title": "",
	},
	{
		"name": "4-4",
		"planet": "Tinselar",
		"password": "SNOWDRIFT",
		"title": "",
	},
	{
		"name": "4-5",
		"planet": "Tinselar",
		"password": "PENGUIN",
		"title": "",
	},
	{
		"name": "4-6",
		"planet": "Tinselar",
		"password": "ENDDEMOGAMITAINA",
		"title": "",
	},
]

PLANET_NAME = {}
LEVEL_NAME = {}

for i in range(0, STAGE_COUNT-1)
{
	PLANET_NAME[i] = STAGE_INFO[i]["planet"]
	LEVEL_NAME[i] = STAGE_INFO[i]["name"]
}

COMPLETE_BY_WORLD = {
	"1": 2,
	"2": 3,
	"3": 5,
	"4": 5,
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_level() => round_active() == 1 && game_state() >= 0x07 && game_state() <= 0x10 && boot_state() != 0x55

function level_complete() => (
	// all batteries collected (confirmation) and victory value set (victory value flickers)
	remaining_batteries() == 0 && victory() == 1 && 
	// transition from round active to 0xff is the more reliable check
	prev(round_active()) == 1 && round_active() == 0xff
)

function completed_levels() => sum_of(range(0, STAGE_COUNT-1), i => byte(PERSONAL_BESTS + i) / byte(PERSONAL_BESTS + i))

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(in_level(),
	"🎁🎄🎁 Cube Droid is saving Planet {0} ☃️ ({1}) | 👣 {2} step{3} | 🔋 {4} batter{5} remaining{6}",
	/* 0 */ rich_presence_lookup("Planet", current_level(), PLANET_NAME, fallback=PLANET_NAME[0]),
	/* 1 */ rich_presence_lookup("Level", current_level(), LEVEL_NAME, fallback=LEVEL_NAME[0]),
	/* 2 */ rich_presence_number(step_counter()),
	/* 3 */ plural(step_counter()),
	/* 4 */ rich_presence_number(remaining_batteries()),
	/* 5 */ rich_presence_lookup("_PlY", remaining_batteries(), {1: "y"}, fallback="ies"),
	/* 6 */ rich_presence_lookup("Alarm", remaining_batteries(), {0: " 🚨"}, fallback="")
)

rich_presence_display(
	"🎁🎄🎁 Cube Droid is saving Christmas ☃️ (completed {0} level{1})",
	rich_presence_number(completed_levels()),
	plural(completed_levels())
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

for level in range(0, STAGE_COUNT-1)
{
	stage = STAGE_INFO[level]
	// levelname = format("{0} {1}", stage["planet"], stage["name"])
	levelname = stage["title"]

	achievement(
		title=format("{0} Complete", levelname),
		description=format("Complete level {0}", stage["name"]),
		type=if_else(level == STAGE_COUNT-1, "win_condition", "progression"),
		points=COMPLETE_BY_WORLD[substring(stage["name"], 0, 1)],
		trigger=current_level() == level && level_complete()
	)
	
	if (dictionary_contains_key(stage, "challenge"))
	{
		achievement(
			title=format("{0} Optimized", levelname),
			description=format("Complete level {0} {1}", stage["name"], stage["challenge"]["desc"]),
			points=stage["challenge"]["points"],
			trigger=current_level() == level && trigger_when(level_complete()) && stage["challenge"]["trigger"]
		)
	}
}

// --- LEADERBOARDS -------------------------------------------------------------------

for level in range(0, STAGE_COUNT-1)
{
	stage = STAGE_INFO[level]
	leaderboard(
		title=format("{0} {1}", stage["planet"], stage["name"]),
		description=format("Complete level {0} in the fewest steps", stage["name"]),
	
		start=current_level() == level && level_complete(),
		cancel=always_false(),
		submit=always_true(),
	
		value=measured(step_counter()),
		format="VALUE",
		lower_is_better=true
	)
}