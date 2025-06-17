// ~Hack~ Get Rich Quick
// #ID = 33663

// --- HELPERS -------------------------------------------------------------------

id = (x) => x
function if_else(p, t, f) { if (p) { return t } else return f }
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

// --- MEMORY -------------------------------------------------------------------

// $000071: Current Player - Animation State [8 bit]
//          0x09 = death
function anim() => byte(0x000071)

// $0100: Game State [8 bit]
//        0x02 = boot, presents
//        0x04 = title screen, profile select
//        0x06 = world select
//        0x07 = level loading
//        0x08 = gameplay
//        0x0a = level complete
//        0x11 = Luigi unlocked
//        0x13 = credits
function game_state() => byte(0x000100)

// $0DB3: Character [8 bit]
//        0 = Mario
//        1 = Luigi
function character() => byte(0x000DB3)

// $102E: Current Coins [16 bit]
function current_coins() => word(0x00102E)

// $1030: Target Coins [16 bit]
function target_coins() => word(0x001030)

// $1035: Timer [16 bit] - 60 fps
function stage_timer() => word(0x001035)

// $1039: Current Profile [16 bit]
//        0-indexed
function current_profile() => word(0x001039)

// $103B: Current World [16 bit]
//        0-indexed
function current_world() => word(0x00103B)

// $103D: Current Stage [16 bit]
//        0-indexed
function current_stage() => word(0x00103D)

// $1041: Level ID [16 bit]
//        uniquely identifies the actual stage
function level_id() => word(0x001041)

// $2600: Best Times [64 bytes]
//        16 bytes per world, each time stored in 16-bit format
function best_time(w, s) => word(0x002600 + (w * 8 + s) * 2)

// $2700: Total Coins Collected [32 bit]
function total_coins() => dword(0x002700)

// $02000A: Character Select Option Available [8 bit]
//          0 = No
//          1 = Yes
function player_select_available() => byte(0x02000A)

// --- MAIN DATA -------------------------------------------------------------------

STATE_BOOT = 0x02
STATE_TITLE = 0x04
STATE_LEVEL_SELECT = 0x06
STATE_LOADING = 0x07
STATE_PLAYING = 0x08
STATE_COMPLETE = 0x0a
STATE_UNLOCK_LUIGI = 0x11
STATE_CREDITS = 0x13

CHAR_MARIO = 0x00
CHAR_LUIGI = 0x01

function maketime(m, s, x=0) => x + 60 * (s + 60 * m)

WORLD_GOALS = [
	maketime(01, 00), 
	maketime(02, 00), 
	maketime(02, 30), 
	maketime(03, 00),
]

BRONZE_TARGETS = [
	// World 1
	maketime(00, 16), // 1-1
	maketime(00, 15), // 1-2
	maketime(00, 16), // 1-3
	maketime(00, 24), // 1-4
	maketime(00, 20), // 1-5
	maketime(00, 32), // 1-6
	maketime(00, 30), // 1-S
	maketime(02, 00), // 1-GP

	// World 2
	maketime(00, 48), // 2-1
	maketime(01, 30), // 2-2
	maketime(00, 50), // 2-3
	maketime(00, 40), // 2-4
	maketime(00, 48), // 2-5
	maketime(01, 00), // 2-6
	maketime(00, 30), // 2-S
	maketime(06, 00), // 2-GP

	// World 3
	maketime(01, 00), // 3-1
	maketime(01, 05), // 3-2
	maketime(00, 28), // 3-3
	maketime(00, 32), // 3-4
	maketime(00, 36), // 3-5
	maketime(00, 32), // 3-6
	maketime(00, 30), // 3-S
	maketime(08, 00), // 3-GP
	
	// World 4
	maketime(01, 00), // 4-1
	maketime(01, 10), // 4-2
	maketime(01, 00), // 4-3
	maketime(01, 15), // 4-4
	maketime(01, 30), // 4-5
	maketime(01, 25), // 4-6
	maketime(00, 30), // 4-S
	maketime(09, 30), // 4-GP
]

