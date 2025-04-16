// ~Hack~ BAZR
// #ID = 33246

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function plurale(x) => rich_presence_lookup("_Plurale", x, {1: ""}, fallback="es")
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

// === Card IDs ===
//          = Active =
//          0x01 | Jump
//          0x02 | Weak Jump
//          0x03 | Triple Jump
//          0x04 | Special Triple Jump
//          0x05 | Beta Triple Jump
//          0x06 | Backflip/Sideflip
//          0x07 | Punch
//          0x08 | Dive/Kick
//          0x09 | Air Jump
//          0x0a | Rocket Launch
//          0x0b | Galaxy Spin
//          0x0c | Clip
//          0x0d | Crouch/Groundpound
//          0x0e | Long Jump
//          0x0f | Totsugeki
//          0x10 | Balloon
//          0x11 | BLJ
//          0x12 | Throw Bomb
//          0x13 | Tweester
//          0x14 | Crazy Box
//          0x15 | Koopa Shell
//          0x16 | Cannon Launch
//          0x17 | Cloud Flower
//          0x18 | Updraft Wind
//          0x19 | Breakdance
//          0x1a | Shoulder Bash
//          0x1b | Bonk
//          0x1c | Trip
//          0x1d | Heal in Ground
//          0x1e | Health Refill
//          0x1f | Wing Cap Jump
//          0x20 | Lose One Health
//          0x21 | Four of Hearts
//          0x22 | Mystery Card
//          0x23 | Spheal
//          0x24 | Charizard
//          0x25 | Amoonguss
//          0x26 | Explosive Jump
//          0x27 | Random Teleport
//          0x28 | Get Ten Coins
//          0x29 | Levitate
//          0x2a | Right Arm of the Forbidden One
//          0x2b | Left Arm of the Forbidden One
//          0x2c | Right Leg of the Forbidden One
//          0x2d | Left Leg of the Forbidden One
//          0x2e | Spawn Work Elevator
//          0x2f | Hey Stinky!
//          0x30 | Rollout
//          0x31 | Fix All Cards
//          0x32 | Launch Towards Star
//          0x33 | Activate All Caps
//          0x34 | Hover
//          0x35 | Lava Boost
//          0x36 | Chuckya Friend
//          0x37 | Warp to Spawn
//          0x38 | Fire Flower
//          0x39 | Super Jump
//          0x3a | Button Lock
//          0x3b | Metal Cap
//          0x3c | Vanish Cap
//          
//          = Passive =
//          0x01 | Wallkicks
//          0x02 | Green Demon
//          0x03 | Coin Magnet
//          0x04 | Star Magnet
//          0x05 | Health Drain
//          0x06 | Health Regen
//          0x07 | Speed Up
//          0x08 | Luigi Physics
//          0x09 | Goomba Army
//          0x0a | Bomb Rain
//          0x0b | Mario Maker Spam
//          0x0c | High Gravity
//          0x0d | Low Gravity
//          0x0e | Speed Down
//          0x0f | Invisible
//          0x10 | RNG Manip
//          0x11 | Button Swap
//          0x12 | Buttery
//          0x13 | Reverse Controls
//          0x14 | Releasio Physics
//          0x15 | DS D-Pad
//          0x16 | Squished
//          0x17 | 2x Coins
//          0x18 | No Glasses
//          0x19 | Sinusoidal Movespeed
//          0x1a | Cinematic Mode
//          0x1b | Quake Pro FOV
//          0x1c | Glue Man
//          0x1d | Hoverboots
//          0x1e | No Fall Damage
//          0x1f | Walkies
//          0x20 | Pop-up Ads
//          0x21 | Show Hitboxes
//          0x22 | Exodia the Forbidden One
//          0x24 | Hatless
//          
//          = Special =
//          0x01 | Drop to One Health
//          0x02 | Shuffler
//          0x03 | Repair all Cards
//          0x04 | Random Textbox
//          0x05 | Spin the Wheel
//          0x06 | URGH!
//          0x07 | Trivia Question
//          0x08 | Where we Droppin'?
//          0x09 | Mad Piano
//          0x0a | Troll
//          0x0b | Mario Choir
//          0x0c | Pizza Time
//          0x0d | Snowman Firing Squad
//          0x0e | Chuckya Foes
//          0x0f | Pitfall

// $04CDA0: [Bitflag]
//          bit4 | Tutorial Seen (set on tutorial start)
//          bit5 | In Level (used for Resetti?)
function tutorial_seen() => bit4(0x04CDA0)
function in_level() => bit5(0x04CDA0)

