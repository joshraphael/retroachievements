// Monopoly
// #ID = 11067

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $0363: Turns Remaining in Jail [6 bytes]
//        indexed by token
function jail_time(t) => byte(0x000363+t)

// $038F: Get Out of Jail Free (Chance) Owner [8 bit]
// $0390: Get Out of Jail Free (CC) Owner [8 bit]
//        0xFF = unowned
//        indexed by token (0-indexed)
function jailcard_1_owner() => byte(0x00038F)
function jailcard_2_owner() => byte(0x000390)

// $0395: Game State [8 bit]
//        0xff = Normal Game
//        0x80 = Short Game
function game_type() => byte(0x000395)

// $0397: Frames Remaining Short Game [8 bit]
//        rolls over at 49->0
function short_game_frames() => byte(0x000397)

// $0398: Seconds Remaining Short Game [8 bit]
//        "seconds", rolls over at 57->0
function short_game_seconds() => byte(0x000398)

// $0399: Time Remaining Short Game [3 bytes]
//        1:59 => 0x09 0x05 0x01
function short_game_timer() => tbyte(0x000399)
function short_game_minutes() => byte(0x000399) + 10 * byte(0x00039a) + 60 * byte(0x00039b)

// $14C2: Setup and Title Indicator [8 bit]
//        this value *probably* has something to do with showing the 6 pieces in the bottom field
//        
//        0xFF = title screen or in-game
//        use player count to discern between those cases
//        0x08 = pre-game setup or post-game stats, but just check not-0xFF
function setup_indicator() => byte(0x0014C2)

// $7CEC: Dice Sum [8 bit]
//        during gameplay, not during selecting turn order
function dice_sum() => byte(0x007CEC)

// $7D82: Player Position on Board [6 bytes]
//        6 x 8-bit values for each player's position
//        indexed by token
//        
//        0 = Go!
//        1 = Old Kent Road / £60
//        2 = Community Chest
//        3 = Whitechapel Road / £60
//        4 = Income Tax / Pay £200
//        5 = Kings Cross Station / £200
//        6 = The Angel Islington / £100
//        7 = Chance
//        8 = Euston Road / £100
//        9 = Pentonville Road / £120
//        10 = Just Visiting Jail
//        11 = Pall Mall / £140
//        12 = Electric Company / £150
//        13 = Whitehall / £140
//        14 = Northumber Land Avenue / £160
//        15 = Marylebone Station / £200
//        16 = Bow Street / £180
//        17 = Community Chest
//        18 = Marlborough Street / £180
//        19 = Vine Street / £200
//        20 = Free Parking
//        21 = Strand / £220
//        22 = Chance
//        23 = Fleet Street / £220
//        24 = Trafalgar Square / £240
//        25 = Fenchurch St Station / £200
//        26 = Leicester Square / £260
//        27 = Coventry Street / £260
//        28 = Water Works / £150
//        29 = Piccadilly / £280
//        30 = Go to Jail
//        31 = Regent Street / £300
//        32 = Oxford Street / £300
//        33 = Community Chest
//        34 = Bond Street / £320
//        35 = Liverpool St Station / £200
//        36 = Chance
//        37 = Park Lane / £350
//        38 = Super Tax / Pay £100
//        39 = Mayfair / £400
//        
//        0xFF = In Jail
function position_by_token(t) => byte(0x007D82 + t)

// $7D89: Money [12 bytes]
//        6 x 16-bit values for each player's money
//        indexed by token
//        players start with £1500
function money_by_token(t) => word(0x007D89 + t*2)

// $7DA8: Player Info [6 bytes]
//        one byte per player, in order of selection
//        
//        lower4 | board piece
//        0 = Iron
//        1 = Car
//        2 = Top Hat
//        3 = Boot
//        4 = Dog
//        5 = Ship
//        bit7 | computer controlled (0 no, 1 yes)
function player_info(i) => byte(0x007DA8 + i)
function player_token(i) => low4(0x007DA8 + i)
function player_active(i) => ~bit6(0x007DA8 + i)
function player_is_com(i) => bit7(0x007DA8 + i)

