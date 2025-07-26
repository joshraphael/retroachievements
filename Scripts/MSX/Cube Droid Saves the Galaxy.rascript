// ~Homebrew~ Cube Droid Saves the Galaxy
// #ID = 34126

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

// --- MEMORY -------------------------------------------------------------------

// $000000: Fixed State [8 bit]
//          0x0d = Always after the game has booted
//          0x55 = MSX boot screen
//          0xFF = initial boot (might depend on the core)
function boot_state() => byte(0x000000)

// $000016: Game State [8 bit]
//          0x07 = loading level
//          0x10 = playing level
//          0x22 = select starting level
//          0x9b = write password
function game_state() => byte(0x000016)

// $00001D: Title Screen Mode [8 bit]
//          1 = Title Card
//          2 = Story
//          3 = Credits
function title_screen_mode() => byte(0x00001D)

// $000022: Current Level [8 bit]
//          0 indexed, 0 = 1-1
function current_level() => byte(0x000022)

// $000023: Remaining Batteries [8 bit]
function remaining_batteries() => byte(0x000023)

// $000026: Victory [8 bit]
//          1 = Level Ended
//          0 = Otherwise
function victory() => byte(0x000026)

// $000130: Round Active [8 bit]
//          0x00 = Round Starting
//          0x01 = In Game
//          0xFF = Out of Game (victory, loading)
function round_active() => byte(0x000130)

// $000134: Player X Position [8 bit]
//          use Upper4 for column number
function x_pos() => byte(0x000134)

// $000135: Player Y Position [8 bit]
//          use Upper4 for row number
function y_pos() => byte(0x000135)

// $000145: Board Layout [256 bytes]
//          12x12 layout with a 2-wide border all the way around
//          
//          0x00 = Empty
//          0x01 = Pushable
//          0x02 = Player
//          0x03 = Battery
//          0x04 = Exit
//          0x06 = Teleport Crates
//          0x07 = Enemy - Guardian (Awake)
//          0x08 = Enemy - Laser Tower
//          0x0b = Enemy - Roller Saw
//          0x0c = Wall
//          0x0f = Vat/Tank
//          0x10 = Enemy - Guardian (Asleep)
//          0x34 = Enemy - Cannon Shooter
BOARD_LAYOUT = 0x000145
function tile_at(x, y) => byte(BOARD_LAYOUT + (y + 2) * 16 + (x + 2))

// $000415: Personal Bests (Step Count) [36 bytes]
//          setting a level to non-zero unlocks the next level
PERSONAL_BESTS = 0x000415

// $0005AA: Step Counter [8 bit]
//          max 0xff = 255
function step_counter() => byte(0x0005AA)

// $0005DA: Alive [8 bit]
//          while on a board only
//          1 is alive, 0 is dead
function alive() => byte(0x0005DA)

// $00077E: Sound Effect Playing [8 bit]
//          1 = sound effect active
//          0 = otherwise
function sound_effect_playing() => byte(0x00077E)

// $00077F: Sound Sequence [16 bit]
//          0xE1BD = Select Level, Cannon Shooting
//          0xE140 = Collect Battery
//          0xE1FF = Teleport Crate Disappeared
//          0xE27D = Zapped
//          0xE392 = Entering Stage
//          0xE444 = Dying
function sound_sequence() => word(0x00077F)
function play_sound(x) => prev(sound_effect_playing()) == 0 && sound_effect_playing() == 1 && sound_sequence() == x

// --- MAIN DATA -------------------------------------------------------------------

STAGE_COUNT = 36

SOUND_TELEPORT_CRATE_DISAPPEAR = 0xE1FF

POINTS_MEDIUM = 3
POINTS_TRICKY = 5
POINTS_HARD = 5