// $04CDA1: [Bitflag] Completed / Unlocks
//          bit4 | Golden Unlocked
//          bit5 | Mario
//          bit6 | Luigi
//          bit7 | Toad
// $04CDA2: [Bitflag] Completed
//          bit0 | Peach
//          bit1 | Baby
//          bit2 | Fallout
//          bit3 | Pizza
//          bit4 | May
//          bit5 | Skeleton
//          bit6 | ABC
//          bit7 | Demon
// $04CDA3: [Bitflag] Completed
//          bit0 | Simple
//          bit1 | Walkies
//          bit2 | Gold
//          bit3 | Bowser
//          bit4 | TAS
//          bit5 | Chaos
function golden_deck_unlocked() => bit4(0x04CDA1)
function completed_deck(i) => bitx(i + 5, 0x04CDA1)

// $04CDA4: [Bitflag] Cool Cool Mountain - Stars Collected
//          bit0 | Slip Slidin' Away
//          bit1 | Li'l Penguin Lost
//          bit2 | Big Penguin Race
//          bit3 | Frosty Slide for 8 Red Coins
//          bit4 | Snowman's Lost His Head
//          bit5 | Wall Kicks Will Work
//          
//          bit7 | Jolly Roger Bay Card Vault
function star_ccm(i) => bit(i, 0x04CDA4)
function vault_jrb() => bit7(0x04CDA4)

// $04CDA5: [Bitflag] Jolly Roger Bay - Stars Collected
//          bit0 | Treasure of the Hidden Cave
//          bit1 | Ocean Salvage for Red Coins
//          bit2 | Lighthouse Shining Bright
//          bit3 | Hop the Tilting Boardwalk
//          bit4 | Plunder in the Pirate Ship
//          bit5 | Lump in the Sand
//          
//          bit7 | Whomp's Fortress Card Vault
function star_jrb(i) => bit(i, 0x04CDA5)
function vault_wf() => bit7(0x04CDA5)

// $04CDA6: [Bitflag] Whomp's Fortress - Stars Collected
//          bit0 | Chip Off Whomp's Block
//          bit1 | To the Top of the Fortress
//          bit2 | Climb into the Wild Blue
//          bit3 | Red Coins on the Floating Isle
//          bit4 | Fall onto the Caged Island
//          bit5 | Break Away the Wall
//          
//          bit7 | Bob-Omb Battlefield Card Vault
function star_wf(i) => bit(i, 0x04CDA6)
function vault_bob() => bit7(0x04CDA6)

// $04CDA7: [Bitflag] Bob-Omb Battlefield - Stars Collected
//          bit0 | Big Bob-Omb on the Summit
//          bit1 | Footrace with Koopa the Quick
//          bit2 | Leap to the Island in the Sky
//          bit3 | Find the 8 Red Coins
//          bit4 | Mario Wings to the Sky
//          bit5 | Behind Chain Chomp's Gate
function star_bob(i) => bit(i, 0x04CDA7)

// $04CDA8: [Bitflag] Shifting Sand Land - Stars Collected
//          bit0 | In the Talons of the Big Bird
//          bit1 | Shining Atop the Pyramid
//          bit2 | Inside the Ancient Pyramid
//          bit3 | Stand Tall on the Four Pillars
//          bit4 | Free Flying for 8 Red Coins
//          bit5 | Pyramid Puzzle
//          
//          bit7 | Lethal Lava Land Card Vault
function star_ssl(i) => bit(i, 0x04CDA8)
function vault_lll() => bit7(0x04CDA8)

// $04CDA9: [Bitflag] Lethal Lava Land - Stars Collected
//          bit0 | Boil the Big Bully
//          bit1 | Bully the Bullies
//          bit2 | 8-Coin Puzzle with 15 Pieces
//          bit3 | Red-Hot Log Rolling
//          bit4 | Hot-Foot-It into the Volcano
//          bit5 | Elevator Tour in the Volcano
//          
//          bit7 | Hazy Maze Cave Card Vault
function star_lll(i) => bit(i, 0x04CDA9)
function vault_hmc() => bit7(0x04CDA9)

// $04CDAA: [Bitflag] Hazy Maze Cave - Stars Collected
//          bit0 | Swimming Beast in the Cavern
//          bit1 | Elevate for 8 Red Coins
//          bit2 | Metal-Head Mario Can Move!
//          bit3 | Navigating the Toxic Maze
//          bit4 | A-Maze-ing Emergency Exit
//          bit5 | Watch for Rolling Rocks
//          
//          bit7 | Big Boo's Haunt Card Vault
function star_hmc(i) => bit(i, 0x04CDAA)
function vault_bbh() => bit7(0x04CDAA)

// $04CDAB: [Bitflag] Big Boo's Haunt - Stars Collected
//          bit0 | Go on a Ghost Hunt
//          bit1 | Ride Big Boo's Merry-Go-Round
//          bit2 | Secret of the Haunted Books
//          bit3 | Seek the 8 Red Coins
//          bit4 | Big Boo's Balcony
//          bit5 | Eye to Eye in the Secret Room
//          
//          bit7 | Cool Cool Mountain Card Vault
function star_bbh(i) => bit(i, 0x04CDAB)
function vault_ccm() => bit7(0x04CDAB)