// $7DAF: Auction Price [16 bit]
function auction_price() => word(0x007DAF)

// $7DB1: Auction Current Bidder [8 bit]
//        0xFF = no bids
function auction_current_bidder() => byte(0x007DB1)

// $7DB3: Auction Timer [16 bit]
//        first byte is counting down fast 10->0
//        rollover counts down second byte
//        0x000a = auction ends
function auction_timer() => word(0x007DB3)
function auction_seconds() => byte(0x007DB4)

// $7DC1: Number of Players [8 bit]
function player_count() => byte(0x007DC1)

// $7E04: Player Turn [8 bit]
//        indexes into list at 0x007da8
function current_player() => byte(0x007E04)

// $7E26: #1 Iron Name [8 bytes ASCII]
//        0x0d = CR, used as terminator
//        first character 0x0d (or 0x20?) would indicate no player
// $7E2F: #2 Car Name [8 bytes ASCII]
// $7E38: #3 Hat Name [8 bytes ASCII]
// $7E41: #4 Shoe Name [8 bytes ASCII]
// $7E4A: #5 Dog Name [8 bytes ASCII]
// $7E53: #6 Ship Name [8 bytes ASCII]
function name_addr(p) => 0x007E26 + (p * 9)

// $7EA8: Deed Owned By [40 bytes]
//        indexed by token (0 = unowned, other tokens offset by 1)
//        bit7 | is mortgaged
//        
//        bit6 | use to determine special tile below
//        can use to determine tile type
//        0xF0 = Chance
//        0xF1 = Jail
//        0xF2 = Super Tax
//        0xF3 = Community Chest
//        0xF4 = Go To Jail
//        0xFF = Go/Income Tax/Free Parking
function deed_info(x) => byte(0x007EA8 + x)
function deed_owner(x) => low4(0x007EA8 + x) - 1
function deed_special(x) => bit6(0x007EA8 + x)
function deed_is_mortgaged(x) => bit7(0x007EA8 + x)

// $7ED0: Property Development [40 bytes]
//        0x00-0x04 = 0-4 houses
//        0x05 = hotel
//        0x06 = owned by the bank
function houses(x) => byte(0x007ED0 + x)

// --- MAIN DATA -------------------------------------------------------------------

JAIL_CARDS = [jailcard_1_owner(), jailcard_2_owner()]

// game modes
MODE_SHORT = 0x80
MODE_NORMAL = 0xFF

// hotels are represented as 5 houses
HOTEL = 5

// property groups
PGROUP_YELLOW = [1, 3]
PGROUP_LBLUE = [6, 8, 9]
PGROUP_PINK = [11, 13, 14]
PGROUP_RED = [16, 18, 19]
PGROUP_DRED = [21, 23, 24]
PGROUP_LYELLOW = [26, 27, 29]
PGROUP_GREEN = [31, 32, 34]
PGROUP_BLUE = [37, 39]

PGROUP_UTIL = [12, 28]
PGROUP_RAIL = [5, 15, 25, 35]

// for semantic clarity
ALL_PLAYERS = range(0, 5)
ALL_TOKENS = range(0, 5)

DEED_NAMES = {
	0: "Passing Go!",
	1: "Old Kent Road",
	2: "Community Chest",
	3: "Whitechapel Road",
	4: "Income Tax",
	5: "Kings Cross Station",
	6: "The Angel Islington",
	7: "Chance",
	8: "Euston Road",
	9: "Pentonville Road",
	10: "Just Visiting Jail",
	11: "Pall Mall",
	12: "Electric Company",
	13: "Whitehall",
	14: "Northumber Land Avenue",
	15: "Marylebone Station",
	16: "Bow Street",
	17: "Community Chest",
	18: "Marlborough Street",
	19: "Vine Street",
	20: "Free Parking",
	21: "Strand",
	22: "Chance",
	23: "Fleet Street",
	24: "Trafalgar Square",
	25: "Fenchurch St Station",
	26: "Leicester Square",
	27: "Coventry Street",
	28: "Water Works",
	29: "Piccadilly",
	30: "Go to Jail",
	31: "Regent Street",
	32: "Oxford Street",
	33: "Community Chest",
	34: "Bond Street",
	35: "Liverpool St Station",
	36: "Chance",
	37: "Park Lane",
	38: "Super Tax",
	39: "Mayfair",
	0xFF: "In Jail",
}

