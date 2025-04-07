// Virtual Hydlide
// #ID = 14552

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)

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

function dword_me(addr) => word(addr) * 65536 + word(addr+2)

// --- MEMORY -------------------------------------------------------------------

// $000007: Game Status [8 bit]
//          00 = Console Intro
//          1f = Watching a Cutscene / Score Screen?
//          10 = Setup Menu
//          02 = In-game
function status() => byte(0x000007)

// $000334: [8 bit] Currently In-Game? 0 - No, 1 - Yes
function in_game() => byte(0x000334)

// $104C56: [8 bit] Game Over Menu Index
//          0 = Continue
//          1 = Load Save Slot #1
//          2 = Load Save Slot #2
//          3 = Load Save Slot #3
function game_over_slot() => byte(0x104C56)

// $104E26: [Ending] Total Score Display Index
//          00 - <None>
//          01 - Score (Base In-Game Score) Shown
//          02 - Time Bonus Shown
//          1 million - (500 pts per minute)
//          
//          03 - Monsters Killed Shown
//          100 pts per monster
//          
//          04 - Game Level Shown
//          Easy - 100k pts
//          Normal - 500k pts
//          Hard - 1mil pts
//          Pro - 2mil pts
//          
//          05 - Survivors' Bonus Shown (unused in US, supposed to be a bonus for a deathless run)
//          Easy - 1mil pts
//          Normal - 2mil pts
//          Hard - 5mil pts
//          Pro - 10mil pts
//          
//          06 - Final Total Shown
function ending_index() => byte(0x104E26)

// $104F6C: Start of End of Game Computed Score (4 bytes)
//          [32 bit, two 16-bit LE/BE mixed format]
function final_score() => dword_me(0x104F6C)

// $105026: Progress Bitfield [bitflags] [8 bit]
//          ---------------------------
//          b0 = Graveyard/Crucifix (+1 Lvl)
//          b1 = Trial Dungeon/Spectacles (+1 Lvl)
//          b2 = Ruins/Flame Amulet (+1 Lvl)
//          b3 = Volcanic Cave/Flute of Zaldis (+1 Lvl)
//          b4 = Sealed Dungeon/Tears of the Earth (+1 Lvl)
//          b5 =
//          b6 =
//          b7 =
// $105027: Progress Bitfield [bitflags] [8 bit]
//          ---------------------------
//          b0 = Lost Castle Fairy (+1 Lvl)
//          b1 = Sealed Dungeon Fairy
//          b2 = Fairy Grove Fairy (+1 Lvl)
//          b3 =
//          b4 = Kill Vampire (+1 Lvl)
//          b5 = Kill Mad Dragon
//          b6 =
//          b7 =
PROGRESS = 0x105026

function progress_graveyard() => bit(0, PROGRESS)
function progress_trialdungeon() => bit(1, PROGRESS)
function progress_ruins() => bit(2, PROGRESS)
function progress_volcano() => bit(3, PROGRESS)
function progress_sealeddungeon() => bit(4, PROGRESS)

function progress_lostcastle() => bit(8, PROGRESS)
function progress_fairygrove() => bit(10, PROGRESS)
function progress_vampire() => bit(12, PROGRESS)

function all_progress() => word(PROGRESS)

// $10502C: Current Score [32 bit, two 16-bit LE/BE mixed format]
function current_score() => dword_me(0x10502C)

// $105045: World Name [Char #1]
//          -----------------------
//          Mapping for all chars is as follows:
//          BCDFGHJKLMNPQRSTAIUEO VWXYZ.,&♂♀
// $105044: World Name [Char #2]
// $105047: World Name [Char #3]
// $105046: World Name [Char #4]
// $105049: World Name [Char #5]
// $105048: World Name [Char #6]
// $10504B: World Name [Char #7]
// $10504A: World Name [Char #8]
// $10504D: World Name [Char #9]
// $10504C: World Name [Char #10]
function world_name_char(i) => byte(0x105044 + 2 * (i / 2) + 1 - (i % 2))

// $10504F: [Equip] Accessory (Index into Inventory) [8 bit]
//          0xff = unequipped
function equip_accessory() => byte(0x10504F)

// $105051: [Equip] Shield (Index into Inventory) [8 bit]
//          0xff = unequipped
function equip_shield() => byte(0x105051)

// $10505C: Map ID [8 bit]
//          ---------------------------------
//          ff - [Menu / Out of Game]
//          00 = Field
//          01 = Field/Fairy Grove
//          02 = Graveyard
//          03 = Trial Dungeon
//          04 = Vampire's Mansion 1F
//          05 = Vampire's Mansion 2F
//          06 = Vampire's Mansion 3F
//          07 = Ruins
//          08 = Volcanic Cave
//          09 = Sealed Dungeon B1F
//          0a = Sealed Dungeon B2F
//          0b = Sealed Dungeon B3F
//          0c = Sealed Dungeon B4F
//          0d = Sealed Dungeon / Mage's
//          0e = Lost Castle / Edifice
//          0f = Lost Castle / Power Unit
//          10 = Lost Castle / Bottom
//          11 = Fortress of Varalys
//          12 = Fortress of Varalys
//          13 = Fortress of Varalys [Varalys' room only]
function map_id() => byte(0x10505C)

// $10505E: Difficulty [Current Game] [8 bit] (00 = Easy, 01 = Normal, 02 = Hard)
function difficulty() => byte(0x10505E)

// $105061: Current Time [Hours] [8 bit]
// $105060: Current Time [Minutes] [8 bit]
// $105063: Current Time [Seconds] [8 bit]
// $105062: Current Time [Frames] [8 bit]
function time_hrs() => byte(0x105061)
function time_min() => byte(0x105060)
function time_sec() => byte(0x105063)
function time_frm() => byte(0x105062)

function total_time() => 60 * (60 * (60 * time_hrs() + time_min()) + time_sec()) + time_frm()