// $04CDAC: [Bitflag] Tall, Tall Mountain - Stars Collected
//          bit0 | Scale the Mountain
//          bit1 | Mystery of the Monkey Cage
//          bit2 | Scary 'Shrooms, Red Coins
//          bit3 | Mysterious Moustainside
//          bit4 | Breathtaking View from Bridge
//          bit5 | Blast to the Lonely Mushroom
//          
//          bit7 | Wet-Dry World Card Vault
function star_ttm(i) => bit(i, 0x04CDAC)
function vault_wdw() => bit7(0x04CDAC)

// $04CDAD: [Bitflag] Wet-Dry World - Stars Collected
//          bit0 | Top o' the World
//          bit1 | Quick Slide to the Cage!
//          bit2 | Star's Behind Bars
//          bit3 | Way Above the Rooftops
//          bit4 | Shocking Arrow Lifts!
//          bit5 | Go to Town for Red Coins
//          
//          bit7 | Snowman's Land Card Vault
function star_wdw(i) => bit(i, 0x04CDAD)
function vault_sl() => bit7(0x04CDAD)

// $04CDAE: [Bitflag] Snowman's Land - Stars Collected
//          bit0 | Snowman's Big Head
//          bit1 | Chill with the Bully
//          bit2 | In the Deep Freeze
//          bit3 | Whirl from the Freezing Pond
//          bit4 | Shell Shreddin' for Red Coins
//          bit5 | Into the Igloo
function star_sl(i) => bit(i, 0x04CDAE)

// $04CDAF: [Bitflag]
//          bit7 | Shifting Sand Land Card Vault
function vault_ssl() => bit7(0x04CDAF)

// $04CDB0: [Bitflag]
//          bit7 | Rainbow Ride Card Vault
function vault_rr() => bit7(0x04CDB0)

// $04CDB1: [Bitflag] Rainbow Ride - Stars Collected
//          bit0 | Cruiser Crossing the Rainbow
//          bit1 | The Big House in the Sky
//          bit2 | Coins Amassed in a Maze
//          bit3 | Swingin' in the Breeze
//          bit4 | Tricky Triangles
//          bit5 | Somewhere Over the Rainbow
//          
//          bit7 | Tick Tock Clock Card Vault
function star_rr(i) => bit(i, 0x04CDB1)
function vault_ttc() => bit7(0x04CDB1)

// $04CDB2: [Bitflag] Tick Tock Clock - Stars Collected
//          bit0 | Roll Into the Cage
//          bit1 | The Pit and the Pendulums
//          bit2 | Get a Hand
//          bit3 | Stomp on the Thwomp
//          bit4 | Timed Jumps on Moving Bars
//          bit5 | Stop Time for Red Coins
//          
//          bit7 | Tiny-Huge Island Card Vault
function star_ttc(i) => bit(i, 0x04CDB2)
function vault_thi() => bit7(0x04CDB2)

// $04CDB3: [Bitflag] Tiny-Huge Island - Stars Collected
//          bit0 | Pluck the Piranha Flower
//          bit1 | The Tip Top of the Huge Island
//          bit2 | Rematch with Koopa the Quick
//          bit3 | Five Itty Bitty Secrets
//          bit4 | Wiggler's Red Coins
//          bit5 | Make Wiggler Squirm
//          
//          bit7 | Tall, Tall Mountain Card Vault
function star_thi(i) => bit(i, 0x04CDB3)
function vault_ttm() => bit7(0x04CDB3)

// $04CE5A: [8-bit] Current Hub Painting
//          0x00 | Bob-omb Battlefield
//          0x01 | Cool, Cool Mountain
//          0x02 | Whomp's Fortress
//          0x03 | Tall, Tall Mountain
//          0x04 | Jolly Roger Bay
//          0x05 | Wet-Dry World
//          0x06 | Lethal Lava Land
//          0x07 | Tick Tock Clock
//          0x08 | Rainbow Ride
//          0x09 | Big Boo's Haunt
//          0x0a | Shifting Sand Land
//          0x0b | Snowman's Land
//          0x0c | Hazy Maze Cave
//          0x0d | Tiny-Huge Island
function current_hub_painting() => byte(0x04CE5A)

// $04CE5C: [32-bit] Total Time Spent (frames)
function total_time_f() => dword(0x04CE5C)

// $04CE66: [8-bit] Total Losses
function total_losses() => byte(0x04CE66)

// $04CE67: [8-bit] Total Wins
function total_wins() => byte(0x04CE67)

// $04CF4A: [8-bit] Resetti Tracker - Number of Encounters
//          (increments on encounter start)
function resetti_encounters() => byte(0x04CF4A)

