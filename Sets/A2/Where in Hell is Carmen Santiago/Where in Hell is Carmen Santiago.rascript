// ~Homebrew~ Where in Hell is Carmen Santiago?
// #ID = 33413

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function ptr(x) => word(x)

function zfill(num, c)
{
	result = format("{0}", num)
	for i in range(0, 10)
	{
		if (length(result) >= c) return result
		result = format("0{0}", result)
	}
	return result
}

function commas(x)
{
	function comma_join(list)
	{
		res = ""
		for i in range(0, length(list)-1)
		{
			if (i == length(list) - 1)
				res = format("{0}", list[i]) + res
			else res = "," + zfill(list[i], 3) + res
		}
		return res
	}

	parts = []
	for i in range(1, 10)
	{
		if (x == 0) return comma_join(parts)
		array_push(parts, x % 1000)
		x = x / 1000
	}
}

// --- MEMORY -------------------------------------------------------------------

// $006B: Game State Pointer [16 bit]
//        +0x007 = Item Needed by Room [36 x 16-bits]
//        +0x056 = Searchable Rooms [36 x 16-bits]
//        +0x0A5 = Room to Find Shade [7 x 16-bits]
//        +0x0BA = Inventory [34 bytes] (just search the table for numbers)
//        +0x108 = Questions Remaining by Shade [7 x 16-bit]
//        
//        Scenario 1 Items:
//        0x01 = Handful of Dirt
//        0x02 = Request
//        0x03 = Prayer
//        0x04 = Ariadne's Thread
//        0x05 = Coin
//        0x06 = Gown
//        0x07 = Rope Belt
//        0x08 = Hood
//        0x09 = Laurel Wreath
//        0x0a = Gall Stone
//        0x0b = Appeal
//        0x0c = Gold Nugget
//        0x0d = Map
//        
//        Scenario 2 Items:
//        0x01 = Apple //c
//        0x02 = Where in Hell (etc) (2)
//        0x03 = The Bilestoad
//        0x04 = Messy-DOS
//        0x05 = GS/OS source code
//        0x06 = Leisure Suit Larry
//        0x07 = Where in Hell (etc) (1)
//        0x08 = Ultima MCLIX
//        0x09 = Unclaimed Interrupt
//        0x0a = Pie Man
//        0x0b = MegaWrite v 0.3B
//        0x0c = Death Sword
//        0x0d = Apple File Exchange
//        0x0e = AppleWorks
//        0x0f = Labyrinth
//        0x10 = ICEbreaker program
function ptr_to_gamestate() => ptr(0x00006B)
function room_needed_item(i) => word_be(ptr_to_gamestate() + 0x007 + (i * 2))
function room_blocked(i) => room_needed_item(i) / room_needed_item(i)
function room_searched(i) => word_be(ptr_to_gamestate() + 0x056 + (i * 2)) == 0xFFFF
function shade_room(i) => word_be(ptr_to_gamestate() + 0x0A5 + (i * 2))
function questions_remaining(i) => word_be(ptr_to_gamestate() + 0x108 + (i * 2))

// $6ABB: Game Mode [MBF32]
//        1 = Classic Inferno
//        2 = Pit of the Programs
//        
//        36 = Main Menu
function game_mode() => mbf32(0x006ABB)