// $10545B: Current Inventory Count (Max = 30?) [8 bit]
function inventory_count() => byte(0x10545B)

// $10545C: Start of Inventory Array (180 bytes, 6 bytes per object)
//          +0 | ?
//          +1 | id
//          +2 | ?
//          +3 | flags 1
//          .. 0x1 = curse
//          .. high 6 bits = +/- bonus
//          .. mapping is complex
//          +4 | flags 2
//          .. 0x1 = equipped
//          .. 0x8 = bonus identification
//          +5 | ?
INVENTORY_START = 0x10545C
function inventory_id(i) => byte(INVENTORY_START + (i * 6) + 1)

// $106102: [16 bit] Number of Monsters Killed
function monsters_killed() => word(0x106102)

// $106118: [Fortress of Varalys] Room Index [8 bit]
//          00 = Entrance
//          01 = Vampire Refight
//          02 = Vampire Dead / Secret Hallway
//          03 = Mage Refight
//          04 = Mage Dead / Door Open
//          05 = Trippy Hallway (Point of No Return)
//          06 = Varalys' Room
function varalys_progress() => byte(0x106118)

// $106128: [Sealed Dungeon] Submap # [8 bit]
//          ----------------------------------------------
//          0 = B1F
//          1 = B2F before minecart
//          2 = B2F after minecart
//          3 = B3F before minecart
//          4 = B3F after minecart
//          5 = B4F
//          6 = Mage's room
function sealed_dungeon_room() => byte(0x106128)

// $10B052: [16 bit] Unique Overlay Identifier
//          0x0414 = Field
//          0x0804 = Lost Castle
//          0x0ae0 = Title Screen*
//          0x3284 = Sealed Dungeon
//          0xa588 = Graveyard
//          0xbdc8 = Trial Dungeon
//          0xc810 = Vampire's Mansion
//          0xcc7c = Volcanic Cave
//          0xcea4 = Fortress of Varalys
//          0xde14 = Ruins
//          0xdfb0 = Ending Cutscene*
//          0xe5bc = Intro Cutscene/Game Over*
function overlay() => word(0x10B052)

// $1519D2: Shop Flag [8 bit]
//          01 = Category Menu
//          03 = Selecting an Item
//          07 = Confirm Purchase
function shop_flag() => byte(0x1519D2)

// $155470: [Fortress of Varalys] Current X coord
//          [32 bit, two 16-bit LE/BE mixed format]
// $155478: [Fortress of Varalys] Current Z coord
//          [32 bit, two 16-bit LE/BE mixed format]
function varalys_x() => word(0x155470)
function varalys_z() => word(0x155478)

// $19E11F: [8 bit] Game Over Menu Loading Trigger
//          0x00 = Game Over Screen Active
//          0xff = Now Loading
function game_over_active() => byte(0x19E11F)

// $19E563: Game Over Menu Identifier [8 bit]
//          0=Not Game Over
//          1=Continue/Load Game Countdown
//          2=Enter Name for Scoreboard
//          3=Show Hi-Score Rankings
function game_over_screen() => byte(0x19E563)

// $14BF36: [Field] In-Game Menu ID [8 bit]
//          00 = Main Menu
//          01 = Item
//          02 = Option
//          03 = Data
//          0a = Item Submenu
//          15 = Controls
//          16 = Screen
//          17 = Audio
//          2d = Save data
//          2e = Load data
//          2f = Quit game
//          64 = Item Help
//          c2 = Overwrite Save
//          cc/cd = Now Loading
//          dc = Color Bars
//          d6 = Thank you for playing.

// $14D3C2: Main Menu - Menu ID [8 bit]
//          00 - Main Menu
//          01 - Create new world
//          02 - Resume game
//          03 - Load game data
//          04 - Copy game data
//          05 - Delete game data
//          06 - View rankings
//          07 - Options
//          0a - Rolling a random world
//          0b - Input world code
//          0c - Confirm named world
//          0e - Loaded new world (unrelated to menu)
//          1e - Now loading
//          28 - Copy slot selection
//          29 - Copy confirmation
//          32 - Erase confirmation
//          46 - Difficulty selection
//          47 - Controls settings
//          48 - Screen settings
//          49 - Audio settings
//          52 - (Game Over) Score entry / Continue
//          6e - Confirm random world creation
//          d0 - Color bars (0x1d0 with next byte)
//          eb - Error (Copy game failed)
//          ed - Error (Resume game failed)
function main_menu_id() => byte(0x14D3C2)

// $15BE40: [Sealed Dungeon] Status Flags [bitflags] [8 bit]
//          b0 =
//          b1 = Poisoned
//          b2 = Paralyzed
//          b3 = Panicked
//          b4 =
//          b5 =
//          b6 =
//          b7 =
function status_sealed() => bit1(0x15BE40)

// $15BE54: [Sealed Dungeon] Current Z coord
//          [32 bit, two 16-bit LE/BE mixed format]
function sealed_z() => word(0x15BE54)

// --- MAIN DATA -------------------------------------------------------------------

STATUS_INTRO = 0x00
STATUS_CUTSCENE = 0x1f
STATUS_SETUP = 0x10
STATUS_INGAME = 0x02

DIFF_EASY = 0
DIFF_NORMAL = 1
DIFF_HARD = 2
DIFF_PRO = 3

OVERLAY_FIELD = 0
OVERLAY_LOST_CASTLE = 1
OVERLAY_SEALED_DUNGEON = 2
OVERLAY_GRAVEYARD = 3
OVERLAY_TRIAL_DUNGEON = 4
OVERLAY_VAMPIRE = 5
OVERLAY_VOLCANO = 6
OVERLAY_VARALYS = 7
OVERLAY_RUINS = 8

