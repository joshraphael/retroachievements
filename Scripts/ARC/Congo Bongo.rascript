// Congo Bongo | Tip Top
// #ID = 15762

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function ptr(x) => dword(x)

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

// $0005: Game Mode [8 bit]
//        0x00 = startup
//        0x01 = demo
//        0x02 = press start
//        0x03 = gameplay
function game_mode() => byte(0x000005)

// $0007: Players [8 bit]
//        0 = 1 player
//        1 = 2 players
function players_setting() => byte(0x000007)

// $000a: Player State [8 bit]
//        0x03 = stage loading
//        0x04 = alive/playing
//        0x05 = death
//        0x06 = death animation ending
//        0x0c = stage complete
function player_state() => byte(0x00000a)

// $0012: Credits [8 bit]
function credits() => byte(0x000012)

// $0013: Points Per Extra Life [8 bit] (DIP)
//        1 = 10k
//        2 = 20k
//        3 = 30k
//        4 = 40k
function points_per_extra_life_setting() => byte(0x000013)

// $0014: Lives Per Credit [8 bit] (DIP)
//        6 = Free Play
function lives_per_credit() => byte(0x000014)

function _score(addr) => (
	high4(addr + 2) * 100000 +
	low4 (addr + 2) * 10000 +
	high4(addr + 1) * 1000 +
	low4 (addr + 1) * 100 +
	high4(addr + 0) * 10 +
	low4 (addr + 0)
)

// $00B7: Score P1 [24 bit BCD]
// $00BA: Score P2 [24 bit BCD]
// $00BD: High Score [24 bit BCD]
function score_p1() => _score(0x0000B7)
function score_p2() => _score(0x0000BA)
function high_score() => _score(0x0000BD)

// $0200: Player 1 Lives [8 bit]
// $0210: Player 2 Lives [8 bit]
function p1_lives() => byte(0x000200)
function p2_lives() => byte(0x000210)

// $0220: Current Player Lives [8 bit]
function current_player_lives() => byte(0x000220)

// $0222: Current Player Loop [8 bit]
function current_player_loop() => byte(0x000222)

// $0223: Current Player Stage [8 bit]
//        1 = Steep Peak
//        2 = Snake Lake
//        3 = Rhino Ridge
//        4 = Lazy Lagoon
function current_player_stage() => byte(0x000223)

// $0304: Stage Bonus [8 bit BCD]
function stage_bonus_hundreds() => bcd(byte(0x000304))

// $0306: Bonus Countdown Timer [8 bit]
//        resets to 72 frames after 0, decrements 0x0304
function bonus_countdown_timer() => byte(0x000306)

// --- MAIN DATA -------------------------------------------------------------------

MODE_BOOTING = 0x00
MODE_DEMO = 0x01
MODE_PRESS_START = 0x02
MODE_GAMEPLAY = 0x03

STATE_LOADSTAGE = 0x03
STATE_PLAYING = 0x04
STATE_DEAD = 0x05
STATE_WINSTAGE = 0x0c

BONUS_TARGETS = [
	{ "stage": 1, "bonus": 3900, "points":  5, "title": "Watch For Rolling Coconuts", },
	{ "stage": 2, "bonus": 4200, "points":  5, "title": "The Log Runner", },
	{ "stage": 3, "bonus": 4300, "points":  5, "title": "Stampede!", },
	{ "stage": 4, "bonus": 3900, "points": 10, "title": "No Time to Relax", },
]

