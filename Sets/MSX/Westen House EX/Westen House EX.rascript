// ~Homebrew~ Westen House EX
// #ID = ?????

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $26DF: Language Selection [8 bit]
//        13 = english
//        15 = spanish
function language_selection() => byte(0x0026DF)

// $2F3F: Game Cycle [8 bit]
function game_cycle() => byte(0x002F3F)

// $2F40: HUD Messages [8 bytes, 4 x 2 byte values]
function hud_messages(i) => word(0x002F40 + 2*i)

// $2F46: Last Message in HUD [16 bit]
//        0x0041 -> 0x0177 = But no time for money now...
//        0x00df -> 0x0055 = GAME SAVED
function last_message_in_hud() => word(0x002F46)

// $2F48: HUD Message Timer [8 bit]
function hud_message_timer() => byte(0x002F48)

// $2F49: HUD Message Queue [16 bytes, 8 x 2 byte values]
function hud_message_queue(i) => word(0x002F49 + 2*i)

// $2F59: HUD Message Queue Size [8 bit]
function hud_message_queue_size() => byte(0x002F59)

// $2F63: Player Direction [8 bit]
function player_direction() => byte(0x002F63)

// $2F64: Player State [8 bit]
function player_state() => byte(0x002F64)

// $2F65: Player State Timer [8 bit]
function player_state_timer() => byte(0x002F65)

// $2F66: Player Iso X [8 bit]
function player_iso_x() => byte(0x002F66)

// $2F67: Player Iso Y [8 bit]
function player_iso_y() => byte(0x002F67)

// $2F68: Player Iso Z [8 bit]
function player_iso_z() => byte(0x002F68)

// $2F69: Player Iso W [8 bit]
function player_iso_w() => byte(0x002F69)

// $2F6A: Player Iso H [8 bit]
function player_iso_h() => byte(0x002F6A)

// $2F6B: Player Iso Z height [8 bit]
function player_iso_z_height() => byte(0x002F6B)

// $2F6C: Player Screen X [8 bit]
function player_screen_x() => byte(0x002F6C)

// $2F6D: Player Screen Y [8 bit]
function player_screen_y() => byte(0x002F6D)

// $2F6E: Vitality [8 bit]
function vitality() => byte(0x002F6E)

// $2F6F: Vitality Max [8 bit]
function vitality_max() => byte(0x002F6F)

// $2F70: Invuln Frames [8 bit]
function invuln_frames() => byte(0x002F70)

// $2F71: Inventory [24 bytes]
//        0 = EMPTY
//        1 = STOOL
//        2 = YELLOW_KEY
//        3 = GUN
//        4 = WHITE_KEY
//        5 = RED_KEY_H1
//        6 = RED_KEY_H2
//        7 = RED_KEY
//        8 = LETTER3
//        9 = LAMP
//        10 = OIL
//        11 = HEART
//        12 = BOOK
//        13 = CANDLE
//        14 = GUN_KEY
//        15 = GREEN_KEY
//        16 = DIARY1
//        17 = DIARY2
//        18 = DIARY3
//        19 = BACKYARD_KEY
//        20 = LAB_NOTES
//        21 = HAMMER
//        22 = GARLIC
//        23 = STAKE
//        24 = RUBBED_STAKE
//        25 = VAMPIRE1_NOTE
//        26 = VAMPIRE2_NOTE
//        27 = LUGGAGE
//        28 = NEWSPAPER
//        29 = HISTORY_OF_ROMANIA
//        30 = LUCY_TORN_NOTE
//        31 = PUZZLE_BOX
//        32 = VLAD_NOTE
//        33 = VLAD_DIARY
//        34 = REVEAL_CLUE
//        35 = PRISON_KEY
//        36 = CUTLERY
//        37 = CAULDRON
//        38 = SHOVEL
//        39 = SKELETON_KEY
//        40 = CLAY
//        41 = QUINCEY_KEY
//        42 = FRANKY_KEY
//        43 = QUINCEY_LETTER
//        44 = CAULDRON_CUTLERY
//        45 = WET_MOLD
//        46 = MOLD
//        47 = SILVER_BULLETS
//        48 = FRANKY_NOTE
function inventory() => Array(0x002F71)

