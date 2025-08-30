// ~Homebrew~ S.o.L.o.
// #ID = 33895

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function is_set(acc) => acc > prev(acc)
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

function rich_presence_condition_table(lookupname, list)
{
	dict = {}
	expr = max_of(array_map(range(1, length(list)), i => measured(length(list)-i, when=list[i-1][0])))
	for i in range(1, length(list)) dict[length(list)-i] = list[i-1][1]
	return rich_presence_lookup(lookupname, expr, dict, "")
}

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $2028: Game Progress [8 bit]
//        0 = initial value
//        1 = password entered, teleporter to Organic unlocked
//        2 = collected fuel in Organic 5
//        3 = selected to go to Cold Zone
//        4 = selected to go to Drainage
//        5 = Cold Zone, recovered gyroscope
//        6 = Drainage, recovered gyroscope
//        7 = entering the Mine
//        8 = return to spaceship, entering Spacecraft
//        10 = escape the Spacecraft
//        11 = self destruct sequence
function progress() => byte(addr_offset() + 0x002028)

// $202A: Playing [8 bit]
//        0 = loading, 1 = playing
function playing() => byte(addr_offset() + 0x00202A)

// $202B: Slot Item [8 bit]
//        0x00 = Nothing
//        0x01 = Laser Gun
//        0x01 = Laser Gun (waiting to fire)
//        0x03 = Hover
//        0x04 = Key / Heat
//        0x05 = Broken / Jumping
function slot() => byte(addr_offset() + 0x00202B)

// $2039: Current Player Color [8 bit]
//        0x0a = Yellow
//        0x06 = Red
function player_color() => byte(addr_offset() + 0x002039)

// $205B: Lives [8 bit]
//        0 = out of game
function lives() => byte(addr_offset() + 0x00205B)

// $2060: Room ID [8 bit]
//        0x01 = Home
//        0x02 = Hanger 1
//        0x03 = Hanger 2
//        0x04 = Outside 1 (spaceship)
//        0x05 = Outside 2
//        0x06 = Outside 3 (teleporter)
//        0x09 = The Mine 1
//        0x0a = Spacecraft 5
//        0x0f = Hanger 3
//        0x10 = Hanger 4
//        0x11 = Hanger 5
//        0x15 = The Mine 2
//        0x16 = Spacecraft 4
//        0x19 = Organic 1
//        0x1a = Organic 2
//        0x1b = Organic 3
//        0x1c = Drainage 5
//        0x1d = Drainage 4
//        0x1e = Drainage 3
//        0x1f = Drainage 2
//        0x20 = Drainage 1
//        0x21 = The Mine 3
//        0x22 = Spacecraft 3
//        0x26 = Organic 5
//        0x27 = Organic 4
//        0x29 = Cold Zone 3
//        0x2a = Cold Zone 2
//        0x2b = Cold Zone 1
//        0x2d = The Mine 4
//        0x2e = Spacecraft 2
//        0x35 = Cold Zone 4
//        0x36 = Cold Zone 5
//        0x39 = The Mine 5
//        0x3a = Spacecraft 1
function room() => byte(addr_offset() + 0x002060)

// --- MAIN DATA -------------------------------------------------------------------

