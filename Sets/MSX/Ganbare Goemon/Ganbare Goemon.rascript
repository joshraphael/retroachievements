// Ganbare Goemon! Karakuri Douchuu
// #ID = 3269

// https://pidlio.com/goemon1/data/item.html
// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function plurale(x) => rich_presence_lookup("_PlE", x, {1: ""}, fallback="es")
function if_else(p, t, f) { if (p) { return t } else return f }

function score_wrap(score, max, n=20, reset=always_false()) => (
	max_of(array_map(range(0,n), i => measured(max*i+score, when=if_else(i == 0, always_true(), tally(i, score < prev(score)) && never(reset)))))
)

function rich_presence_condition_table(lookupname, list)
{ // highest priority needs to be listed first in the pairs list
	dict = {}
	expr = max_of(array_map(range(1, length(list)), i => measured(length(list)-i, when=list[i-1][0])))
	for i in range(1, length(list)) dict[length(list)-i] = list[i-1][1]
	return rich_presence_lookup(lookupname, expr, dict, "")
}

// --- MEMORY -------------------------------------------------------------------

// $0000: Game Mode [8 bit]
//        0xff = boot
//        0x00 = Konami presents
//        0x01 = title
//        0x02 = demo
//        0x03 = newgame
//        0x04 = map/loading
//        0x05 = playing
//        0x06 = death
//        0x07 = game over
//        0x08 = between levels cutscene
//        0x09 = loading zone
//        0x0a = paused
//        0x0b = end of loop cutscene
//        0x0d = viewing password
//        0x0e = entering password
//        0x0f = end of game cutscene
function game_mode() => byte(0x000000)

// $0002: Game State [8 bit]
//        bit5 | is two player mode?
//        bit6 | is in-game?
//        bit7 | is player two? (Nezumi)
function two_player_mode() => bit5(0x000002)
function game_active() => bit6(0x000002)
function current_player() => bit7(0x000002)

// $0257: P1 Score [24 bit BCD]
// $025A: P2 Score [24 bit BCD]
function p1_score() => bcd(tbyte(0x000257))
function p2_score() => bcd(tbyte(0x00025A))
function score(i) => bcd(tbyte(0x000257 + 3*i))

// $0260: Rest (lives) [8 bit BCD]
function lives() => bcd(byte(0x000260))

// $0265: Koban (money) [16 bit BCD]
function money() => bcd(word(0x000265))

// $0270: Current Player Sandals [8 bit] (0-3)
//        sandals make the player run and jump faster, reset to 0 on death
function current_player_sandals() => byte(0x000270)

// $0271: Item - Slingshot [8 bit] (0/1)
function item_slingshot() => byte(0x000271)

// $0272: Item - Armor [8 bit]
//        blocks enemy projectiles
//        purchase in shop sets this to 5
//        icon appears in hud for any non-zero value
function item_armor() => byte(0x000272)

// $0273: Item - Talisman [8 bit]
//        general protection
//        purchase in shop sets this to 5
//        icon appears in hud for any non-zero value
function item_talisman() => byte(0x000273)

// $0274: Item - Inrou [8 bit]
//        blocks contact damage
//        purchase in shop sets this to 5
//        icon appears in hud for any non-zero value
function item_inrou() => byte(0x000274)

// $0275: Item - Straw Hat [8 bit]
//        blocks attacks dropped from birds above
//        purchase in shop sets this to 5
//        icon appears in hud for any non-zero value
function item_strawhat() => byte(0x000275)

// $0276: Item - Helmet [8 bit]
//        blocks attacks from rocks and bales
//        purchase in shop sets this to 5
//        icon appears in hud for any non-zero value
function item_helmet() => byte(0x000276)

// $0277: Item - Bento [8 bit] (0/1)
function item_bento() => byte(0x000277)

// $0278: Item - Candle [8 bit] (0/1)
//        shows the location of hidden passages
function item_candle() => byte(0x000278)

// $0279: Passes [8 bit] (0-3)
function passes() => byte(0x000279)