OVERLAYS =
[
	{"id": 0x0414, "menu": 0x14BF36, "hp": NULL, "name": "Field"},
	{"id": 0x0804, "menu": 0x14BBE6, "hp": 0x15946A, "bosshp": [0x1594CE,], "bosshpmax": 1000, "name": "Lost Castle"},
	{"id": 0x3284, "menu": 0x1505A6, "hp": 0x15BE46, "bosshp": [0x15BEAA,], "bosshpmax": 500, "name": "Sealed Dungeon"},
	{"id": 0xa588, "menu": 0x1473CA, "hp": NULL, "name": "Graveyard"},
	{"id": 0xbdc8, "menu": 0x1490EA, "hp": NULL, "name": "Trial Dungeon"},
	{"id": 0xc810, "menu": 0x14840A, "hp": 0x154E22, "bosshp": [0x154E86,], "bosshpmax": 800, "name": "Vampire's Mansion"},
	{"id": 0xcc7c, "menu": 0x148D86, "hp": 0x155EFA, "bosshp": [0x155FC2, 0x156026, 0x15608A], "bosshpmax": 800, "name": "Volcanic Cave"},
	{"id": 0xcea4, "menu": 0x14946A, "hp": 0x15546A, "name": "Fortress of Varalys"},
	{"id": 0xde14, "menu": 0x14B136, "hp": NULL, "name": "Ruins"},
]

OVERLAY_TITLE = 0x0ae0
OVERLAY_END = 0xdfb0
OVERLAY_INTRO = 0xe5bc

MENU_LOAD_DATA = 0x2e
MENU_NOW_LOADING = 0xcc
MENU_QUIT_GAME = 0xd6

MAIN_MENU_RANDOM_WORLD = 0x0a
MAIN_MENU_CONFIRM_NAME = 0x0c
MAIN_MENU_LOADED_WORLD = 0x0e

MAP_NONE = 0xff
MAP_FIELD = 0x00
MAP_FAIRY_GROVE = 0x01
MAP_GRAVEYARD = 0x02
MAP_TRIAL_DUNGEON = 0x03
MAP_VAMP_1F = 0x04
MAP_VAMP_2F = 0x05
MAP_VAMP_3F = 0x06
MAP_RUINS = 0x07
MAP_VOLCANO = 0x08
MAP_SEALED_DUNGEON_B1F = 0x09
MAP_SEALED_DUNGEON_B2F = 0x0a
MAP_SEALED_DUNGEON_B3F = 0x0b
MAP_SEALED_DUNGEON_B4F = 0x0c
MAP_SEALED_DUNGEON_MAGE = 0x0d
MAP_LOST_EDIFICE = 0x0e
MAP_LOST_POWERUNIT = 0x0f
MAP_LOST_BOTTOM = 0x10
MAP_VARALYS_1 = 0x11
MAP_VARALYS_2 = 0x12
MAP_VARALYS_BOSS = 0x13

ITEM_CRUCIFIX = 0x0f
ITEM_SPECTACLES = 0x20
ITEM_GEM_AMETHYST = 0x22
ITEM_GEM_RDIAMOND = 0x23
ITEM_GEM_EMERALD = 0x24
ITEM_MASTER_SWORD = 0x2E
ITEM_FAIRY_ARMOR = 0x03
ITEM_LIGHT_SWORD = 0x31

SCORE_THRESHOLD_LUCKY = 7777777
SCORE_THRESHOLD_LO = 100000
SCORE_THRESHOLD_HI = 874300

