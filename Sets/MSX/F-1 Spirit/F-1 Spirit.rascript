// F-1 Spirit: The Way to Formula-1
// #ID = 34535

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

// $2210: Timer [16 bit]
//        gets used for countdown at start as well
//        at end of race, (x+1)/20 is time in seconds
function raw_timer() => word(addr_offset() + 0x002210)

// $2250: Game State [8 bit]
//        0x00 = Konami Presents / Title Screen
//        0x02 = Game Menus Loading
//        0x03 = Game Menus
//        0x04 = Command Menu Loading
//        0x05 = Command Menu
//        0x06 = Car Select Loading
//        0x07 = Car Select
//        0x0a = Race Loading
//        0x0b = Racing
//        0x0c = Pit Stop
//        0x0d = Pit Service
//        0x0e = Race Results Loading
//        0x0f = Race Results
//        0x10 = Ending Sequence Loading
//        0x11 = Ending Sequence
//        0x1a = Cross Finish Line
//        0x1b = Cross Finish Line Cutscene
//        0x1c = Paused
//        0x1d = Returning to Title after Credits
function game_state() => byte(addr_offset() + 0x002250)

// $2251: Submenu ID [8 bit]
//        for game menu (0x03):
//        0x02 = event selection
//        
//        for command menu (0x05):
//        0x03 = view password
//        0x04 = enter password
//        0x05 = game reset
//        0x06 = game reset
//        
//        for car select (0x07):
//        0x00 = ready made vs original design
//        0x00 = ready made select
//        0x01 = engine select
//        0x02 = body select
//        0x03 = brake select
//        0x04 = suspension select
//        0x05 = transmission select
//        0x06 = confirm original design
//        0x07 = confirm ready made selection
//        
//        when game state 0x07->0x0a, check if prev(0x2251) is 0x06 or 0x07 to determine ready made vs original design car
function submenu_id() => byte(addr_offset() + 0x002251)

// $225B: Car Type [8 bit]
//        0 = rally
//        1 = stock
//        2 = endurance
//        3 = F3 open wheel
//        4 = F3000 open wheel
//        5 = F1 open wheel
function car_type() => byte(addr_offset() + 0x00225B)

// $225C: Event [8 bit]
//        0 = Rally
//        1 = Stock Race
//        2 = Endurance Race
//        3 = F3 Race
//        4 = F3000 Race
//        5 = F1 Round 1 - Brazil
//        6 = F1 Round 2 - San Marino
//        7 = F1 Round 3 - Belgium
//        8 = F1 Round 4 - Monaco
//        9 = F1 Round 5 - USA
//        10 = F1 Round 6 - France
//        11 = F1 Round 7 - Great Britain
//        12 = F1 Round 8 - West Germany
//        13 = F1 Round 9 - Hungary
//        14 = F1 Round 10 - Austria
//        15 = F1 Round 11 - Italy
//        16 = F1 Round 12 - Portugal
//        17 = F1 Round 13 - Spain
//        18 = F1 Round 14 - Mexico
//        19 = F1 Round 15 - Japan
//        20 = F1 Round 16 - Australia
function event() => byte(addr_offset() + 0x00225C)

// $2280: Points by Race [21 bytes]
//        indexed by events enumerated at 0x225c
//        updates during game state 0x0f
//        
//        1st place - 9 pts
//        2nd place - 8 pts
//        3rd place - 7 pts
//        4th place - 6 pts
//        5th place - 5 pts
//        6th place - 4 pts
//        7th place - 3 pts
//        8th place - 2 pts
//        9th place - 1 pt
//        10th place or worse - shame
function points_by_race(i) => byte(addr_offset() + 0x002280 + i)

// $2295: Total Points [8 bit]
//        updates during game state 0x0f
//        updates on the same frame as table value at 0x2280
function total_points() => byte(addr_offset() + 0x002295)