// $027A: Item - Maze Map [8 bit] (0/1)
function item_maze_map() => byte(0x00027A)

// $027B: Item - Maze Chest Count [8 bit]
function item_maze_chest_count() => byte(0x00027B)

// $027C: Candle Timer [8 bit]
//        purchase in shop sets to 100 (lasts for 100 in-game seconds)
function candle_timer() => byte(0x00027C)

// $027E: Item - Letter [8 bit] (0/1)
function item_letter() => byte(0x00027E)

// $0280: Current Zone [8 bit]
//        when changing levels, game mode = 0x08 during increment
function current_zone() => byte(0x000280)

// $0281: Overworld Screen [8 bit]
function overworld_screen() => byte(0x000281)

// $0288: Current Loop/Province [8 bit]
//        0 = Izumo
//        1 = Tanba
//        2 = Settsu
//        3 = Oumi
//        4 = Owari
//        5 = Shinano
//        6 = Edo
//        
//        value increments at the same time as the mode transitions 0x0b -> 0x04
function current_loop() => byte(0x000288)

// $0480: Health Max [8 bit]
function health_max() => byte(0x000480)

// $0481: Health [8 bit]
function health() => byte(0x000481)

// $0482: In Shop? [8 bit] (0/1)
// $0483: In Underground? [8 bit] (0/1)
function in_shop() => byte(0x000482)
function in_underground() => byte(0x000483)

// $04B0: Time [16 bit BCD]
//        clock adds 200 seconds
function time() => bcd(word(0x0004B0))

// $04B2: Frames (time) [8 bit]
//        decrements every 2f, when rollover, subtract one from time
//        freezes indoors
function frames_time() => byte(0x0004B2)

// $0500: Shop/Indoor #1 [8 bit]
//        bit7 | player is inside
//        
//        0x00 = shop - pass, talisman, inrou
//        0x01 = shop - clock, sandals, slingshot
//        0x02 = shop - helmet, armor, straw hat
//        0x03 = shop - candle, sandals, onigiri
//        0x04 = shop - helmet, sandals, talisman
//        0x05 = shop - strawhat, slingshot, inrou
//        0x06 = shop - onigiri, sandals, armor
//        0x07 = shop - helmet, slingshot, straw hat
//        0x08 = shop - (empty), onigiri, pass
//        0x09 = shop - (empty), slingshot, inrou
//        0x0a = shop - (empty), armor, talisman
//        0x0b = shop - (empty), straw hat, onigiri
//        0x0c = shop - (empty), ramen, dango
//        0x0d = shop - (empty), onigiri, (empty)
//        0x0e = shop - (empty), pass, (empty)
//        0x0f = shop - (empty), candle, (empty)
//        0x10 = secret passage
//        0x11 = gambling house
//        0x12 = inn
//        0x13 = pawn shop
//        0x14 = informant
// $0510: Shop/Indoor #2 [8 bit]
function shop_indoor_1() => byte(0x000500)
function shop_indoor_2() => byte(0x000510)
function indoors_1() => bit7(0x000500)
function indoors_2() => bit7(0x000510)

// $0600: Dialogue/Actor Script [8 bit]
function dialogue_actor_script() => byte(0x000600)

// $0601: Dialogue Step [8 bit]
//        values are not unique in all cases
//        
//        0x24,2->3 = results of the gambling game
function dialogue_step() => byte(0x000601)

// $0D8D: Die #2 [8 bit]
// $0D8E: Die #1 [8 bit]
function die_2() => byte(0x000D8D)
function die_1() => byte(0x000D8E)

// $0D8F: Bet: Even or Odd [8 bit]
//        1 = Odd
//        2 = Even
function bet_even_or_odd() => byte(0x000D8F)

// $0DB1: In Maze [8 bit] (0/1)
//        tie this value to being inside a secret passage shop
function maze() => byte(0x000DB1)

// --- MAIN DATA -------------------------------------------------------------------

ORDINALS = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th"]
ROMAN = ["I", "II", "III", "IV", "V", "VI", "VII"]

