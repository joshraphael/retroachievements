// ~Homebrew~ XSpelunker
// #ID = 31894

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

function rich_presence_flag(str, when=always_true(), lookupname="_F") => 
	rich_presence_lookup(lookupname, max_of(measured(1, when=when), measured(0)), {1: str}, "")

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset(offset=0x00C000) => ~bit7(0x00FC48) * offset

// $0058: Selected Inventory Slot [8 bit]
function selected_inventory_slot() => byte(addr_offset() + 0x000058)

// $005A: Current Player Input [8 bit]
//        bit0 = up
//        bit1 = down
//        bit2 = left
//        bit3 = right
//        bit4 = trigger 1
//        bit5 = trigger 2
//        bit7 = no buttons held
// $005B: Previous Frame Player Input [8 bit]
// $005C: Player Input Rises [8 bit]
// $005D: Player Input Double Taps [8 bit]
function current_input() => byte(addr_offset() + 0x00005A)
function prev_input() => byte(addr_offset() + 0x00005B)
function input_rises() => byte(addr_offset() + 0x00005C)
function input_double() => byte(addr_offset() + 0x00005D)

// $0061: Jump Inertia [8 bit]
//        0xFF = jumping left
//        0x00 = neutral jump
//        0x01 = jumping right
function jump_inertia() => byte(addr_offset() + 0x000061)

// $0062: Health [8 bit]
//        max 6, death at 0
function health() => byte(addr_offset() + 0x000062)

// $0063: Inventory [16 bytes]
//        each entry is two bytes: item id, count
//        0 = empty
//        1 = bomb
//        2 = rope
//        3 = arrow
//        4 = rock/stone
//        5 = machete
//        6 = shield 🛡️
//        7 = bow 🏹
//        8 = boots 🥾
//        9 = belt (slow fall) 🪶
//        10 = scuba mask 🤿
//        11 = idol 🗿
//        12 = phaser 🔫
//        13 = boulder
//        14 = button
//        15 = door
INVENTORY = addr_offset() + 0x000063
function inv_slot_id(i) => byte(INVENTORY + 2*i + 0)
function inv_slot_count(i) => byte(INVENTORY + 2*i + 1)

// $0073: Current Level Main [8 bit]
//        0 = Yucatan Jungle
//        1 = Outer Ruins
//        2 = Alien Lab (Inner Ruins)
// $0074: Current Level Section [8 bit]
function level_area() => byte(addr_offset() + 0x000073) + 1
function level_stage() => byte(addr_offset() + 0x000074) + 1
function level_full() => word_be(addr_offset() + 0x000073)

// $0075: Total Accumulated Game Time [16 bit]
function total_gametime() => word(addr_offset() + 0x000075)

// $00AF: Time Readout in HUD [4 bytes]
//        format is 0:00, level time isn't stored any other way :(
TIME_READOUT = addr_offset() + 0x0000AF

// $00BA: Game Speed [8 bit]
//        0 = 50hz
//        1 = 60hz
function game_speed() => byte(addr_offset() + 0x0000BA)

// $00BB: Game State [8 bit]
//        0 = Intro (Unused)
//        1 = Title
//        2 = Level Setup (Used Incorrectly)
//        3 = Playing Level
//        4 = Game Over (Unused)
//        5 = Ending
function game_state() => byte(addr_offset() + 0x0000BB)

// $00C0: Map Layout [4096 bytes]
//        stores 8x8 px tiles
MAP_DATA = addr_offset() + 0x0000C0

// $10C1: Map Width [8 bit]
// $10C2: Map Height [8 bit]
function map_width() => byte(addr_offset() + 0x0010C1)
function map_height() => byte(addr_offset() + 0x0010C2)

// $10C3: Map Enemy Count [8 bit]
function map_enemy_count() => byte(addr_offset() + 0x0010C3)

// $10C4: Map Enemies Table [256 bytes] [32 x 8 byte structs]
//        +0 | type
//        +1 | hp
//        +2 | state2
//        +3 | state3
//        +4 | ypos [16 bit] (tile, pixel) [read as BE]
//        +6 | xpos [16 bit] (tile, pixel) [read as BE]
ENEMIES_TABLE = addr_offset() + 0x0010C4
function enemy_addr(i) => ENEMIES_TABLE + 8*i

function enemy_id(i) => byte(enemy_addr(i) + 0)
function enemy_hp(i) => byte(enemy_addr(i) + 1)