// $2297: Car Design - Engine [8 bit]
//        0x00 = [endurance] V6 2000 DOHC Super-Charger Low-Compress 780PS
//        0x01 = [endurance] V6 2800 DOHC Super-Charger Wide-Torque 870PS
//        0x02 = [endurance] V8 3200 DOHC-Turbo Easy-Control 900PS
//        0x06 = [stock] V6 1500 DOHC Super-Charger Low-Compress 580PS
//        0x07 = [stock] V6 1490 DOHC Super-Charger Wide-Torque 600PS
//        0x08 = [stock] V8 1200 DOHC-Turbo Easy-Control 700PS
//        0x0c = [rally] V6 1500 DOHC Super-Charger Low-Compress 580PS
//        0x0d = [rally] V6 1490 DOHC Super-Charger Wide-Torque 600PS
//        0x0e = [rally] V8 1200 DOHC-Turbo Easy-Control 700PS
//        0x12 = [F3] V6 2000 DOHC Super-Charger Low-Compress 175PS
//        0x13 = [F3] V6 1800 DOHC Super-Charger Wide-Torque 165PS
//        0x14 = [F3] V8 2000 DOHC-Turbo Easy-Control 175PS
//        0x18 = [F3000] V6 1500 DOHC Super-Charger Low-Compress 400PS
//        0x19 = [F3000] V6 1490 DOHC Super-Charger Wide-Torque 450PS
//        0x1a = [F3000] V8 1200 DOHC-Turbo Easy-Control 470PS
//        0x1e = [F1] V6 1500 DOHC Super-Charger Low-Compress 1180PS
//        0x1f = [F1] V6 1490 DOHC Super-Charger Wide-Torque 1100PS
//        0x20 = [F1] V8 1200 DOHC-Turbo Easy-Control 1200PS
function car_design_engine() => byte(addr_offset() + 0x002297)

// $2298: Car Design - Body [8 bit]
//        0x00 = [rally] (Lt Blue) Strong-Body Carbon Fiber Frame
//        0x01 = [rally] (White) Balanced Setting Carbon Fiber Frame
//        0x02 = [rally] (Yellow) Light-Weight Carbon Fiber Frame
//        0x05 = [stock] (Red) Strong-Body Carbon Fiber Frame
//        0x06 = [stock] (Blue) Balanced Setting Carbon Fiber Frame
//        0x07 = [stock] (Yellow) Light-Weight Carbon Fiber Frame
//        0x09 = [F3] (Red) Strong-Body Carbon Fiber Frame
//        0x0a = [F3] (Green) Balanced Setting Carbon Fiber Frame
//        0x0b = [F3] (Blue) Light-Weight Carbon Fiber Frame
//        0x0c = [F3000] (Blue) Strong-Body Carbon Fiber Frame
//        0x0d = [F3000] (Red) Balanced Setting Carbon Fiber Frame
//        0x0e = [F3000] (Lt Blue) Light-Weight Carbon Fiber Frame
//        0x0f = [stock] (Red) Strong-Body Carbon Fiber Frame
//        0x10 = [stock] (Blue) Balanced Setting Carbon Fiber Frame
//        0x11 = [stock] (Yellow) Light-Weight Carbon Fiber Frame
//        
//        some ids get reused based on chasis type (0x225b)
//        0x06 = [endurance] (Lt Blue) Strong-Body Carbon Fiber Frame
//        0x07 = [endurance] (Green) Balanced Setting Carbon Fiber Frame
//        0x08 = [endurance] (Red) Light-Weight Carbon Fiber Frame
function car_design_body() => byte(addr_offset() + 0x002298)

// $2299: Car Design - Brake [8 bit]
//        0x00 = Front: Disk Type-A / Rear: Disk Type-A
//        0x01 = Front: Disk Type-B / Rear: Drum
//        0x02 = Front: Disk Type-B / Rear: Disk Type-B
//        0x03 = [rally] Front: Disk Type-A / Rear: Disk Type-A
//        0x04 = [rally] Front: Disk Type-B / Rear: Drum
//        0x05 = [rally] Front: Disk Type-B / Rear: Disk Type-B
function car_design_brake() => byte(addr_offset() + 0x002299)

// $229A: Car Design - Suspension [8 bit]
//        0x00 = [rally] Twintube Gas Shock Type Soft-Setting
//        0x01 = [rally] Twintube Adjustable Type Medium-Setting
//        0x02 = [rally] Monotube Oil Shock Type Hard-Setting
//        0x03 = Twintube Gas Shock Type Soft-Setting
//        0x04 = Twintube Adjustable Type Medium-Setting
//        0x05 = Monotube Oil Shock Type Hard-Setting
function car_design_suspension() => byte(addr_offset() + 0x00229A)