STAGE_INFO = [
	{
		"name": "1-1",
		"planet": "Aruru",
		"password": "HEADROOM",
		"title": "Battery",
		"challenge": {
			"trigger": (step_counter() <= 21),
			"desc": "in 21 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "1-2",
		"planet": "Aruru",
		"password": "JOHNNYCAB",
		"title": "Grand Cross",
		"challenge": {
			"trigger": (step_counter() <= 31),
			"desc": "in 31 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "1-3",
		"planet": "Aruru",
		"password": "BISHOP",
		"title": "Cannoneer",
		"challenge": {
			"trigger": (step_counter() <= 50),
			"desc": "in 50 steps or fewer",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "1-4",
		"planet": "Aruru",
		"password": "KRYTEN",
		"title": "Guardian",
		"challenge": {
			"trigger": (step_counter() <= 30),
			"desc": "in 30 steps or fewer",
			"points": POINTS_TRICKY,
		},
	},
	{
		"name": "1-5",
		"planet": "Aruru",
		"password": "DALEK",
		"title": "Rollerblade",
		"challenge": {
			"trigger": (step_counter() <= 41),
			"desc": "in 41 steps or fewer",
			"points": POINTS_HARD,
		},
	},
	{
		"name": "1-6",
		"planet": "Aruru",
		"password": "CENTURION",
		"title": "Dematerialize",
		"challenge": {
			"trigger": (step_counter() <= 110),
			"desc": "in 110 steps or fewer",
			"points": POINTS_HARD,
		},
	},

	{
		"name": "2-1",
		"planet": "Ishtar",
		"password": "RODRIGUEZ",
		"title": "Ambush",
		/*
		"challenge": {
			"trigger": (step_counter() <= 50),
			"desc": "in 50 steps or fewer",
			"points": POINTS_TRICKY,
		},
		*/
		"challenge": {
			"trigger": disable_when(
				tile_at(5, 8) != 0x01 || tile_at(5, 9) != 0x01 || tile_at(7, 8) != 0x01 || tile_at(7, 9) != 0x01,
				until=step_counter() == 0
			),
			"desc": "without moving any boxes",
			"points": POINTS_TRICKY,
		},
	},
	{
		"name": "2-2",
		"planet": "Ishtar",
		"password": "T1000",
		"title": "Chambers",
		"challenge": {
			"trigger": (step_counter() <= 45),
			"desc": "in 45 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "2-3",
		"planet": "Ishtar",
		"password": "ASH",
		"title": "Standoff",
		"challenge": {
			"trigger": (step_counter() <= 55),
			"desc": "in 55 steps or fewer",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "2-4",
		"planet": "Ishtar",
		"password": "DOROTHYROBOT",
		"title": "Security",
		"challenge": {
			"trigger": (step_counter() <= 50),
			"desc": "in 50 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "2-5",
		"planet": "Ishtar",
		"password": "PSSSTROBBIE",
		"title": "Slow Rollin'",
		"challenge": {
			"trigger": (step_counter() <= 41),
			"desc": "in 41 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "2-6",
		"planet": "Ishtar",
		"password": "AVA",
		"title": "Firing Squad",
		"challenge": {
			"trigger": (step_counter() <= 28),
			"desc": "in 28 steps or fewer",
			"points": 0,
		},
	},

	{
		"name": "3-1",
		"planet": "Nergal",
		"password": "ROBY",
		"title": "Labyrinth",
		"challenge": {
			"trigger": (step_counter() <= 110),
			"desc": "in 110 steps or fewer",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "3-2",
		"planet": "Nergal",
		"password": "MUFFIT",
		"title": "Sawmill",
		"challenge": {
			"trigger": (step_counter() <= 60),
			"desc": "in 60 steps or fewer",
			"points": POINTS_HARD,
		},
	},
	{
		"name": "3-3",
		"planet": "Nergal",
		"password": "TWIKI",
		"title": "Skull",
		"challenge": {
			"trigger": (step_counter() < 60),
			"desc": "in fewer than 60 steps",
			"points": POINTS_TRICKY,
		},
	},
	{
		"name": "3-4",
		"planet": "Nergal",
		"password": "MARVIN",
		"title": "Columns",
		"challenge": {
			"trigger": (step_counter() <= 30),
			"desc": "in 30 steps or fewer",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "3-5",
		"planet": "Nergal",
		"password": "KITT",
		"title": "Anticipation",
		"challenge": {
			"trigger": (step_counter() <= 55),
			"desc": "in 55 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "3-6",
		"planet": "Nergal",
		"password": "THETURK",
		"title": "Bodyguards",
		"challenge": {
			"trigger": (step_counter() <= 40),
			"desc": "in 40 steps or fewer",
			"points": 0,
		},
	},

	{
		"name": "4-1",
		"planet": "Ninurta",
		"password": "DRTHEOPOLIS",
		"title": "Back-to-Back",
		"challenge": {
			"trigger": (step_counter() <= 59),
			"desc": "in 59 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "4-2",
		"planet": "Ninurta",
		"password": "CYLON",
		"title": "Obstruction",
		"challenge": {
			"trigger": (step_counter() <= 90),
			"desc": "in 90 steps or fewer",
			"points": POINTS_HARD,
		},
	},
	{
		"name": "4-3",
		"planet": "Ninurta",
		"password": "NUMBERSIX",
		"title": "Timing is Key",
		"challenge": {
			"trigger": (step_counter() <= 56), // TODO: i can't even beat 60 lmao
			"desc": "in 56 steps or fewer",
			"points": POINTS_TRICKY,
		},
	},
	{
		"name": "4-4",
		"planet": "Ninurta",
		"password": "SVI2000",
		"title": "Frenemies",
		"challenge": {
			"trigger": (step_counter() <= 120),
			"desc": "in 120 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "4-5",
		"planet": "Ninurta",
		"password": "OPTIMUSPRIME",
		"title": "Stealth",
		"challenge": {
			"trigger": (step_counter() <= 55),
			"desc": "in 55 steps or fewer",
			"points": POINTS_TRICKY,
		},
	},
	{
		"name": "4-6",
		"planet": "Ninurta",
		"password": "DATA",
		"title": "Resupply",
		"challenge": {
			"trigger": once(
				// when the battery count goes down 3->2
				prev(remaining_batteries()) == 3 && remaining_batteries() == 2 && 
				// is the player standing on the tile where the left-most battery was?
				tile_at(0, 6) == 0x02 && 
				// reset when level resets
				never(step_counter() == 0)
			),
			"desc": "after collecting the left-most battery first",
			"points": POINTS_TRICKY,
		},
	},

	{
		"name": "5-1",
		"planet": "Marduk",
		"password": "FURBY",
		"title": "Panopticon",
		"challenge": {
			"trigger": (step_counter() <= 87),
			"desc": "in 87 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "5-2",
		"planet": "Marduk",
		"password": "ANDROIDONE",
		"title": "Sniper",
		"challenge": {
			"trigger": (step_counter() <= 95),
			"desc": "in 95 steps or fewer",
			"points": POINTS_TRICKY,
		},
	},
	{
		"name": "5-3",
		"planet": "Marduk",
		"password": "CURIOUSITY",
		"title": "Checkmate",
		"challenge": {
			"trigger": (step_counter() <= 100),
			"desc": "in 100 steps or fewer",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "5-4",
		"planet": "Marduk",
		"password": "T800",
		"title": "Portal",
		"challenge": {
			"trigger": (step_counter() <= 102),
			"desc": "in 102 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "5-5",
		"planet": "Marduk",
		"password": "HAL9000",
		"title": "Surrounded",
		"challenge": {
			"trigger": (step_counter() <= 50),
			"desc": "in 50 steps or fewer",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "5-6",
		"planet": "Marduk",
		"password": "TALKIETOASTER",
		"title": "Take the Shot",
		"challenge": {
			"trigger": repeated(6, play_sound(SOUND_TELEPORT_CRATE_DISAPPEAR)) && never(step_counter() == 0),
			"desc": "after destroying all but two teleport crates",
			"points": POINTS_MEDIUM,
		},
	},

	{
		"name": "6-1",
		"planet": "Shamash",
		"password": "ED209",
		"title": "Canyon",
		"challenge": {
			"trigger": all_of(range(0,11), y => all_of(range(0,11), x => tile_at(x, y) != 0x06)),
			"desc": "after destroying all teleport crates",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "6-2",
		"planet": "Shamash",
		"password": "ROOMBA",
		"title": "Blind",
		"challenge": {
			"trigger": (step_counter() <= 50),
			"desc": "in 50 steps or fewer",
			"points": POINTS_TRICKY,
		},
	},
	{
		"name": "6-3",
		"planet": "Shamash",
		"password": "SEVENOFNINE",
		"title": "Spiral",
		"challenge": {
			"trigger": (step_counter() <= 102),
			"desc": "in 102 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "6-4",
		"planet": "Shamash",
		"password": "LOCUTUS",
		"title": "For Want of a Box",
		"challenge": {
			"trigger": (step_counter() <= 137),
			"desc": "in 137 steps or fewer",
			"points": 0,
		},
	},
	{
		"name": "6-5",
		"planet": "Shamash",
		"password": "ROYBATTY",
		"title": "Copycat",
		"challenge": {
			"trigger": (step_counter() <= 65),
			"desc": "in 65 steps or fewer",
			"points": POINTS_MEDIUM,
		},
	},
	{
		"name": "6-6",
		"planet": "Shamash",
		"password": "ENDDEMOGAMITAINA", // https://www.angelfire.com/art2/unicorndreams/msx/Hints.html
		"title": "Checkers",
		"challenge": {
			"trigger": (step_counter() <= 95),
			"desc": "in 95 steps or fewer",
			"points": POINTS_MEDIUM,
		},
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
	"3": 3,
	"4": 5,
	"5": 5,
	"6": 5,
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
	"🤖 Cube Droid is saving Planet {0} 🪐 ({1}) | 👣 {2} step{3} | 🔋 {4} batter{5} remaining{6}",
	/* 0 */ rich_presence_lookup("Planet", current_level(), PLANET_NAME, fallback=PLANET_NAME[0]),
	/* 1 */ rich_presence_lookup("Level", current_level(), LEVEL_NAME, fallback=LEVEL_NAME[0]),
	/* 2 */ rich_presence_number(step_counter()),
	/* 3 */ plural(step_counter()),
	/* 4 */ rich_presence_number(remaining_batteries()),
	/* 5 */ rich_presence_lookup("_PlY", remaining_batteries(), {1: "y"}, fallback="ies"),
	/* 6 */ rich_presence_lookup("Alarm", remaining_batteries(), {0: " 🚨"}, fallback="")
)

rich_presence_display(
	"🤖 Cube Droid is saving the galaxy 🪐 (completed {0} level{1})",
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
	
	if (stage["challenge"]["points"] >= POINTS_MEDIUM)
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