ZONE_NAME = {
	0x01: "Home",
	0x02: "Hangar",
	0x03: "Hangar",
	0x04: "Outside",
	0x05: "Outside",
	0x06: "Outside",
	0x09: "The Mine",
	0x0a: "Spacecraft",
	0x0f: "Hangar",
	0x10: "Hangar",
	0x11: "Hangar",
	0x15: "The Mine",
	0x16: "Spacecraft",
	0x19: "Organic Zone",
	0x1a: "Organic Zone",
	0x1b: "Organic Zone",
	0x1c: "Drainage Zone",
	0x1d: "Drainage Zone",
	0x1e: "Drainage Zone",
	0x1f: "Drainage Zone",
	0x20: "Drainage Zone",
	0x21: "The Mine",
	0x22: "Spacecraft",
	0x26: "Organic Zone",
	0x27: "Organic Zone",
	0x29: "Cold Zone",
	0x2a: "Cold Zone",
	0x2b: "Cold Zone",
	0x2d: "The Mine",
	0x2e: "Spacecraft",
	0x35: "Cold Zone",
	0x36: "Cold Zone",
	0x39: "The Mine",
	0x3a: "Spacecraft",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => lives() > 0 && lives() <= 4

function room_change(a, b) => prev(room()) == a && playing() == 0x00 && room() == b
function room_load(a) => room() == a && prev(playing()) == 0x00 && playing() == 0x01

function deathless_zone(room1, room5, exit) => (
	once(in_game() && room_load(room1)) &&
	never(lives() < prev(lives())) &&
	trigger_when(room_change(room5, exit))
)

function start_game() => in_game() && room() == 0x01 && prev(playing()) == 0 && playing() == 1
function complete_game() => room() == 0x3a && prev(progress()) == 10 && progress() == 11

// --- RICH PRESENCE -------------------------------------------------------------------

rp_slot = rich_presence_condition_table("Slot", [
	[slot() == 0x00, "❌ None"],
	[slot() == 0x01, "🔫 Gun"],
	[slot() == 0x02, "🔫 Gun"],
	[slot() == 0x03, "🪽 Hover"],
	[slot() == 0x04 && player_color() == 0x0a, "🔑 Key"],
	[slot() == 0x04 && player_color() == 0x06, "🔥 Heat"],
	[slot() == 0x05, "⚠️ [ERROR]"],
])

rich_presence_conditional_display(in_game(),
	"S.o.L.o. 🤖x{0} | 🗺️ {1} | Slot: {2}",
	rich_presence_number(lives()),
	rich_presence_lookup("Area", room(), ZONE_NAME, fallback="Outside"),
	rp_slot
)

rich_presence_display(
	"S.o.L.o. 🤖 | © Angel Colaso 2021"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Home Is Where the Hint Is",
	description="Enter the password outside to begin the takeoff procedures",
	type="progression",
	points=5,
	trigger=in_game() && room() == 0x04 && prev(progress()) == 0 && progress() == 1
)

achievement(
	title="Hangar Defragmented",
	description="Complete the Hangar without losing any CPUs",
	type="missable",
	points=5,
	trigger=deathless_zone(0x02, 0x11, 0x05)
)

achievement(
	title="Lithium-Powered Lifeform",
	description="Collect the fuel in the Organic Zone",
	type="progression",
	points=5,
	trigger=in_game() && room() == 0x26 && prev(progress()) == 1 && progress() == 2
)

achievement(
	title="Organic Zone Defragmented",
	description="Complete the Organic Zone without losing any CPUs",
	type="missable",
	points=10,
	trigger=deathless_zone(0x19, 0x26, 0x06)
)

achievement(
	title="An Icy Reception",
	description="Collect the gyroscope in the Cold Zone",
	type="progression",
	points=10,
	trigger=in_game() && room() == 0x36 && prev(progress()) == 3 && progress() == 5
)

achievement(
	title="Cold Zone Defragmented",
	description="Complete the Cold Zone without losing any CPUs",
	type="missable",
	points=10,
	trigger=deathless_zone(0x2b, 0x36, 0x06)
)

achievement(
	title="Live Wires and Water Don't Mix",
	description="Collect the gyroscope in the Drainage Zone",
	type="progression",
	points=10,
	trigger=in_game() && room() == 0x1c && prev(progress()) == 4 && progress() == 6
)

achievement(
	title="Drainage Zone Defragmented",
	description="Complete the Drainage Zone without losing any CPUs",
	type="missable",
	points=10,
	trigger=deathless_zone(0x20, 0x1c, 0x06)
)

achievement(
	title="Mind in Mine",
	description="Retrieve I.S.A.C's psyche from the bottom of the Mines",
	type="progression",
	points=10,
	trigger=in_game() && progress() == 7 && room_change(0x39, 0x06)
)

achievement(
	title="Mine Defragmented",
	description="Complete the Mines without losing any CPUs",
	type="missable",
	points=25,
	trigger=deathless_zone(0x09, 0x39, 0x06)
)

achievement(
	title="Asimov's Ambush",
	description="Meet I.S.A.C at the top of the spacecraft",
	type="progression",
	points=10,
	trigger=in_game() && progress() == 8 && room_change(0x16, 0x0a)
)

achievement(
	title="Spacecraft Defragmented",
	description="Climb to the top of the Spacecraft without losing any CPUs",
	type="missable",
	points=10,
	trigger=deathless_zone(0x3a, 0x16, 0x0a)
)

achievement(
	title="For Saint Camillus' Relic",
	description="Survive I.S.A.C's ambush at the top of the Spacecraft",
	type="progression",
	points=5,
	trigger=in_game() && room() == 0x0a && prev(progress()) == 8 && progress() == 10
)

achievement(
	title="Slot One, Level One",
	description="Escape the Spacecraft and uphold the Three Laws",
	type="progression",
	points=25,
	trigger=complete_game()
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Minimum CPUs",
	description="Complete the entire game with the minimum number of CPUs lost",

	start=start_game(),
	cancel=!in_game(),
	submit=complete_game(),

	value=measured(tally(0, lives() < prev(lives()))),
	format="VALUE",
	lower_is_better=true
)

leaderboard(
	title="Fastest Shutdown",
	description="Complete the entire game in the fastest time",

	start=start_game(),
	cancel=!in_game(),
	submit=complete_game(),

	value=measured(tally(0, playing() == 1)),
	format="FRAMES",
	lower_is_better=true
)