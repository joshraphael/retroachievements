// Super Cooks
// #ID = 32666

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $0800: Tiles on Screen [768 bytes]
//        32 tiles per row, 24 rows
// $09AB: Bottom Right of "Munch" Sugar Cube (13, 11)
function screen_tiles(r, c) => byte(0x000800 + 0x20*r + c)

// $0B01: Map Type [8 bit]
//        0 = Talking Cave/Paused
//        1 = Overworld
//        2 = Side Platformer
//        4 = Talk Bubble/Box
//        5 = Boss Arena
function map_type() => byte(0x000B01)

// $0B02: Current Zone Width [8 bit]
// $0B03: Current Zone Height [8 bit]
function current_zone_width() => byte(0x000B02)
function current_zone_height() => byte(0x000B03)

// $0B04: Overworld Screen ID [8 bit] row-major
function screen_id() => byte(0x000B04)

// $0B10: Player X Position [8 bit]
// $0B11: Player Y Position [8 bit]
function player_x_position() => byte(0x000B10)
function player_y_position() => byte(0x000B11)

// $0B2F: Number of Enemies Killed in Current Room [8 bit]
function enemies_killed() => byte(0x000B2F)

// $0F00: Weapon - Fry Pan [8 bit] (0/1)
function has_fry_pan() => byte(0x000F00)

// $0F01: Weapon - Salt & Pepper [8 bit] (0/1)
//        screen=1,0x1c
//        loc_check(1, 0x1c)
function has_salt_pepper() => byte(0x000F01)

// $0F02: Weapon - Knife [8 bit] (0/1)
//        screen=
function has_knife() => byte(0x000F02)

// $0F03: Weapon - Fire [8 bit] (0/1)
//        screen=3,0x0a
//        loc_check(3, 0x0a)
function has_fire() => byte(0x000F03)

// $0F04: Upgrade - Fry Pan [8 bit] (0/1)
//        screen=0,0x08
//        loc_check(0, 0x08)
function upgrade_fry_pan() => byte(0x000F04)

// $0F05: Upgrade - Salt & Pepper [8 bit] (0/1)
//        screen=1,0x0f
//        loc_check(1, 0x0f)
function upgrade_salt_pepper() => byte(0x000F05)

// $0F06: Upgrade - Knife [8 bit] (0/1)
//        screen=2,0x14
//        loc_check(2, 0x14)
function upgrade_knife() => byte(0x000F06)

// $0F07: Upgrade - Fire [8 bit] (0/1)
//        screen=3,0x0c
//        loc_check(3, 0x0c)
function upgrade_fire() => byte(0x000F07)

// $0F09: Item - Key to Pyramid [8 bit] (0/1)
//        screen=
function has_key_to_pyramid() => byte(0x000F09)

// $0F0C: Item - Canned Spinach [8 bit] (0/1)
//        screen=1,0x10
//        loc_check(1, 0x10)
function has_canned_spinach() => byte(0x000F0C)

// $0F0E: Item - Guild Membership Card [8 bit] (0/1)
//        screen=2,0x1f
//        loc_check(2, 0x1f)
function has_guild_membership_card() => byte(0x000F0E)

// $0F0F: Item - Guild Apron [8 bit] (0/1)
//        screen=2,0x13
//        loc_check(2, 0x13)
function has_guild_apron() => byte(0x000F0F)

// $0F10: Item - Guild Treasure Box [8 bit] (0/1)
//        screen=2,0x22
//        loc_check(2, 0x22)
function has_guild_treasure_box() => byte(0x000F10)

// $0F11: Item - Bung [8 bit] (0/1)
//        walk on water
//        screen=2,0x16
//        loc_check(2, 0x16)
function has_bung() => byte(0x000F11)

// $0F15: Item - Coat [8 bit] (0/1)
//        screen=3,0x19
//        loc_check(3, 0x19)
function has_coat() => byte(0x000F15)

// $0F16: Item - Spatula [8 bit] (0/1)
//        crush sugar with fry pan
//        screen=4,0x16
//        loc_check(4, 0x16)
function has_spatula() => byte(0x000F16)

// $0F17: Item - Grip Pot [8 bit] (0/1)
//        screen=4,0x10
//        loc_check(4, 0x10)
function has_grip_pot() => byte(0x000F17)

// $0F18: Item - Santa's Cake [8 bit] (0/1)
//        screen=4,0x26
//        loc_check(4, 0x26)
function has_cake() => byte(0x000F18)

// $0F19: Item - Santa's Contact Lenses [8 bit] (0/1)
//        screen=4,0x19
//        loc_check(4, 0x19)
function has_contact_lenses() => byte(0x000F19)

// $0F1A: Item - Door Key [8 bit] (0/1)
//        screen=4,0x12
//        loc_check(4, 0x12)
function has_door_key() => byte(0x000F1A)

// $0F1B: Event - English Language Learned [8 bit] (0/1)
//        screen=1,0x1a
//        loc_check(1, 0x1a)
function english_language_learned() => byte(0x000F1B)

// $0F1C: Event - Chinese Language Learned [8 bit] (0/1)
//        screen=3,0x1d
//        loc_check(3, 0x1d)
function chinese_language_learned() => byte(0x000F1C)