// $11C4: Map Item Count [8 bit]
function map_item_count() => byte(addr_offset() + 0x0011C4)

// $11C5: Map Items Table [256 bytes] [32 x 8 byte structs]
//        +0 | type
//        +1 | x tile
//        +2 | y tile
//        +3 | ???
//        +4 | background behind tile [4 bytes]
//        
//        for dropping a weight on a switch in the jungle:
//        - 0x0b item id for idol/weight
//        - 0x07,0x08 in background is a pressed switch
MAP_ITEMS_TABLE = addr_offset() + 0x0011C5
function map_item_addr(i) => MAP_ITEMS_TABLE + 8*i

function map_item_id(i) => byte(map_item_addr(i) + 0)
function map_item_x(i) => byte(map_item_addr(i) + 1)
function map_item_y(i) => byte(map_item_addr(i) + 2)
function map_bg_tiles(i) => array_map(range(4,7), x => byte(map_item_addr(i) + x))

// $15F0: Player Y Tile [8 bit]
// $15F1: Player Y Pixel [8 bit]
// $15F2: Player X Tile [8 bit]
// $15F3: Player X Pixel [8 bit]
function player_y_tile() => byte(addr_offset() + 0x0015F0)
function player_y_pixel() => byte(addr_offset() + 0x0015F1)
function player_x_tile() => byte(addr_offset() + 0x0015F2)
function player_x_pixel() => byte(addr_offset() + 0x0015F3)

// $15F4: Player State [8 bit]
//        0 = idle right
//        1 = idle left
//        2 = crouching right
//        3 = crouching left
//        4 = falling right
//        5 = falling left
//        6 = walking right
//        7 = walking left
//        8 = jumping right
//        9 = jumping left
//        10 = climb right
//        11 = climb left
//        12 = swim right
//        13 = swim left
//        14 = machete right
//        15 = machete left
//        16 = shield right
//        17 = shield left
//        18 = item throw right
//        19 = item throw left
//        20 = hurt right
//        21 = hurt left
//        22 = dead right
//        23 = dead left
//        
//        can infer facing direction from bit0 (0 = right, 1 = left)
function player_state() => byte(addr_offset() + 0x0015F4)

// --- MAIN DATA -------------------------------------------------------------------

STATE_TITLE = 1
STATE_SETUP = 2
STATE_PLAYING = 3
STATE_ENDING = 5

ITEM_EMPTY = 0
ITEM_BOMB = 1
ITEM_ROPE = 2
ITEM_ARROW = 3
ITEM_ROCK = 4
ITEM_MACHETE = 5
ITEM_SHIELD = 6
ITEM_BOW = 7
ITEM_BOOTS = 8
ITEM_BELT = 9
ITEM_SCUBA = 10
ITEM_IDOL = 11
ITEM_PHASER = 12
// the following aren't held items, but appear in stages
ITEM_BOULDER = 13
ITEM_BUTTON = 14
ITEM_DOOR = 15

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function item_count(x) => max_of(array_map(range(0,7), i => measured(inv_slot_count(i), when=inv_slot_id(i) == x)))

function has_item(x) => any_of(range(0,7), i => inv_slot_id(i) == x)
function found_item(x) => any_of(range(0,7), i => inv_slot_id(i) == x && prev(inv_slot_id(i)) == 0)

function start_game() => prev(game_state()) == STATE_TITLE && game_state() == STATE_SETUP && level_area() == 1 && level_stage() == 1

function in_game() => once(
	// set a checkpoint hit on transitioning out of the title screen
	start_game() && 
	// clear the hit when health goes to 0 or returning to the title screen
	never(game_state() == STATE_TITLE) && never(health() == 0)
)

// check that the level incremented upwards when the setup state is transitioned to
function complete_any_level() => prev(game_state()) == STATE_PLAYING && game_state() == STATE_SETUP && level_full() > prev(level_full())

function complete_world(x) => (
	// previously was playing A-4
	prev(game_state()) == STATE_PLAYING && prev(level_area()) == x && prev(level_stage()) == 4 &&
	// now we are setting up for B-1
	game_state() == STATE_SETUP && level_area() == x+1 && level_stage() == 1
)