// $270564: {1.0.3} [40 Bytes, 8 Bytes per card] {montyMoleCards}
//          +0x00 | [8-bit] Max Uses
//          +0x01 | [8-bit] Uses Left
//          +0x02 | [8-bit] Card ID
//          +0x03 | [8-bit] Type
//          --- 0x00 | Used (add new card)
//          --- 0x01 | Active
//          --- 0x02 | Passive
//          --- 0x03 | Special
//          --- 0x05 | Empty
function monty_slot() => 0x270564 + 0x8*i

// $270616: {1.0.3} [16-bit] Witch Card Dialog {gWitchInterestingCardDialog}
//          0xd5 | Weak Jump
//          0xd6 | Galaxy Spin
//          0xd7 | Air Jump
//          0xd8 | Crouch
//          0xd9 | Clip
//          0xda | BLJ
//          0xdb | Updraft Wind
//          0xdc | Four of Hearts
//          0xdd | Exodia
//          0xde | Heal in Ground
//          0xdf | Launch towards Star
//          0xe0 | Mystery Card
//          0xe1 | Balloon
//          0xe2 | Wallkicks Will Work
//          0xe3 | RNG Manip
//          0xe4 | Green Demon
//          0xe5 | Button Swap
//          0xe6 | Walkies
//          0xe7 | Reverse Controls
//          0xe8 | Star Magnet
//          0xe9 | DS D-Pad
//          0xea | Shuffler
//          0x112 | Koopa Shell
//          0x113 | Trip
//          0x114 | Button Lock
//          0x115 | Metal Cap
//          0x116 | Vanish Cap
//          0x117 | Buttery
//          0x118 | Fix All Cards
//          0x119 | Troll
//          0x11a | Hoverboots
//          0x11b | Pizza Time
function witch_dialog() => word(0x270616)

// $27061A: {1.0.3} [16-bit] Painting Re-roll Price {gCurrRerollCost}
function painting_reroll_cost() => word(0x27061A)

// $27062F: {1.0.3} [8-bit] Free Rerolls Cheat Active {freeRerollsCheat}
function cheat_free_rerolls() => byte(0x27062F) == 1

// $270DA8: {1.0.3} [32-bit] {gGlobalTimer}
function global_timer() => dword(0x270DA8)

// $270DAE: {1.0.3} [8-bit] {gPaintingPenguinEntered}
function penguin_entered_painting() => byte(0x270DAE)

// $272F77: {1.0.3} [8-bit] Unlock Alls Cheat Active {unlockAllDecksCheat}
//          0x00 | Inactive
//          0x01 | Active
function cheat_unlock_all_decks() => byte(0x272F77)

// $2734D3: {1.0.3} [8-bit] {gPizzaTimeActive}
function pizza_time_active() => byte(0x2734D3)

// $2734D5: {1.0.3} [8-bit] Run Active {gRunActive}
function active_run() => byte(0x2734D5)

// $2734D6: {1.0.3} [16-bit] Total Coins Spent {gTotalSpentCoins}
function total_coins_spent() => word(0x2734D6)

// $2734DA: {1.0.3} [16-bit] Total Coins {gTotalCoins}
function total_coins() => word(0x2734DA)

// $2734DF: {1.0.3} [8-bit] {maxPermaPassives}
function max_laminated() => byte(0x2734DF)


// $2734E3: {1.0.3} [8-bit] Laminated Card - 1 {gPermaPassives}
// $2734E2: {1.0.3} [8-bit] Laminated Card - 2 {gPermaPassives}
// $2734E1: {1.0.3} [8-bit] Laminated Card - 3 {gPermaPassives}
function laminated1() => byte(0x2734E3)
function laminated2() => byte(0x2734E2)
function laminated3() => byte(0x2734E1)

// $2734E7: {1.0.3} [8-bit] Current Passive {gCurrPassive}
function current_passive() => byte(0x2734E7)

// $27378A: {1.0.3} [8-bit] Menu Filter Setting
//          0x01 | All
//          0x02 | Active
//          0x03 | Passive
//          0x04 | Special
//          0x05 | Laminated
function menu_filter() => byte(0x27378A)

// $273792: {1.0.3} [16-bit] Dialogue ID (Vanilla Text) {gDialogID}
function dialogue_id() => word(0x273792)

// $274A56: {1.0.3} [16-bit] Current Map ID {gCurrLevelNum}
//          0x04 | Big Boo's Haunt
//          0x05 | Cool Cool Mountain
//          0x07 | Hazy Maze Cave
//          0x08 | Shifting Sand Land
//          0x09 | Bob-Omb Battlefield
//          0x0a | Snowman's Land
//          0x0d | Tiny-Huge Island
//          0x0e | Tick Tock Clock
//          0x0f | Rainbow Ride
//          0x11 | Bowser's Gauntlet (1)
//          0x13 | Bowser's Gauntlet (2)
//          0x15 | Bowser's Gauntlet (3)
//          0x16 | Lethal Lava Land
//          0x18 | Whomp's Fortress
//          0x24 | Tall Tall Mountain
//          0x27 | Luigi's Casino
//          0x28 | Jolly Roger Bay
//          0x29 | Wet Dry World
function current_map() => word(0x274A56)

