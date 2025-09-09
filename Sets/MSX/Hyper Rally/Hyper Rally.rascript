// Hyper Rally
// #ID = 27468

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $2000: Game State [16 bit BE]
//        0x00xx = Konami presents
//        0x01xx = title screen
//        0x0200 = loading attract mode
//        0x0201 = attract mode screen
//        0x03xx = new game start
//        0x0400 = loading stage card
//        0x0402 = stage card (stage X)
//        0x0403 = loading race stage
//        0x0404 = race "ready"
//        0x0405 = race "start"
//        0x0500 = racing
//        0x06xx = game over?
//        0x0700 = cross finish line
//        0x0701 = qualification (both)
//        0x0702 = unloading race stage
//        0x0800 = cross finish line of last leg
//        0x0801 = "goal"
function full_state() => word_be(addr_offset() + 0x002000)
function game_state() => byte(addr_offset() + 0x002000)

// $200A: Player Input [8 bit]
//        bit0 | up (brake)
//        bit1 | down
//        bit2 | left
//        bit3 | right
//        bit4 | btn1 (gas)
//        bit5 | btn2
function btn_up() => bit0(addr_offset() + 0x00200A)
function btn_dn() => bit1(addr_offset() + 0x00200A)
function btn_lt() => bit2(addr_offset() + 0x00200A)
function btn_rt() => bit3(addr_offset() + 0x00200A)
function btn_1() => bit4(addr_offset() + 0x00200A)
function btn_2() => bit5(addr_offset() + 0x00200A)

function btn_gas() => btn_1()
function btn_brake() => btn_up()

// $203A: Sound Effect Info [8 bit]
//        0x8a = Collision
//        0x98 = Gutter
//        0xaa = Squealing Tires
//        0xb8 = Normal Driving
function sound() => byte(addr_offset() + 0x00203A)

// $2058: Score [24 bit BCD]
function score() => bcd(tbyte(addr_offset() + 0x002058))

// $205B: Rank [16 bit BE BCD]
function rank() => bcd(word_be(addr_offset() + 0x00205B))

// $205D: Qualifying Rank [16 bit BE BCD]
function qualifying_rank() => bcd(word_be(addr_offset() + 0x00205D))

// $2060: Stage [8 bit]
function stage() => byte(addr_offset() + 0x002060)

// $2061: Map Type [8 bit]
//        0x00 = sunny day
//        0x01 = tunnel
//        0x02 = ice
//        0x06 = snow
//        0x08 = night city/pyramids
//        0x10 = overcast
//        0x20 = desert
//        0x40 = highlands
function map_type() => byte(addr_offset() + 0x002061)

// $2065: Fuel Units [8 bit]
//        starts 0xFF, counts down to 0
function fuel_units() => byte(addr_offset() + 0x002065)

// $2066: Fuel Sub-Units [8 bit]
//        when 0->40, decrement 0x002065
//        goes down by 3 when speed is <=17 (~25 km/h)
//        goes down by 1 otherwise
function fuel_sub_units() => byte(addr_offset() + 0x002066)

// $2068: Time Seconds [8 bit BCD]
//        every "second" lasts 17 frames
function time_seconds() => bcd(byte(addr_offset() + 0x002068))

// $2069: Time Minutes [8 bit BCD]
function time_minutes() => bcd(byte(addr_offset() + 0x002069))
function time() => time_minutes() * 60 + time_seconds()

// $2071: Stage Progress [8 bit]
//        counts down, 0 at finish line
function stage_progress() => byte(addr_offset() + 0x002071)

// $2085: Speed [8 bit]
//        0x10 = 21 km/h
//        0x20 = 46 km/h
//        0x30 = 71 km/h
//        0x40 = 96 km/h
//        0x7F = 194 km/h
//        0x80 = 196 km/h
//        0xFF = 394 km/h (max)
function speed() => byte(addr_offset() + 0x002085)

// $2086: Gear [8 bit]
//        0 = Low
//        1 = High
//        
//        can shift to high gear if speed >= 80
//        automatically shifts to low when speed < 80
function gear() => byte(addr_offset() + 0x002086)