// $229B: Car Design - Transmission [8 bit]
//        bit7 | transmission type (0 = manual, 1 = automatic)
//        
//        0x80 = 4 Speed Automatic New Type
//        0x01 = 4 Speed Manual
//        0x02 = 4 Speed Manual Hi-Gear
//        0x83 = 4 Speed Automatic New Type
//        0x04 = 4 Speed Manual
//        0x05 = 4 Speed Manual Hi-Gear
function car_design_transmission() => byte(addr_offset() + 0x00229B)
function is_automatic_transmission() => bit7(addr_offset() + 0x00229B)

// $22A2: Race Active [8 bit]
//        0 = Not Racing
//        1 = Racing
function race_active() => byte(addr_offset() + 0x0022A2)

// $22BC: Laps Remaining [8 bit]
function laps_remaining() => byte(addr_offset() + 0x0022BC)

// $22D0: Speed [16 bit]
//        3256 = 303 km/h
function raw_speed() => word(addr_offset() + 0x0022D0)

// $2310: Fuel [8 bit]
function raw_fuel() => byte(addr_offset() + 0x002310)

// $2315: Pit Status [8 bit]
//        match this up with 0x22a2 (only reliable while race active)
//        0 = In Pit
//        1 = Not in Pit
function in_pit() => 1 - byte(addr_offset() + 0x002315)

// $2323: Pit Repair Timer [8 bit]
//        when stopping it the pit lane, this goes to 160
//        if the entire time is elapsed, car is repaired to good condition
function pit_repair_timer() => byte(addr_offset() + 0x002323)

// $2324: Vehicle Damage Progress [8 bit]
//        damage warning lights are nonsense
//        they are arbitrarily set as this value counts up or if a crash occurs
function vehicle_damage_progress() => byte(addr_offset() + 0x002324)

// $2328: Vehicle Damage Indicators [8 bit]
//        bit0 | Tire F
//        bit1 | Tire R
//        bit2 | Engine
//        bit3 | Brake
function vehicle_damage_indicators() => byte(addr_offset() + 0x002328)
function damage_tire_f() => bit0(addr_offset() + 0x002328)
function damage_tire_r() => bit1(addr_offset() + 0x002328)
function damage_engine() => bit2(addr_offset() + 0x002328)
function damage_brakes() => bit3(addr_offset() + 0x002328)

// $2329: Gear [8 bit]
//        0 = 1st gear
//        1 = 2nd gear
//        etc
function gear() => byte(addr_offset() + 0x002329) + 1

// $2331: Position [8 bit]
function position() => byte(addr_offset() + 0x002331)

// $235D: Highest Unlocked F1 Race [8 bit]
//        for use during event select, 15 max
function highest_unlocked_f1_race() => byte(addr_offset() + 0x00235D)

// --- MAIN DATA -------------------------------------------------------------------

MODE_LOADING_INTRO = 0x00
MODE_INTRO = 0x01
MODE_LOADING_MENU = 0x02
MODE_MENU = 0x03
MODE_LOADING_COMMAND = 0x04
MODE_COMMAND = 0x05
MODE_LOADING_CAR_SELECT = 0x06
MODE_CAR_SELECT = 0x07
MODE_LOADING_RACE = 0x0a
MODE_RACE = 0x0b
MODE_PIT_STOP = 0x0c
MODE_PIT_SERVICE = 0x0d
MODE_LOADING_RACE_RESULTS = 0x0e
MODE_RACE_RESULTS = 0x0f
MODE_LOADING_ENDING = 0x10
MODE_ENDING = 0x11
MODE_FINISH_LINE = 0x1a
MODE_FINISH_LINE_CUTSCENE = 0x1b
MODE_PAUSED = 0x1c
MODE_POST_CREDITS_RETURN = 0x1d

MODES = {
	MODE_LOADING_INTRO: "Title Screen",
	MODE_INTRO: "Title Screen",
	MODE_LOADING_MENU: "Game Menu",
	MODE_MENU: "Game Menu",
	MODE_LOADING_COMMAND: "Command Menu",
	MODE_COMMAND: "Command Menu",
	MODE_LOADING_CAR_SELECT: "Car Select",
	MODE_CAR_SELECT: "Car Select",
	MODE_LOADING_RACE: "Racing",
	MODE_RACE: "Racing",
	MODE_PIT_STOP: "Racing (Pit Stop)",
	MODE_PIT_SERVICE: "Racing (Pit Stop)",
	MODE_LOADING_RACE_RESULTS: "Race Results",
	MODE_RACE_RESULTS: "Race Results",
	MODE_LOADING_ENDING: "Credits",
	MODE_ENDING: "Credits",
	MODE_FINISH_LINE: "Finish Line",
	MODE_FINISH_LINE_CUTSCENE: "Finish Line",
	MODE_PAUSED: "Paused",
	MODE_POST_CREDITS_RETURN: "Credits",
}