// $27619F: {1.0.3} [8-bit] Cards Left to Draw {remaining_deck_size}
function remaining_deck() => byte(0x27619F)

// $276278: {1.0.3} [32-bit] Current Costume {gLoadedCostume}
//          0x00 | Mario
//          0x01 | Luigi
//          0x02 | Toad
//          0x03 | Peach
//          0x04 | Baby
//          0x05 | Fallout
//          0x06 | Pizza
//          0x07 | May
//          0x08 | Skeleton
//          0x09 | ABC
//          0x0a | Demon
//          0x0b | Simple
//          0x0c | Walkies
//          0x0d | Golden
//          0x0e | Bowser
//          0x0f | TAS
//          0x10 | Chaos
//          0x11 | (Dev)
function current_deck() => dword(0x276278)

// $27B627: {1.0.3} [8-bit] Big Head Mode Active {bigHeadMode}
function cheat_big_head_mode() => byte(0x27B627)

// $27B62D: {1.0.3} [8-bit] {gMissionTimerRunning}
function mission_timer_running() => byte(0x27B62D)

// $27B62E: {1.0.3} [16-bit] {gPizzaTimer}
function pizza_timer() => word(0x27B62E)

// $27B630: {1.0.3} [8-bit] {gCardUsedThisFrame}
function cards_used_this_frame() => byte(0x27B630)

// $27B631: {1.0.3} [8-bit] {gAirMoveUsed}
function air_move_used() => byte(0x27B631)

// $27B632: {1.0.3} [16-bit] {gMissionTimer}
function mission_timer() => word(0x27B632)

// $2851A1: {1.0.3} [8-bit] Current/Last Casino Visitor
//          0x00 | (none)
//          0x01 | Yoshi
//          0x02 | Ukiki
//          0x03 | Mr I
//          0x04 | Gambling Koopa
//          0x05 | Toads
//          0x06 | Penguins
//          0x07 | Boos
//          0x08 | Piranha Plants
//          0x09 | Peach
//          0x0a | MIPS
//          0x0b | Big Bom-Omb Buddy
//          0x0c | Bathroom Queue
function current_casino_visitor() => byte(0x2851A1)

// $2868B3: {1.0.3} [8-bit] Text Selection {currSelection}
function text_selection() => byte(0x2868B3)

// $286A6C: {1.0.3} [256 Bytes] Current Text {mainCopyDialog}
function current_text() => byte(0x286A6C)

// $286B6C: {1.0.3} [256 Bytes] Drawn Text {mainDialogDisplay}
function drawn_text() => byte(0x286B6C)

// $286C6C: {1.0.3} [24 Bytes] {gDialogState}
//          +0x00 | Main Text Box State [32-bit]
//          --- 0x02 | Drawing Text
//          --- 0x06 | Finished
function text_box_state() => byte(0x286C6C)

// $286C84: {1.0.3} [24 Bytes] {gCurrDialogID}
function current_dialog_id() => byte(0x286C84)

// $287E94: {1.0.3} [16-bit] Current Sub-Map ID
function current_submap_id() => word(0x287E94)

// $2884B4: {1.0.3} [48 Bytes, 8 Bytes per card} Luigi Shop Contents
//          +0x00 | [8-bit] Max Uses
//          +0x01 | [8-bit] Uses Left
//          +0x02 | [8-bit] Card ID
//          +0x03 | [8-bit] Type
//          --- 0x00 | Used (add new card)
//          --- 0x01 | Active
//          --- 0x02 | Passive
//          --- 0x03 | Special
//          --- 0x05 | Empty
function luigi_slot(i) => 0x2884B4 + 0x8*i

// $28867C: {1.0.3} [40 Bytes] {PlayerHand}
//          +0x00 | [8 Bytes] B Button
//          --- +0x00 | [8-bit] Max Uses
//          --- +0x01 | [8-bit] Uses Left
//          --- +0x02 | [8-bit] Card ID
//          --- +0x03 | [8-bit] Type
//          --- --- 0x00 | Used (add new card)
//          --- --- 0x01 | Active
//          --- --- 0x02 | Passive
//          --- --- 0x03 | Special
//          --- --- 0x05 | Empty
//          +0x08 | [8 Bytes] A Button
//          --- +0x00 | [8-bit] Max Uses
//          --- +0x01 | [8-bit] Uses Left
//          --- +0x02 | [8-bit] Card ID
//          --- +0x03 | [8-bit] Type
//          +0x10 | [8 Bytes] Z Button
//          --- +0x00 | [8-bit] Max Uses
//          --- +0x01 | [8-bit] Uses Left
//          --- +0x02 | [8-bit] Card ID
//          --- +0x03 | [8-bit] Type
//          +0x18 | [8 Bytes] R Button
//          --- +0x00 | [8-bit] Max Uses
//          --- +0x01 | [8-bit] Uses Left
//          --- +0x02 | [8-bit] Card ID
//          --- +0x03 | [8-bit] Type
//          +0x20 | [8 Bytes] Passive Card
//          --- +0x00 | [8-bit] Max Uses
//          --- +0x01 | [8-bit] Uses Left
//          --- +0x02 | [8-bit] Card ID
//          --- +0x03 | [8-bit] Type
function player_hand(i) => 0x28867C + 0x8*i

