// Lifeline | Life Line
// #ID = 19057

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function is_set(acc) => acc > prev(acc)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function ptr(x) => dword(x)

// --- MEMORY -------------------------------------------------------------------

// $34F440: Message Identifier [32 bit]
function message_identifier() => dword(0x34F440)

// $38CF24: Pointer to Rio's Active/Recent Voice Data [32 bit]
//          
//          +0x090 | Rio's Active Voice Line Time Sequence [32 bit]
//          +0x1E0 | Pointer to Active/Recent Voice Stream Data [32 bit]
//          +0x3C4 | Is Actively Talking [32 bit] (1 when talking)
RIO_VOICE_STRUCT = 0x38CF24
function ptr_to_active_voice_stream() => ptr(ptr(0x38CF24) + 0x1E0)
function is_rio_talking() => dword(ptr(0x38CF24) + 0x3C4)

// $38D100: Pointer to Game State [32 bit]
//          +0x0000 | Pointer to Game State Table [32 bit]
//          .. +0x7FF0 | Location ID / Game State [32 bit]
//          .. +0x8014 | Game Time (in frames) [32 bit]
//          .. +0x8034 | Meta Location/State [32 bit]
//          +0x0AD4 | Can Talk [8 bit] (0 = Cannot Talk, 1 = Talk Now)
//          +0x0B0C | Voice Score [16 bit]
//          +0x0B64 | Voice Command Given [ASCII]
//          
//          Locations:
//          0x01 = Equipment Room
//          0x02 = Guest Room 1
//          0x03 = Guest Room 2
//          0x04 = Guest Room 3
//          0x05 = Guest Room 4
//          0x08 = Guest Room 5
//          0x09 = Sun Suite
//          0x0A = Moon Suite
//          0x0B = Restrooms (Dark)
//          0x0C = Medical Room
//          0x0D = Security Room
//          0x0E = Receiving Port
//          0x0F = Staff Room
//          0x11 = Service Staff Quarters
//          0x13 = Waiting Room
//          0x14 = Elevator Hall (by Observatory Restaurant)
//          0x16 = Warehouse
//          0x15 = Elevator Hall (top of elevator)
//          0x17 = Elevator Hall (by Receiving Port)
//          0x19 = Observatory Restaurant
//          0x1A = Observatory Elevator
//          0x20 = Break Room
//          0x21 = Manager's Office
//          0x22 = Exhibit Room
//          0x24 = Hideaway
//          0x25 = Laboratory
//          0x26 = Zero-Gravity Warehouse
//          0x28 = Shuttleport
//          0x3D = Hall - GUEST (1)
//          0x3E = Hall - GUEST (1)
//          0x44 = Hall - GUEST (1 return)
//          0x4D = Hall - STAFF
//          0x4E = Hall - STAFF
//          0x4F = Duct
//          0x50 = Hall - STAFF
//          0x58 = Hall - SENIOR STAFF
//          0x5E = Corridor
//          
//          State:
//          0x63 (99) = Ending
//          0x64 (100) = Save Game
//          0x65 (101) = Load Game
//          
//          0x3E8 (1000) = Tutorial
//          0x3EC (1004) = Title Screen
//          0x3ED (1005) = Bonus Game (All)
//          0x3F7 (1015) = Game Over
function game_state_ptr() => ptr(0x38D100)
function game_state_tbl() => ptr(game_state_ptr() + 0x00)

function location() => dword(game_state_tbl() + 0x7FF0)
function game_time_f() => dword(game_state_tbl() + 0x8014)
function game_time_secs() => game_time_f() / 60
function meta_state() => dword(game_state_tbl() + 0x8034)

function can_talk() => byte(game_state_ptr() + 0x0AD4)
function voice_score() => word(game_state_ptr() + 0x0B0C)
VOICE_COMMAND_TEXT = game_state_ptr() + 0x0B64

