// Monkey Academy
// #ID = 34485

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $2000: Game State [8 bit]
//        0x00-0x06 = Title Screen
//        0x07 = Demo Playing
//        0x08 = Level Select
//        0x09 = Loading/Unloading Stage
//        0x0a = Setting Up
//        0x0b = Waiting for Player Ready
//        0x0c = Playing
//        0x0d = Death
//        0x0f = Game Over
//        0x11 = Death
//        0x12 = Play Select
function game_state() => byte(addr_offset() + 0x002000)

// $2002: Game Flags [8 bit]
//        bit5 | 2-Player Mode
//        bit7 | is P2's turn?
function is_2p_mode() => bit5(addr_offset() + 0x002002)
function current_player() => bit7(addr_offset() + 0x002002)

// $2040: Hi Score [24 bit BCD]
// $2043: P1 Score [24 bit BCD]
// $2046: P2 Score [24 bit BCD]
function hi_score() => bcd(tbyte(addr_offset() + 0x002040))
function p1_score() => bcd(tbyte(addr_offset() + 0x002043))
function p2_score() => bcd(tbyte(addr_offset() + 0x002046))
function current_player_score() => bcd(tbyte(addr_offset() + 0x002043 + 3*current_player()))

// $2050: Lives [8 bit]
function lives() => byte(addr_offset() + 0x002050)

// $2051: Current Round [8 bit]
// $2054: Current Sub-Round [8 bit]
function current_round() => byte(addr_offset() + 0x002051)
function current_sub_round() => byte(addr_offset() + 0x002054)

// $2055: Time - Seconds Remaining [8 bit BCD]
// $2056: Time - Minutes Remaining [8 bit BCD]
function time_seconds_remaining() => bcd(addr_offset() + byte(0x002055))
function time_minutes_remaining() => bcd(addr_offset() + byte(0x002056))

// $2057: Strikes [8 bit]
function strikes() => byte(addr_offset() + 0x002057)

// $2058: Equation Length [8 bit]
function equation_length() => byte(addr_offset() + 0x002058)

// $2114: Crab State [8 bit]
//        0x00 = not spawned
//        0x01 = landing?
//        0x02 = walking
//        0x06 = falling
//        0x07 = spawning
//        0x09 = hit with fruit
function crab_state() => byte(addr_offset() + 0x002114)

// $2153: Current Level [8 bit] (0-4)
//        0 = Addition
//        1 = Subtraction
//        2 = Multiplication
//        3 = Division
//        4 = Algebra
function current_level(p) => byte(addr_offset() + 0x002153 + p)

// $21B5: Current Equation [10 bytes]
//        0x00-0x09 = digit
//        0x0a = plus sign
//        0x0b = minus/negative sign
//        0x0c = mult sign
//        0x0d = division sign
//        0x0e = equal sign
//        0x0f = colon?
//        0x10 = left paren
//        0x11 = right paren
//        0x12 = question mark
function current_equation(i) => byte(addr_offset() + 0x0021B5 + i + 12*current_player())

// $21CD: Correct Answer [8 bit]
function correct_answer() => byte(addr_offset() + 0x0021CD)

// --- MAIN DATA -------------------------------------------------------------------

TYPE_ADD = 0
TYPE_SUB = 1
TYPE_MUL = 2
TYPE_DIV = 3
TYPE_ALG = 4

PROBLEM_TYPES = {
	TYPE_ADD: "(Lv1) Addition",
	TYPE_SUB: "(Lv2) Subtraction",
	TYPE_MUL: "(Lv3) Multiplication",
	TYPE_DIV: "(Lv4) Division",
	TYPE_ALG: "(Lv5) Algebraic",
}

ALL_MODES = range(0, 4)