// $2F89: Date/Time [8 bit]
//        0 = start / Nov 26 pm
//        1 = reach Westen House / Nov 27 am
//        2 = code seen / Nov 27 pm
//        3 = reach west wing / Nov 28 am
//        4 = pentagram clue seen / Nov 28 pm
//        5 = reach basement / Nov 29 am
//        6 = reach feeding room / Nov 29 pm
//        7 = reach second floor / Nov 30 am
//        8 = reach lab / Nov 30 pm
//        9 = vampires arrive / Dec 1 am
//        10 = Lucy enters sub-basement / Dec 1 pm
//        11 = sub-basement open / Dec 2 am
function date_time() => byte(0x002F89)

// $2F8A: Room [8 bit]
//        0x00 = path to Westen House
//        0x01 = Westen House front door
//        0x02 = entry room
//        0x03 = southeast hallway
//        0x04 = northeast hallway
//        0x05 = southeast dining room
//        0x06 = room between dining room and kitchen
//        0x07 = northeast study
//        0x08 = kitchen
//        0x09 = larder
//        0x0a = upstairs landing
//        0x0b = back garden
//        0x10 = west hallway
//        0x11 = west music room
//        0x12 = west hallway bathroom
//        0x13 = west hallway branch
//        0x14 = west wing library
//        0x15 = blocked storage room
//        0x16 = hidden storage
//        0x17 = west blockade room
//        0x18 = pentagram chamber
//        0x20 = basement connecting room with spikes
//        0x21 = basement step access
//        0x22 = basement 3x spikes T room
//        0x23 = basement July's room
//        0x24 = basement spike pit double hallway
//        0x25 = basement columns L room
//        0x26 = basement spider T room
//        0x27 = basement spider hallway
//        0x28 = basement Vlad's altar
//        0x29 = basement vestibule to Lucy's room
//        0x2a = basement Lucy's room
//        0x2b = basement fireplace study
//        0x2c = basement human remains dining room
//        0x2d = basement Westen's room
//        0x2e = basement exit stairs
//        0x30 = upstairs first hallway
//        0x31 = upstairs second hallway
//        0x32 = upstairs east hallway
//        0x33 = upstairs hallway bathroom
//        0x34 = upstairs bedroom near left
//        0x35 = upstairs bedroom far left
//        0x36 = upstairs bedroom
//        0x37 = upstairs bathroom
//        0x38 = upstairs farthest bedroom
//        0x39 = upstairs bathroom off farthest bedroom
//        0x3a = upstairs east bedroom
//        0x3b = upstairs east bathroom
//        0x3c = upstairs attic access
//        0x3d = upstairs attic JW's lab
//        0x40 = home foyer
//        0x41 = home living room
//        0x42 = home kitchen
//        0x43 = home bedroom
//        0x44 = home washroom
//        0x45 = street by house
//        0x46 = back alley
//        0x47 = street by bookstore
//        0x48 = bookstore
//        0x50 = subbasement ossuary
//        0x51 = subbasement savepoint hallway
//        0x52 = subbasement Vlad's statue
//        0x53 = subbasement armor hallway
//        0x54 = subbasement long dining table
//        0x55 = subbasement coffin room south
//        0x56 = subbasement coffin room north
//        0x57 = subbasement ritual chamber
//        0x58 = subbasement Vlad's room
//        0x59 = subbasement prison #1
//        0x5a = subbasement prison #2
//        0x5b = subbasement trapped prison
//        0x5c = subbasement skeleton miniboss
//        0x5d = subbasement Frankey's room
//        0x5e = subbasement snake hallway
//        0x5f = subbasement room behind ritual chamber
function room() => byte(0x002F8A)

// $2F8B: Key State - Yellow [8 bit]
//        0 = not taken
//        1 = taken
//        2 = used
function key_state_yellow() => byte(0x002F8B)

