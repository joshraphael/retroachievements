import csv
import re

masteryfocus = {
	"I play RA sets specifically for mastery, and will often complete challenges that I don't find fun in order to complete the set" : 4,
	"I play RA sets specifically for mastery, but I will stop short if I find myself not having fun with certain challenges": 3,
	"I don't pay much attention to RA, but I will occasionally look at the RA set to see if there are any challenges that I want to try": 2,
	"I don't pay much attention to RA, and I don't change my playstyle with regards to the RA achievement set. I earn whatever achievements I earn": 1,
	"I am not a player.": 0,
}

milestonebreakdown = {
	"I like one achievement per stage, even when there might be a lot of stages": +1,
	"I don't have an opinion on the number of progression achievements.": 0,
	"I like stages to be grouped to reduce the number of overall achievements": -1,
}

affinity = {
	"Love": +2,
	"Like": +1,
	"Neutral": 0,
	"Dislike": -1,
	"Hate/Avoid": -2,
}

agreement = {
	"Strongly Agree": +2,
	"Agree": +1,
	"Neutral": 0,
	"Disagree": -1,
	"Strongly Disagree": -2,
}

output = []
favsets = dict()
with open('00-raw-deidentified.csv', 'r', newline='', encoding='utf8') as csvfile:
	csvfile.readline() # skip the header
	for row in csv.reader(csvfile):
		fav = re.findall(r'retroachievements\.org/game/(\d+)', row[3])
		for i in fav: favsets[i] = favsets.get(i, 0) + 1
		output.append(
			[
				1 if "I am a player" in row[0] else 0,
				1 if "I am a Developer" in row[0] else 0,
				1 if "I volunteer" in row[0] else 0,
				masteryfocus.get(row[1], -1),
				row[2],
				', '.join(fav),
				row[4],
			] +
			[affinity.get(x, 0) for x in row[5:16]] +
			[
				row[16],
				milestonebreakdown.get(row[17], 0),
				1 if "completion of all possible routes/endings, where applicable" in row[18] else 0,
				1 if "100%, as defined by the game" in row[18] else 0,
				1 if "further completion, as defined by the dev (collect all 1ups, collect all ammo packs, etc)" in row[18] else 0,
				1 if "per-boss and/or per-stage challenges, as defined by the dev" in row[18] else 0,
				1 if "full-game challenges, as defined by the dev" in row[18] else 0,
				int(row[19]) - 3,
				agreement.get(row[20], 0),
				agreement.get(row[21], 0),
				agreement.get(row[22], 0),
				agreement.get(row[23], 0),
				agreement.get(row[24], 0),
			]
		)

with open('01-processed.csv', 'w', newline='', encoding='utf8') as csvfile:
	writer = csv.writer(csvfile)
	writer.writerow([
		'is-player', # 0 = no, 1 = yes
		'is-dev', # 0 = no, 1 = yes
		'is-volunteer', # 0 = no, 1 = yes
		'how-focused-on-mastery', # 4 = high, 1 = low, 0 = not a player
		'what-is-well-designed', # [open response]
		'best-sets', # comma-separated list of RA set ids
		'best-sets-why', # [open response]

		# +2 love, +1 like, 0 neutral, -1 dislike, -2 hate/avoid
		'achtype:progression', # Standard Progression & Milestones
		'achtype:completion', # Completion (100%, collectables, all stages/missions)
		'achtype:grinding', # Grinding / Hyper-Completion (reach level 99, collect every drop, reach 1000 kills with every weapon, etc)
		'achtype:damageless-boss', # Damageless Boss Challenges
		'achtype:deathless-boss', # Deathless Boss Challenges
		'achtype:other-boss', # Other Boss Challenges (weapon restrictions, party restrictions, etc)
		'achtype:level-challenges', # Level Challenges (no powerups, don't press left, no jumping, etc)
		'achtype:easter-eggs', # Easter Eggs (highlighting one-off points of interest in a game, intended by the game developers)
		'achtype:dev-challenges', # Developer-Created Challenges (highlighting one-off points of interest in a game, NOT intended by the game developers)
		'achtype:score', # Score Challenges
		'achtype:speedrun', # Speedrun Challenges

		'other-enjoyed-achievements', # [open response]
		'milestone-breakdown', # +1 individual achievements, 0 no opinion, -1 grouped achievements

		# 0 = no, 1 = yes
		'set-expectation:all-endings', # completion of all possible routes/endings, where applicable
		'set-expectation:completion', # 100%, as defined by the game
		'set-expectation:full-collection', # further completion, as defined by the dev (collect all 1ups, collect all ammo packs, etc)
		'set-expectation:boss-stage-challenges', # per-boss and/or per-stage challenges, as defined by the dev
		'set-expectation:full-game-challenges', # full-game challenges, as defined by the dev

		'willing-multiple-playthroughs' # -2 very unwilling, 0 neutral, +2 very willing

		# +2 strongly agree, +1 agree, 0 neutral, -1 disagree, -2 strong disagree
		'opinion:have-skipped-difficult', # I have skipped achievements for being too difficult
		'opinion:have-skipped-by-type', # I have skipped achievements for being a type of achievement I don't like
		'opinion:skipped-set', # I have not played *an entire set* because it contained a small number of achievements I didn't want to complete
		'opinion:must-master', # I feel the need to master every set that I play, even if I don't care for some of the achievements
		'opinion:single-genre-series', # I mostly play games of a specific series or genre
	])
	for row in output:
		writer.writerow(row)

with open('01-favorite-sets.txt', 'w') as f:
	bycount = [(c, k) for k, c in favsets.items()]
	for count, setid in reversed(sorted(bycount)):
		import requests
		import _credentials
		import time

		r = requests.get(f'https://retroachievements.org/API/API_GetGame.php?i={setid}&y={_credentials.webkey}')
		name = '<unknown>'
		if r.ok:
			data = r.json()
			name = f"{data['GameTitle']} ({data['ConsoleName']})"
		time.sleep(0.5)

		f.write(f"{count} {setid} {name}\n")