DEED_PRICE = {
	1: 60,
	3: 60,
	5: 200,
	6: 100,
	8: 100,
	9: 120,
	11: 140,
	12: 150,
	13: 140,
	14: 160,
	15: 200,
	16: 180,
	18: 180,
	19: 200,
	21: 220,
	23: 220,
	24: 240,
	25: 200,
	26: 260,
	27: 260,
	28: 150,
	29: 280,
	31: 300,
	32: 300,
	34: 320,
	35: 200,
	37: 350,
	39: 400,
}

TOKEN_IRON = 0
TOKEN_CAR = 1
TOKEN_HAT = 2
TOKEN_BOOT = 3
TOKEN_DOG = 4
TOKEN_SHIP = 5

TOKEN_NAMES = {
	TOKEN_IRON: "Iron",
	TOKEN_CAR: "Car",
	TOKEN_HAT: "Top Hat",
	TOKEN_BOOT: "Boot",
	TOKEN_DOG: "Dog",
	TOKEN_SHIP: "Ship",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// just to restrict Measured popups while memory flickers during boot
function game_loaded() => dword(0x000000) == 0xc09cc0e4

function in_game() => game_loaded() && setup_indicator() == 0xFF && player_count() > 0 && player_info(0) != 0xFF
function human_count() => sum_of(ALL_PLAYERS, i => ~player_is_com(i))

function money(p) => money_by_token(player_token(p))
function position(p) => position_by_token(player_token(p))

function make_comma_list(x)
{
	a = x[0]
	for i in range(1, length(x)-1)
		a = a + ", " + x[i]
	return a
}
function pgroup_to_deed_names(g) => make_comma_list(array_map(g, d => DEED_NAMES[d]))

function start_game() => prev(setup_indicator()) != 0xFF && setup_indicator() == 0xFF && human_count() == 1
function setup_short_game() => setup_indicator() == 0xFF && prev(game_type()) != MODE_SHORT && game_type() == MODE_SHORT

function game_end_knockout() => setup_indicator() == 0xFF && player_count() == 2 && prev(player_info(1)) != 0xFF && player_info(1) == 0xFF
function game_end_timeout() => setup_indicator() == 0xFF && game_type() == MODE_SHORT && prev(short_game_timer()) == 0x010000 && short_game_timer() == 0
function human_wins() => game_end_knockout() && player_is_com(0) == 0

// --- RICH PRESENCE -------------------------------------------------------------------

RP_OWNER = { 0: "", }
for t in ALL_TOKENS
	RP_OWNER[t+1] = " (Owned by " + TOKEN_NAMES[t] + ")"

rich_presence_conditional_display(in_game() && human_count() != 1,
	"⚠️ Achievements only supported for games with exactly one human player"
)

for p in ALL_PLAYERS
{
	rich_presence_conditional_display(in_game() && p < player_count() && player_is_com(p) == 0 && game_type() == MODE_NORMAL,
		"{0} vs {1} computer{2} (Normal Game) · 📍 {3}{4} · 💰 £{5}",
		rich_presence_lookup("Token", player_token(p), TOKEN_NAMES, fallback=TOKEN_NAMES[0]),
		rich_presence_number(player_count()-1), plural(player_count()-1),
		rich_presence_lookup("BoardLocation", position(p), DEED_NAMES, fallback=DEED_NAMES[0]),
		"", //rich_presence_lookup("PropertyOwner", deed_owner(position(p))+1, RP_OWNER, fallback=""),
		rich_presence_number(money(p))
	)

	rich_presence_conditional_display(in_game() && p < player_count() && player_is_com(p) == 0,
		"{0} vs {1} computer{2} (Short Game: ⏳ {6} remaining) · 📍 {3}{4} · 💰 £{5}",
		rich_presence_lookup("Token", player_token(p), TOKEN_NAMES, fallback=TOKEN_NAMES[0]),
		rich_presence_number(player_count()-1), plural(player_count()-1),
		rich_presence_lookup("BoardLocation", position(p), DEED_NAMES, fallback=DEED_NAMES[0]),
		"", //rich_presence_lookup("PropertyOwner", deed_owner(position(p))+1, RP_OWNER, fallback=""),
		rich_presence_number(money(p)),
		rich_presence_value("_M", short_game_minutes(), "MINUTES")
	)
}

rich_presence_display(
	"Monopoly: Property Trading Board Game (Leisure Genius)"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Dressed to the Nines",
	description="Win a 2-player game against one computer opponent by knockout",
	type="win_condition",
	points=10,
	trigger=(
		once(start_game() && player_count() == 2) &&
		never(!in_game()) &&
		trigger_when(human_wins())
	)
)

achievement(
	title="Acquisition by Any Means Necessary",
	description="Win a 6-player game against five computer opponents by knockout",
	type="win_condition",
	points=25,
	trigger=(
		once(start_game() && player_count() == 6) &&
		never(!in_game()) &&
		trigger_when(human_wins())
	)
)

achievement(
	title="Hostile Takeover",
	description="Start a short game with a time limit of less than or equal to 1h30 and any number of players and win by knockout before the time expires",
	type="win_condition",
	points=25,
	trigger=(
		once(start_game()) &&
		once(setup_short_game() && short_game_minutes() <= 90) &&
		never(!in_game()) &&
		never(short_game_timer() == 0) &&
		trigger_when(human_wins())
	)
)

function monopoly_achievement(g, group_desc, title)
{
	achievement(
		title=title,
		description=format(
			"In a full-length game, own {0} {1} at once: {2}", 
			if_else(length(g) == 2, "both", "all"), 
			group_desc, pgroup_to_deed_names(g)
		),
		points=length(g),
		trigger=(
			in_game() && human_count() == 1 &&
			any_of(ALL_PLAYERS, p => (
				// add up the number of properties in this group they have
				measured(tally_of(g, length(g), d => (
					once(
						// player is human
						player_is_com(p) == 0 && 
						// mark if this player is the owner of the deed
						deed_owner(d) == player_token(p) && 
						// clear this hit if they stop being the owner of the deed
						never(deed_owner(d) != player_token(p))
					)
				// track while in-game only
				)), when=in_game()) && 
				// previous frame they should not have owned the whole set
				__ornext(any_of(g, d => prev(deed_owner(d)) != player_token(p))) &&
				// clear all hits if in short game
				never(game_type() == MODE_SHORT) &&
				// clear all hits if not in-game
				never(!in_game())
			))
		)
	)
}

function hotel_achievement(g, group_desc, title)
{
	achievement(
		title=title,
		description=format(
			"In a full-length game, develop hotels on {0} {1}: {2}",
			if_else(length(g) == 2, "both", "all"), 
			group_desc, pgroup_to_deed_names(g)
		),
		points=5,
		trigger=(
			in_game() && human_count() == 1 && game_type() == MODE_NORMAL &&
			any_of(ALL_PLAYERS, p => (
				// player must be a human
				player_is_com(p) == 0 && 
				// and they must already own all of the properties (unmortgaged) in the group
				all_of(g, d => (deed_owner(d) == player_token(p) && deed_is_mortgaged(d) == 0))
			)) &&
			// one of the properties must not have had a hotel yet
			__ornext(any_of(g, d => prev(houses(d)) != HOTEL)) &&
			// but finally, all properties have hotels
			trigger_when(all_of(g, d => houses(d) == HOTEL))
		)
	)
}

monopoly_achievement(PGROUP_YELLOW, "properties in the yellow group", "The Road to the Old Country")
monopoly_achievement(PGROUP_LBLUE, "properties in the light blue group", "Blessings of Heaven")
monopoly_achievement(PGROUP_PINK, "properties in the pink group", "No'umberl'd")
monopoly_achievement(PGROUP_RED, "properties in the red group", "Are You Going to Marlborough Fair?")
monopoly_achievement(PGROUP_DRED, "properties in the dark red group", "Which Way to Trafalgar?")
monopoly_achievement(PGROUP_LYELLOW, "properties in the light yellow group", "There Are No Animals at the Piccadilly Circus")
monopoly_achievement(PGROUP_GREEN, "properties in the green group", "The Shopping District")
monopoly_achievement(PGROUP_BLUE, "properties in the blue group", "Mayfair Play")

monopoly_achievement(PGROUP_UTIL, "utilities", "Act Utilitarianism")
monopoly_achievement(PGROUP_RAIL, "railroads", "Now You're on the Trolley")

hotel_achievement(PGROUP_YELLOW, "properties in the yellow group", "Gold Saucer")
hotel_achievement(PGROUP_LBLUE, "properties in the light blue group", "Delfino")
hotel_achievement(PGROUP_PINK, "properties in the pink group", "Marrymore")
hotel_achievement(PGROUP_RED, "properties in the red group", "Mario")
hotel_achievement(PGROUP_DRED, "properties in the dark red group", "Dusk")
hotel_achievement(PGROUP_LYELLOW, "properties in the light yellow group", "Stock Pot")
hotel_achievement(PGROUP_GREEN, "properties in the green group", "Last Resort")
hotel_achievement(PGROUP_BLUE, "properties in the blue group", "Monotoli")

achievement(
	title="Miserly Mr. Monopoly",
	description="Have £5,000 cash on hand",
	points=5,
	trigger=(
		in_game() && human_count() == 1 && 
		any_of(ALL_PLAYERS, p => (
			// a human reached £5000
			player_is_com(p) == 0 && prev(money(p)) < 5000 && money(p) >= 5000
		))
	)
)

achievement(
	title="If the Penalty for a Crime Is a Fine...",
	description="Collect a Get Out of Jail Free card from Chance or Community Chest",
	points=2,
	trigger=(
		// current player is a human
		in_game() && human_count() == 1 && player_is_com(current_player()) == 0 && 
		// either of the jailcards went from unclaimed to being owned by the current player
		any_of(JAIL_CARDS, c => prev(c) == 0xFF && c - player_token(current_player()) == 0)
//		any_of(JAIL_CARDS, c => prev(c) == 0xFF && c == player_token(current_player()))
	)
)

achievement(
	title="Estate Sale",
	description="Land on a property and win it from auction for less than its purchase price",
	points=3,
	trigger=(
		// current player is a human
		in_game() && human_count() == 1 && player_is_com(current_player()) == 0 && 
		// current player is the winner of the auction
		auction_current_bidder() == current_player() && prev(auction_seconds()) == 1 && auction_seconds() == 0 &&
		// the auction price is less than the property purchase price
		any_of(DEED_PRICE, d => position(current_player()) == d && auction_price() < DEED_PRICE[d])
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Maximum Cash in Hand",
	description="Most cash in hand at the end of a game",

	start=(
		once(start_game()) &&
		never(!in_game()) &&
		human_count() == 1 &&
		(game_end_knockout() || game_end_timeout())
	),
	cancel=always_false(),
	submit=always_true(),

	value=max_of(array_map(ALL_PLAYERS, p => measured(money(p), when=player_is_com(p) == 0))),
	format="VALUE",
	lower_is_better=false
)