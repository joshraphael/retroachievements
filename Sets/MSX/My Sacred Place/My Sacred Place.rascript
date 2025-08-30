// ~Homebrew~ My Sacred Place
// #ID = 33893

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0xC033
//        MSX2 mode = 0xFFFF
//        check bit7 for address shifting by $C000
function addr_offset(offset=0x00C000) => ~bit7(0x00FC48) * offset

// $0010: Boot Screen [8 bit]
//        0 = Boot
//        0x0d = Otherwise
function boot_screen() => byte(addr_offset() + 0x000010)

// $003B: In Game [8 bit]
//        0 = Title Screen
//        1 = Game Started
function _in_game() => byte(addr_offset() + 0x00003B)

// $0045: Current Season [8 bit]
//        win the game on 7->8
function season() => byte(addr_offset() + 0x000045)

// $0047: X Position [16 bit]
function xpos() => word(addr_offset() + 0x000047)

// $0049: Y Position [16 bit]
function ypos() => word(addr_offset() + 0x000049)

// $004D: Garks Remaining [8 bit]
function garks_remaining() => byte(addr_offset() + 0x00004D)

// $004F: Setup Time Remaining [16 bit]
//        garks attack when time=0
function time() => word(addr_offset() + 0x00004F)

// $0059: Gark X Position [16 bit]
function gark_xpos() => word(addr_offset() + 0x000059)

// $005B: Gark Y Position [16 bit]
function gark_ypos() => word(addr_offset() + 0x00005B)

// $006D: Current Health [8 bit]
//        initial/max is 6
function health() => byte(addr_offset() + 0x00006D)

// $006F: Taken Damage This Round [8 bit]
//        0 = No Damage Taken
//        1 = Damage Taken
function has_taken_damage() => byte(addr_offset() + 0x00006F)

// $0074: Magic Soil Patches [20 bytes]
//        ten 16-bit BE values, column-major order
//        first five values are column 1, next five are column 2
//        0 = Empty
//        1 = Ginger Seedling Planted
function soil(i) => byte(addr_offset() + 0x000074 + 2*i + 1)

// $0093: Fireballs Blocked [8 bit]
//        in home dojo
//        transitions 8->0 and rewards coin(s) on same frame
function fireballs() => byte(addr_offset() + 0x000093)

// $0097: Next Dojo Coin Bonus [8 bit]
//        starts at 1, increments by 1 every time a bonus is earned (8 fireballs)
//        whenever a bonus is earned, this is how many coins will be rewarded
function next_dojo_bonus() => byte(addr_offset() + 0x000097)

// $009F: Tyzin Coins [16 bit]
function coins() => word(addr_offset() + 0x00009F)

// $00BF: Ginger Seedlings [16 bit]
function ginger() => word(addr_offset() + 0x0000BF)

// $00C1: Silver Daggers [16 bit]
function daggers() => word(addr_offset() + 0x0000C1)

// $37D1: Score Display [5 bytes ASCII]
//        subtract 0x30 from each digit for numerical value
SCORE_BYTES = addr_offset() + 0x0037D1

// $37FB: Score [3 byte BCD]
//        flickers unreliably when incrementing
function score() => bcd(tbyte(addr_offset() + 0x0037FB))

// $4000: Text/Tiles on Screen [32 bytes]
//        this represents the topmost row
// $400B: Screen Differentiator [8 bit]
//        0x00 = Season Screen
//        0x45 = Title Screen
//        0x48 = Isao the Old Wise Man
//        0x49 = Aris the Witch
//        0x55 = Your Home Dojo
//        0x60 = Village Map
//        
//        yes, this is ASCII/tile data, but there is no screen id
function screen_id() => byte(addr_offset(0x4000) + 0x00400B)

// --- MAIN DATA -------------------------------------------------------------------

SCREEN_VILLAGE = 0x60
SCREEN_WISEMAN = 0x48
SCREEN_SHOP = 0x49
SCREEN_DOJO = 0x55
SCREEN_TITLE = 0x45