// $2121: Player Car X Position [8 bit]
//        this value seems to be tied to graphics, but does seem manipulable
//        similar type values for this car seem to be at 4 byte offsets from this location
//        
//        leftmost 0x1d
//        left lane 0x2a-0x60
//        right lane 0x7e-0xb5
//        rightmost 0xc2
function player_car_x_position() => dword(addr_offset() + 0x002121)

// --- MAIN DATA -------------------------------------------------------------------

STATE_KONAMI = 0x00
STATE_TITLE = 0x01
STATE_DEMO = 0x02
STATE_NEWGAME = 0x03
STATE_SETUP = 0x04
STATE_RACING = 0x05
STATE_GAMEOVER = 0x06
STATE_FINISH_STAGE = 0x07
STATE_FINISH_GAME = 0x08

GAME_STATE = {
	STATE_SETUP: "🚦",
	STATE_RACING: "🏎️",
	STATE_FINISH_STAGE: "🏁",
	STATE_FINISH_GAME: "🏁",
}

TYPE_SUNNY = 0x00
TYPE_TUNNEL = 0x01
TYPE_ICE = 0x02
TYPE_SNOW = 0x06
TYPE_NIGHT = 0x08
TYPE_OVERCAST = 0x10
TYPE_DESERT = 0x20
TYPE_HIGHLANDS = 0x40

DARK_TYPES = [TYPE_TUNNEL, TYPE_NIGHT]
ICE_TYPES = [TYPE_ICE, TYPE_SNOW]

MAP_TYPES = {
	TYPE_SUNNY: "☀️",
	TYPE_TUNNEL: "🚞",
	TYPE_ICE: "🧊",
	TYPE_SNOW: "❄️",
	TYPE_NIGHT: "🌃",
	TYPE_OVERCAST: "⛈️",
	TYPE_DESERT: "🏜️",
	TYPE_HIGHLANDS: "🌄",
}

GEAR_LO = 0
GEAR_HI = 1

GEARS = {
	GEAR_LO: "🔽",
	GEAR_HI: "🔼",
}

SOUND_COLLISION = 0x8a
SOUND_GUTTER = 0x98

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => game_state() >= STATE_NEWGAME

function race_start() => prev(full_state()) == 0x0404 && full_state() == 0x0405
function race_done() => prev(game_state()) == STATE_RACING && game_state() >= STATE_FINISH_STAGE
function race_qualified() => race_done() && rank() <= qualifying_rank()

function speed_kmh() => speed() * (0.0000437729844 * speed() + 1.54588068) - 2.98243984
// function speed_kmh() => 1.56049106 * speed() - 4.015686 + (11.6165825 / speed())

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(game_state() == STATE_RACING,
	"{0} Stage {1} · 📈 Progress: {2}% ⏱️ {3} · 🏅 Rank {4}/{5} {6} · ⛽ Fuel: {7}% · ⏩ {8} km/h {9}",
	rich_presence_lookup("MapType", map_type(), MAP_TYPES, fallback=MAP_TYPES[TYPE_SUNNY]),
	rich_presence_number(stage()),
	rich_presence_value("Progress", (1000 * (0xD0 - stage_progress())) / 0xD0, "FIXED1"),
	rich_presence_value("Time", time(), "SECS"),
	rich_presence_number(rank()),
	rich_presence_number(qualifying_rank()),
	rich_presence_lookup("Qualified", max_of(measured(1, when=rank() <= qualifying_rank()), measured(0)), {1: "✅"}, fallback="❌"),
	rich_presence_value("Fuel", 1000 * fuel_units() / 0xFF, "FIXED1"),
	rich_presence_number(speed_kmh()),
	rich_presence_lookup("Gear", gear(), GEARS, fallback=GEARS[0])
)

rich_presence_conditional_display(game_state() == STATE_SETUP,
	"🚦 Setting Up · {0} Stage {1} · 🏅 Rank {2}/{3}",
	rich_presence_lookup("MapType", map_type(), MAP_TYPES, fallback=MAP_TYPES[TYPE_SUNNY]),
	rich_presence_number(stage()),
	rich_presence_number(rank()),
	rich_presence_number(qualifying_rank())
)