function win_the_game() => (
	// the transition from PLAYING -> SETUP happens before this
	prev(game_state()) == STATE_SETUP && game_state() == STATE_ENDING && 
	// the level is incremented to the equivalent to 4-1, so we can use this as an extra check
	level_area() == 4 && level_stage() == 1
)

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(game_state() == STATE_PLAYING,
	"Level {0}-{1} [⏳{2}:{3}{4}] · ❤️{5} · Items: [💣x{6} 🪢x{7}{8}{9}{10}{11}{12}{13}{14}] · ⏱️ Total Run Time: {15}",
	rich_presence_number(level_area()),
	rich_presence_number(level_stage()),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 0)),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 2)),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 3)),
	rich_presence_number(health()),
	rich_presence_number(item_count(ITEM_BOMB)),
	rich_presence_number(item_count(ITEM_ROPE)),
	rich_presence_flag(" 🛡️", when=has_item(ITEM_SHIELD), lookupname="_Item6"),
	rich_presence_flag(" 🏹", when=has_item(ITEM_BOW), lookupname="_Item7"),
	rich_presence_flag(" 🥾", when=has_item(ITEM_BOOTS), lookupname="_Item8"),
	rich_presence_flag(" 🪶", when=has_item(ITEM_SHIELD), lookupname="_Item9"),
	rich_presence_flag(" 🤿", when=has_item(ITEM_SCUBA), lookupname="_Item10"),
	rich_presence_flag(" 🗿", when=has_item(ITEM_IDOL), lookupname="_Item11"),
	rich_presence_flag(" 🔫", when=has_item(ITEM_PHASER), lookupname="_Item12"),
	rich_presence_value("Time", total_gametime(), "SECS")
)

rich_presence_conditional_display(game_state() == STATE_SETUP,
	"Level {0}-{1} · ❤️{5} · Items: [💣x{6} 🪢x{7}{8}{9}{10}{11}{12}{13}{14}] · ⏱️ Total Run Time: {15}",
	rich_presence_number(level_area()),
	rich_presence_number(level_stage()),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 0)),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 2)),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 3)),
	rich_presence_number(health()),
	rich_presence_number(item_count(ITEM_BOMB)),
	rich_presence_number(item_count(ITEM_ROPE)),
	rich_presence_flag(" 🛡️", when=has_item(ITEM_SHIELD), lookupname="_Item6"),
	rich_presence_flag(" 🏹", when=has_item(ITEM_BOW), lookupname="_Item7"),
	rich_presence_flag(" 🥾", when=has_item(ITEM_BOOTS), lookupname="_Item8"),
	rich_presence_flag(" 🪶", when=has_item(ITEM_SHIELD), lookupname="_Item9"),
	rich_presence_flag(" 🤿", when=has_item(ITEM_SCUBA), lookupname="_Item10"),
	rich_presence_flag(" 🗿", when=has_item(ITEM_IDOL), lookupname="_Item11"),
	rich_presence_flag(" 🔫", when=has_item(ITEM_PHASER), lookupname="_Item12"),
	rich_presence_value("Time", total_gametime(), "SECS")
)

rich_presence_conditional_display(game_state() == STATE_ENDING,
	"Run Complete! ⏱️ Total Run Time: {15} · ❤️{5} · Items: [💣x{6} 🪢x{7}{8}{9}{10}{11}{12}{13}{14}]",
	rich_presence_number(level_area()),
	rich_presence_number(level_stage()),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 0)),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 2)),
	rich_presence_macro("ASCIIChar", byte(TIME_READOUT + 3)),
	rich_presence_number(health()),
	rich_presence_number(item_count(ITEM_BOMB)),
	rich_presence_number(item_count(ITEM_ROPE)),
	rich_presence_flag(" 🛡️", when=has_item(ITEM_SHIELD), lookupname="_Item6"),
	rich_presence_flag(" 🏹", when=has_item(ITEM_BOW), lookupname="_Item7"),
	rich_presence_flag(" 🥾", when=has_item(ITEM_BOOTS), lookupname="_Item8"),
	rich_presence_flag(" 🪶", when=has_item(ITEM_SHIELD), lookupname="_Item9"),
	rich_presence_flag(" 🤿", when=has_item(ITEM_SCUBA), lookupname="_Item10"),
	rich_presence_flag(" 🗿", when=has_item(ITEM_IDOL), lookupname="_Item11"),
	rich_presence_flag(" 🔫", when=has_item(ITEM_PHASER), lookupname="_Item12"),
	rich_presence_value("Time", total_gametime(), "SECS")
)