// $0F1D: Diploma Count [8 bit] (max=4)
function diploma_count() => byte(0x000F1D)

// $0F1E: Start of Potions & Cookbooks
function has_upgrade(i) => byte(0x000F1E + i)

// $0F80: Current Zone [8 bit]
//        all areas are part of Kitchenland
//        
//        0 = Cooking School
//        1 = Carrot Farms (Fresh Food)
//        2 = Sushi Swamp (Sushi)
//        3 = Tempura Town (China, Fried Food)
//        4 = Candyland (Dessert)
//        5 = (Ending Cutscenes)
function current_zone() => byte(0x000F80)

// $0F9D: Health Max [16 bit BCD]
function health_max() => bcd(word(0x000F9D))

// $0FA1: Health [16 bit BCD]
function health() => bcd(word(0x000FA1))

// $0FA5: Dish Max [24 bit BCD]
function dish_max() => bcd(tbyte(0x000FA5))

// $0FAB: Dish [24 bit BCD]
function dish() => bcd(tbyte(0x000FAB))

// $0FB1: Boss #1 Mandarin Killed [8 bit] (0/1)
// $0FB2: Boss #2 Corn Killed [8 bit] (0/1)
// $0FB3: Boss #3 Octopus Killed [8 bit] (0/1)
// $0FB4: Boss #4 Shumai Killed [8 bit] (0/1)
// $0FB5: Boss #5 Golvellius Killed [8 bit] (0/1)
function boss_killed(i) => byte(0x000FB1 + i)

// $0FB8: Cookbook Count [8 bit]
function cookbook_count() => byte(0x000FB8)

// $0FB9: Selected Weapon [8 bit]
//        0 = Fry Pan
//        1 = Salt & Pepper
//        2 = Knife
//        3 = Fire
function selected_weapon() => byte(0x000FB9)

// $0FBA: Event - Zone 0 Pyramid Revealed [8 bit] (0/1)
//        screen=0,0x07
//        loc_check(0, 0x07)
function event_revealed_pyramid() => byte(0x000FBA)

// $0FBB: Event - Zone 1 Peppered Man [8 bit] (0/1)
//        screen=1,0x0e
//        loc_check(1, 0x0e)
function event_pepper_man() => byte(0x000FBB)

// $0FBC: Event - Zone 1 Peppered Tree [8 bit] (0/1)
//        screen=1,0x0f
//        loc_check(1, 0x0f)
function event_pepper_tree() => byte(0x000FBC)

// $0FBE: Event - Flaming Statue Comes Down [8 bit] (0/1)
//        screen=3,0x0a
//        loc_check(3, 0x0a)
function event_flaming_statue() => byte(0x000FBE)

// $0FC1: Event - Zone 3 Magician Disappears [8 bit] (0/1)
//        screen=3,0x26
//        loc_check(3, 0x26)
function event_magician() => byte(0x000FC1)

// $0FC2: Event - Zone 4 Cake Opened [8 bit] (0/1)
//        screen=4,0x0a
//        loc_check(4, 0x0a)
function event_cake_opened() => byte(0x000FC2)

// $0FC3: Event - Zone 4 Door to Cake Opens [8 bit] (0/1)
//        screen=4,0x11
//        loc_check(4, 0x11)
function event_cake_door() => byte(0x000FC3)

// --- MAIN DATA -------------------------------------------------------------------

BOSS_1_MANDARIN = 0
BOSS_2_CORN = 1
BOSS_3_OCTOPUS = 2
BOSS_4_SHUMAI = 3
BOSS_GOLVELLIUS = 4

MAP_TALKING = 0
MAP_OVERWORLD = 1
MAP_PLATFORMER = 2
MAP_BUBBLE = 4
MAP_BOSSFIGHT = 5

ZONES = {
	0: "Cooking School",
	1: "Carrot Farms",
	2: "Sushi Swamp",
	3: "The Plate Wall of China",
	4: "Candy Land",
	5: "Ending Cutscene"
}

WEAPONS = {
	0: "Fry Pan",
	1: "Salt & Pepper",
	2: "Knife",
	3: "Fire",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// set to zero in the title screen, obviously any in-game map would have to be wider than 0
function in_game() => current_zone_width() != 0 && current_zone() < 5

// check zone and screen
function loc_check(zone, screen) => in_game() && current_zone() == zone && screen_id() == screen

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(in_game(),
	"🗺️ {0} · ⚔️ {1} · 📜 {2}/4 diploma{3} · ❤️ {4}/{5} power · 🪙 {6}/{7} dish",
	rich_presence_lookup("Zone", current_zone(), ZONES, fallback="Kitchenland"),
	rich_presence_lookup("Weapon", selected_weapon(), WEAPONS, fallback=WEAPONS[0]),
	rich_presence_number(diploma_count()), plural(diploma_count()),
	rich_presence_number(health()),
	rich_presence_number(health_max()),
	rich_presence_number(dish()),
	rich_presence_number(dish_max())
)

rich_presence_conditional_display(current_zone() == 5,
	"[Ending] Super Cooks | © Compile 1989"
)

rich_presence_display(
	"[Title Screen] Super Cooks | © Compile 1989"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// The Wok of Ages
// Shumai, Don't Bother Me

// --- LEADERBOARDS -------------------------------------------------------------------