EQUATION_GLYPHS = {
	0x00: "0",
	0x01: "1",
	0x02: "2",
	0x03: "3",
	0x04: "4",
	0x05: "5",
	0x06: "6",
	0x07: "7",
	0x08: "8",
	0x09: "9",
	0x0a: "+",
	0x0b: "-",
	0x0c: "×",
	0x0d: "÷",
	0x0e: "=",
	0x10: "(",
	0x11: ")",
	0x12: "?",
}

PLAYER_1 = 0
PLAYER_2 = 1
ALL_PLAYERS = [PLAYER_1, PLAYER_2]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => game_state() > 0x08 && game_state() < 0x12

function on_title_screen() => game_state() < 0x08

function round_start() => prev(game_state()) == 0x08 && game_state() == 0x09 && current_sub_round() == 0

function clear_game_mode(player, mode, count) => (
	// repeat the correct number of times
	tally(count, (
		// only count if we are in-game as player P
		in_game() && current_player() == player && prev(current_player()) == current_player() &&
		// check that the game mode is correct
		current_level(player) == mode && 
		// counting the number of times the round increments
		current_round() > prev(current_round()) && 
		// reset if we pick any other mode
		never(current_level(player) != mode) &&
		// reset if we ever return to the title screen
		never(on_title_screen())
	))
)

// --- RICH PRESENCE -------------------------------------------------------------------

GAME_INFO = "Monkey Academy | © Konami 1984"

function rp_eqchar(x) => rich_presence_lookup("EqChar", current_equation(x), EQUATION_GLYPHS, fallback="")

rich_presence_conditional_display(game_state() <= 0x07,
	"[Title Screen] " + GAME_INFO
)

rich_presence_conditional_display(game_state() == 0x08,
	"[Level Select] " + GAME_INFO
)

rich_presence_conditional_display(game_state() == 0x12,
	"[Player Select] " + GAME_INFO
)

// how long is the current equation?
for len in range(5, 10)
{
	rich_presence_conditional_display(equation_length() == len,
		"🎓 {0} Problems · 🧑‍🏫 Round {1}{2}{3} · 🐒 {4} {5} · 💯 {6} Score: {7} · 🧮 Current Equation: {8}{9}{10}{11}{12}{13}{14}{15}{16}{17}",
		rich_presence_lookup("ProblemType", current_level(current_player()), PROBLEM_TYPES, fallback="(?) Math"),
		rich_presence_number(current_round()),
		rich_presence_lookup("SubRound", current_sub_round(), {1: "b", 2: "c"}, fallback="a"),
		rich_presence_lookup("Strikes", strikes(), {1: " ❌", 2: " ❌❌", 3: " ❌❌❌"}, fallback=""),
		rich_presence_number(lives()),
		rich_presence_lookup("LifeWord", lives(), {1: "Life"}, fallback="Lives"),
		rich_presence_lookup("PlayerName", current_player(), {1: "P2"}, fallback="P1"),
		rich_presence_value("_S", current_player_score(), "SCORE"),
		if_else(len > 0, rp_eqchar(0), ""),
		if_else(len > 1, rp_eqchar(1), ""),
		if_else(len > 2, rp_eqchar(2), ""),
		if_else(len > 3, rp_eqchar(3), ""),
		if_else(len > 4, rp_eqchar(4), ""),
		if_else(len > 5, rp_eqchar(5), ""),
		if_else(len > 6, rp_eqchar(6), ""),
		if_else(len > 7, rp_eqchar(7), ""),
		if_else(len > 8, rp_eqchar(8), ""),
		if_else(len > 9, rp_eqchar(9), "")
	)
}

rich_presence_display(GAME_INFO)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="___Addition1",
	description="Complete a stage on Level 1: Addition Problems",
	type="progression",
	points=2,
	trigger=(
		in_game() && current_level(current_player()) == TYPE_ADD && 
		current_round() > prev(current_round()) && 
		current_player() == prev(current_player())
	)
)

achievement(
	title="___Addition5",
	description="Complete five stages in a row on Level 1: Addition Problems",
	type="progression",
	points=5,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_ADD, 5)))
)