rich_presence_conditional_display(game_state() >= STATE_FINISH_STAGE,
	"🏁 Finish Line · {0} Stage {1} · 🏅 Rank {2}/{3} {4}",
	rich_presence_lookup("MapType", map_type(), MAP_TYPES, fallback=MAP_TYPES[TYPE_SUNNY]),
	rich_presence_number(stage()),
	rich_presence_number(rank()),
	rich_presence_number(qualifying_rank()),
	rich_presence_lookup("Qualified", max_of(measured(1, when=rank() <= qualifying_rank()), measured(0)), {1: "✅"}, fallback="❌")
)

rich_presence_display(
	"Hyper Rally | © Konami 1985"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

PROGRESSION_ACHIEVEMENTS = [
	{ "stage": 1, "points": 5, "title": "From the Back of the Pack", },
	{ "stage": 2, "points": 5, "title": "Tunnel Vision", },
	{ "stage": 3, "points": 10, "title": "Get a Grip", },
	{ "stage": 4, "points": 10, "title": "Snow One Sleep in Tokyo", },
	{ "stage": 5, "points": 5, "title": "Night of Fire", },
	{ "stage": 6, "points": 5, "title": "Life in the Fast Lane", },
	{ "stage": 7, "points": 5, "title": "I Bless the Rains", },
	{ "stage": 8, "points": 5, "title": "There Can Be Only One", },
	{ "stage": 9, "points": 10, "title": "Gas Gas Gas", },
	{ "stage": 10, "points": 5, "title": "Running in the 90s", },
	{ "stage": 11, "points": 10, "title": "It's All Sand", },
	{ "stage": 12, "points": 10, "title": "Neon Night Riders", },
//	{ "stage": 13, "points": "25", "title": "", },
]

for data in PROGRESSION_ACHIEVEMENTS
{
	achievement(
		title=data["title"],
		description=format("Complete Stage {0} and qualify for the next stage", data["stage"]),
		type="progression",
		points=data["points"],
		trigger=stage() == data["stage"] && race_qualified()
	)
}

achievement(
	title="The Cream of the Crop",
	description="Cross the finish line of the final stage and complete the Konami Hyper Rally",
	type="win_condition",
	points=10,
	trigger=stage() == 13 && race_done()
)

achievement(
	title="The Best of the Best",
	description="Complete the final stage in first place",
	points=10,
	trigger=stage() == 13 && race_done() && rank() == 1
)

achievement(
	title="Braking the Habit",
	description="Reach the finish line of any stage without braking",
	points=10,
	trigger=(
		once(race_start()) && 
		never(btn_brake() == 1) && 
		never(!in_game()) &&
		trigger_when(race_done())
	)
)

achievement(
	title="Fender Defender",
	description="Reach the finish line of any ice or snow stage without colliding with another car",
	points=10,
	trigger=(
		once(race_start() && __ornext(any_of(ICE_TYPES, t => map_type() == t))) && 
		never(sound() == SOUND_COLLISION) && 
		never(!in_game()) &&
		trigger_when(race_done())
	)
)

achievement(
	title="I Wear My Sunglasses at Night",
	description="Reach the finish line of any night or tunnel stage without touching the edges of the road",
	points=5,
	trigger=(
		once(race_start() && __ornext(any_of(DARK_TYPES, t => map_type() == t))) && 
		never(sound() == SOUND_GUTTER) && 
		never(!in_game()) &&
		trigger_when(race_done())
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="High Score",
	description="Highest score at the end of the final stage or when disqualified",

	start=(
		// game over mid-race
		(prev(game_state()) == STATE_RACING && game_state() == STATE_GAMEOVER) ||
		// finish a leg and don't qualify (works for final stage because q.rank is 0)
		(race_done() && rank() > qualifying_rank())
	),
	cancel=always_false(),
	submit=always_true(),

	value=measured(score()),
	format="SCORE",
	lower_is_better=false
)

for x in range(1,13)
{
	leaderboard(
		title=format("Hyper Stage {0} Speedrun", x),
		description=format("Fastest time on Stage {0} at the finish line", x),
	
		start=stage() == x && race_done(),
		cancel=always_false(),
		submit=always_true(),
	
		value=measured(time()),
		format="SECS",
		lower_is_better=true
	)
}