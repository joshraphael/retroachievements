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

// $2016: Stage State [8 bit]
//        0x0c = Playing
//        0x0d = Complete
//        0x0e = Shade Falling
function stage_state() => byte(addr_offset() + 0x002016)

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
function time_seconds() => bcd(byte(addr_offset() + 0x002055))
function time_minutes() => bcd(byte(addr_offset() + 0x002056))
function time() => time_minutes() * 60 + time_seconds()

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
//        2 = Division
//        3 = Multiplication
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
TYPE_DIV = 2
TYPE_MUL = 3
TYPE_ALG = 4

PROBLEM_TYPES = {
	TYPE_ADD: "(Lv1) Addition",
	TYPE_SUB: "(Lv2) Subtraction",
	TYPE_DIV: "(Lv3) Division",
	TYPE_MUL: "(Lv4) Multiplication",
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

function complete_one_stage(mode) => (
	in_game() && current_level(current_player()) == mode && 
	current_round() > prev(current_round()) && 
	current_player() == prev(current_player())
)

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
		never(current_level(player) != mode)
	))
)

function complete_multiple(mode, count) => (
	// check players separately; no funny business here!
	any_of(ALL_PLAYERS, p => measured(clear_game_mode(p, mode, count))) &&
	// reset if we ever return to the title screen
	never(on_title_screen())
)

function time_to_secs(m, s) => m * 60 + s

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
	title="Addition Novice",
	description="Complete a stage on Level 1: Addition Problems",
	type="progression",
	points=2,
	trigger=complete_one_stage(TYPE_ADD)
)

achievement(
	title="The Sum of Its Parts",
	description="Complete five stages in a row on Level 1: Addition Problems",
	type="progression",
	points=5,
	trigger=complete_multiple(TYPE_ADD, 5)
)

achievement(
	title="Fun in the Sum",
	description="Complete ten stages in a row on Level 1: Addition Problems",
	type="progression",
	points=10,
	trigger=complete_multiple(TYPE_ADD, 10)
)

achievement(
	title="Subtraction Novice",
	description="Complete a stage on Level 2: Subtraction Problems",
	type="progression",
	points=2,
	trigger=complete_one_stage(TYPE_SUB)
)

achievement(
	title="What Difference Does It Make?",
	description="Complete five stages in a row on Level 2: Subtraction Problems",
	type="progression",
	points=5,
	trigger=complete_multiple(TYPE_SUB, 5)
)

achievement(
	title="Difference Doyen",
	description="Complete ten stages in a row on Level 2: Subtraction Problems",
	type="progression",
	points=10,
	trigger=complete_multiple(TYPE_SUB, 10)
)

achievement(
	title="Division Novice",
	description="Complete a stage on Level 3: Division Problems",
	type="progression",
	points=2,
	trigger=complete_one_stage(TYPE_DIV)
)

achievement(
	title="Divide and Conquer",
	description="Complete five stages in a row on Level 3: Division Problems",
	type="progression",
	points=5,
	trigger=complete_multiple(TYPE_DIV, 5)
)

achievement(
	title="Quotient Qualifications",
	description="Complete ten stages in a row on Level 3: Division Problems",
	type="progression",
	points=10,
	trigger=complete_multiple(TYPE_DIV, 10)
)

achievement(
	title="Multiplication Novice",
	description="Complete a stage on Level 4: Multiplication Problems",
	type="progression",
	points=2,
	trigger=complete_one_stage(TYPE_MUL)
)

achievement(
	title="The Times They Are A-Changin'",
	description="Complete five stages in a row on Level 4: Multiplication Problems",
	type="progression",
	points=5,
	trigger=complete_multiple(TYPE_MUL, 5)
)

achievement(
	title="Product Proficiency",
	description="Complete ten stages in a row on Level 4: Multiplication Problems",
	type="progression",
	points=10,
	trigger=complete_multiple(TYPE_MUL, 10)
)

achievement(
	title="Algebra Novice",
	description="Complete a stage on Level 5: Algebra Problems",
	type="progression",
	points=2,
	trigger=complete_one_stage(TYPE_ALG)
)

achievement(
	title="Like a Monkey Doing a Math Problem",
	description="Complete five stages in a row on Level 5: Algebra Problems",
	type="progression",
	points=5,
	trigger=complete_multiple(TYPE_ALG, 5)
)

achievement(
	title="Arithmetic Adept",
	description="Complete ten stages in a row on Level 5: Algebra Problems",
	type="progression",
	points=10,
	trigger=complete_multiple(TYPE_ALG, 10)
)

achievement(
	title="A Barrel of Monkeys",
	description="Score 20,000 points and earn an extra life",
	points=5,
	trigger=in_game() && (
		(current_player() == PLAYER_1 && prev(p1_score()) < 20000 && p1_score() >= 20000) ||
		(current_player() == PLAYER_2 && prev(p2_score()) < 20000 && p2_score() >= 20000)
	)
)

achievement(
	// title="Simian Speed",
	// title="2 Plus 2 Furious",
	// title="Two Plus Two is Four Minus One That's Three, Quick Maths",
	// title="Quick Maths",
	title="2 Plus 2 Furious: Simian Drift",
	description="Clear a stage (three sub-stages) with 4:00 or more left on the clock",
	points=10,
	trigger=(
		in_game() && time() >= time_to_secs(4, 00) &&
		trigger_when(game_state() == 0x0c && current_sub_round() == 2 && prev(stage_state()) != 0x0d && stage_state() == 0x0d)
	)
)

achievement(
	title="Kabourophobia",
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

FINAL_EXAM_STAGES = 3
achievement(
	title="The Final Exam",
	description="Complete three stages on every level without any strikes and without running out of lives",
	points=25,
	trigger=(
		any_of(ALL_PLAYERS, p => (
			// clear one stage on each mode
			measured(tally_of(ALL_MODES, 5 * FINAL_EXAM_STAGES, mode => tally(FINAL_EXAM_STAGES, complete_one_stage(mode) && current_player() == p))) &&
			// if the strike count goes up for this player, reset
			never(current_player() == prev(current_player()) && strikes() > prev(strikes()))
		)) &&
		never(on_title_screen())
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------