SCORE_CHALLENGES = [
	{ "score": 19830, "points": 10, "title": "Finding My Fortune", },
	{ "score": 50000, "points": 25, "title": "The Riches of the Congo", },
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function num_players() => players_setting() + 1

function stage_bonus() => stage_bonus_hundreds() * 100

function points_per_extra_life() => points_per_extra_life_setting() * 10000

function correct_settings() => num_players() == 1 && lives_per_credit() == 3

function died() => player_state() == STATE_DEAD

function begin_stage(x) => (
	game_mode() == MODE_GAMEPLAY &&
	current_player_stage() == x &&
	prev(player_state()) == STATE_LOADSTAGE &&
	player_state() == STATE_PLAYING
)

function complete_any_stage() => prev(player_state()) == STATE_PLAYING && player_state() == STATE_WINSTAGE

function complete_stage(x) => (
	game_mode() == MODE_GAMEPLAY &&
	current_player_stage() == x &&
	complete_any_stage()
)

function game_over() => (
	game_mode() == MODE_GAMEPLAY &&
	prev(current_player_lives()) == 1 &&
	current_player_lives() == 0
)

// --- RICH PRESENCE -------------------------------------------------------------------

StageNames = {
	1: "Steep Peak",
	2: "Snake Lake",
	3: "Rhino Ridge",
	4: "Lazy Lagoon",
}

StageEmoji = {
	1: "🦍",
	2: "🐍",
	3: "🦏",
	4: "🐊",
}

rp_stage_name = rich_presence_lookup("StageName", current_player_stage(), StageNames, fallback=StageNames[1])
rp_stage_emoji = rich_presence_lookup("StageEmoji", current_player_stage(), StageEmoji, fallback=StageEmoji[1])
rp_loop = rich_presence_value("_Number", current_player_loop(), "VALUE")
rp_lives = rich_presence_value("_Number", current_player_lives(), "VALUE")
rp_score = rich_presence_value("_Score", score_p1(), "SCORE")
rp_lives_word = rich_presence_lookup("LifeWord", current_player_lives(), {1: "life"}, fallback="lives")

rich_presence_conditional_display(game_mode() != MODE_GAMEPLAY,
	"🌴🦍 Congo Bongo 🍌🐒"
)

rich_presence_conditional_display(!correct_settings(),
	"⚠️ Playing Congo Bongo with the wrong settings"
)

rich_presence_display(
	"{0} {1} (Loop {2}) | 💯 Score: {3} | {4} {5} remaining",
	rp_stage_emoji, rp_stage_name, rp_loop,
	rp_score,
	rp_lives, rp_lives_word
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Primate Plateau",
	description="Reach Bongo at the top of Steep Peak",
	type="progression",
	points=2,
	trigger=correct_settings() && complete_stage(1)
)

achievement(
	title="Snakes and Ladders",
	description="Reach Bongo on the other side of Snake Lake",
	type="progression",
	points=3,
	trigger=correct_settings() && complete_stage(2)
)

achievement(
	title="Rhino Rumble",
	description="Reach Bongo beyond Rhino Ridge",
	type="progression",
	points=5,
	trigger=correct_settings() && complete_stage(3)
)

achievement(
	title="We Have Frogger at Home",
	description="Reach Bongo on the opposite bank of Lazy Lagoon",
	type="win_condition",
	points=10,
	trigger=correct_settings() && complete_stage(4)
)

achievement(
	title="Fool Me Twice, Shame on Me",
	description="Complete a second loop",
	points=10,
	trigger=correct_settings() && complete_stage(4) && current_player_loop() == 2
)

for bdata in BONUS_TARGETS
{
	achievement(
		title=bdata["title"],
		description=format("Complete {0} on the first loop with a bonus of {1} or more", StageNames[bdata["stage"]], bdata["bonus"]),
		points=bdata["points"],
		trigger=correct_settings() && current_player_loop() == 1 && complete_stage(bdata["stage"]) && stage_bonus() >= bdata["bonus"]
	)
}

HOLE_BONUS_COUNT = 15
achievement(
	title="Whack-a-Hunter",
	description=format("In Rhino Ridge, earn the mole hole bonus {0} times in a single life", HOLE_BONUS_COUNT),
	points=25,
	trigger=(
		correct_settings() &&
		measured(
			repeated(
				HOLE_BONUS_COUNT, 
				score_p1() >= 1000 + prev(score_p1())
			), 
			when=current_player_stage() == 3
		) &&
		never(game_mode() != MODE_GAMEPLAY) &&
		never(player_state() != STATE_PLAYING) &&
		never(current_player_stage() != 3)
	)
)

achievement(
	title="Van Pelt, Immortal",
	description="Complete any loop without dying",
	points=10,
	trigger=(
		once(correct_settings() && begin_stage(1)) &&
		never(died()) &&
		never(game_mode() != MODE_GAMEPLAY) &&
		trigger_when(complete_stage(4))
	)
)

for challenge in SCORE_CHALLENGES
{
	score = challenge["score"]
	achievement(
		title=challenge["title"],
		description=format("Earn {0} points", commas(score)),
		points=challenge["points"],
		trigger=(
			correct_settings() &&
			game_mode() == MODE_GAMEPLAY &&
			prev(score_p1()) < score &&
			score_p1() >= score
		)
	)
}

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Congo Bongo Speedrunner",
	description="Complete the first loop of Congo Bongo as quickly as possible",

	start=begin_stage(1) && current_player_loop() == 1,
	cancel=!correct_settings() || game_mode() != MODE_GAMEPLAY,
	submit=complete_stage(4) && current_player_loop() == 1,

	value=measured(tally(0, always_true())),
	format="FRAMES",
	lower_is_better=true
)

leaderboard(
	title="Cleared Stages",
	description="Clear as many stages as possible in Congo Bongo",

	start=correct_settings() && game_over(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(current_player_loop() * 4 + current_player_stage() - 5),
	format="VALUE",
	lower_is_better=false
)

leaderboard(
	title="Highest Score",
	description="Earn the highest score possible in Congo Bongo",

	start=correct_settings() && game_over(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(score_p1()),
	format="VALUE",
	lower_is_better=false
)