// $2886A4: {1.0.3} [400 Bytes, 8 Bytes per Card] {MasterDeck}
//          +0x00 | [8-bit] Max Uses
//          +0x01 | [8-bit] Uses Left
//          +0x02 | [8-bit] Card ID
//          +0x03 | [8-bit] Type
//          --- 0x00 | Used (add new card)
//          --- 0x01 | Active
//          --- 0x02 | Passive
//          --- 0x03 | Special
//          --- 0x05 | Empty
function full_deck(i) => 0x2886A4 + 0x8*i

// $288834: {1.0.3} [400 Bytes, 8 Bytes per Card] Drawn Stack {PlayerDeck}
//          (populated on level enter, cards are drawn off the top)
//          +0x00 | [8-bit] Max Uses
//          +0x01 | [8-bit] Uses Left
//          +0x02 | [8-bit] Card ID
//          +0x03 | [8-bit] Type
//          --- 0x00 | Used (add new card)
//          --- 0x01 | Active
//          --- 0x02 | Passive
//          --- 0x03 | Special
//          --- 0x05 | Empty
function shuffled_deck(i) => 0x288834 + 0x8*i

// $2B3235: {1.0.3} [8-bit] Sub-Map ID (loading)
function submap_id() => byte(0x2B3235)

// $2B3236: {1.0.3} [8-bit] Map ID (loading)
function map_id() => byte(0x2B3236)

// $2B3237: {1.0.3} [8-bit] Map is Loading
//          0x01 = Loading
function loading_in_progress() => byte(0x2B3237) == 1

// $2B3244: {1.0.3} [16-bit] (HUD) Total Coins - Amount
function hud_total_coins() => word(0x2B3244)

// $2B3246: {1.0.3} [16-bit] (HUD) Lives - Amount
function hud_lives() => word(0x2B3246)

// $2B3260: {1.0.3} [8-bit] Animation ID
//          0x02 | Star Collected
function animation_id() => byte(0x2B3260)

// $2B3290: [Float] {1.0.3} Mario Position - X
function mario_position_x() => float(0x2B3290)

// $2B3294: [Float] {1.0.3} Mario Position - Y
function mario_position_y() => float(0x2B3294)

// $2B3298: [Float] {1.0.3} Mario Position - Z
function mario_position_z() => float(0x2B3298)

// $2B32FC: {1.0.3} [16-bit] Stars Obtained (amount)
function stars_obtained() => word(0x2B32FC)

// $2B32FE: {1.0.3} [16-bit] Level Coins
function level_coins() => word(0x2B32FE)

// $2B3301: {1.0.3} [8-bit] Current HP
function current_hp() => byte(0x2B3301)

// $2B3302: {1.0.3} [8-bit] Lives - Amount
function lives_remaining() => byte(0x2B3302)

// $7CD504: {1.0.3} [8 Bytes] Cheat Code Input
function cheat_code_input() => byte(0x7CD504)

// --- MAIN DATA -------------------------------------------------------------------

MAX_DECK_SIZE = 50

BTN_B = 0
BTN_A = 1
BTN_Z = 2
BTN_R = 3
PASSIVE_SLOT = 4