// $38D14C: Pointer to Player Vars [32 bit]
//          +0x08 | Pointer to Player Vars Table [32 bit]
//          .. +0x0018 | Current Health [32 bit] (max = 1000)
//          .. +0x0058 | Heal Capsules [32 bit]
//          .. +0x0078 | Launcher Grenades [32 bit]
//          .. +0x00b8 | Chips Collected [32 bit]
//          .. +0x03f8 | Number of Voice Commands [16 bit]
//          .. +0x0478 | Word Jumble High Score [32 bit]
//          .. +0x0498 | Complete the Phrases High Score [32 bit]
//          .. +0x04b8 | The Calc High Score [32 bit]
//          .. +0x04d8 | Categories Game Wins [32 bit]
//          .. +0x04f8 | Categories Game Losses [32 bit]
function player_vars_ptr() => ptr(0x38D14C)
function player_vars_tbl() => ptr(player_vars_ptr() + 0x08)

function current_health() => dword(player_vars_tbl() + 0x0018)
function heal_capsules() => dword(player_vars_tbl() + 0x0058)
function launcher_grenades() => dword(player_vars_tbl() + 0x0078)
function chips_collected() => dword(player_vars_tbl() + 0x00b8)
function voice_command_count() => dword(player_vars_tbl() + 0x03f8)
function word_jumble_high_score() => dword(player_vars_tbl() + 0x0478)
function complete_the_phrases_high_score() => dword(player_vars_tbl() + 0x0498)
function the_calc_high_score() => dword(player_vars_tbl() + 0x04b8)
function categories_game_wins() => dword(player_vars_tbl() + 0x04d8)
function categories_game_losses() => dword(player_vars_tbl() + 0x04f8)

// $38D174: Pointer to Rio's Voice Database [32 bit]
//          +0x0 | Pointer to Start of Voice Stream Data [32 bit]
//          +0x4 | Pointer to Table of Voice Offsets by ID [32 bit]
//          +0x8 | Size of Voice Data Table
//          +0xC | Size of individual Voice Table Entries [32 bit] (1 = 0x10, 2 = 0x20)
function voice_stream_ptr() => ptr(0x38D174)
function ptr_to_voice_stream_data() => ptr(voice_stream_ptr() + 0x0)
function ptr_to_voice_table() => ptr(voice_stream_ptr() + 0x4)
function voice_table_size() => dword(voice_stream_ptr() + 0x8)
function voice_table_entry_size() => dword(voice_stream_ptr() + 0xC) * 0x10

// $3E5130: Flags [8 bit]

// --- MAIN DATA -------------------------------------------------------------------

VOICE_CONCLUDES_TUTORIAL = 0xC431
VOICE_GOODBYE_BADEND = 0x0C77
VOICE_RIO_BARKS = 0x5070
VOICE_RIO_SEXY_POSE = 0x1133
VOICE_RIO_CAMERA_CHECK = 0x1134
VOICE_SHE_SELLS_LOSE = 0x5044
VOICE_SHE_SELLS_WIN = 0x5059
VOICE_GIRL_NAME_KRISTEN = 0x2220
VOICE_GIRL_NAME_RIO = 0x2222
VOICE_MOON_PM_HOLD_UP = 0x2B5F
VOICE_MOON_RIO_STOP = 0x2B91

LOC_EQUIPMENT_ROOM = 0x01
LOC_GUEST_ROOM_1 = 0x02
LOC_GUEST_ROOM_2 = 0x03
LOC_GUEST_ROOM_3 = 0x04
LOC_GUEST_ROOM_4 = 0x05
LOC_GUEST_ROOM_5 = 0x08
LOC_SUN_SUITE = 0x09
LOC_MOON_SUITE = 0x0A
LOC_RESTROOMS = 0x0B
LOC_MEDICAL_ROOM = 0x0C
LOC_SECURITY_ROOM = 0x0D
LOC_RECEIVING_PORT = 0x0E
LOC_STAFF_ROOM = 0x0F
LOC_SERVICE_STAFF_QTRS = 0x11
LOC_WAITING_ROOM = 0x13
LOC_ELEVATOR_HALL_1 = 0x14
LOC_WAREHOUSE = 0x16
LOC_ELEVATOR_HALL_2 = 0x15
LOC_ELEVATOR_HALL_3 = 0x17
LOC_OBSERVATORY_RESTAURANT = 0x19
LOC_OBSERVATORY_ELEVATOR = 0x1A
LOC_BREAK_ROOM = 0x20
LOC_MANAGERS_OFFICE = 0x21
LOC_EXHIBIT_ROOM = 0x22
LOC_HIDEAWAY = 0x24
LOC_ZEROG_LABORATORY = 0x25
LOC_ZEROG_WAREHOUSE = 0x26
LOC_SHUTTLEPORT = 0x28
LOC_HALL_GUEST1A = 0x3D
LOC_HALL_GUEST1B = 0x3E
LOC_HALL_GUEST1_RETURN = 0x44
LOC_HALL_STAFF_A = 0x4D
LOC_HALL_STAFF_B = 0x4E
LOC_DUCTS = 0x4F
LOC_HALL_STAFF_C = 0x50
LOC_HALL_SENIOR_STAFF = 0x58
LOC_ZEROG_CORRIDOR = 0x5E

