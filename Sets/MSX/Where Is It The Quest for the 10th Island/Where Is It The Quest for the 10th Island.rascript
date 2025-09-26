// ~Homebrew~ Where Is It: The Quest for the 10th Island
// #ID = 34391

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $000C: In Game [8 bit] (0/1)
function in_game() => byte(addr_offset() + 0x00000C)

// $002C: Current Board [8 bit]
//        
//        --- Story Mode ---
//        0x0a = tenth island
//        0x0b = ending
//        0x0c = fakeout board into final words
//        
//        --- Other Modes ---
//        0x0a = final board
//        0x0b = final words
function current_board() => byte(addr_offset() + 0x00002C)

// $002D: Round [8 bit]
//        anything above 0x0a is challenge round
function round() => byte(addr_offset() + 0x00002D)

// $002E: Perfect Count [8 bit]
function perfect_count() => byte(0x00002E)

// $002F: Frames Per Time Unit [8 bit]
//        Arcade Easy -> 50
//        Arcade Normal -> 45
//        Arcade Hard -> 42
//        Arcade Mix -> 38
function frames_per_time_unit() => byte(addr_offset() + 0x00002F)

// $0035: Challenge Score [8 bit]
function challenge_score() => byte(addr_offset() + 0x000035)

// $0043: Time Elapsed [8 bit]
//        round timer is 73 seconds consistently on Arcade
function time_elapsed() => byte(addr_offset() + 0x000043)

// $0045: Clocks Remaining [8 bit]
function clocks_remaining() => byte(addr_offset() + 0x000045)

// $0049: Score [16 bit]
function score() => word(addr_offset() + 0x000049)

// $006F: Game Mode [8 bit]
//        0 = Arcade Easy (time counts down every 50f)
//        1 = Arcade Normal (time counts down every 45f)
//        2 = Arcade Hard (time counts down every 42f)
//        3 = Arcade Mix
//        4 = Story
function game_mode() => byte(addr_offset() + 0x00006F)

// $0083: Board Layout [300 bytes]
BOARD_LAYOUT = 0x000083
function board_cell(x, y) => byte(BOARD_LAYOUT + y*15 + x)

// --- MAIN DATA -------------------------------------------------------------------

ORDINAL = ["", "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth"]

MODE_ARCADE_EASY = 0
MODE_ARCADE_NORMAL = 1
MODE_ARCADE_HARD = 2
MODE_ARCADE_MIX = 3
MODE_STORY = 4