PROGRESSION_POINTS_PER_PROVINCE = [3, 4, 4, 5, 5, 5, 10]

ALL_DEFENSE_ITEMS = [
	item_armor(),
	item_talisman(),
	item_inrou(),
	item_strawhat(),
	item_helmet(),
]

MODE_BOOT = 0xff
MODE_KONAMI = 0x00
MODE_TITLE = 0x01
MODE_DEMO = 0x02
MODE_NEWGAME = 0x03
MODE_MAP = 0x04
MODE_PLAYING = 0x05
MODE_DEATH = 0x06
MODE_GAMEOVER = 0x07
MODE_CUTSCENE_LEVEL = 0x08
MODE_LOADING = 0x09
MODE_PAUSED = 0x0a
MODE_CUTSCENE_LOOP = 0x0b
MODE_VIEW_PASSWORD = 0x0d
MODE_ENTER_PASSWORD = 0x0e
MODE_ENDING = 0x0f

MODES = {
	MODE_BOOT: "Booting MSX",
	MODE_KONAMI: "Konami Presents",
	MODE_TITLE: "Title Screen",
	MODE_DEMO: "Demo Playing",
	MODE_NEWGAME: "New Game",
	MODE_MAP: "Looking at the Map",
	MODE_PLAYING: "Playing",
	MODE_DEATH: "Died",
	MODE_GAMEOVER: "Game Over",
	MODE_CUTSCENE_LEVEL: "Cutscene",
	MODE_LOADING: "Loading",
	MODE_PAUSED: "Paused",
	MODE_CUTSCENE_LOOP: "Cutscene",
	MODE_VIEW_PASSWORD: "Paused",
	MODE_ENTER_PASSWORD: "Password Entry",
	MODE_ENDING: "Ending",
}

CHAR_GOEMON = 0
CHAR_NEZUMI = 1

SHOP_SECRET = 0x10
SHOP_GAMBLING = 0x11
SHOP_INN = 0x12
SHOP_PAWNSHOP = 0x13
SHOP_INFORMANT = 0x14