META_TITLE_SCREEN = 0x3EC
META_TUTORIAL = 0x3E8
META_BONUS_GAME = 0x3ED
META_ENDING = 0x63
META_GAME_OVER = 0x3F7
META_SAVE_GAME = 0x64
META_LOAD_GAME = 0x65

MIRRORS = [
	bit2(0x3E516E), // [Mirror] Restrooms Ladies' Washstands left
	bit3(0x3E516E), // [Mirror] Restrooms Ladies' Washstands middle
	bit4(0x3E516E), // [Mirror] Restrooms Ladies' Washstands right
	bit5(0x3E516E), // [Mirror] Restrooms Men's Washstands left
	bit6(0x3E516E), // [Mirror] Restrooms Men's Washstands middle
	bit7(0x3E516E), // [Mirror] Restrooms Men's Washstands right
	bit1(0x3E51A1), // [Mirror] Guest Room 2 Dresser
	bit6(0x3E51A1), // [Mirror] Guest Room 2 Bathroom
	bit5(0x3E51A2), // [Mirror] Guest Room 3 Dresser
	bit6(0x3E51A3), // [Mirror] Guest Room 4 Dresser
	bit3(0x3E51A5), // [Mirror] Sun Suite 2nd Floor Washroom
	bit5(0x3E51A6), // [Mirror] Guest Room 1 Dresser
	bit2(0x3E51A7), // [Mirror] Guest Room 1 Bathroom
]

COMMANDS = [
	bit3(0x3E514A), // [Command] Sexy pose
	bit4(0x3E514A), // [Command] Camera check
	bit5(0x3E514A), // [Command] Jumpback
	bit6(0x3E514A), // [Command] Jump
	bit0(0x3E514B), // [Command] Microphone check
	bit1(0x3E514B), // [Command] Category Game
	bit2(0x3E514B), // [Command] Break time
	bit3(0x3E514B), // [Command] Strafe
	bit4(0x3E514B), // [Command] Spin the Gun
	bit5(0x3E514B), // [Command] Taunt
	bit6(0x3E514B), // [Command] Auto-fire
	bit7(0x3E514B), // [Command] Zoom in
	bit0(0x3E514C), // [Command] I'll leave it to you
	bit1(0x3E514C), // [Command] She sells
	bit2(0x3E514C), // [Command] Low kick
]

CHIPS = [
	bit7(0x3E5136), // [Chip] Sun Suite Fruits @ Lounge
	bit5(0x3E513C), // [Chip] Security Room Locker
	bit4(0x3E5145), // [Chip] Equipment Room center Utility Unit shelf
	bit1(0x3E5148), // [Chip] Break Room Table Mug
	bit5(0x3E514F), // [Chip] Guest Room 1 Trunk
	bit1(0x3E5153), // [Chip] Guest Room 2 Nightstand
	bit4(0x3E5156), // [Chip] Guest Room 3 - Cigar Case
	bit7(0x3E5159), // [Chip] Guest Room 4 Bed
	bit2(0x3E515D), // [Chip] Guest Room 5 - Bathrobe on Bed
	bit7(0x3E5168), // [Chip] Infirmary Case 5
	bit1(0x3E516C), // [Chip] Restrooms - Men's Stalls #2
	bit5(0x3E5174), // [Chip] Waiting Room Under Video Camera
	bit6(0x3E5175), // [Chip] Staff Room Gustav's locker
	bit3(0x3E5179), // [Chip] Manager's Office Bed under pillow
	bit0(0x3E517B), // [Chip] Warehouse Area B-2
	bit6(0x3E5184), // [Chip] Observatory Restaurant VIP Seat 2
]

