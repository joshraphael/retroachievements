// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function is_set(acc) => acc > prev(acc)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function rich_presence_number(x) => rich_presence_value("_Number", x, "VALUE")
function ptr(x) => dword(x)

function rp_hex(x) => rich_presence_lookup("Hex", x, {
	00: "0", 01: "1", 02: "2", 03: "3", 04: "4", 05: "5", 06: "6", 07: "7",
	08: "8", 09: "9", 10: "A", 11: "B", 12: "C", 13: "D", 14: "E", 15: "F",
}, fallback="0")

function rp_zpad(x) => rich_presence_lookup("Zero", x, {
	0: "0", 1: "0", 2: "0", 3: "0", 4: "0",
	5: "0", 6: "0", 7: "0", 8: "0", 9: "0",
}, fallback="")

function millis_to_timestamp(x) => format("{0}'{1}\"{2}", 
	x / (60 * 1000),
	substring(format("0{0}", (x / 1000) % 60), -2, 2),
	substring(format("00{0}", x), -3, 3)
)

function zfill(num, c)
{
	if (length(format("{0}", num)) >= c) return format("{0}", num)
	return substring(format("0000000000000000000{0}", num), -c, c)
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

// --- MAIN DATA -------------------------------------------------------------------

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- LEADERBOARDS -------------------------------------------------------------------