// $2F8C: Key State - White [8 bit]
//        0 = not taken
//        1 = taken
//        2 = used
function key_state_white() => byte(0x002F8C)

// $2F8D: Key State - Red [8 bit]
//        0 = not taken
//        1 = taken
//        2 = used
function key_state_red() => byte(0x002F8D)

// $2F8E: Key State - Green [8 bit]
//        0 = not taken
//        1 = taken
//        2 = used
function key_state_green() => byte(0x002F8E)

// $2F8F: Key State - Backyard [8 bit]
//        0 = not taken
//        1 = taken
//        2 = used
function key_state_backyard() => byte(0x002F8F)

// $2F90: Gun State [8 bit]
//        0 =
//        1 =
//        2 =
function gun_state() => byte(0x002F90)

// $2F91: Letter 3 State [8 bit]
//        0 = not taken
//        1 = taken
//        2 = read
//        3 = code developed
//        4 = code seen
//        5 = code used
function letter_3_state() => byte(0x002F91)

// $2F92: Lamp State [8 bit]
function lamp_state() => byte(0x002F92)

// $2F93: Oil State [8 bit]
function oil_state() => byte(0x002F93)

// $2F94: Painting/Safe State [8 bit]
function painting_safe_state() => byte(0x002F94)

// $2F95: Heart #1 Taken [8 bit] (0/1)
function heart_1_taken() => byte(0x002F95)

// $2F96: Heart #2 Taken [8 bit] (0/1)
function heart_2_taken() => byte(0x002F96)

// $2F97: Heart #3 Taken [8 bit] (0/1)
function heart_3_taken() => byte(0x002F97)

// $2F98: Heart #4 Taken [8 bit] (0/1)
function heart_4_taken() => byte(0x002F98)

// $2F99: Book Taken [8 bit] (0/1)
function book_taken() => byte(0x002F99)

// $2F9A: Diary #1 Taken [8 bit] (0/1)
function diary_1_taken() => byte(0x002F9A)

// $2F9B: Diary #2 Taken [8 bit] (0/1)
function diary_2_taken() => byte(0x002F9B)

// $2F9C: Diary #3 Taken [8 bit] (0/1)
function diary_3_taken() => byte(0x002F9C)

// $2F9D: Candle #1 Room [8 bit]
function candle_1_room() => byte(0x002F9D)

// $2F9E: Candle #1 X [8 bit]
function candle_1_x() => byte(0x002F9E)

// $2F9F: Candle #1 Y [8 bit]
function candle_1_y() => byte(0x002F9F)

// $2FA0: Candle #1 Z [8 bit]
function candle_1_z() => byte(0x002FA0)

// $2FA1: Candle #2 Room [8 bit]
function candle_2_room() => byte(0x002FA1)

// $2FA2: Candle #2 X [8 bit]
function candle_2_x() => byte(0x002FA2)

// $2FA3: Candle #2 Y [8 bit]
function candle_2_y() => byte(0x002FA3)

// $2FA4: Candle #2 Z [8 bit]
function candle_2_z() => byte(0x002FA4)

// $2FA5: Candle #3 Room [8 bit]
function candle_3_room() => byte(0x002FA5)

// $2FA6: Candle #3 X [8 bit]
function candle_3_x() => byte(0x002FA6)

// $2FA7: Candle #3 Y [8 bit]
function candle_3_y() => byte(0x002FA7)

// $2FA8: Candle #3 Z [8 bit]
function candle_3_z() => byte(0x002FA8)

// $2FA9: Writing Room Message [8 bit]
function writing_room_message() => byte(0x002FA9)

// $2FAA: Ritual Room State [8 bit]
//        0 = not found
//        1 = found
//        2 = solved (1st pattern)
//        3 = solved (2nd pattern)
function ritual_room_state() => byte(0x002FAA)

// $2FAB: Hammer Taken [8 bit] (0/1)
function hammer_taken() => byte(0x002FAB)

// $2FAC: Garlic Crates [3 bytes]
function garlic_crates() => tbyte(0x002FAC)