CARD_NAME = {
	// active cards (0x01)
	0x0100: "-",
	0x0101: "Jump",
	0x0102: "Weak Jump",
	0x0103: "Triple Jump",
	0x0104: "Special Triple",
	0x0105: "Beta Triple",
	0x0106: "Flipma",
	0x0107: "Punch",
	0x0108: "Dive/Kick",
	0x0109: "Air Jump",
	0x010a: "Rocket Launch",
	0x010b: "Galaxy Spin",
	0x010c: "Clip",
	0x010d: "Crouch",
	0x010e: "Long Jump",
	0x010f: "Totsugeki",
	0x0110: "Balloon",
	0x0111: "BLJ",
	0x0112: "Throw Bomb",
	0x0113: "Tweester",
	0x0114: "Crazy Box",
	0x0115: "Koopa Shell",
	0x0116: "Cannon Launch",
	0x0117: "Cloud Flower",
	0x0118: "Updraft Wind",
	0x0119: "Breakdance",
	0x011a: "Shoulder Bash",
	0x011b: "Bonk",
	0x011c: "Trip",
	0x011d: "Heal in Ground",
	0x011e: "Health Refill",
	0x011f: "Wing Cap Jump",
	0x0120: "Lose One Health",
	0x0121: "Four of Hearts",
	0x0122: "Mystery Card",
	0x0123: "Spheal",
	0x0124: "Charizard",
	0x0125: "Amoonguss",
	0x0126: "Explosive Jump",
	0x0127: "Random Teleport",
	0x0128: "Get Ten Coins",
	0x0129: "Levitate",
	0x012a: "Exodia R Arm",
	0x012b: "Exodia L Arm",
	0x012c: "Exodia R Leg",
	0x012d: "Exodia L Leg",
	0x012e: "Work Elevator",
	0x012f: "Hey Stinky!",
	0x0130: "Rollout",
	0x0131: "Fix All",
	0x0132: "Launch Towards Star",
	0x0133: "All Caps",
	0x0134: "Hover",
	0x0135: "Lava Boost",
	0x0136: "Chuckya Friend",
	0x0137: "Warp to Spawn",
	0x0138: "Fire Flower",
	0x0139: "Super Jump",
	0x013a: "Button Lock",
	0x013b: "Metal Cap",
	0x013c: "Vanish Cap",
	
	// passive cards (0x02)
	0x0200: "-",
	0x0201: "Wallkicks",
	0x0202: "Green Demon",
	0x0203: "Coin Magnet",
	0x0204: "Star Magnet",
	0x0205: "Health Drain",
	0x0206: "Health Regen",
	0x0207: "Speed Up",
	0x0208: "Luigi Physics",
	0x0209: "Goomba Army",
	0x020a: "Bomb Rain",
	0x020b: "Mario Maker Spam",
	0x020c: "Hi Grav",
	0x020d: "Lo Grav",
	0x020e: "Speed Down",
	0x020f: "Invisible",
	0x0210: "RNG Manip",
	0x0211: "Button Swap",
	0x0212: "Buttery",
	0x0213: "Reverse Controls",
	0x0214: "Releasio Physics",
	0x0215: "DS D-Pad",
	0x0216: "Squished",
	0x0217: "2x Coins",
	0x0218: "No Glasses",
	0x0219: "Sine Speed",
	0x021a: "Cinematic Mode",
	0x021b: "Quake Pro",
	0x021c: "Glue Man",
	0x021d: "Hoverboots",
	0x021e: "No Fall Damage",
	0x021f: "Walkies",
	0x0220: "Pop-up Ads",
	0x0221: "Hitboxes",
	0x0222: "Exodia",
	0x0224: "Hatless",
	
	// special cards (0x03)
	0x0300: "-",
	0x0301: "One Health",
	0x0302: "Shuffler",
	0x0303: "Repair All",
	0x0304: "Random Textbox",
	0x0305: "Spin the Wheel",
	0x0306: "URGH!",
	0x0307: "Trivia Question",
	0x0308: "Where we Droppin'?",
	0x0309: "Mad Piano",
	0x030a: "Troll",
	0x030b: "Mario Choir",
	0x030c: "Pizza Time",
	0x030d: "Snowman Firing Squad",
	0x030e: "Chuckya Foes",
	0x030f: "Pitfall",

	// empty
	0x0500: "-",
}

STAGE_NAME = {
	0x04: "Big Boo's Haunt",
	0x05: "Cool Cool Mountain",
	0x07: "Hazy Maze Cave",
	0x08: "Shifting Sand Land",
	0x09: "Bob-Omb Battlefield",
	0x0a: "Snowman's Land",
	0x0d: "Tiny-Huge Island",
	0x0e: "Tick Tock Clock",
	0x0f: "Rainbow Ride",
	0x11: "Bowser's Gauntlet (Dark World)",
	0x13: "Bowser's Gauntlet (Fire Sea)",
	0x15: "Bowser's Gauntlet (In the Sky)",
	0x16: "Lethal Lava Land",
	0x18: "Whomp's Fortress",
	0x24: "Tall Tall Mountain",
	0x27: "Luigi's Casino",
	0x28: "Jolly Roger Bay",
	0x29: "Wet Dry World",
}

PAINTING_NAME = {
	0x00: "Bob-omb Battlefield",
	0x01: "Cool, Cool Mountain",
	0x02: "Whomp's Fortress",
	0x03: "Tall, Tall Mountain",
	0x04: "Jolly Roger Bay",
	0x05: "Wet-Dry World",
	0x06: "Lethal Lava Land",
	0x07: "Tick Tock Clock",
	0x08: "Rainbow Ride",
	0x09: "Big Boo's Haunt",
	0x0a: "Shifting Sand Land",
	0x0b: "Snowman's Land",
	0x0c: "Hazy Maze Cave",
	0x0d: "Tiny-Huge Island",
	0xff: "Bowser's Gauntlet"
}