LTR2NUM = {}
NUM2LTR = {}
LETTERS = "BCDFGHJKLMNPQRSTAIUEO VWXYZ.,&♂♀"
for i in range(0, length(LETTERS)-1)
{
	LTR2NUM[substring(LETTERS, i, 1)] = i
	LTR2NUM[i] = substring(LETTERS, i, 1)
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function is_loading(x) => byte(x["menu"]) & 0xfe == MENU_NOW_LOADING //&& prev(byte(addr)) == MENU_LOAD_DATA

function overlay_is(x) => overlay() == OVERLAYS[x]["id"]

function currently_loading() => any_of(OVERLAYS, x => overlay() == x["id"] && is_loading(x))

function continue_load() => overlay() == OVERLAY_INTRO && prev(game_over_active()) == 0x00 && game_over_active() == 0xFF && game_over_slot() != 0

function playing_area(x) => prev(overlay_is(x)) && !is_loading(OVERLAYS[x])

function collected_item(x) => (
	// item count went up
	inventory_count() == 1 + prev(inventory_count()) && 

	// item in last slot is the item in question
	byte(INVENTORY_START + (inventory_count() - 1) * 6 + 1) == x && 

	// and that wasn't there before
	prev(byte(INVENTORY_START + (inventory_count() - 1) * 6 + 1)) != x
)

function boss_start(x) => (
	prev(word(OVERLAYS[x]["bosshp"][0])) != OVERLAYS[x]["bosshpmax"] && 
		 word(OVERLAYS[x]["bosshp"][0])  == OVERLAYS[x]["bosshpmax"]
)

function boss_dead(x) => all_of(OVERLAYS[x]["bosshp"], addr => word(addr) == 0)

function boss_take_damage(x) => any_of(OVERLAYS[x]["bosshp"], addr => word(addr) < prev(word(addr)))

function current_hp(x) => word(OVERLAYS[x]["hp"])

function take_damage(x) => current_hp(x) < prev(current_hp(x))

function equipped(slot, id) => slot < inventory_count() && inventory_id(slot) == id

function boss_fight_challenge(ovr, map) => (
	// ensure we are in the correct area
	playing_area(ovr) && prev(map_id()) == map &&

	// challenge start and trigger when dead
	once(boss_start(ovr)) && trigger_when(boss_dead(ovr)) &&

	// never leave the area
	never(!overlay_is(ovr)) && never(map_id() != map)
)

function win_the_game() => prev(in_game()) == 1 && prev(overlay_is(OVERLAY_VARALYS)) && overlay() == OVERLAY_END

function name_is(name) => all_of(range(0, length(name)-1), i => world_name_char(i) == LTR2NUM[substring(name, i, 1)])

function SECS(x) => x * 60
function MINS(x) => SECS(x) * 60
function HRS(x) => MINS(x) * 60

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

KILL_THRESHOLD_LO = 25
achievement(id=391192, badge="444761",
	title="This Isn't How You Level Up",
	description=format("Kill {0} enemies of any type", KILL_THRESHOLD_LO),
	points=2,
	trigger=(
		prev(in_game()) == 1 && !currently_loading() &&

		prev(monsters_killed()) < KILL_THRESHOLD_LO && measured(monsters_killed() >= KILL_THRESHOLD_LO)
	)
)

KILL_THRESHOLD_HI = 100
achievement(id=391193, badge="444762",
	title="Doing This Just for the Thrill",
	description=format("Kill {0} enemies of any type", KILL_THRESHOLD_HI),
	points=4,
	trigger=(
		prev(in_game()) == 1 && !currently_loading() &&

		prev(monsters_killed()) < KILL_THRESHOLD_HI && measured(monsters_killed() >= KILL_THRESHOLD_HI)
	)
)

achievement(id=383283, badge="441731",
	title="Jim the Exorcist",
	description="Obtain the Crucifix from the Graveyard",
	points=5,
	trigger=playing_area(OVERLAY_GRAVEYARD) && progress_graveyard() > prev(progress_graveyard())
)

achievement(id=383290, badge="441732",
	title="The Righteous Jimstones - Amethyst",
	description="Obtain the Amethyst from the Graveyard",
	points=5,
	trigger=playing_area(OVERLAY_GRAVEYARD) && collected_item(ITEM_GEM_AMETHYST)
)

achievement(id=383284, badge="441733",
	title="Mankind Ill Needs a Savior Such as You",
	description="Defeat the Vampire in the Mansion",
	points=5,
	trigger=playing_area(OVERLAY_VAMPIRE) && progress_vampire() > prev(progress_vampire())
)

achievement(id=383285, badge="441734",
	title="?yddaC ruoY s'ohW",
	description="Defeat the Vampire in the Mansion without taking damage on Hard difficulty or higher",
	points=10,
	type="missable",
	trigger=boss_fight_challenge(OVERLAY_VAMPIRE, MAP_VAMP_3F) && difficulty() >= DIFF_HARD && never(take_damage(OVERLAY_VAMPIRE))
)

achievement(id=391072, badge="446287",
	title="Say Your Prayers",
	description="Defeat the Vampire in the Mansion without the Crucifix equipped",
	points=10,
	type="missable",
	trigger=boss_fight_challenge(OVERLAY_VAMPIRE, MAP_VAMP_3F) && never(boss_take_damage(OVERLAY_VAMPIRE) && equipped(equip_accessory(), ITEM_CRUCIFIX))
)

achievement(id=383286, badge="441735",
	title="Rose-Colored Glasses",
	description="Obtain the Spectacles from the Trial Dungeon",
	points=5,
	trigger=playing_area(OVERLAY_TRIAL_DUNGEON) && progress_trialdungeon() > prev(progress_trialdungeon())
)

achievement(id=383287, badge="441736",
	title="The Sign Kinda Gave It Away",
	description="Enter the Ruins while not wearing the Spectacles of Truth",
	points=5,
	trigger=(
		// just came from the field, not from loading
		prior(overlay_is(OVERLAY_FIELD)) && !is_loading(OVERLAYS[OVERLAY_FIELD]) &&
		
		// this is a transition from the field to the ruins
		// map change happens after overlay change
		prev(map_id()) == MAP_FIELD && map_id() == MAP_RUINS &&

		// spectacles not equipped
		!equipped(equip_accessory(), ITEM_SPECTACLES)
	)
)

achievement(id=383288, badge="441737",
	title="Flame On!",
	description="Obtain the Flame Amulet from the Ruins",
	points=5,
	type="progression",
	trigger=playing_area(OVERLAY_RUINS) && progress_ruins() > prev(progress_ruins())
)

achievement(id=383294, badge="441738",
	title="Welcome to Warp Zone",
	description="Obtain the Flute of Zaldis from the Volcanic Cave",
	points=5,
	type="progression",
	trigger=playing_area(OVERLAY_VOLCANO) && progress_volcano() > prev(progress_volcano())
)

achievement(id=383301, badge="441739",
	title="Overcoming the 3v1 Odds",
	description="Defeat the Mad Dragon without taking damage on Hard difficulty or higher",
	points=10,
	type="missable",
	trigger=boss_fight_challenge(OVERLAY_VOLCANO, MAP_VOLCANO) && difficulty() >= DIFF_HARD && never(take_damage(OVERLAY_VOLCANO))
)

achievement(id=383302, badge="441740",
	title="Just Keep Moving",
	description="Defeat the Mad Dragon without equipping a shield",
	points=25,
	type="missable",
	trigger=(
		// ensure we are in the correct area
		playing_area(OVERLAY_VOLCANO) && prev(map_id()) == MAP_VOLCANO &&

		// challenge start and trigger when dead
		once(boss_start(OVERLAY_VOLCANO)) && trigger_when(boss_dead(OVERLAY_VOLCANO)) &&

		// never leave the area
		never(!overlay_is(OVERLAY_VOLCANO)) && never(map_id() != MAP_VOLCANO) &&
		
		// never equip a shield
		never(equip_shield() < inventory_count())
	)
)

achievement(id=383291, badge="441741",
	title="The Righteous Jimstones - Red Diamond",
	description="Obtain the Red Diamond from the Volcanic Caves",
	points=5,
	trigger=playing_area(OVERLAY_VOLCANO) && collected_item(ITEM_GEM_RDIAMOND)
)

achievement(id=383297, badge="441743",
	title="50-50 + Nosegrab + Dungeon Gap",
	description="Prove that Jim weighs less than a housecat by jumping the gnarly gap in the B3F minecart in the Sealed Dungeon",
	points=3,
	trigger=(
		// ensure we are in the correct area
		overlay_is(OVERLAY_SEALED_DUNGEON) && playing_area(OVERLAY_SEALED_DUNGEON) &&
		
		// on the correct floor
		prev(map_id()) == MAP_SEALED_DUNGEON_B3F && map_id() == MAP_SEALED_DUNGEON_B3F &&

		// in the correct room
		prev(sealed_dungeon_room()) == 3 &&

		// either we make the jump, or made it into the next map (as a backup)
		(sealed_dungeon_room() == 4 || (sealed_z() >= 349 && prev(sealed_z()) < 349 && prev(sealed_z()) > 320))
	)
)

achievement(id=383295, badge="441744",
	title="The Biggest Mosquito You've Ever Seen",
	description="Obtain the Tears of the Earth and the Fairy from the Sealed Dungeon",
	points=5,
	type="progression",
	trigger=playing_area(OVERLAY_SEALED_DUNGEON) && progress_sealeddungeon() > prev(progress_sealeddungeon())
)

achievement(id=383306, badge="441745",
	title="Da-MAGE-less",
	description="Defeat the Evil Mage in the Sealed Dungeon without taking damage on Hard difficulty or higher",
	points=10,
	type="missable",
	trigger=boss_fight_challenge(OVERLAY_SEALED_DUNGEON, MAP_SEALED_DUNGEON_MAGE) && difficulty() >= DIFF_HARD && never(take_damage(OVERLAY_SEALED_DUNGEON))
)

achievement(id=391189, badge="442257",
	title="I'm in a Bit of a Hurry Here!",
	description="Defeat the Evil Mage in the Sealed Dungeon while poisoned the entire time (must enter the room poisoned)",
	points=10,
	type="missable",
	trigger=boss_fight_challenge(OVERLAY_SEALED_DUNGEON, MAP_SEALED_DUNGEON_MAGE) && never(status_sealed() != 1)
)

achievement(id=384373, badge="441746",
	title="Unsinking the Lost Castle",
	description="Discover the Secret of the Lost Castle",
	points=5,
	type="progression",
	trigger=(
		// just came from the field, not from loading
		prior(overlay_is(OVERLAY_FIELD)) && !is_loading(OVERLAYS[OVERLAY_FIELD]) &&
		
		// this is a transition from the field to the ruins
		// map change happens after overlay change
		prev(map_id()) == MAP_FIELD && map_id() == MAP_LOST_EDIFICE
	)
)

achievement(id=383300, badge="441747",
	title="It's a Load-Bearing Eel",
	description="Defeat the Eel boss and Obtain the Fairy in the Lost Castle",
	points=5,
	type="progression",
	trigger=playing_area(OVERLAY_LOST_CASTLE) && progress_lostcastle() > prev(progress_lostcastle())
)

achievement(id=383303, badge="441748",
	title="That's a Moray!",
	description="Defeat the Eel boss without taking damage on Hard difficulty or higher",
	points=10,
	trigger=boss_fight_challenge(OVERLAY_LOST_CASTLE, MAP_LOST_BOTTOM) && difficulty() >= DIFF_HARD && never(take_damage(OVERLAY_LOST_CASTLE))
)

achievement(id=383292, badge="441749",
	title="The Righteous Jimstones - Emerald",
	description="Obtain the Emerald from the Lost Castle",
	points=5,
	type="missable",
	trigger=playing_area(OVERLAY_LOST_CASTLE) && collected_item(ITEM_GEM_EMERALD)
)

achievement(id=383282, badge="441750",
	title="Answering the Fairy Phone",
	description="Obtain the Fairy from the Fairy Grove",
	points=5,
	type="progression",
	trigger=playing_area(OVERLAY_FIELD) && progress_fairygrove() > prev(progress_fairygrove())
)

achievement(id=383296, badge="443118",
	title="Discovering Varalys' Secret Stash",
	description="\"Hey, that's not yours! Leave that stuff alone!\" - Varalys, probably",
	points=5,
	trigger=prev(overlay_is(OVERLAY_VARALYS)) && varalys_z() >= 43 && varalys_z() <= 97 && (varalys_x() > 4 || varalys_x() < 2)
)

achievement(id=383304, badge="441751",
	title="Jim the Hero",
	description="Defeat Varalys, rescue Princess Iina, and save Fairy Land",
	points=25,
	type="win_condition",
	trigger=win_the_game()
)

achievement(id=383305, badge="441752",
	title="Who Needs Immortal Medicine?",
	description="Defeat Varalys without taking damage on Hard difficulty or higher",
	points=25,
	trigger=(
		// entered the varalys fight
		once(overlay_is(OVERLAY_VARALYS) && prev(varalys_progress()) == 5 && varalys_progress() == 6) &&

		// correct difficulty
		difficulty() >= DIFF_HARD &&

		// trigger on the end screen
		trigger_when(prev(overlay_is(OVERLAY_VARALYS)) && overlay() == OVERLAY_END) &&

		// reset when taking damage
		never(take_damage(OVERLAY_VARALYS)) &&

		// reset if leaving area
		never(varalys_progress() != 6) && //never(prev(!overlay_is(OVERLAY_VARALYS))) &&

		// reset if loading
		never(is_loading(OVERLAYS[OVERLAY_VARALYS]))
	)
)

achievement(id=383289, badge="443117",
	title="Ignoring the Adventure Line",
	description="Obtain the Flame Amulet while Level 1",
	points=10,
	type="missable",
	trigger=(
		// in the ruins
		playing_area(OVERLAY_RUINS) && prev(map_id()) == MAP_RUINS && 
		
		// collecting the flame amulet when there was no previous progress
		prev(all_progress()) == 0 && progress_ruins() == 1
	)
)

achievement(id=383298, badge="441754",
	title="The Hero of Hyrule",
	description="Obtain the Master Sword",
	points=5,
	trigger=collected_item(ITEM_MASTER_SWORD)
)

achievement(id=383299, badge="441755",
	title="Feels Like I'm Wearing Nothing at All!",
	description="Obtain the Fairy Armor",
	points=10,
	trigger=collected_item(ITEM_FAIRY_ARMOR)
)

achievement(id=383307, badge="441756",
	title="Feel the Force! Powerful You Have Become",
	description="Obtain the Sword of Light",
	points=10,
	trigger=collected_item(ITEM_LIGHT_SWORD)
)

achievement(id=383309, badge="441757",
	title="Saving Fairy Land the Hard Way",
	description="Beat the game on Hard difficulty or higher",
	points=25,
	trigger=win_the_game() && difficulty() >= DIFF_HARD
)

achievement(id=391191, badge="442275",
	title="Feeling Lucky?",
	description=format("Earn {0} or more points in the final score tally", commas(SCORE_THRESHOLD_LUCKY)),
	points=25,
	trigger=(
		// in the end game scene, final account
		overlay() == OVERLAY_END &&

		// check that the final score tally has reached line 6
		repeated(6, 1 + prev(ending_index()) == ending_index()) &&
		
		// confirm line 6 is active for at least 5f (handling memory flickering)
		repeated(5, ending_index() == 6) &&

		// final score is above 7,777,777
		final_score() >= SCORE_THRESHOLD_LUCKY &&

		// reset hitcounts if memory flickers
		never(ending_index() > 6)
	)
)

achievement(id=383293, badge="441759",
	title="Shop Smart, Shop S-Mart",
	description="Buy Something from the Shop, Won't Ya?",
	points=5,
	trigger=(
		// in the shop in the field
		playing_area(OVERLAY_FIELD) && shop_flag() == 7 &&

		// money goes down
		current_score() < prev(current_score()) &&

		// when inventory count goes up
		inventory_count() == 1 + prev(inventory_count())
	)
)

achievement(id=384202, badge="441760",
	title="It Is Now Safe to Power Off Your Emulator",
	description="Quit the Game from the In-Game Menu",
	points=1,
	trigger=(
		// currently in-game
		status() == STATUS_INGAME &&

		// selected quit game from the menu
		any_of(OVERLAYS, x => overlay() == x["id"] && byte(x["menu"]) == MENU_QUIT_GAME)
	)
)

achievement(id=391138, badge="442258",
	title="Better than Naito",
	description=format("Earn the top spot on the hi-score table by earning more than {0} points before the end of the game", commas(SCORE_THRESHOLD_LO)),
	points=5,
	trigger=(
		prev(in_game()) == 1 && !currently_loading() &&
		
		current_score() > SCORE_THRESHOLD_LO && prev(current_score()) <= SCORE_THRESHOLD_LO
	)
)

achievement(id=391139, badge="442259",
	title="Better than Billy",
	description=format("Earn more than {0} points legitimately before the end of the game", commas(SCORE_THRESHOLD_HI)),
	points=10,
	trigger=(
		prev(in_game()) == 1 && !currently_loading() &&
		
		current_score() > SCORE_THRESHOLD_HI && prev(current_score()) <= SCORE_THRESHOLD_HI
	)
)

achievement(id=391767, badge="443555",
	title="RETROACHEV Speedrun Challenge",
	description="In one session, start a game with the set seed RETROACHEV on any difficulty and beat the game in less than 60 minutes without loading a save",
	points=50,
	trigger=(
		// checkpoint hit: set seed game was started
		once(prev(main_menu_id()) == MAIN_MENU_CONFIRM_NAME && main_menu_id() == MAIN_MENU_LOADED_WORLD) &&

		// checkpoint hit: game started
		once(prev(status()) == STATUS_SETUP && status() == STATUS_INGAME) &&

		// checkpoint hit: start of game (0 time and no progress)
		once(all_progress() == 0) && once(total_time() == 0) &&

		// correct world name
		name_is("RETROACHEV") &&

		// within the time goal
		total_time() < HRS(1) &&

		// trigger on completing the game
		trigger_when(win_the_game()) &&

		// reset on loading a game or leaving the game
		never(currently_loading()) && never(continue_load()) && never(overlay() == OVERLAY_TITLE)
	)
	
	//	never((repeated(3, overlay() == 2052) && prev(menu_lcastle()) == 46 &&
	//		menu_lcastle() == 204) || menu_lcastle() == 205)
)

/*

achievement(id=384133, badge="441758",
	title="[VOID] Jim the Immortal Knight",
	description="In one session, start a game with a random seed on Normal difficulty or higher and beat the game without dying or loading a save",
	points=0,
	trigger=once(prev(overlay()) == 2784 && prev(main_menu_id()) == 10 &&
				  overlay() != 2784
			  ) && once(prev(status()) == 16 && status() == 2) &&
			  once(once(progress_bitfield_8_bit() == 0) && progress_bitfield_8_bit() == 0) &&
			  once((time_hrs() * 216000 + time_min() * 3600 +
				  time_sec() * 60 + time_frm()) == 0
			  ) && difficulty() >= 1 &&
			  trigger_when(prev(overlay()) == 52900) &&
			  trigger_when(overlay() == 57264) && never(overlay() == 58812) &&
			  (always_false() || ((overlay() != 1044 || prev(menu_field()) != 46 ||
				menu_field() != 204) && menu_field() != 205 &&
				(overlay() != 2052 || prev(menu_lcastle()) != 46 ||
				menu_lcastle() != 204) && menu_lcastle() != 205 &&
				(overlay() != 12932 || prev(menu_sealedd()) != 46 ||
				menu_sealedd() != 204) && menu_sealedd() != 205 &&
				(overlay() != 42376 || prev(menu_graveyard()) != 46 ||
				menu_graveyard() != 204) && menu_graveyard() != 205 &&
				(overlay() != 48584 || prev(menu_triald()) != 46 ||
				menu_triald() != 204) && menu_triald() != 205 &&
				(overlay() != 52900 || prev(menu_varalys()) != 46 ||
				menu_varalys() != 204) &&
				menu_varalys() != 205 &&
				(overlay() != 51216 || prev(menu_vampire()) != 46 ||
				menu_vampire() != 204) && menu_vampire() != 205 &&
				(overlay() != 52348 || prev(menu_volcano()) != 46 ||
				menu_volcano() != 204) && menu_volcano() != 205 &&
				(overlay() != 56852 || prev(menu_ruins()) != 46 ||
				menu_ruins() != 204) && menu_ruins() != 205))
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	id = 85356, title = "Fastest Clear (Easy Difficulty, Random Seed)",
	description = "In one session, start a game with a random seed and beat the game without loading a save",
	start  = difficulty() == 0 && prev(main_menu_id()) == 10 &&
			 main_menu_id() == 14,
	cancel = ((overlay() == 1044 && prev(menu_field()) == 46 &&
			   (menu_field() == 204 || menu_field() == 205)) ||
			  (overlay() == 2052 && prev(menu_lcastle()) == 46 &&
			   (menu_lcastle() == 204 || menu_lcastle() == 205)) ||
			  (overlay() == 12932 && prev(menu_sealedd()) == 46 &&
			   (menu_sealedd() == 204 || menu_sealedd() == 205)) ||
			  (overlay() == 42376 && prev(menu_graveyard()) == 46 &&
			   (menu_graveyard() == 204 || menu_graveyard() == 205)) ||
			  (overlay() == 48584 && prev(menu_triald()) == 46 &&
			   (menu_triald() == 204 || menu_triald() == 205)) ||
			  (overlay() == 52900 && prev(menu_varalys()) == 46 &&
			   (menu_varalys() == 204 || menu_varalys() == 205)) ||
			  (overlay() == 51216 && prev(menu_vampire()) == 46 &&
			   (menu_vampire() == 204 || menu_vampire() == 205)) ||
			  (overlay() == 52348 && prev(menu_volcano()) == 46 &&
			   (menu_volcano() == 204 || menu_volcano() == 205)) ||
			  (overlay() == 56852 && prev(menu_ruins()) == 46 &&
			   (menu_ruins() == 204 || menu_ruins() == 205)) ||
			  (overlay() == 58812 && game_over_screen() == 1 &&
			   prev(game_over_active()) == 0 && game_over_active() == 255 &&
			   game_over_slot() != 0) ||
			  (overlay() == 2784)),
	submit = prev(overlay()) == 52900 && overlay() == 57264,
	value  = measured((time_hrs() * 216000 + time_min() * 3600 +
				 time_sec() * 60 + time_frm())
			 ),
	format = "FRAMES"
)

leaderboard(
	id = 85357, title = "Fastest Clear (Normal Difficulty, Random Seed)",
	description = "In one session, start a game with a random seed and beat the game without loading a save",
	start  = difficulty() == 1 && prev(main_menu_id()) == 10 &&
			 main_menu_id() == 14,
	cancel = ((overlay() == 1044 && prev(menu_field()) == 46 &&
			   (menu_field() == 204 || menu_field() == 205)) ||
			  (overlay() == 2052 && prev(menu_lcastle()) == 46 &&
			   (menu_lcastle() == 204 || menu_lcastle() == 205)) ||
			  (overlay() == 12932 && prev(menu_sealedd()) == 46 &&
			   (menu_sealedd() == 204 || menu_sealedd() == 205)) ||
			  (overlay() == 42376 && prev(menu_graveyard()) == 46 &&
			   (menu_graveyard() == 204 || menu_graveyard() == 205)) ||
			  (overlay() == 48584 && prev(menu_triald()) == 46 &&
			   (menu_triald() == 204 || menu_triald() == 205)) ||
			  (overlay() == 52900 && prev(menu_varalys()) == 46 &&
			   (menu_varalys() == 204 || menu_varalys() == 205)) ||
			  (overlay() == 51216 && prev(menu_vampire()) == 46 &&
			   (menu_vampire() == 204 || menu_vampire() == 205)) ||
			  (overlay() == 52348 && prev(menu_volcano()) == 46 &&
			   (menu_volcano() == 204 || menu_volcano() == 205)) ||
			  (overlay() == 56852 && prev(menu_ruins()) == 46 &&
			   (menu_ruins() == 204 || menu_ruins() == 205)) ||
			  (overlay() == 58812 && game_over_screen() == 1 &&
			   prev(game_over_active()) == 0 && game_over_active() == 255 &&
			   game_over_slot() != 0) ||
			  (overlay() == 2784)),
	submit = prev(overlay()) == 52900 && overlay() == 57264,
	value  = measured((time_hrs() * 216000 + time_min() * 3600 +
				 time_sec() * 60 + time_frm())
			 ),
	format = "FRAMES"
)

leaderboard(
	id = 85358, title = "Fastest Clear (Hard Difficulty, Random Seed)",
	description = "In one session, start a game with a random seed and beat the game without loading a save",
	start  = difficulty() == 2 && prev(main_menu_id()) == 10 &&
			 main_menu_id() == 14,
	cancel = ((overlay() == 1044 && prev(menu_field()) == 46 &&
			   (menu_field() == 204 || menu_field() == 205)) ||
			  (overlay() == 2052 && prev(menu_lcastle()) == 46 &&
			   (menu_lcastle() == 204 || menu_lcastle() == 205)) ||
			  (overlay() == 12932 && prev(menu_sealedd()) == 46 &&
			   (menu_sealedd() == 204 || menu_sealedd() == 205)) ||
			  (overlay() == 42376 && prev(menu_graveyard()) == 46 &&
			   (menu_graveyard() == 204 || menu_graveyard() == 205)) ||
			  (overlay() == 48584 && prev(menu_triald()) == 46 &&
			   (menu_triald() == 204 || menu_triald() == 205)) ||
			  (overlay() == 52900 && prev(menu_varalys()) == 46 &&
			   (menu_varalys() == 204 || menu_varalys() == 205)) ||
			  (overlay() == 51216 && prev(menu_vampire()) == 46 &&
			   (menu_vampire() == 204 || menu_vampire() == 205)) ||
			  (overlay() == 52348 && prev(menu_volcano()) == 46 &&
			   (menu_volcano() == 204 || menu_volcano() == 205)) ||
			  (overlay() == 56852 && prev(menu_ruins()) == 46 &&
			   (menu_ruins() == 204 || menu_ruins() == 205)) ||
			  (overlay() == 58812 && game_over_screen() == 1 &&
			   prev(game_over_active()) == 0 && game_over_active() == 255 &&
			   game_over_slot() != 0) ||
			  (overlay() == 2784)),
	submit = prev(overlay()) == 52900 && overlay() == 57264,
	value  = measured((time_hrs() * 216000 + time_min() * 3600 +
				 time_sec() * 60 + time_frm())
			 ),
	format = "FRAMES"
)

leaderboard(
	id = 85359, title = "Fastest Clear (PRO Difficulty, Random Seed)",
	description = "In one session, start a game with a random seed and beat the game without loading a save",
	start  = difficulty() == 3 && prev(main_menu_id()) == 10 &&
			 main_menu_id() == 14,
	cancel = ((overlay() == 1044 && prev(menu_field()) == 46 &&
			   (menu_field() == 204 || menu_field() == 205)) ||
			  (overlay() == 2052 && prev(menu_lcastle()) == 46 &&
			   (menu_lcastle() == 204 || menu_lcastle() == 205)) ||
			  (overlay() == 12932 && prev(menu_sealedd()) == 46 &&
			   (menu_sealedd() == 204 || menu_sealedd() == 205)) ||
			  (overlay() == 42376 && prev(menu_graveyard()) == 46 &&
			   (menu_graveyard() == 204 || menu_graveyard() == 205)) ||
			  (overlay() == 48584 && prev(menu_triald()) == 46 &&
			   (menu_triald() == 204 || menu_triald() == 205)) ||
			  (overlay() == 52900 && prev(menu_varalys()) == 46 &&
			   (menu_varalys() == 204 || menu_varalys() == 205)) ||
			  (overlay() == 51216 && prev(menu_vampire()) == 46 &&
			   (menu_vampire() == 204 || menu_vampire() == 205)) ||
			  (overlay() == 52348 && prev(menu_volcano()) == 46 &&
			   (menu_volcano() == 204 || menu_volcano() == 205)) ||
			  (overlay() == 56852 && prev(menu_ruins()) == 46 &&
			   (menu_ruins() == 204 || menu_ruins() == 205)) ||
			  (overlay() == 58812 && game_over_screen() == 1 &&
			   prev(game_over_active()) == 0 && game_over_active() == 255 &&
			   game_over_slot() != 0) ||
			  (overlay() == 2784)),
	submit = prev(overlay()) == 52900 && overlay() == 57264,
	value  = measured((time_hrs() * 216000 + time_min() * 3600 +
				 time_sec() * 60 + time_frm())
			 ),
	format = "FRAMES"
)

leaderboard(
	id = 87597, title = "RETROACHEV Speedrun (Any Difficulty, Set Seed)",
	description = "In one session, start a game with the set seed RETROACHEV and beat the game on any difficulty without loading a save",
	start  = prev(main_menu_id()) == 12 && main_menu_id() == 14 && world_name_char_1() == 13 &&
			 world_name_char_2() == 19 && world_name_char_3() == 15 && world_name_char_4() == 13 &&
			 world_name_char_5() == 20 && world_name_char_6() == 16 && world_name_char_7() == 1 &&
			 world_name_char_8() == 5 && world_name_char_9() == 19 && world_name_char_10() == 22,
	cancel = ((overlay() == 1044 && prev(menu_field()) == 46 &&
			   (menu_field() == 204 || menu_field() == 205)) ||
			  (overlay() == 2052 && prev(menu_lcastle()) == 46 &&
			   (menu_lcastle() == 204 || menu_lcastle() == 205)) ||
			  (overlay() == 12932 && prev(menu_sealedd()) == 46 &&
			   (menu_sealedd() == 204 || menu_sealedd() == 205)) ||
			  (overlay() == 42376 && prev(menu_graveyard()) == 46 &&
			   (menu_graveyard() == 204 || menu_graveyard() == 205)) ||
			  (overlay() == 48584 && prev(menu_triald()) == 46 &&
			   (menu_triald() == 204 || menu_triald() == 205)) ||
			  (overlay() == 52900 && prev(menu_varalys()) == 46 &&
			   (menu_varalys() == 204 || menu_varalys() == 205)) ||
			  (overlay() == 51216 && prev(menu_vampire()) == 46 &&
			   (menu_vampire() == 204 || menu_vampire() == 205)) ||
			  (overlay() == 52348 && prev(menu_volcano()) == 46 &&
			   (menu_volcano() == 204 || menu_volcano() == 205)) ||
			  (overlay() == 56852 && prev(menu_ruins()) == 46 &&
			   (menu_ruins() == 204 || menu_ruins() == 205)) ||
			  (overlay() == 58812 && game_over_screen() == 1 &&
			   prev(game_over_active()) == 0 && game_over_active() == 255 &&
			   game_over_slot() != 0) ||
			  (overlay() == 2784)),
	submit = prev(overlay()) == 52900 && overlay() == 57264,
	value  = measured((time_hrs() * 216000 + time_min() * 3600 +
				 time_sec() * 60 + time_frm())
			 ),
	format = "FRAMES"
)

leaderboard(
	id = 87495, title = "Highest Score",
	description = "Earn the highest score possible in the post-game score tally",
	start  = overlay() == 57264 &&
			 repeated(6, (1 + prev(ending_index())) == ending_index()) &&
			 repeated(5, ending_index() == 6) && never(ending_index() > 6),
	cancel = ending_index() != 6,
	submit = repeated(5, ending_index() == 6),
	value  = measured(final_score()),
	format = "VALUE"
)
*/