PLATINUM_TARGETS = [
	// World 1
	maketime(00, 06), // 1-1
	maketime(00, 07), // 1-2
	maketime(00, 04, 30), // 1-3
	maketime(00, 12, 30), // 1-4
	maketime(00, 10), // 1-5
	maketime(00, 12), // 1-6
	maketime(00, 10), // 1-S
	maketime(01, 00), // 1-GP

	// World 2
	maketime(00, 16), // 2-1
	maketime(00, 20), // 2-2
	maketime(00, 20), // 2-3
	maketime(00, 16), // 2-4
	maketime(00, 16), // 2-5
	maketime(00, 16), // 2-6
	maketime(00, 10), // 2-S
	maketime(02, 00), // 2-GP

	// World 3
	maketime(00, 28), // 3-1
	maketime(00, 24), // 3-2
	maketime(00, 12), // 3-3
	maketime(00, 16), // 3-4
	maketime(00, 20), // 3-5
	maketime(00, 14), // 3-6
	maketime(00, 10), // 3-S
	maketime(02, 00), // 3-GP
	
	// World 4
	maketime(00, 25, 30), // 4-1
	maketime(00, 22, 30), // 4-2
	maketime(00, 21, 30), // 4-3
	maketime(00, 26, 30), // 4-4
	maketime(00, 33), // 4-5
	maketime(00, 28), // 4-6
	maketime(00, 13), // 4-S
	maketime(02, 30), // 4-GP
]

STAGE_TAG = {
	0: "1",
	1: "2",
	2: "3",
	3: "4",
	4: "5",
	5: "6",
	6: "S",
	7: "GP",
}

WORLD_NAME = [
	"Cheapskate Park",
	"Skinflint Subterrane",
	"Prosperity Plains",
	"Fat-Cat Flats",
]