rich_presence_display(
	"Michael S. Xavier is leaving for an expedition into the Yucatan jungle"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Straight Outta Yuc'tan",
	description="Complete level 1-4",
	type="progression",
	points=5,
	trigger=complete_world(1)
)

achievement(
	title="Mayan Craft",
	description="Complete level 2-4",
	type="progression",
	points=10,
	trigger=complete_world(2)
)

achievement(
	title="Out of This World",
	description="Complete level 3-4",
	type="win_condition",
	points=25,
	trigger=complete_world(3)
)

achievement(
	title="All I Need is One Finger",
	description="Complete level 3-4 with six hearts",
	points=25,
	trigger=health() == 6 && complete_world(3)
)

// good world 1 stages take 30 seconds
// good world 2 stages take 30-60 seconds
// good world 3 stages take 60 seconds
achievement(
	title="This Isn't a Sightseeing Expedition",
	description="Complete the game in under 10 minutes",
	points=10,
	trigger=in_game() && total_gametime() < 10*60 && trigger_when(complete_world(3))
)

achievement(
	title="Under My Own Steam",
	description="Complete the first world without using any ropes or bombs",
	points=5,
	trigger=(
		// complete world 1
		in_game() && trigger_when(complete_world(1)) &&
		// for both items (bombs & ropes)
		all_of([ITEM_BOMB, ITEM_ROPE], item => (
			// check every inventory slot; is this the item we're looking for, and did the count go down?
			all_of(range(0,7), i => never(prev(inv_slot_id(i)) == item && inv_slot_count(i) < prev(inv_slot_count(i)))) &&
			// when you use the last consumable item, the count doesn't go down, but the id goes to 0
			all_of(range(0,7), i => never(prev(inv_slot_id(i)) == item && inv_slot_id(i) == 0))
		))
	)
)

achievement(
	title="Spelunky Sprinter",
	description="Complete any level in under 10 seconds",
	points=3,
	// check that the time readout says 2:5X when completing a level
	trigger=in_game() && byte(TIME_READOUT + 0) == 0x32 && byte(TIME_READOUT + 2) == 0x35 && trigger_when(complete_any_level())
)

achievement(
	title="Patience is Key",
	description="Block a projectile with the shield",
	points=5,
	trigger=(
		// in game and the player has a shield
		game_state() == STATE_PLAYING && has_item(ITEM_SHIELD) &&
		// transition from idle state to shield state
		trigger_when(player_state() & 0xFE == 0x10 && prev(player_state()) & 0xFE == 0)
	)
)

achievement(
	title="A Little Spring in Your Step",
	description="Collect a pair of boots. They've got little trampolines in 'em",
	points=2,
	trigger=game_state() == STATE_PLAYING && found_item(ITEM_BOOTS)
)

achievement(
	title="Take a Bow",
	description="Collect a bow. Did you find any arrows for it?",
	points=2,
	trigger=game_state() == STATE_PLAYING && found_item(ITEM_BOW)
)

achievement(
	title="I Can Hold My Breath for Ten Minutes",
	description="Collect a diving mask. Water is no problem anymore",
	points=3,
	trigger=game_state() == STATE_PLAYING && found_item(ITEM_SCUBA)
)

achievement(
	title="Capes Are More Stylish",
	description="Collect a belt. You feel a little bit lighter",
	points=3,
	trigger=game_state() == STATE_PLAYING && found_item(ITEM_BELT)
)

achievement(
	title="Set Phasers to Kill",
	description="Collect a phaser weapon. Be careful where you point that thing!",
	points=3,
	trigger=game_state() == STATE_PLAYING && found_item(ITEM_PHASER)
)

achievement(
	title="He's So Heavy",
	description="Use something heavy to hold down a pressure switch",
	points=5,
	trigger=(
		// in game
		game_state() == STATE_PLAYING &&
		// check every item slot
		any_of(range(0,31), i => (
			// check that there wasn't an item in this slot before, and now it's an idol
			prev(map_item_id(i)) == 0 && map_item_id(i) == 0x0b &&
			// and any of the background tiles are switch tiles
			__ornext(any_of(map_bg_tiles(i), m => m == 0x07 || m == 0x08))
		))
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Fastest Expedition",
	description="Complete the game as quickly as possible",

	start=complete_world(3),
	cancel=always_false(),
	submit=always_true(),

	value=measured(total_gametime()),
	format="SECS",
	lower_is_better=true
)