achievement(
	title="___Addition10",
	description="Complete ten stages in a row on Level 1: Addition Problems",
	type="progression",
	points=10,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_ADD, 10)))
)

achievement(
	title="___Subtraction1",
	description="Complete a stage on Level 2: Subtraction Problems",
	type="progression",
	points=2,
	trigger=(
		in_game() && current_level(current_player()) == TYPE_SUB && 
		current_round() > prev(current_round()) && 
		current_player() == prev(current_player())
	)
)

achievement(
	title="___Subtraction5",
	description="Complete five stages in a row on Level 2: Subtraction Problems",
	type="progression",
	points=5,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_SUB, 5)))
)

achievement(
	title="___Subtraction10",
	description="Complete ten stages in a row on Level 2: Subtraction Problems",
	type="progression",
	points=10,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_SUB, 10)))
)

achievement(
	title="___Multiplication1",
	description="Complete a stage on Level 3: Multiplication Problems",
	type="progression",
	points=2,
	trigger=(
		in_game() && current_level(current_player()) == TYPE_MUL && 
		current_round() > prev(current_round()) && 
		current_player() == prev(current_player())
	)
)

achievement(
	title="___Multiplication5",
	description="Complete five stages in a row on Level 3: Multiplication Problems",
	type="progression",
	points=5,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_MUL, 5)))
)

achievement(
	title="___Multiplication10",
	description="Complete ten stages in a row on Level 3: Multiplication Problems",
	type="progression",
	points=10,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_MUL, 10)))
)

achievement(
	title="___Division1",
	description="Complete a stage on Level 4: Division Problems",
	type="progression",
	points=2,
	trigger=(
		in_game() && current_level(current_player()) == TYPE_DIV && 
		current_round() > prev(current_round()) && 
		current_player() == prev(current_player())
	)
)

achievement(
	title="___Division5",
	description="Complete five stages in a row on Level 4: Division Problems",
	type="progression",
	points=5,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_DIV, 5)))
)

achievement(
	title="___Division10",
	description="Complete ten stages in a row on Level 4: Division Problems",
	type="progression",
	points=10,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_DIV, 10)))
)

achievement(
	title="___Algebra1",
	description="Complete a stage on Level 5: Algebra Problems",
	type="progression",
	points=2,
	trigger=(
		in_game() && current_level(current_player()) == TYPE_ALG && 
		current_round() > prev(current_round()) && 
		current_player() == prev(current_player())
	)
)

achievement(
	title="___Algebra5",
	description="Complete five stages in a row on Level 5: Algebra Problems",
	type="progression",
	points=5,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_ALG, 5)))
)

achievement(
	title="___Algebra10",
	description="Complete ten stages in a row on Level 5: Algebra Problems",
	type="progression",
	points=10,
	trigger=any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, TYPE_ALG, 10)))
)

achievement(
	title="__Score20000",
	description="Score 20,000 points and earn an extra life",
	points=5,
	trigger=in_game() && (
		(current_player() == PLAYER_1 && prev(p1_score()) < 20000 && p1_score() >= 20000) ||
		(current_player() == PLAYER_2 && prev(p2_score()) < 20000 && p2_score() >= 20000)
	)
)

achievement(
	title="__UnderMinute",
	description="Clear a stage (three sub-stages) with 4 minutes or more left on the clock",
	points=10,
	trigger=(
		always_false() &&
		time_minutes_remaining() >= 4
	)
)

achievement(
	title="__Kill20Crabs",
	description="Kill 20 crabs in a single stage without dying",
	points=10,
	trigger=(
		// count the number of times the crab was killed
		measured(tally(20, game_state() == 0x0c && prev(crab_state()) != 0x09 && crab_state() == 0x09)) &&
		// reset the counter if the lives goes down
		never(lives() < prev(lives())) &&
		// reset the counter if we change stage
		never(current_round() != prev(current_round())) &&
		// reset if we are back at the title screen for any reason
		never(on_title_screen())
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------