PROVINCES = {
	0: "Izumo Province", 
	// https://www.roningallery.com/Hirose-Izumo-province
	1: "Tanba Province", 
	// https://www.roningallery.com/Tanba-Province.-Kanegasaka
	2: "Settsu Province", 
	// https://www.roningallery.com/Settsu-Province.-Sumiyoshi-Beach
	3: "Oumi Province", 
	// https://www.roningallery.com/Omi-Province-Lake-Biwa-Ishiyama-Temple_2
	4: "Owari Province", 
	// https://www.roningallery.com/Owari.-Festival-at-Tsushima
	5: "Shinano Province", 
	// https://www.roningallery.com/sarashina-in-shinano-province
	6: "Edo",
	// https://www.metmuseum.org/art/collection/search/45434
	// https://www.metmuseum.org/art/collection/search/36932
	// https://www.metmuseum.org/art/collection/search/36461
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => game_active() == 1 // game_mode() > MODE_NEWGAME && game_mode() < MODE_PASSWORD

// this method makes sure that data isn't changing just because the players swapped in a 2p game
function sanity_check() => in_game() && prev(current_player()) == current_player()

function in_specific_shop(x) => in_shop() == 1 && __ornext(
	shop_indoor_1() == (0x80 ^ (x & 0x7f)) || 
	shop_indoor_2() == (0x80 ^ (x & 0x7f))
)

function gambling_result() => (
	dialogue_actor_script() == 0x24 && 
	prev(dialogue_step()) == 2 && dialogue_step() == 3
)

function gambling_win() => (die_1() + die_2() + bet_even_or_odd()) % 2 == 1

function in_maze() => in_specific_shop(SHOP_SECRET) && maze() == 1

function win_the_game() => (
	prev(current_loop()) == 6 && current_loop() == 7 &&
	prev(current_zone()) == 6 && current_zone() == 0 &&
	prev(game_mode()) == MODE_CUTSCENE_LOOP && game_mode() == MODE_ENDING
)

// --- RICH PRESENCE -------------------------------------------------------------------

rp_action = rich_presence_condition_table("Action", [
	[in_maze(), "is lost in the maze"],
	[in_specific_shop(SHOP_GAMBLING), "is gambling"],
	[in_specific_shop(SHOP_INN), "is sleeping at the inn"],
	[in_specific_shop(SHOP_PAWNSHOP), "is selling"],
	[in_specific_shop(SHOP_INFORMANT), "is getting information"],
	[in_shop() == 1, "is shopping"],
	[in_underground() == 1, "is underground"],
	[always_true(), "is"],
])

rich_presence_conditional_display(in_game() && game_mode() != MODE_BOOT,
	"{0} {1} in 🏯 {2} {3}-{4} · 🏃 {5} {6} · ❤️ {7}/{8} health · 🪙 {9} koban · 🪪 {10} pass{11} · ⏳ {12} · 💯 {13} points",
	rich_presence_lookup("Name", current_player(), {CHAR_NEZUMI: "Nezumi"}, fallback="Goemon"),
	rp_action,
	rich_presence_lookup("Province", current_loop(), PROVINCES, fallback=PROVINCES[0]),
	rich_presence_number(current_loop() + 1),
	rich_presence_number(current_zone() + 1),
	rich_presence_number(lives()),
	rich_presence_lookup("LifeWord", lives(), {1: "life"}, fallback="lives"),
	rich_presence_number(health()),
	rich_presence_number(health_max()),
	rich_presence_number(money()),
	rich_presence_number(passes()), plurale(passes()),
	rich_presence_number(time()),
	rich_presence_value("Score", score(current_player()), "SCORE")
)

rich_presence_conditional_display(game_mode() == 0x0f,
	"{0} has confronted the Feudal Lords at Edo and put an end to the corruption · 💯 {1} points",
	rich_presence_lookup("Name", current_player(), {1: "Nezumi"}, fallback="Goemon"),
	rich_presence_value("Score", score(current_player()), "SCORE")
)

rich_presence_display(
	"[{0}] Ganbare Goemon! Karakuri Douchuu | © Konami 1987",
	rich_presence_lookup("Mode", game_mode(), MODES, fallback=MODES[MODE_TITLE])
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// progression for all loops
for loop in range(0,6)
{
	loopname = if_else(loop == 6, "", "the ") + PROVINCES[loop]
	for zone in range(0,5)
	{
		achievement(
			title=format("{0} {1}", PROVINCES[loop], ROMAN[zone]),
			description=format("Complete the {0} stage of {1}", ORDINALS[zone], loopname),
			type="progression",
			points=PROGRESSION_POINTS_PER_PROVINCE[loop],
			trigger=(
				in_game() && game_mode() == MODE_CUTSCENE_LEVEL && 
				prev(current_loop()) == loop && current_loop() == loop &&
				prev(current_zone()) == zone && current_zone() == zone+1
			)
		)
	}

	// next mode after the feudal lords cutscene is usually the map, but its the ending 
	target_mode = if_else(loop == 6, MODE_ENDING, MODE_MAP)
	achievement(
		title=format("No More Corruption in {0}", loopname),
		description=format("Complete the last stage of {0} and meet with the feudal lords", loopname),
		type=if_else(loop == 6, "win_condition", "progression"),
		points=if_else(loop == 6, 25, 10),
		trigger=(
			prev(game_mode()) == MODE_CUTSCENE_LOOP && game_mode() == target_mode &&
			prev(current_loop()) == loop && current_loop() == loop+1 &&
			prev(current_zone()) == 6 && current_zone() == 0
		)
	)
}

// buyables
achievement(
	title="They're Calling It \"Sandalmaxxing\"",
	description="Reach maximum speed by wearing three pairs of sandals at the same time. Wait, that can't be right...",
	points=2,
	trigger=sanity_check() && prev(current_player_sandals()) == 2 && current_player_sandals() == 3
)

achievement(
	title="The Gift of the Lucky Cat",
	description="Find or buy a slingshot for a little more firepower",
	points=2,
	trigger=sanity_check() && is_set(item_slingshot())
)

achievement(
	title="Why Does Your Mom Let You Wear Two Hats?",
	description="Purchase and wear all five defensive items at the same time: Armor, Talisman, Inrou, Straw Hat, and Helmet",
	points=10,
	trigger=(
		sanity_check() &&
		measured(sum_of(ALL_DEFENSE_ITEMS, x => x / x) == length(ALL_DEFENSE_ITEMS)) &&
		sum_of(ALL_DEFENSE_ITEMS, x => prev(x) / prev(x)) == length(ALL_DEFENSE_ITEMS)-1
	)
)

achievement(
	title="I Love Jelly Donuts",
	description="Purchase the onigiri for a pick-me-up when times get tough",
	points=2,
	trigger=sanity_check() && is_set(item_bento())
)

achievement(
	title="Jack Be Nimble",
	description="Purchase the candle to show you the way",
	points=3,
	trigger=sanity_check() && is_set(item_candle())
)

achievement(
	title="Lord of the Gourds",
	description="Reach the maximum health capacity",
	points=10,
	trigger=sanity_check() && prev(health_max()) == 28 && health_max() == 32
)

// buy 3 passes
achievement(
	title="Pay2Win",
	description="Buy three passes in one stage. Finding a pass in a maze or underground will not count",
	points=5,
	trigger=(
		any_of([CHAR_GOEMON, CHAR_NEZUMI], ch => (
			measured(tally(3, (
				// current player is correct and didn't just change
				current_player() == ch && current_player() == prev(current_player()) &&
				// pass count went up by one
				passes() == prev(passes()) + 1 &&
				// currently in a shop, but not in a maze
				in_shop() == 1 && !in_maze() &&
				// reset this counter if the player changes levels
				never(sanity_check() && prev(current_zone()) != current_zone())
			)),
			when=current_player() == ch)
		)) &&
		// reset all counters if we leave the game
		never(!in_game())
	)
)

// 3 gambling wins
achievement(
	title="I Can Stop Any Time I Want",
	description="Win three gambling games in a row",
	points=5,
	trigger=(
		any_of([CHAR_GOEMON, CHAR_NEZUMI], ch => (
			measured(tally(3, (
				// player won the gambling game
				current_player() == ch && gambling_result() && gambling_win() &&
				// reset if player lost the gambling game
				never(current_player() == ch && gambling_result() && !gambling_win())
			)),
			when=current_player() == ch)
		)) &&
		// reset all counters if we leave the game
		never(!in_game())
	)
)

// maze completion? might need to search maze structure


// --- LEADERBOARDS -------------------------------------------------------------------

// highest score in a one-player game
leaderboard(
	title="High Score",
	description="Highest score earned in a one player game started from a new game (no passwords)",

	start=prev(game_mode()) == MODE_NEWGAME && game_mode() == MODE_MAP,
	cancel=game_mode() == MODE_TITLE,
	submit=game_mode() == MODE_GAMEOVER || game_mode() == MODE_ENDING,

	value=score_wrap(p1_score(), max=1000000, n=100),
	format="SCORE",
	lower_is_better=false
)

// most consecutive gambling wins in one visit
/*
leaderboard(
	title="Gambling Expert",
	description="Win the most bets in a row, losing a bet cancels the leaderboard. Leaderboard starts when entering the gambling hall, and submits when changing map screens. Are you brave enough to roll just one more time? Or do you play it safe and lock in an average score?",

	start=prev(indoors_1()) == 0 && prev(indoors_2()) == 0 && in_specific_shop(SHOP_GAMBLING),
	cancel=(gambling_result() && !gambling_win()) || !in_game(),
	submit=overworld_screen() != prev(overworld_screen()),

	value=measured(tally(0, gambling_result() && gambling_win())),
	format="VALUE",
	lower_is_better=false
)
*/