// $2FAF: Stake Crates [3 bytes]
function stake_crates() => tbyte(0x002FAF)

// $2FB2: Lab Notes State [8 bit]
//        0 = not taken
//        1 = taken
//        2 = read
function lab_notes_state() => byte(0x002FB2)

// $2FB3: Vampire #1 (July) State [8 bit]
//        0 = door closed
//        1 = door open
//        2 = killed
// $2FB4: Vampire #2 (Westen) State [8 bit]
//        0 = door closed
//        1 = door open
//        2 = killed
// $2FB5: Vampire #3 (Lucy) State [8 bit]
//        0 = door closed
//        1 = door open
//        2 = killed (never set, assumed in ending calc)
// $2FB6: Vampire #4 (Lucard) State [8 bit]
//        0 = door closed
//        1 = door open
function vampire(i) => byte(0x002FB3 + i)

// $2FB7: Luggage Taken [8 bit] (0/1)
function luggage_taken() => byte(0x002FB7)

// $2FB8: Newspaper Taken [8 bit] (0/1)
function newspaper_taken() => byte(0x002FB8)

// $2FB9: Beggar State [8 bit]
//        0 = init
//        1 = talked once
//        2 = talked twice
//        3 = dead
function beggar_state() => byte(0x002FB9)

// $2FBA: Chauffer/Bookstore State [8 bit]
//        0 = chauffer sleeping
//        1 = chauffer awake
//        2 = book found
//        3 = book purchased
function chauffer_bookstore_state() => byte(0x002FBA)

// $2FBB: Torn Note State [8 bit]
function torn_note_state() => byte(0x002FBB)

// $2FBC: Reached Subbasement [8 bit]
function reached_subbasement() => byte(0x002FBC)

// $2FBD: Puzzle Box State [8 bit]
//        0 = not taken
//        1 = taken
//        2 = attempted
//        3 = solved
function puzzle_box_state() => byte(0x002FBD)

// $2FBE: Vlad Statue Examined [8 bit] (0/1)
function vlad_statue_examined() => byte(0x002FBE)

// $2FBF: Vlad Diary Taken [8 bit] (0/1)
function vlad_diary_taken() => byte(0x002FBF)

// $2FC0: Reveal Clue Taken [8 bit] (0/1)
function reveal_clue_taken() => byte(0x002FC0)

// $2FC1: Mirrors Broken [8 bit bitflags]
//        bit0 | Vlad's mirror (key)
//        bit1 | bathroom by entry hall (heart) [0x12]
//        bit2 | bathroom off upstairs hall (candle)
//        bit3 | upstairs bedroom (candle)
//        bit4 | upstairs far bedroom [0x39]
//        bit5 | upstairs bedroom
function mirrors_broken() => byte(0x002FC1)

// $2FC2: Cutlery Taken [8 bit] (0/1)
function cutlery_taken() => byte(0x002FC2)

// $2FC3: Prison Door State [8 bit]
function prison_door_state() => byte(0x002FC3)

// $2FC4: Cauldron Taken [8 bit] (0/1)
function cauldron_taken() => byte(0x002FC4)

// $2FC5: Switches State [8 bit bitflags]
//        bit0 | prison 1
//        bit1 | prison 2
//        bit2 | boss 1
function switches_state() => byte(0x002FC5)

// $2FC6: Shovel Taken [8 bit] (0/1)
function shovel_taken() => byte(0x002FC6)

// $2FC7: Skeleton Miniboss Defeated [8 bit] (0/1)
function skeleton_miniboss_defeated() => byte(0x002FC7)

// $2FC8: Skeleton Key State [8 bit]
//        0 = not taken
//        1 = taken
//        2 = used
function skeleton_key_state() => byte(0x002FC8)

// $2FC9: Quincey Grave State [8 bit]
//        0 = not dug
//        1 = key taken
//        2 = key used
//        3 = dug, key not taken
function quincey_grave_state() => byte(0x002FC9)

// $2FCA: Clay Taken [8 bit] (0/1)
function clay_taken() => byte(0x002FCA)