CANDY = [
	bit3(0x3E519F), // Staff Room Table - Eat Candy (#1 Orange)
	bit4(0x3E519F), // Staff Room Table - Eat Candy (#2 Banana)
	bit5(0x3E519F), // Staff Room Table - Eat Candy (#3 Watermelon)
	bit6(0x3E519F), // Staff Room Table - Eat Candy (#4 Grape)
]

TONGUE_TWISTERS = [
	{
		"name": "Peter Piper", 
		"voice": 0x5054,
		"text": "Peter Piper",
	},
	{
		"name": "Woodchuck", 
		"voice": 0x5055,
		"text": "How much wood",
	},
	{
		"name": "I Saw Esau", 
		"voice": 0x5056,
		"text": "I saw Esau",
	},
	{
		"name": "She Stood on the Balcony", 
		"voice": 0x5057,
		"text": "She stood on",
	},
	{
		"name": "Betty Batter", 
		"voice": 0x5058,
		"text": "Betty Batter",
	},
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => meta_state() <= 0x5E

function not_loading() => prev(bit0(0x3E522B)) == bit0(0x3E522B)

function win_the_game() => prev(meta_state()) == LOC_SHUTTLEPORT && meta_state() == META_ENDING

function complete_tutorial() => prev(meta_state()) == META_TUTORIAL && meta_state() == LOC_SECURITY_ROOM

function bits_completion(a, t = 0, when = always_true())
{
	if (t == 0) t = length(a)
	return sum_of(a, x => prev(x)) == t-1 && measured(sum_of(a, x => x) >= t, when=when)
}

function chip_check(n) => (
	not_loading() && prev(chips_collected()) == n-1 && measured(chips_collected() >= n, when=in_game())
)

function command_check(n) => (
	not_loading() && bits_completion(COMMANDS, t=n, when=in_game())
)

function flag_location(flag, loc) => in_game() && not_loading() && location() == loc && is_set(flag)

// I owe Souzooka big time for helping me work this logic out :)
// usable ids can be found by putting an execution breakpoint at 00162E80 and checking the contents of register a1
TABLE_MAX = 300
function rio_says(id, size = 300, step = 0x10) => (
	// rio stopped talking
	is_rio_talking() < prev(is_rio_talking()) &&

	// if we know what the size should be, this should be explicit
	voice_table_entry_size() == step &&

	// loop through voice table
	any_of(range(0, size), (i) => (
		// the index is within the bounds of the table
		i < voice_table_size() &&

		// the id of the voice line in the table matches the id we are looking for
		dword(ptr_to_voice_table() + (i * step) + 0x0) == id &&

		// the pointer to the current spoken voice line matches this entry with a 0x10 offset
		ptr_to_voice_stream_data() + dword(ptr_to_voice_table() + (i * step) + 0x8) + 0x10 == ptr_to_active_voice_stream()
	))
)

function player_spoke() => prev(can_talk()) == 1 && can_talk() == 0 && voice_score() != 0

// --- RICH PRESENCE -------------------------------------------------------------------

Locations = {
	LOC_EQUIPMENT_ROOM: "Equipment Room",
	LOC_GUEST_ROOM_1: "Guest Room 1",
	LOC_GUEST_ROOM_2: "Guest Room 2",
	LOC_GUEST_ROOM_3: "Guest Room 3",
	LOC_GUEST_ROOM_4: "Guest Room 4",
	LOC_GUEST_ROOM_5: "Guest Room 5",
	LOC_SUN_SUITE: "Sun Suite",
	LOC_MOON_SUITE: "Moon Suite",
	LOC_RESTROOMS: "Toilet",
	LOC_MEDICAL_ROOM: "Medical Room",
	LOC_SECURITY_ROOM: "Security Room",
	LOC_RECEIVING_PORT: "Receiving Port",
	LOC_STAFF_ROOM: "Staff Room",
	LOC_SERVICE_STAFF_QTRS: "Service Staff Quarters",
	LOC_WAITING_ROOM: "Waiting Room",
	LOC_ELEVATOR_HALL_1: "Elevator Hall",
	LOC_WAREHOUSE: "Warehouse",
	LOC_ELEVATOR_HALL_2: "Elevator Hall",
	LOC_ELEVATOR_HALL_3: "Elevator Hall",
	LOC_OBSERVATORY_RESTAURANT: "Observatory Restaurant",
	LOC_OBSERVATORY_ELEVATOR: "Observatory Elevator",
	LOC_BREAK_ROOM: "Break Room",
	LOC_MANAGERS_OFFICE: "Manager's Office",
	LOC_EXHIBIT_ROOM: "Exhibit Room",
	LOC_HIDEAWAY: "Hideaway",
	LOC_ZEROG_LABORATORY: "Laboratory",
	LOC_ZEROG_WAREHOUSE: "Zero-Gravity Warehouse",
	LOC_SHUTTLEPORT: "Shuttleport",
	LOC_HALL_GUEST1A: "Guest Floor Hall",
	LOC_HALL_GUEST1B: "Guest Floor Hall",
	LOC_HALL_GUEST1_RETURN: "Guest Floor Hall",
	LOC_HALL_STAFF_A: "Staff Floor Hall",
	LOC_HALL_STAFF_B: "Staff Floor Hall",
	LOC_DUCTS: "Duct",
	LOC_HALL_STAFF_C: "Staff Floor Hall",
	LOC_HALL_SENIOR_STAFF: "Senior Staff Floor Hall",
	LOC_ZEROG_CORRIDOR: "Zero-Gravity Corridor",
}

ASCII = {
	0x20: " ",
	0x2C: ",",
	0x2E: ".",
	0x30: "0",
	0x31: "1",
	0x32: "2",
	0x33: "3",
	0x34: "4",
	0x35: "5",
	0x36: "6",
	0x37: "7",
	0x38: "8",
	0x39: "9",
	0x41: "A",
	0x42: "B",
	0x43: "C",
	0x44: "D",
	0x45: "E",
	0x46: "F",
	0x47: "G",
	0x48: "H",
	0x49: "I",
	0x4A: "J",
	0x4B: "K",
	0x4C: "L",
	0x4D: "M",
	0x4E: "N",
	0x4F: "O",
	0x50: "P",
	0x51: "Q",
	0x52: "R",
	0x53: "S",
	0x54: "T",
	0x55: "U",
	0x56: "V",
	0x57: "W",
	0x58: "X",
	0x59: "Y",
	0x5A: "Z",
	0x61: "A",
	0x62: "B",
	0x63: "C",
	0x64: "D",
	0x65: "E",
	0x66: "F",
	0x67: "G",
	0x68: "H",
	0x69: "I",
	0x6A: "J",
	0x6B: "K",
	0x6C: "L",
	0x6D: "M",
	0x6E: "N",
	0x6F: "O",
	0x70: "P",
	0x71: "Q",
	0x72: "R",
	0x73: "S",
	0x74: "T",
	0x75: "U",
	0x76: "V",
	0x77: "W",
	0x78: "X",
	0x79: "Y",
	0x7A: "Z",
}

rp_location = rich_presence_lookup("Location", location(), Locations, fallback="JSL Station")
rp_health = rich_presence_value("_Fixed1", current_health(), "FIXED1")
rp_chips = rich_presence_value("_Number", chips_collected(), "VALUE")
rp_heal_capsules = rich_presence_value("_Number", heal_capsules(), "VALUE")
rp_time = rich_presence_value("_Minutes", game_time_secs() / 60, "MINUTES")
rp_voice_commands = rich_presence_value("_Number", voice_command_count(), "VALUE")
rp_found_commands = rich_presence_value("_Number", sum_of(COMMANDS, v => v), "VALUE")

rich_presence_conditional_display(meta_state() == META_TUTORIAL,
	"🔰 The operator is going through the tutorial"
)

rich_presence_conditional_display(meta_state() == META_BONUS_GAME,
	"The operator is playing a minigame with Rio"
)

rich_presence_conditional_display(meta_state() == META_ENDING,
	"🚀 Rio and the operator are escaping the JSL Station ⌛ game time: {0}m 🎤 {1} command{2}",
	rp_time,
	rp_voice_commands, plural(voice_command_count())
)

rich_presence_conditional_display(meta_state() == META_TITLE_SCREEN || location() == 0,
	"The operator is getting ready for a Voice Action Adventure"
)

rich_presence_display(
	"📍 {0} ❤️ {1}% 🎟️ {2} chip{3} 💊 {4} EC{5} ⌛ game time: {6}m 🎤 {7} command{8} [{9}]",
	rp_location,
	rp_health,
	rp_chips, plural(chips_collected()),
	rp_heal_capsules, plural(heal_capsules()),
	rp_time,
	rp_voice_commands, plural(voice_command_count()),
	rp_found_commands
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="RTFM | Read the Field Manual",
	description="Start a new game and complete the tutorial",
	type="progression",
	points=2,
	trigger=complete_tutorial()
)

achievement(
	title="Literally Not My Job",
	description="Refuse to help your new friend Rio in the Security Room",
	points=1,
	trigger=location() == LOC_SECURITY_ROOM && rio_says(VOICE_GOODBYE_BADEND)
)

achievement(
	title="Smooth Operator",
	description="Who's Naomi? Rio is my girlfriend now",
	points=1,
	trigger=location() == LOC_SECURITY_ROOM && rio_says(VOICE_GIRL_NAME_RIO)
)

achievement(
	title="Why Does That Name Sound Familiar?",
	description="My girlfriend? You probably wouldn't know her. She's a voice actress in a video game.",
	points=1,
	trigger=location() == LOC_SECURITY_ROOM && rio_says(VOICE_GIRL_NAME_KRISTEN)
)

achievement(
	title="Good Girl! Sit, Stay",
	description="Rio, bark like a dog",
	points=1,
	trigger=in_game() && rio_says(VOICE_RIO_BARKS)
)

achievement(
	title="Pose for the Fans",
	description="Rio, strike a sexy pose",
	points=3,
	trigger=in_game() && bit3(0x3E514A) == 1 && rio_says(VOICE_RIO_SEXY_POSE)
)

achievement(
	title="I Saw Esau Kissing Kate",
	description="Win a game of tongue twisters and heal a bit of health back",
	points=5,
	trigger=in_game() && bit1(0x3E514C) == 1 && rio_says(VOICE_SHE_SELLS_WIN, step=0x20)
)

achievement(
	title="Leave the Security Room? Okay.",
	description="Break out of the hoosegow",
	type="progression",
	points=3,
	trigger=flag_location(bit4(0x3E5149), LOC_HALL_GUEST1A)
)

achievement(
	title="That's a Problem for Future Rio",
	description="Close Shutter 4 on the spider monster",
	type="progression",
	points=5,
	trigger=flag_location(bit5(0x3E5130), LOC_HALL_GUEST1A)
)

achievement(
	title="I Want to Monopolize",
	description="Enter the Sun Suite with your new bride. Who's Naomi, again?",
	type="progression",
	points=5,
	trigger=flag_location(bit1(0x3E5132), LOC_SUN_SUITE)
)

achievement(
	title="Cocktail Waitress",
	description="Defeat the spider monster with the molotov cocktail",
	type="progression",
	points=5,
	trigger=flag_location(bit7(0x3E5130), LOC_HALL_GUEST1B)
)

achievement(
	title="Space Ghosts: Coast to Coast",
	description="Find the key for Shutter 5 in the spooky bathroom",
	type="progression",
	points=5,
	trigger=flag_location(bit4(0x3E5138), LOC_RESTROOMS)
)

achievement(
	title="Dodge, Duck, Dip, Dive, & Dodge",
	description="Avoid an ambush in the Moon Suite and come out unscathed",
	type="missable",
	points=5,
	trigger=location() == LOC_MOON_SUITE && rio_says(VOICE_MOON_RIO_STOP)
)

achievement(
	title="A Quick Costume Change",
	description="Meet up with the goon squad in the Receiving Port and get some new clothes",
	type="progression",
	points=5,
	trigger=flag_location(bit7(0x3E5163), LOC_RECEIVING_PORT)
)

achievement(
	title="Feed Me, Seymour",
	description="Kill the weird plant monster in the Service Staff Quarters and collect the ID card",
	type="progression",
	points=10,
	trigger=flag_location(bit3(0x3E5168), LOC_SERVICE_STAFF_QTRS)
)

achievement(
	title="Taste the Rainbow",
	description="Try every flavor of candy on the table in the Senior Staff Room",
	type="missable",
	points=1,
	trigger=bits_completion(CANDY, when=location() == LOC_STAFF_ROOM)
)

achievement(
	title="gamma_correction.exe",
	description="The files are in the computer. Improve lowlight vision with the surveillance camera extension program",
	type="progression",
	points=5,
	trigger=flag_location(bit1(0x3E5135), LOC_STAFF_ROOM)
)

achievement(
	title="Oh No! The Aliens Are Hot!",
	description="Cross the warehouse",
	type="progression",
	points=10,
	trigger=flag_location(bit5(0x3E517A), LOC_WAREHOUSE)
)

achievement(
	title="There Will Be Time to Rest When I'm Dead",
	description="Cross the warehouse without restoring any lost health",
	type="missable",
	points=25,
	trigger=(
		// enter the warehouse from the staff hall and complete the simon says minigame initially
		once(prior(location()) == LOC_HALL_STAFF_A && location() == LOC_WAREHOUSE && is_set(bit7(0x3E517A))) &&

		never(
			// if the player takes damage in the warehouse...
			once(current_health() < prev(current_health()) && location() == LOC_WAREHOUSE) && 

			// restoring health will reset the achievement
			current_health() > prev(current_health())
		) &&

		// complete the challenge when reaching the other side of the warehouse
		trigger_when(is_set(bit5(0x3E517A))) &&

		// reset if not in the warehouse for some reason
		never(prev(location()) != LOC_WAREHOUSE)
	)
)

achievement(
	title="I'll Wait For It on Blu-ray",
	description="Rendezvous with Helen Johnson in the Waiting Room and collect the DVD",
	type="progression",
	points=5,
	trigger=flag_location(bit3(0x3E5181), LOC_WAITING_ROOM)
)

achievement(
	title="I Hope You're Prepared for an Unforgettable Luncheon",
	description="Rescue the chef trapped in the Observatory Restaurant and get the Elevator code",
	type="progression",
	points=5,
	trigger=flag_location(bit6(0x3E5186), LOC_OBSERVATORY_RESTAURANT)
)

achievement(
	title="Renegotiating Our Contract",
	description="Defeat the creature in the Manager's Office on the Senior Staff level",
	type="progression",
	points=10,
	trigger=flag_location(bit7(0x3E518A), LOC_MANAGERS_OFFICE)
)

achievement(
	title="All I Need Is One Finger!",
	description="Defeat the creature in the Manager's Office without using any explosive charges or heal capsules",
	type="missable",
	points=25,
	trigger=(
		// checkpoint hit on shooting Tanaka in the pre-fight cutscene in the manager's office
		once(not_loading() && location() == LOC_MANAGERS_OFFICE && bit7(0x3E518A) == 0 && is_set(bit4(0x3E513A))) &&

		// reset the challenge if the number of launcher grenades ever goes down
		never(launcher_grenades() < prev(launcher_grenades())) &&

		// reset the challenge if the number of heal capsules ever goes down
		never(heal_capsules() < prev(heal_capsules())) &&

		// challenge is complete when Tanaka (humanoid alien) is defeated
		trigger_when(is_set(bit7(0x3E518A))) &&

		// reset if we leave the manager's office, obviously
		never(location() != LOC_MANAGERS_OFFICE)
	)
)

achievement(
	title="I Was Promised There Wouldn't Be Any Math",
	description="Open the safe in the Manager's Office",
	type="progression",
	points=5,
	trigger=flag_location(bit4(0x3E518A), LOC_MANAGERS_OFFICE) && bit1(0x3E517A) == 1
)

achievement(
	title="wikihow.com/How-To-Defuse-a-Bomb",
	description="Disarm the PBX device in the Exhibit Room",
	type="progression",
	points=5,
	trigger=flag_location(bit6(0x3E518A), LOC_EXHIBIT_ROOM)
)

achievement(
	title="The Big Mystery in Science Sphere Seven",
	description="Reach the Laboratory level of the JSL station",
	type="progression",
	points=5,
	trigger=flag_location(bit6(0x3E5135), LOC_ZEROG_CORRIDOR)
)

achievement(
	title="We Do All Our Science From Scratch. No Hand Holding",
	description="Eject experiment rack 2 in the Laboratory by operating the input panel",
	type="progression",
	points=5,
	trigger=flag_location(bit0(0x3E5194), LOC_ZEROG_LABORATORY)
)

achievement(
	title="Mother? Brain?",
//	title="Gossip Around the Water Cooler",
	description="Learn more about Rio's past on the JSL station",
	type="progression",
	points=1,
	trigger=flag_location(bit1(0x3E513A), LOC_HIDEAWAY)
)

achievement(
	title="Hearts and Krafts",
	description="Discover the truth about Rio Hohenheim and the philosopher's stone from Joe Kraft",
	type="progression",
	points=1,
	trigger=flag_location(bit3(0x3E5139), LOC_ZEROG_CORRIDOR)
)

achievement(
	title="The Stone Is Mine, Kraft!",
	description="Help Rio free you and escape the JSL station together once and for all",
	type="win_condition",
	points=25,
	trigger=win_the_game()
)

// ### COLLECTIONS

achievement(
	title="You've Got Me All Mixed Up",
	description="Collect 4 chips and unlock the Word Jumble minigame",
	type="missable",
	points=5,
	trigger=chip_check(4)
)

achievement(
	title="Ill Weeds Grow Apace",
	description="Collect 8 chips and unlock the Complete the Phrases minigame",
	type="missable",
	points=5,
	trigger=chip_check(8)
)

achievement(
	title="The Human Calculator",
	description="Collect 12 chips and unlock the Calc minigame",
	type="missable",
	points=5,
	trigger=chip_check(12)
)

achievement(
	title="Chips Challenge",
	description="Collect all 16 chips and unlock the Category Game minigame",
	type="missable",
	points=10,
	trigger=chip_check(16)
)

achievement(
	title="Do You Copy, Rio?",
	description="Find 5 of the discoverable voice commands",
	type="missable",
	points=5,
	trigger=command_check(5)
)

achievement(
	title="Stand By For Further Instructions, Rio",
	description="Find 10 of the discoverable voice commands",
	type="missable",
	points=5,
	trigger=command_check(10)
)

achievement(
	title="Full Radio Clearance",
	description="Find all 15 of the discoverable voice commands",
	type="missable",
	points=10,
	trigger=command_check(15)
)

achievement(
	title="They've Got Electrolytes!",
	description="Collect and hold 10 Energy Capsules at once",
	points=10,
	trigger=not_loading() && measured(heal_capsules() >= 10, when=in_game()) && prev(heal_capsules()) == 9
)

achievement(
	title="Seven Years of Bad Luck",
	description="Rio, you can't just break every mirror on the JSL station",
	type="missable",
	points=10,
	trigger=not_loading() && bits_completion(MIRRORS, when=in_game())
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="JSL Space Station Sprint",
	description="Complete the game as fast as possible",

	start=win_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(game_time_f()),
	format="FRAMES",
	lower_is_better=true
)

leaderboard(
	title="I'll Leave It To You",
	description="Complete the game giving the fewest number of voice commands",

	start=win_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(voice_command_count()),
	format="VALUE",
	lower_is_better=true
)

ttid = 1
for twist in TONGUE_TWISTERS
{
	leaderboard(
		title=format("Tongue Twister Expert {0}", ttid),
		description=format("Get the highest voice score on the \"{0}\" tongue twister", twist["name"]),

		start=rio_says(twist["voice"], step=0x20),
		cancel=voice_table_entry_size() != 0x20 || prev(meta_state()) != meta_state(),
		submit=player_spoke() && ascii_string_equals(VOICE_COMMAND_TEXT, twist["text"]),

		value=measured(voice_score()),
		format="VALUE",
		lower_is_better=false
	)
	ttid = ttid + 1
}