// $6AC2: Current Location [MBF32]
//        0 = Vestibule [the Opportunists]
//        1 = Circle I: Limbo [the Virtuous Pagans]
//        2 = Minos the Judge of the Damned
//        3 = Circle II [the Carnal]
//        4 = Cerberus the three-headed dog
//        5 = Circle III [the Gluttons]
//        6 = Plutus the God of Money
//        7 = Circle VI [the Hoarders & Wasters]
//        8 = Circle V [the Wrathful & Sullen]
//        9 = Phlegyas at the River Styx
//        10 = The Gates of Dis
//        11 = Circle VI [the Heretics]
//        12 = the Minotaur
//        13 = Circle VII, Round 1 [Violent Against Neighbours]
//        14 = the Centaurs
//        15 = Circle VII, Round 2 [Violent Against Themselves]
//        16 = the Harpies
//        17 = Circle VII, Round 3 [Violent Against God, Nature, & Art]
//        18 = Geryon on the Waterfall
//        19 = Circle VIII, Bolgia 1 [Panderers & Seducers]
//        20 = Circle VIII, Bolgia 2 [Flatterers]
//        21 = Circle VIII, Bolgia 3 [Simoniacs]
//        22 = Circle VIII, Bolgia 4 [Fortunetellers & Diviners]
//        23 = Circle VIII, Bolgia 5 [Grafters]
//        24 = Malacoda and the Malebranche
//        25 = Circle VIII, Bolgia 6 [Hypocrites]
//        26 = Circle VIII, Bolgia 7 [Theives]
//        27 = Circle VIII, Bolgia 8 [Evil Counselors]
//        28 = Circle VIII, Bolgia 9 [Sowers of Discord]
//        29 = Circle VIII, Bolgia 10 [Falsifiers]
//        30 = Antaeus & the Giants
//        31 = Circle IX, Round 1 [Treacherous Against Kin]
//        32 = Circle IX, Round 2 [Treacherous Against Country]
//        33 = Circle IX, Round 3 [Treacherous Against Friends and Hosts]
//        34 = Circle IX, Round 4 [Treacherous Against Masters]
//        35 = Salvation to Mt Purgatory
function current_location() => mbf32(0x006AC2)

// $6AC9: Max Turns [MBF32]
//        140 = Classic Mode
//        186 = Pit of the Programs
function max_turns() => mbf32(0x006AC9)

// $6AD0: Turns Remaining [MBF32]
function turns_remaining() => mbf32(0x006AD0)

// $6AEC: Current Location [MBF32] (while on map screen)
function current_location_on_map() => mbf32(0x006AEC)

// $6B01: Last Called Shade [MBF32]
//        updates on a call, succeeded or failed, does not reset to default value
function last_called_shade() => mbf32(0x006B01)

// $6B1D: Current Highlighted Location [MBF32] (only on map screen)
function highlighted_location_on_map() => mbf32(0x006B1D)

// $6B24: Magic Menu Selection [MBF32]
//        1-indexed from the top of whichever active menu
function magic_menu_selection() => mbf32(0x006B24)

// $6B40: Magic Menu Size [MBF32]
function magic_menu_size() => mbf32(0x006B40)

// $BBF0: Name of Loaded Script [ASCII Text]
//        
//        Dossiers:
//        WIHICS.SCEN/DOSSIER#.#
//        0 = Carmen Santiago
//        1.1 - 1.6 = Classic Inferno Dossiers
//        2.1 - 2.6 = Pit of the Programs Dossiers
//        
//        /WHCS/WIHICS.SCEN/SAVED.GAME - Loading Saved Game
//        /WHCS/WIHICS.SCEN/LIST - Show List of Scenarios
//        /WHCS/WIHICS.SCEN/INFO1 - Show Scenario 1 Information
//        /WHCS/WIHICS.SCEN/INFO1 - Show Scenario 1 Information
LOADED_SCRIPT_STR = 0x00BBF0

// --- MAIN DATA -------------------------------------------------------------------

SCENARIOS = {
	1: "Classic Inferno",
	2: "Pit of the Programs",
}