STAGE_NAME = [
	// World 1
	"Koopa Hills", // 1-1
	"Gold Forest Glade", // 1-2
	"Turn-Block Bluff", // 1-3
	"Sky High Circuit", // 1-4
	"Green Block Grotto", // 1-5
	"Skytree Terrace", // 1-6
	"Prize Block Parade", // 1-S
	"", // 1-GP
	
	// World 2
	"Monty's Molehill", // 2-1
	"The Chucklands", // 2-2
	"Rad Rex Ravine", // 2-3
	"Miser's Mountain", // 2-4
	"Parakoopa Cavern", // 2-5
	"Cape Feather Cliff", // 2-6
	"Winged Coin Cavalcade", // 2-S
	"", // 2-GP
	
	// World 3
	"Warp Pipe Prairie", // 3-1
	"C-Note Cenote", // 3-2
	"Piranha Plant Sewers", // 3-3
	"Rope Bridge Battle", // 3-4
	"Volcanic Vault", // 3-5
	"Sawblade Stronghold", // 3-6
	"Super Koopa Coffer", // 3-S
	"", // 3-GP
	
	// World 4
	"Tidal Treasures", // 4-1
	"Phantom Forest", // 4-2
	"Lakitu Ledge", // 4-3
	"Line-Guide Grove", // 4-4
	"Shivering Storeroom", // 4-5
	"Dry Bones Bastion", // 4-6
	"Flying Fish", // 4-S
	"", // 4-GP
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function level_name(w, s) => format("{0}-{1}", w+1, STAGE_TAG[s])

function world_completed(w, f=id) => (
	// all stages (X-1 through X-6) have been played and a time recorded
	all_of(range(0, 5), s => f(best_time(w, s)) != 0) && 

	// the sum of those times is strictly less than the world goal
	sum_of(range(0, 5), s => f(best_time(w, s))) < WORLD_GOALS[w]
)

function all_levels_complete() => all_of(range(0, 3), w => all_of(range(0, 7), s => best_time(w, s) != 0))

// transition from playing to the completed state
function complete_stage() => prev(game_state()) == STATE_PLAYING && game_state() == STATE_COMPLETE

function is_personal_best(w, s) => (
	// transition to the complete stage screen
	complete_stage() && 

	// check if this is the correct world and stage
	current_world() == w && current_stage() == s &&

	// is this an improvement to the best timer? 
	stage_timer() <= best_time(w, s)
)

function best_time_current() => best_time(current_world(), current_stage())

function sum_of_best() => sum_of(range(0, 3), w => sum_of(range(0, 7), s => best_time(w, s)))

function completed_stage_count() => sum_of(range(0, 3), w => sum_of(range(0, 7), s => best_time(w, s) / best_time(w, s)))

// DONTUSE: doesn't emit valid arithmetic on RATools 1.15.2
function platinum_count_arith() => (
	// count the number of times that are less than the platinum time
	sum_of(range(0, 3), w => sum_of(range(0, 7), s => ((best_time(w, s) - PLATINUM_TARGETS[w * 8 + s] - 1) / 0xF0000000)))

	// subtract the number of incomplete stages (no time posted)
	- (32 - completed_stage_count())
)

function platinum_count() => (
	// add one hit for each platinum earned
	tally_of(range(0, 31), 32, s => once(best_time(0, s) != 0 && best_time(0, s) <= PLATINUM_TARGETS[s])) && 

	// clear all hits when not on level select
	never(game_state() != STATE_LEVEL_SELECT)
)

function coin_target(x) => prev(current_coins()) == x-1 && current_coins() == x

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(game_state() == STATE_LEVEL_SELECT && all_levels_complete(),
	"Level Select | ⏱️ Sum of Best Times: {0} | 🏅 {1} P | 🪙 {2}",
	rich_presence_value("_T", sum_of_best(), "FRAMES"),
	rich_presence_number(platinum_count()),
	rich_presence_value("_S", total_coins(), "SCORE")
)

rich_presence_conditional_display(game_state() == STATE_LEVEL_SELECT,
	"Level Select | 📈 Progress: {0} / 32 | 🏅 {1} P | 🪙 {2}",
	rich_presence_number(completed_stage_count()),
	rich_presence_number(platinum_count()),
	rich_presence_value("_S", total_coins(), "SCORE")
)

rich_presence_conditional_display(any_of([STATE_LOADING, STATE_PLAYING], x => game_state() == x) && best_time_current() != 0,
	"{0} is in {1}-{2} | 🪙 {3} / {4} | ⏱️ {5} (PB: {6})",
	rich_presence_lookup("Character", character(), {1: "Luigi"}, fallback="Mario"),
	rich_presence_number(current_world() + 1),
	rich_presence_lookup("Tag", current_stage(), STAGE_TAG, fallback="1"),
	rich_presence_number(current_coins()),
	rich_presence_number(target_coins()),
	rich_presence_value("_T", stage_timer(), "FRAMES"),
	rich_presence_value("_T", best_time_current(), "FRAMES")
)

rich_presence_conditional_display(game_state() == STATE_LOADING || game_state() == STATE_PLAYING,
	"{0} is in {1}-{2} | 🪙 {3} / {4} | ⏱️ {5}",
	rich_presence_lookup("Character", character(), {1: "Luigi"}, fallback="Mario"),
	rich_presence_number(current_world() + 1),
	rich_presence_lookup("Tag", current_stage(), STAGE_TAG, fallback="1"),
	rich_presence_number(current_coins()),
	rich_presence_number(target_coins()),
	rich_presence_value("_T", stage_timer(), "FRAMES")
)

rich_presence_conditional_display(game_state() == STATE_COMPLETE,
	"Completed {0}-{1} | ⏱️ {2} (PB: {3})",
	rich_presence_number(current_world() + 1),
	rich_presence_lookup("Tag", current_stage(), STAGE_TAG, fallback="1"),
	rich_presence_value("_T", stage_timer(), "FRAMES"),
	rich_presence_value("_T", best_time_current(), "FRAMES")
)

rich_presence_display("Getting Rich Quick! 🪙")

// --- ACHIEVEMENTS -------------------------------------------------------------------

for w in range(0, 3) // worlds
{
	achievement(
		title=WORLD_NAME[w],
		description=format("Complete the world goal for World {0} to unlock {0}-S and {0}-GP", w+1),
		type="progression",
		points=10,
		trigger=game_state() > STATE_LOADING && world_completed(w) && !world_completed(w, prev)
	)
}

for w in range(0, 3) // worlds
for s in range(0, 7) // stages
{
	stage_name = STAGE_NAME[w * 8 + s]
	if (s == 7) stage_name = format("World {0} Grand Prix", w+1)

	achievement(
		title=format("{0} - Any Medal", stage_name),
		description=format("Earn any medal on {0}", level_name(w, s)),
		type="progression",
		points=if_else(s == 7, 5, 2),
		trigger=(
			current_world() == w && current_stage() == s && 
			complete_stage() && stage_timer() <= BRONZE_TARGETS[w * 8 + s]
		)
	)

	achievement(
		title=format("{0} - Platinum Medal", stage_name),
		description=format("Earn a platinum medal on {0}", level_name(w, s)),
		points=if_else(s == 7, 10, 5),
		trigger=(
			current_world() == w && current_stage() == s && 
			complete_stage() && stage_timer() <= PLATINUM_TARGETS[w * 8 + s]
		)
	)
}

achievement(
	title="Challenger Approaching",
	description="Collect 32 platinum medals and unlock a surprise",
	points=50,
	trigger=(
		// all times are platinum
		all_of(range(0, 3), w => all_of(range(0, 7), s => best_time(w, s) <= PLATINUM_TARGETS[w * 8 + s])) &&

		// the bit for the player select flips first
		player_select_available() == 1 &&

		// transition from complete screen to unlock luigi
		prev(game_state()) == STATE_COMPLETE && game_state() == STATE_UNLOCK_LUIGI
	) 
)

achievement(
	title="Climbing the Kooporate Ladder",
	description="Collect all 40 coins in 3-S",
	points=3,
	trigger=(
		// correct stage (backup confirmation with level id)
		current_world() == 2 && current_stage() == 6 && level_id() == 0x16 && 

		// check that the player has the correct number of coins
		trigger_when(coin_target(40))
	)
)

achievement(
	title="Fishy Funds",
	description="Collect 100 coins in 4-S. Watch for falling fish!",
	points=10,
	trigger=(
		// correct stage (backup confirmation with level id)
		current_world() == 3 && current_stage() == 6 && level_id() == 0x1e && 

		// check that the player has the correct number of coins
		trigger_when(coin_target(100))
	)
)

COIN_TARGET = 500
achievement(
	title="Do You Wanna Make More Money?",
	description=format("Collect {0} total coins on one profile", COIN_TARGET),
	points=3,
	trigger=game_state() == STATE_PLAYING && prev(total_coins()) < COIN_TARGET && total_coins() >= COIN_TARGET
)

COIN_TARGET = 1000
achievement(
	title="A Small Investment",
	description=format("Collect {0} total coins on one profile", COIN_TARGET),
	points=5,
	trigger=game_state() == STATE_PLAYING && prev(total_coins()) < COIN_TARGET && total_coins() >= COIN_TARGET
)

COIN_TARGET = 2500
achievement(
	title="Generational Wealth",
	description=format("Collect {0} total coins on one profile", COIN_TARGET),
	points=10,
	trigger=game_state() == STATE_PLAYING && prev(total_coins()) < COIN_TARGET && total_coins() >= COIN_TARGET
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="4-S Survival",
	description="Earn as many coins as possible on 4-S without dying. Coins max out at 999",

	start=(
		// correct stage
		current_world() == 3 && current_stage() == 6 && level_id() == 0x1e && 

		// either the player has 999 coins or they have died
		(coin_target(999) || (prev(anim()) == 0 && anim() == 0x09))
	),
	cancel=always_false(),
	submit=always_true(),

	value=measured(current_coins()),
	format="VALUE",
	lower_is_better=false
)

for w in range(0, 3) // worlds
for s in range(0, 7) // stages
{
	leaderboard(
		title=format("{0}: Fastest Time", level_name(w, s)),
		description=format("Complete {0} in the fastest possible time", level_name(w, s)),
	
		start=is_personal_best(w, s),
		cancel=always_false(),
		submit=always_true(),
	
		value=measured(stage_timer()),
		format="FRAMES",
		lower_is_better=true
	)
}

leaderboard(
	title="Fastest Overall Time",
	description="Earn the fastest combined time over all 32 stages",

	start=all_levels_complete() && is_personal_best(current_world(), current_stage()),
	cancel=always_false(),
	submit=always_true(),

	value=measured(sum_of_best()),
	format="FRAMES",
	lower_is_better=true
)