DECK_NAME = {
	0x00: "Mario",
	0x01: "Luigi",
	0x02: "Toad",
	0x03: "Peach",
	0x04: "Baby",
	0x05: "Fallout",
	0x06: "Pizza",
	0x07: "May",
	0x08: "Skeleton",
	0x09: "ABC",
	0x0a: "Demon",
	0x0b: "Simple",
	0x0c: "Walkies",
	0x0d: "Golden",
	0x0e: "Bowser",
	0x0f: "TAS",
	0x10: "Chaos",
	0x11: "*Dev",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

//          +0x00 | [8-bit] Max Uses
//          +0x01 | [8-bit] Uses Left
//          +0x02 | [8-bit] Card ID
//          +0x03 | [8-bit] Type
function card_max_uses(addr) => byte(addr + 0)
function card_uses_left(addr) => byte(addr + 1)
function card_short_id(addr) => byte(addr + 2)
function card_type(addr) => byte(addr + 3)

// read Card ID and Type together for a single unique id
function card_id(addr) => word(addr + 2)

// 0x00 means empty (in a deck, not in hand)
function is_card(addr) => card_type(addr)/card_type(addr)

function deck_size() => sum_of(range(0, MAX_DECK_SIZE-1), i => is_card(full_deck(i)))
function draw_size() => sum_of(range(0, MAX_DECK_SIZE-1), i => is_card(shuffled_deck(i)))

function actual_painting() => max_of(
	measured(current_hub_painting(), when=stars_obtained() < 16),
	measured(0xff, when=stars_obtained() >= 16)
)

// --- RICH PRESENCE -------------------------------------------------------------------

rp_deck = rich_presence_lookup("Deck", current_deck(), DECK_NAME, fallback=DECK_NAME[0x00])
rp_deck_size = rich_presence_value("_Number", deck_size(), "VALUE")
rp_draw_size = rich_presence_value("_Number", draw_size(), "VALUE")

rp_stage = rich_presence_lookup("Stage", current_map(), STAGE_NAME, fallback="???")
rp_painting = rich_presence_lookup("Painting", actual_painting(), PAINTING_NAME, fallback="???")
rp_stars = rich_presence_value("_Number", stars_obtained(), "VALUE")

rp_total_coins = rich_presence_value("_Number", total_coins(), "VALUE")
rp_level_coins = rich_presence_value("_Number", level_coins(), "VALUE")

function rp_card_name(x) => rich_presence_lookup("Card", card_id(x), CARD_NAME, fallback="???")
function rp_card_uses(x) => rich_presence_value("_Number", card_uses_left(x), "VALUE")

rp_lives = rich_presence_value("_Number", lives_remaining(), "VALUE")
rp_life_word = rich_presence_lookup("_LifeWord", lives_remaining(), {1: "life"}, fallback="lives")

rp_run_time = rich_presence_value("_Time", global_timer(), "FRAMES")

rp_wins = rich_presence_value("_Number", total_wins(), "VALUE")
rp_loss = rich_presence_value("_Number", total_losses(), "VALUE")

rich_presence_conditional_display(current_map() < 4,
	"🃏 BAZR - Title Screen ({0} win{1}, {2} loss{3})",
	rp_wins, plural(total_wins()),
	rp_loss, plurale(total_losses())
)

rich_presence_conditional_display(active_run() == 0,
	"🃏 BAZR - Starting a new run ({0} win{1}, {2} loss{3})",
	rp_wins, plural(total_wins()),
	rp_loss, plurale(total_losses())
)

rich_presence_conditional_display(current_map() == 0x27,
	"🎰 Luigi's Casino • 🃏 {0} Deck ({1} card{2}) • 🖼️ {3} • ⭐ {4}/16 star{5} • 🚶 {6} {7} • 💰 {8} coin{9} • ⏰ {10}",
	rp_deck, rp_deck_size, plural(deck_size()),
	rp_painting,
	rp_stars, plural(stars_obtained()),
	rp_lives, rp_life_word,
	rp_total_coins, plural(total_coins()),
	rp_run_time
)

rich_presence_display(
	"🗺️ {0} • 🃏 {1} Deck • [B] {2} x{3} • [A] {4} x{5} • [Z] {6} x{7} • [R] {8} x{9} • " + 
		"(passive) {10} • {11} card{12} remaining • ⭐ {13} • 🚶 {14} • 🪙 {15} • ⏰ {16}",
	rp_stage,
	rp_deck,
	rp_card_name(player_hand(BTN_B)), rp_card_uses(player_hand(BTN_B)),
	rp_card_name(player_hand(BTN_A)), rp_card_uses(player_hand(BTN_A)),
	rp_card_name(player_hand(BTN_Z)), rp_card_uses(player_hand(BTN_Z)),
	rp_card_name(player_hand(BTN_R)), rp_card_uses(player_hand(BTN_R)),
	rp_card_name(player_hand(PASSIVE_SLOT)),
	rp_draw_size, plural(draw_size()),
	rp_stars, rp_lives, rp_level_coins, rp_run_time
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- LEADERBOARDS -------------------------------------------------------------------