// $2FCB: Frankey Key Taken [8 bit] (0/1)
function frankey_key_taken() => byte(0x002FCB)

// $2FCC: Quincey Note Read [8 bit] (0/1)
function quincey_note_read() => byte(0x002FCC)

// $2FCD: Frankey Boss State [8 bit]
//        0 = not killed
//        1 = killed, note not taken
//        2 = note taken
function frankey_boss_state() => byte(0x002FCD)

// $2FCE: Current Music ID, Page [16 bit]
//        
//        0x0902 = intro cutscene
//        0x0907 = title screen
//        0x0919 = Lucy's death cutscene
//        0x091a = ending cutscene
function music() => word(0x002FCE)

// --- MAIN DATA -------------------------------------------------------------------

LANGUAGE_EN = 13
LANGUAGE_ES = 15

MUSIC_INTRO = 0x0902
MUSIC_TITLE = 0x0907

ITEM_EMPTY = 0
ITEM_STOOL = 1
ITEM_YELLOW_KEY = 2
ITEM_GUN = 3
ITEM_WHITE_KEY = 4
ITEM_RED_KEY_H1 = 5
ITEM_RED_KEY_H2 = 6
ITEM_RED_KEY = 7
ITEM_LETTER3 = 8
ITEM_LAMP = 9
ITEM_OIL = 10
ITEM_HEART = 11
ITEM_BOOK = 12
ITEM_CANDLE = 13
ITEM_GUN_KEY = 14
ITEM_GREEN_KEY = 15
ITEM_DIARY1 = 16
ITEM_DIARY2 = 17
ITEM_DIARY3 = 18
ITEM_BACKYARD_KEY = 19
ITEM_LAB_NOTES = 20
ITEM_HAMMER = 21
ITEM_GARLIC = 22
ITEM_STAKE = 23
ITEM_RUBBED_STAKE = 24
ITEM_VAMPIRE1_NOTE = 25
ITEM_VAMPIRE2_NOTE = 26
ITEM_LUGGAGE = 27
ITEM_NEWSPAPER = 28
ITEM_HISTORY_OF_ROMANIA = 29
ITEM_LUCY_TORN_NOTE = 30
ITEM_PUZZLE_BOX = 31
ITEM_VLAD_NOTE = 32
ITEM_VLAD_DIARY = 33
ITEM_REVEAL_CLUE = 34
ITEM_PRISON_KEY = 35
ITEM_CUTLERY = 36
ITEM_CAULDRON = 37
ITEM_SHOVEL = 38
ITEM_SKELETON_KEY = 39
ITEM_CLAY = 40
ITEM_QUINCEY_KEY = 41
ITEM_FRANKY_KEY = 42
ITEM_QUINCEY_LETTER = 43
ITEM_CAULDRON_CUTLERY = 44
ITEM_WET_MOLD = 45
ITEM_MOLD = 46
ITEM_SILVER_BULLETS = 47
ITEM_FRANKY_NOTE = 48

DATETIMES = {
	0: "Nov 26 pm",
	1: "Nov 27 am",
	2: "Nov 27 pm",
	3: "Nov 28 am",
	4: "Nov 28 pm",
	5: "Nov 29 am",
	6: "Nov 29 pm",
	7: "Nov 30 am",
	8: "Nov 30 pm",
	9: "Dec 1 am",
	10: "Dec 1 pm",
	11: "Dec 2 am",
}