ROOM_NAMES = {
	0: "Vestibule - the Opportunists",
	1: "Circle I: Limbo - the Virtuous Pagans",
	2: "Minos the Judge of the Damned",
	3: "Circle II - the Carnal",
	4: "Cerberus the three-headed dog",
	5: "Circle III - the Gluttons",
	6: "Plutus the God of Money",
	7: "Circle VI - the Hoarders & Wasters",
	8: "Circle V - the Wrathful & Sullen",
	9: "Phlegyas at the River Styx",
	10: "The Gates of Dis",
	11: "Circle VI - the Heretics",
	12: "the Minotaur",
	13: "Circle VII, Round 1 - Violent Against Neighbours",
	14: "the Centaurs",
	15: "Circle VII, Round 2 - Violent Against Themselves",
	16: "the Harpies",
	17: "Circle VII, Round 3 - Violent Against God, Nature, & Art",
	18: "Geryon on the Waterfall",
	19: "Circle VIII, Bolgia 1 - Panderers & Seducers",
	20: "Circle VIII, Bolgia 2 - Flatterers",
	21: "Circle VIII, Bolgia 3 - Simoniacs",
	22: "Circle VIII, Bolgia 4 - Fortunetellers & Diviners",
	23: "Circle VIII, Bolgia 5 - Grafters",
	24: "Malacoda and the Malebranche",
	25: "Circle VIII, Bolgia 6 - Hypocrites",
	26: "Circle VIII, Bolgia 7 - Theives",
	27: "Circle VIII, Bolgia 8 - Evil Counselors",
	28: "Circle VIII, Bolgia 9 - Sowers of Discord",
	29: "Circle VIII, Bolgia 10 - Falsifiers",
	30: "Antaeus & the Giants",
	31: "Circle IX, Round 1 - Treacherous Against Kin",
	32: "Circle IX, Round 2 - Treacherous Against Country",
	33: "Circle IX, Round 3 - Treacherous Against Friends and Hosts",
	34: "Circle IX, Round 4 - Treacherous Against Masters",
	35: "the Path to Mt Purgatory",

	37: "Checking the Map",
	38: "Checking the Map",
	39: "Checking the Map",
}