TYPE_RALLY = 0
TYPE_STOCK = 1
TYPE_ENDURANCE = 2
TYPE_F3 = 3
TYPE_F3000 = 4
TYPE_F1 = 5

EVENTS = {
	0: "Rally Race",
	1: "Stock Race",
	2: "Endurance Race",
	3: "F3 Race",
	4: "F3000 Race",
	5: "(F1 Round 1) Brazil",
	6: "(F1 Round 2) San Marino",
	7: "(F1 Round 3) Belgium",
	8: "(F1 Round 4) Monaco",
	9: "(F1 Round 5) USA",
	10: "(F1 Round 6) France",
	11: "(F1 Round 7) Great Britain",
	12: "(F1 Round 8) West Germany",
	13: "(F1 Round 9) Hungary",
	14: "(F1 Round 10) Austria",
	15: "(F1 Round 11) Italy",
	16: "(F1 Round 12) Portugal",
	17: "(F1 Round 13) Spain",
	18: "(F1 Round 14) Mexico",
	19: "(F1 Round 15) Japan",
	20: "(F1 Round 16) Australia",
}

ORDINAL = {
	1: "1st",
	2: "2nd",
	3: "3rd",
	4: "4th",
	5: "5th",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// almost every game state has a "loading" version of the state as x-1
function is_game_mode(x) => game_state() == x-1 || game_state() == x

// MODE_RACE includes the countdown at the start of the race, so we have a supporting value
function racing() => game_state() >= MODE_RACE && game_state() <= MODE_PIT_SERVICE && race_active() == 1

function make_custom_car() => (
	prev(game_state()) == MODE_CAR_SELECT && 
	game_state() == MODE_LOADING_RACE && 
	prev(submenu_id()) == 6
)

function is_custom_car() => once(make_custom_car() && never(game_state() == MODE_LOADING_CAR_SELECT))

// conversions of raw values to useful formats
function race_time() => (raw_timer() + 0) / 20.0
function speed() => raw_speed() * 303.0 / 3256
function fuel() => raw_fuel() * 100 / 255

function finish_event(x) => prev(game_state()) == MODE_RACE && game_state() == MODE_FINISH_LINE && event() == x
function unlock_points(p) => game_state() == MODE_RACE_RESULTS && prev(total_points()) < p && total_points() >= p

// --- RICH PRESENCE -------------------------------------------------------------------

rp_custom_car = rich_presence_lookup("CustomCar", 
	max_of(measured(1, when=is_custom_car()), measured(0)), 
	{1: "Original Design"}, fallback="Ready Made")
rp_transmission = rich_presence_lookup("Transmission", is_automatic_transmission(), {1: "AT"}, fallback="MT")

rich_presence_conditional_display(racing() && race_active() == 1,
	"🗺️ {0} ({1} lap{2} remaining) · 🏅 Position: {8} · ⏱️ {9} · 🏎️ {3} ({4}) [{6} km/h, {5} gear, fuel {7}%]",
	rich_presence_lookup("Event", event(), EVENTS, fallback="Unknown Event"),
	rich_presence_number(laps_remaining()), plural(laps_remaining()),
	rp_custom_car, rp_transmission,
	rich_presence_lookup("Ordinal", gear(), ORDINAL, fallback=ORDINAL[1]),
	rich_presence_value("Speed", speed(), "VALUE"),
	rich_presence_number(fuel()),
	rich_presence_number(position()),
	rich_presence_value("RaceTime", race_time() * 100, "MILLISECS")
)

rich_presence_conditional_display(is_game_mode(MODE_RACE),
	"🚦 Race Countdown · 🗺️ {0} · 🏎️ {1} ({2})",
	rich_presence_lookup("Event", event(), EVENTS, fallback="Unknown Event"),
	rp_custom_car, rp_transmission
)

rich_presence_conditional_display(is_game_mode(MODE_FINISH_LINE_CUTSCENE) || is_game_mode(MODE_RACE_RESULTS),
	"📈 Race Results · 🗺️ {0} · 🏅 Final Position: {1} (+{2}p, {3}p total) · ⏱️ {4} · 🏎️ {5} ({6})",
	rich_presence_lookup("Event", event(), EVENTS, fallback="Unknown Event"),
	rich_presence_number(position()),
	rich_presence_number(max_of(
		measured(10-position(), when=position() < 10),
		measured(0)
	)),
	rich_presence_number(total_points()),
	rich_presence_value("RaceTime", race_time() * 100, "MILLISECS"),
	rp_custom_car, rp_transmission
)

rich_presence_display(
	"[{0}] F-1 Spirit: The Way to Formula-1 | © Konami 1987",
	rich_presence_lookup("Mode", game_state(), MODES, fallback=MODES[MODE_INTRO])
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Gentlemen, Start Your Engines",
	description="Place 1st place in the stock car event",
	points=5,
	trigger=finish_event(1) && position() == 1
)

achievement(
	title="Race Hard, Win Easy",
	description="Place 1st place in the rally event",
	points=5,
	trigger=finish_event(0) && position() == 1
)

achievement(
	title="Chase the Checkered Flag",
	description="Place 1st place in the F3 event",
	points=5,
	trigger=finish_event(3) && position() == 1
)

achievement(
	title="The First Step",
	description="Earn 12 points and unlock Endurance and F3000 modes",
	type="progression",
	points=3,
	trigger=unlock_points(12)
)

achievement(
	title="The Best or Nothing",
	description="Place 1st place in the F3000 event",
	points=5,
	trigger=finish_event(4) && position() == 1
)

achievement(
	title="In It for the Long Haul",
	description="Place 1st place in the endurance event",
	points=5,
	trigger=finish_event(2) && position() == 1
)

achievement(
	title="Entering the Big Leagues",
	description="Earn 25 points and unlock your first F1 race, Brazil",
	type="progression",
	points=3,
	trigger=unlock_points(25)
)

achievement(
	title="Interlagos Circuit",
	description="Place 1st place in round 1 of the F1 event, Brazil",
	points=10,
	trigger=finish_event(5) && position() == 1
)

achievement(
	title="Relaxing at the Spa",
	description="Earn 33 points and unlock San Marino and Belgium in F1 mode",
	type="progression",
	points=3,
	trigger=unlock_points(33)
)

achievement(
	title="Imola Circuit",
	description="Place 1st place in round 2 of the F1 event, San Marino",
	points=10,
	trigger=finish_event(6) && position() == 1
)

achievement(
	title="Circuit de Spa-Francorchamps",
	description="Place 1st place in round 3 of the F1 event, Belgium",
	points=10,
	trigger=finish_event(7) && position() == 1
)

achievement(
	title="Yacht-zee",
	description="Earn 48 points and unlock Monaco and USA in F1 mode",
	type="progression",
	points=3,
	trigger=unlock_points(48)
)

achievement(
	title="Monte Carlo", // or: Circuit de Monaco
	description="Place 1st place in round 4 of the F1 event, Monaco",
	points=10,
	trigger=finish_event(8) && position() == 1
)

achievement(
	title="Watkins Glen",
	description="Place 1st place in round 5 of the F1 event, USA",
	points=10,
	trigger=finish_event(9) && position() == 1
)

achievement(
	title="Hail Britannia",
	description="Earn 65 points and unlock France and Great Britain in F1 mode",
	type="progression",
	points=3,
	trigger=unlock_points(65)
)

achievement(
	title="Circuit de Reims-Gueux",
	description="Place 1st place in round 6 of the F1 event, France",
	points=10,
	trigger=finish_event(10) && position() == 1
)

achievement(
	title="Silverstone Circuit",
	description="Place 1st place in round 7 of the F1 event, Great Britain",
	points=10,
	trigger=finish_event(11) && position() == 1
)

achievement(
	title="Mein Hoovercraft Ist Full of Eels",
	description="Earn 84 points and unlock West Germany and Hungary in F1 mode",
	type="progression",
	points=3,
	trigger=unlock_points(84)
)

achievement(
	title="Hockenheimring Baden-Württemberg",
	description="Place 1st place in round 8 of the F1 event, West Germany",
	points=10,
	trigger=finish_event(12) && position() == 1
)

achievement(
	title="The Hungaroring",
	description="Place 1st place in round 9 of the F1 event, Hungary",
	points=10,
	trigger=finish_event(13) && position() == 1
)

achievement(
	title="A Taste of the Old Country",
	description="Earn 105 points and unlock Austria and Italy in F1 mode",
	type="progression",
	points=3,
	trigger=unlock_points(105)
)

achievement(
	title="Österreichring",
	description="Place 1st place in round 10 of the F1 event, Austria",
	points=10,
	trigger=finish_event(14) && position() == 1
)

achievement(
	title="Monza Circuit, the Temple of Speed",
	description="Place 1st place in round 11 of the F1 event, Italy",
	points=10,
	trigger=finish_event(15) && position() == 1
)

achievement(
	title="Iberia Answers the Call",
	description="Earn 128 points and unlock Portugal and Spain in F1 mode",
	type="progression",
	points=3,
	trigger=unlock_points(128)
)

achievement(
	title="Autódromo do Estoril",
	description="Place 1st place in round 12 of the F1 event, Portugal",
	points=10,
	trigger=finish_event(16) && position() == 1
)

achievement(
	title="Circuito de Jerez",
	description="Place 1st place in round 13 of the F1 event, Spain",
	points=10,
	trigger=finish_event(17) && position() == 1
)

achievement(
	title="Taco Yaki",
	description="Earn 153 points and unlock Mexico and Japan in F1 mode",
	type="progression",
	points=3,
	trigger=unlock_points(153)
)

achievement(
	title="Autódromo Hermanos Rodríguez",
	description="Place 1st place in round 14 of the F1 event, Mexico",
	points=10,
	trigger=finish_event(18) && position() == 1
)

achievement(
	title="Suzuka Circuit",
	description="Place 1st place in round 15 of the F1 event, Japan",
	points=10,
	trigger=finish_event(19) && position() == 1
)

achievement(
	title="Downshifting Down Under",
	description="Earn 180 points and unlock Australia in F1 mode",
	type="progression",
	points=3,
	trigger=unlock_points(180)
)

achievement(
	title="The Memorial of Formula-1",
	description="Place 1st place in round 16 of the F1 event, Australia",
	type="win_condition",
	points=25,
	trigger=(
		// check for crossing the finish line in first place
		(finish_event(20) && position() == 1) ||
		// ...or transitioning into the credits (which should be redundant)
		(prev(game_state()) == MODE_LOADING_ENDING && game_state() == MODE_ENDING)
		// I'll be honest, I'm hedging my bets here
	)
)

// CHALLENGES

achievement(
	title="This Engine Runs on Premium",
	description="Use the pit lane to refill on fuel",
	points=1,
	trigger=racing() && in_pit() == 1 && prev(raw_fuel()) == 254 && raw_fuel() == 255
)

achievement(
	title="Please Be Gentle, It's Not a Rental",
	description="Complete any F1 race without taking vehicle damage",
	points=5,
	trigger=(
		once(game_state() == MODE_RACE && prev(race_active()) == 0 && race_active() == 1) &&
		event() >= 5 &&
		trigger_when(prev(game_state()) == MODE_RACE && game_state() == MODE_FINISH_LINE) &&
		never(vehicle_damage_indicators() != 0) &&
		never(game_state() == MODE_RACE_RESULTS) &&
		never(game_state() < MODE_LOADING_RACE)
	)
)

achievement(
	title="Never Senna-nything like It",
	description="Place 1st in any event using manual transmission",
	points=2,
	trigger=(
		is_automatic_transmission() == 0 && position() == 1 && 
		prev(game_state()) == MODE_RACE && game_state() == MODE_FINISH_LINE
	)
)

achievement(
	title="I'm Something of a Mechanic Myself",
	description="Build your own custom car",
	points=1,
	trigger=make_custom_car()
)

// --- LEADERBOARDS -------------------------------------------------------------------

for e in range(0,20)
{
	leaderboard(
		title=format("Fastest Time {0}", EVENTS[e]),
		description=format("Fastest time to complete {0}", EVENTS[e]),
	
		start=event() == e && prev(game_state()) == MODE_FINISH_LINE && game_state() == MODE_FINISH_LINE_CUTSCENE,
		cancel=always_false(),
		submit=always_true(),
	
		value=measured(race_time() * 100),
		format="MILLISECS",
		lower_is_better=true
	)
}