ROOM_NAMES = {
	0x00: "Outside the Westen House",
	0x01: "Outside the Westen House",
	0x02: "Parlor Room",
	0x03: "Southeast Hallway",
	0x04: "Northeast Hallway",
	0x05: "Dining Room",
	0x06: "Hallway",
	0x07: "Study",
	0x08: "Kitchen",
	0x09: "Larder",
	0x0a: "Upstairs Landing",
	0x0b: "Back Garden",
	0x10: "West Hallway",
	0x11: "Music Room",
	0x12: "Hallway Bathroom",
	0x13: "West Hallway",
	0x14: "Library",
	0x15: "Storage Room",
	0x16: "Storage Room",
	0x17: "Back Rooms",
	0x18: "Pentagram Chamber",
	0x20: "Basement",
	0x21: "Basement",
	0x22: "Basement",
	0x23: "Basement",
	0x24: "Basement",
	0x25: "Basement",
	0x26: "Basement",
	0x27: "Basement Hallway",
	0x28: "Basement Altar",
	0x29: "Basement",
	0x2a: "Basement",
	0x2b: "Fireplace Study",
	0x2c: "Basement Dining Room",
	0x2d: "Basement",
	0x2e: "Cellar",
	0x30: "Upstairs Hallway",
	0x31: "Upstairs Hallway",
	0x32: "Upstairs Hallway",
	0x33: "Upstairs Hallway Bathroom",
	0x34: "Upstairs Bedroom",
	0x35: "Upstairs Bedroom",
	0x36: "Upstairs Bedroom",
	0x37: "Upstairs Bathroom",
	0x38: "Upstairs Bedroom",
	0x39: "Upstairs Bathroom",
	0x3a: "Upstairs Bedroom",
	0x3b: "Upstairs Bathroom",
	0x3c: "Attic Access",
	0x3d: "Westen's Lab",
	0x40: "Edward's Home",
	0x41: "Edward's Living Room",
	0x42: "Edward's Kitchen",
	0x43: "Edward's Bedroom",
	0x44: "Edward's Washroom",
	0x45: "Jermin Street, London",
	0x46: "London Back Alley",
	0x47: "Jermin Street, London",
	0x48: "Watkins' Bookstore",
	0x50: "Sub-basement Ossuary",
	0x51: "Sub-basement Hallway",
	0x52: "Sub-basement",
	0x53: "Sub-basement Hallway",
	0x54: "Sub-basement Dining Table",
	0x55: "Sub-basement Coffin Room",
	0x56: "Sub-basement Coffin Room",
	0x57: "Sub-basement Ritual Chamber",
	0x58: "Sub-basement Bedroom",
	0x59: "Sub-basement Prison",
	0x5a: "Sub-basement Prison",
	0x5b: "Sub-basement Prison",
	0x5c: "Sub-basement Chamber",
	0x5d: "Sub-basement Chamber",
	0x5e: "Sub-basement Hallway",
	0x5f: "Sub-basement Hallway",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_ending() => music() == 0x091a
function win_the_game() => room() == 0x57 && prev(music()) == 0x0919 && music() == 0x091a

function vampires_killed() => max_of(
	measured(sum_of(range(0,2), i => vampire(i)/2) + 1, when=in_ending()),
	measured(sum_of(range(0,2), i => vampire(i)/2))
)

function secondary_objectives() => (
	(chauffer_bookstore_state() / 3) +
	(reveal_clue_taken() / 1) +
	(ritual_room_state() / 3) +
	(quincey_grave_state() / quincey_grave_state()) +
	(frankey_key_taken() / 2) +
	(frankey_boss_state() / frankey_boss_state())
)

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(language_selection() == 0xff,
	"[Language Select] Westen House EX | © Brain Games 2024"
)

rich_presence_conditional_display(music() == MUSIC_INTRO,
	"[Intro Cutscene] Westen House EX | © Brain Games 2024"
)

rich_presence_conditional_display(music() == MUSIC_TITLE,
	"[Title Screen] Westen House EX | © Brain Games 2024"
)

rich_presence_display(
	"🗺️ {0} · ❤️ {1}/{2} · 🧛 Vampires killed: {3}/3 · 📋 Secondary objectives: {4}/6",
	rich_presence_lookup("Location", room(), ROOM_NAMES, fallback="Westen House"),
	rich_presence_number(vitality()), rich_presence_number(vitality_max()),
	rich_presence_number(vampires_killed()),
	rich_presence_number(secondary_objectives())
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// Climb the bookshelves in the bookstore
// Stay awake on the train to Purfleet
// Break every mirror
// Greedy greedy

// --- LEADERBOARDS -------------------------------------------------------------------

