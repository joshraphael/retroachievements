// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function ptr(x) => dword(x)

function rich_presence_number(x) => rich_presence_value("_Number", x, "VALUE")
function rp_hex(x) => rich_presence_lookup("Hex", x, {
	00: "0", 01: "1", 02: "2", 03: "3", 04: "4", 05: "5", 06: "6", 07: "7",
	08: "8", 09: "9", 10: "A", 11: "B", 12: "C", 13: "D", 14: "E", 15: "F",
}, fallback="0")

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

// --- MAIN DATA -------------------------------------------------------------------

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- LEADERBOARDS -------------------------------------------------------------------