SCREENS = {
	0x00: "⛩️ My Sacred Place",
	SCREEN_WISEMAN: "👴 Visiting Isao the Old Wise Man",
	SCREEN_SHOP: "🧙‍♀️ Visiting Aris the Witch",
	SCREEN_DOJO: "🥋 Training at the Dojo",
	SCREEN_VILLAGE: "⛩️ My Sacred Place",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function score() => (
	(byte(SCORE_BYTES + 0) - 0x30) * 10000 +
	(byte(SCORE_BYTES + 1) - 0x30) * 1000 +
	(byte(SCORE_BYTES + 2) - 0x30) * 100 +
	(byte(SCORE_BYTES + 3) - 0x30) * 10 +
	(byte(SCORE_BYTES + 4) - 0x30)
)

function start_the_game() => _in_game() == 1 && season() == 1 && prev(time()) == 99 && time() == 98

function in_game() => once(start_the_game() && never(boot_screen() == 0) && never(_in_game() == 0))

function dojo_bonus(x) => (
	// in the dojo
	_in_game() == 1 && screen_id() == SCREEN_DOJO &&
	// fireball count resets from 8 to 0 for the bonus
	prev(fireballs()) == 8 && fireballs() == 0 &&
	// bonus went up to the next level
	prev(next_dojo_bonus()) == x && next_dojo_bonus() == x+1
	// not checking coin count just in case the coin count is maxed somehow
)

function total_fireballs() => (next_dojo_bonus() - 1) * 8 + fireballs()

function complete_season(i) => (
	// in game check
	_in_game() == 1 &&
	// season ticks to the next one
	prev(season()) == i && season() == i+1 &&
	// and time goes from 0 back to 99
	prev(time()) == 0 && time() == 99
)

function win_the_game() => complete_season(7)

function end_the_game() => win_the_game() || (prev(health()) == 1 && health() == 0)

// --- RICH PRESENCE -------------------------------------------------------------------

rp_location = rich_presence_lookup("Screen", screen_id(), SCREENS, fallback=SCREENS[0x00])

rich_presence_conditional_display(in_game() && time() > 0,
	"🍃 Season {0} · {1} · ❤️ {2} · ⏳ {3} · 🪙 {4} · 🫚 {5} · 🗡️ {6} · 💯 {7}",
	rich_presence_number(season()),
	rp_location,
	rich_presence_number(health()),
	rich_presence_number(time()),
	rich_presence_number(coins()),
	rich_presence_number(ginger()),
	rich_presence_number(daggers()),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_conditional_display(in_game(),
	"🍃 Season {0} · ⛩️ Under Attack!! · ❤️ {1} · 👹 {2} · 🪙 {3} · 🫚 {4} · 🗡️ {5} · 💯 {6}",
	rich_presence_number(season()),
	rich_presence_number(health()),
	rich_presence_number(garks_remaining()),
	rich_presence_number(coins()),
	rich_presence_number(ginger()),
	rich_presence_number(daggers()),
	rich_presence_value("Score", score(), "SCORE")
)

rich_presence_display(SCREENS[0x00])

// --- ACHIEVEMENTS -------------------------------------------------------------------

SEASONS = [
	{ "season": 1, "points": 1, "ordinal": "first", "title": "Open Season", },
	{ "season": 2, "points": 3, "ordinal": "second", "title": "A Man About Town", },
	{ "season": 3, "points": 5, "ordinal": "third", "title": "To Everything There Is a Season", },
	{ "season": 4, "points": 5, "ordinal": "fourth", "title": "If There's a Bustle in Your Hedgerow", },
	{ "season": 5, "points": 10, "ordinal": "fifth", "title": "A Man for All Seasons", },
	{ "season": 6, "points": 10, "ordinal": "sixth", "title": "The Ginger Ninja", },
	{ "season": 7, "points": 25, "ordinal": "seventh", "title": "Seasoned Warrior", },
]

for season in SEASONS
{
	achievement(
		title=season["title"],
		description=format("Survive the {0} season", season["ordinal"]) + if_else(season["season"] == 7, " and guarantee peace in the village", ""),
		type=if_else(season["season"] == 7, "win_condition", "progression"),
		points=season["points"],
		trigger=complete_season(season["season"])
	)
}

achievement(
	title="Dojo Renshi",
	description="Earn a coin bonus by blocking fireballs in the dojo",
	points=1,
	trigger=dojo_bonus(1)
)

achievement(
	title="Dojo Kyoshi",
	description="Block 40 fireballs in a row in the dojo",
	points=5,
	trigger=measured(total_fireballs() >= 40, when=_in_game() == 1 && screen_id() == SCREEN_DOJO && next_dojo_bonus() > 0)
)

achievement(
	title="Dojo Hanshi",
	description="Block 75 fireballs in a row in the dojo",
	points=10,
	trigger=measured(total_fireballs() >= 75, when=_in_game() == 1 && screen_id() == SCREEN_DOJO && next_dojo_bonus() > 0)
)

COIN_TARGET_SEASON_1 = 50
achievement(
	title="Tyzin Prize",
	description=format("Have {0} or more Tyzin coins in hand at the start of the second season", COIN_TARGET_SEASON_1),
	points=5,
	trigger=_in_game() == 1 && complete_season(1) && coins() >= COIN_TARGET_SEASON_1
)

achievement(
	title="Respect Your Elders",
	description="Speak to the wise man, Isao, and get a reward of more time, coins, or points",
	points=1,
	trigger=(
		// while visiting the wise man
		_in_game() == 1 && screen_id() == SCREEN_WISEMAN && (
			// score went up
			(score() > prev(score())) ||
			// or coins went up
			(coins() > prev(coins())) ||
			// or time went up
			(time() > prev(time()))
		)
	)
)

achievement(
	title="Expert Gark Wrangler",
	description="Earn a bonus by taking no damage on any gark attack wave after the third season",
	points=2,
	trigger=(
		// during a gark attack when the player hasn't taken damage
		_in_game() == 1 && time() == 0 && has_taken_damage() == 0 && 
		// current season is greater than 3
		season() > 3 &&
		// time the trigger to when the bonus is actually awarded
		trigger_when(garks_remaining() == 0 && coins() > prev(coins()))
	)
)

achievement(
	title="Defense Against the Gark Arts",
	description="Complete all seven seasons without any gark ever getting past the magic soil",
	points=10,
	trigger=(
		// check that the game has started
		once(start_the_game()) &&
		// reset if we left the game
		never(boot_screen() == 0) && never(_in_game() == 0) &&
		// reset if we ever get the damage flag during an invasion
		never(time() == 0 && gark_xpos() < 0xf000 && gark_xpos() > 0x005f) &&
		// challenge ends win we win the game
		trigger_when(win_the_game())
	)
)

achievement(
	title="How Does Your Garden Grow?",
	description="Fill your garden with 10 ginger seedlings",
	points=10,
	trigger=(
		measured(
			sum_of(range(0, 9), i => soil(i)) == 10,
			when=_in_game() == 1 && screen_id() == SCREEN_VILLAGE
		) &&
		sum_of(range(0, 9), i => prev(soil(i))) == 9 &&
		ginger() < prev(ginger())
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="High Score",
	description="Earn the highest score possible",

	start=end_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(score()),
	format="VALUE",
	lower_is_better=false
)

leaderboard(
	title="Coins in Hand",
	description="Have the most unspent coins at the end of the seventh season",

	start=win_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(coins()),
	format="VALUE",
	lower_is_better=false
)

leaderboard(
	title="Fireball Blocker",
	description="Get the longest streak of blocked fireballs before getting hit or forced out due to time",

	start=_in_game() == 1 && prev(screen_id()) == SCREEN_DOJO && screen_id() == SCREEN_VILLAGE,
	cancel=total_fireballs() > 0,
	submit=always_true(),

	value=measured(total_fireballs()),
	format="VALUE",
	lower_is_better=false
)