S2_NPC_ROOMS = [
	26, // Carmen
	13, // Reaver Rabbit
	29, // Victoria Vapor
	 5, // Stinkybear
	15, // Chris Crasher
	 7, // The Ultimate Ninja
	11, // Saint John
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function main_action_menu() => magic_menu_size() == 12

function _item_present(i)
{
	addr = ptr_to_gamestate() + 0x0BA + (i * 2)
	return word_be(addr) / word_be(addr)
}
function item_count() => sum_of(range(0, 16), _item_present)

function game_active() => (
	once(main_action_menu() && (game_mode() == 1 || game_mode() == 2)) &&
	never(game_mode() == 36)
)

function complete_game() => prev(current_location()) == 34 && current_location() == 35

function is_viewing_map() => current_location() >= 37 && current_location() <= 39

// --- RICH PRESENCE -------------------------------------------------------------------

rp_scenario = rich_presence_lookup("Scenario", game_mode(), SCENARIOS, fallback=SCENARIOS[1])
rp_location = rich_presence_lookup("Location", current_location(), ROOM_NAMES, fallback="???")
rp_location_on_map = rich_presence_lookup("Location", current_location_on_map(), ROOM_NAMES, fallback="???")

rp_turns_cur = rich_presence_value("_Number", turns_remaining(), "VALUE")
rp_turns_max = rich_presence_value("_Number", max_turns(), "VALUE")
rp_item_count = rich_presence_value("_Number", item_count(), "VALUE")

rich_presence_conditional_display(game_active() && is_viewing_map(),
	"[{0}] 🗺️ {1} (Checking Map) • ⏳ {2}/{3} turn{4} remaining • 🎒 {5} item{6}",
	rp_scenario, rp_location_on_map,
	rp_turns_cur, rp_turns_max, plural(turns_remaining()),
	rp_item_count, plural(item_count())
)

rich_presence_conditional_display(game_active(),
	"[{0}] 🗺️ {1} • ⏳ {2}/{3} turn{4} remaining • 🎒 {5} item{6}",
	rp_scenario, rp_location,
	rp_turns_cur, rp_turns_max, plural(turns_remaining()),
	rp_item_count, plural(item_count())
)

rich_presence_display(
	"Nel mezzo del cammin di nostra vita"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Hard Is the Way Up and Down Another Man's Stairs",
	description="Read a dossier before your mission to learn about the V.I.L.E. operatives",
	points=1,
	trigger=(
		ascii_string_equals(LOADED_SCRIPT_STR, "WIHICS.SCEN/DOSSIER") ||
		ascii_string_equals(LOADED_SCRIPT_STR, "/WHCS/WIHICS.SCEN/DOSSIER")
	)
)

// Scenario 1:
achievement(
	title="What Do You Gain by Locking Horns with Fate?",
	description="[Classic Inferno] Plead for passage through the Gates of Dis",
	type="progression",
	points=2,
	trigger=(
		game_active() && game_mode() == 1 &&
		current_location() == 10 &&
		prev(room_needed_item(10)) == 3 && room_needed_item(10) == 0
	)
)

achievement(
	title="From Now On We Descend by Stairs like These",
	description="[Classic Inferno] Summon the great beast Geryon to descend into the Malebolge",
	type="progression",
	points=2,
	trigger=(
		game_active() && game_mode() == 1 &&
		current_location() == 17 &&
		prev(room_needed_item(17)) == 7 && room_needed_item(17) == 0
	)
)

achievement(
	title="We Came Out to See Once More the Stars",
	description="[Classic Inferno] Find Carmen Santiago and escape to Mt. Purgatory",
	type="progression",
	points=5,
	trigger=game_active() && game_mode() == 1 && complete_game()
)

achievement(
	title="Then Thou Mayst Hurry Me, as Thou Shalt Wish",
	description="[Classic Inferno] Complete the Classic Inferno scenario with more than 50 turns remaining",
	points=5,
	trigger=game_active() && game_mode() == 1 && turns_remaining() > 50 && trigger_when(complete_game())
)

// Scenario 2:
achievement(
	title="Ask Him Again If More Thou Wish to Know from Him",
	description="[Pit of the Programs] Bribe a shade to allow you to ask questions",
	type="progression",
	points=2,
	trigger=(
		game_active() && game_mode() == 2 &&
		any_of(range(0,6), i => questions_remaining(i) > prev(questions_remaining(i)))
	)
)

achievement(
	title="Along the Brink of the Vermilion Boiling",
	description="[Pit of the Programs] Help the centaurs and cross the Phlegethon",
	type="progression",
	points=2,
	trigger=(
		game_active() && game_mode() == 2 &&
		prev(current_location()) == 13 && current_location() == 14
	)
)

achievement(
	title="Where Thou with Fortitude Must Arm Thyself",
	description="[Pit of the Programs] Find Carmen Santiago and escape to Mt. Purgatory",
	type="progression",
	points=5,
	trigger=game_active() && game_mode() == 2 && complete_game()
)

achievement(
	title="Come Speak to Us, If No One Interdicts It",
	description="[Pit of the Programs] In one session, reach salvation having spoken to all V.I.L.E. operatives",
	points=10,
	trigger=(
		measured(
			tally_of(range(0,6), 7, 
				i => once(
					prev(questions_remaining(i)) == 0 && questions_remaining(i) > 0 &&
					game_mode() == 2 && current_location() == S2_NPC_ROOMS[i]
				)
			),
			when=game_active()
		) &&
		complete_game()
	)
)

achievement(
	title="They unto Vengeance Run as unto Wrath",
	description="[Pit of the Programs] Complete the Pit of the Programs scenario with more than 115 turns remaining",
	points=5,
	trigger=game_active() && game_mode() == 2 && turns_remaining() > 115 && trigger_when(complete_game())
)

achievement(
	title="No Fame of Them the World Permits to Be",
	description="Consign yourself to the fate of the indecisive opportunists",
	points=1,
	trigger=game_active() && prev(current_location()) != 0 && current_location() == 0
)

// --- LEADERBOARDS -------------------------------------------------------------------

// minimum moves to complete
for m in range(1,2)
{
	leaderboard(
		title=format("Most Turns Remaining - {0}", SCENARIOS[m]),
		description=format("Complete {0} with the most turns remaining", SCENARIOS[m]),

		start=game_active() && game_mode() == m && complete_game(),
		cancel=always_false(),
		submit=always_true(),

		value=measured(turns_remaining()),
		format="VALUE",
		lower_is_better=false
	)
}