MODE_NAMES = {
	MODE_ARCADE_EASY: "Arcade Easy",
	MODE_ARCADE_NORMAL: "Arcade Normal",
	MODE_ARCADE_HARD: "Arcade Hard",
	MODE_ARCADE_MIX: "Arcade Mix",
	MODE_STORY: "Story Mode",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function win_the_game() => prev(current_board()) == 10 && current_board() == 11

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(in_game() != 0 && game_mode() == MODE_STORY && current_board() > 0x0a,
	"[Story Mode] Ending · 💯 Score: {0}",
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_conditional_display(in_game() != 0 && game_mode() == MODE_STORY && round() > 20,
	"[Story Mode] 🗺️ Island #{0} · 🚩 Challeng' Stage (Perfect!) · ⏳ {2} · ⏱️ {3} clock{4} remaining · 💯 Score: {5}",
	rich_presence_number(current_board()),
	"",
	rich_presence_number(73-time_elapsed()),
	rich_presence_number(clocks_remaining()), plural(clocks_remaining()),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_conditional_display(in_game() != 0 && game_mode() == MODE_STORY && round() > 10,
	"[Story Mode] 🗺️ Island #{0} · 🚩 Challeng' Stage ({1}/10) · ⏳ {2} · ⏱️ {3} clock{4} remaining · 💯 Score: {5}",
	rich_presence_number(current_board()),
	rich_presence_number(round()-10),
	rich_presence_number(73-time_elapsed()),
	rich_presence_number(clocks_remaining()), plural(clocks_remaining()),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_conditional_display(in_game() != 0 && game_mode() == MODE_STORY,
	"[Story Mode] 🗺️ Island #{0} · 🚩 Round {1}/10 · ⏳ {2} · ⏱️ {3} clock{4} remaining · 💯 Score: {5}",
	rich_presence_number(current_board()),
	rich_presence_number(round()),
	rich_presence_number(73-time_elapsed()),
	rich_presence_number(clocks_remaining()), plural(clocks_remaining()),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_conditional_display(in_game() != 0 && current_board() > 0x0a,
	"[{0}] Ending · 💯 Score: {0}",
	rich_presence_lookup("Mode", game_mode(), MODE_NAMES, fallback=MODE_NAMES[MODE_ARCADE_EASY]),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_conditional_display(in_game() != 0 && round() > 20,
	"[{0}] Board #{1} · 🚩 Challeng' Stage (Perfect!) · ⏳ {3} · ⏱️ {4} clock{5} remaining · 💯 Score: {6}",
	rich_presence_lookup("Mode", game_mode(), MODE_NAMES, fallback=MODE_NAMES[MODE_ARCADE_EASY]),
	rich_presence_number(current_board()),
	"",
	rich_presence_number(73-time_elapsed()),
	rich_presence_number(clocks_remaining()), plural(clocks_remaining()),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_conditional_display(in_game() != 0 && round() > 10,
	"[{0}] Board #{1} · 🚩 Challeng' Stage ({2}/10) · ⏳ {3} · ⏱️ {4} clock{5} remaining · 💯 Score: {6}",
	rich_presence_lookup("Mode", game_mode(), MODE_NAMES, fallback=MODE_NAMES[MODE_ARCADE_EASY]),
	rich_presence_number(current_board()),
	rich_presence_number(round()-10),
	rich_presence_number(73-time_elapsed()),
	rich_presence_number(clocks_remaining()), plural(clocks_remaining()),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_conditional_display(in_game() != 0,
	"[{0}] Board #{1} · 🚩 Round {2}/10 · ⏳ {3} · ⏱️ {4} clock{5} remaining · 💯 Score: {6}",
	rich_presence_lookup("Mode", game_mode(), MODE_NAMES, fallback=MODE_NAMES[MODE_ARCADE_EASY]),
	rich_presence_number(current_board()),
	rich_presence_number(round()),
	rich_presence_number(73-time_elapsed()),
	rich_presence_number(clocks_remaining()), plural(clocks_remaining()),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_display(
	"[Title Screen] Where Is It: The Quest for the 10th Island | © Eric Mendel 2021"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

PROGRESSION_ACHIEVEMENTS = [
	{ "island":  1, "points":  2, "title": "Tide and True Patterns", },
	{ "island":  2, "points":  2, "title": "Hide and Sequence", },
	{ "island":  3, "points":  2, "title": "Isles in the Details", },
	{ "island":  4, "points":  2, "title": "The Case of the Coral Code", },
	{ "island":  5, "points":  2, "title": "Hue Done It?", },
	{ "island":  6, "points":  2, "title": "Stranded in the Sequence", },
	{ "island":  7, "points":  3, "title": "The Usual Suspects", },
	{ "island":  8, "points":  3, "title": "Think Outside the Box", },
	{ "island":  9, "points":  3, "title": "The Grid at World's End", },
	{ "island": 10, "points": 25, "title": "Blinded by the White", },
]

for p in PROGRESSION_ACHIEVEMENTS
{
	achievement(
		title=p["title"],
		description=format("Complete the {0} island in Story mode", ORDINAL[p["island"]]),
		type=if_else(p["island"] == 10, "win_condition", "progression"),
		points=p["points"],
		trigger=in_game() != 0 && game_mode() == MODE_STORY && prev(current_board()) == p["island"] && current_board() == p["island"]+1
	)
}

achievement(
	title="FindIt Friendly",
	description="Complete round 10 of Arcade Easy mode",
	points=3,
	trigger=in_game() != 0 && game_mode() == MODE_ARCADE_EASY && win_the_game()
)

achievement(
	title="FindIt Fairly",
	description="Complete round 10 of Arcade Normal mode",
	points=5,
	trigger=in_game() != 0 && game_mode() == MODE_ARCADE_NORMAL && win_the_game()
)

achievement(
	title="FindIt Frustratingly",
	description="Complete round 10 of Arcade Hard mode",
	points=10,
	trigger=in_game() != 0 && game_mode() == MODE_ARCADE_HARD && win_the_game()
)

achievement(
	title="Mix It Up",
	description="Complete round 10 of Arcade Mix mode",
	points=10,
	trigger=in_game() != 0 && game_mode() == MODE_ARCADE_MIX && win_the_game()
)

achievement(
	title="No Challeng' Too Tough",
	description="Earn a perfect score on the Challeng' Stage after any round of Arcade Mix mode",
	points=5,
	trigger=in_game() != 0 && game_mode() == MODE_ARCADE_MIX && challenge_score() == 10 && prev(round()) == 20 && round() == 21
)

// --- LEADERBOARDS -------------------------------------------------------------------

for mode in range(0,4)
{
	leaderboard(
		title=format("High Score {0}", MODE_NAMES[mode]),
		description=format("Highest score in {0}", MODE_NAMES[mode]),
	
		start=(in_game() != 0 && game_mode() == mode && (
			// end of game
			(win_the_game()) ||
			// game over
			(prev(clocks_remaining()) == 1 && clocks_remaining() == 0)
		)),
		cancel=always_false(),
		submit=always_true(),
	
		value=measured(score() + 1000*perfect_count()),
		format="SCORE",
		lower_is_better=false
	)
}