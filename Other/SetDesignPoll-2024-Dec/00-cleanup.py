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
				"I am a player" in row[0],
				"I am a Developer" in row[0],
				"I volunteer" in row[0],
				masteryfocus.get(row[1], -1),
				row[2],
				', '.join(fav),
				row[4],
			] +
			[affinity.get(x, 0) for x in row[5:16]] +
			[
				row[16],
				milestonebreakdown.get(row[17], 0),
				"completion of all possible routes/endings, where applicable" in row[18],
				"100%, as defined by the game" in row[18],
				"further completion, as defined by the dev (collect all 1ups, collect all ammo packs, etc)" in row[18],
				"per-boss and/or per-stage challenges, as defined by the dev" in row[18],
				"full-game challenges, as defined by the dev" in row[18],
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
		'is_player', # 0 = no, 1 = yes
		'is_dev', # 0 = no, 1 = yes
		'is_volunteer', # 0 = no, 1 = yes
		'how_focused_on_mastery', # 4 = high, 1 = low, 0 = not a player
		'what_is_well_designed', # [open response]
		'best_sets', # comma-separated list of RA set ids
		'best_sets_why', # [open response]

		# +2 love, +1 like, 0 neutral, -1 dislike, -2 hate/avoid
		'achtype_progression', # Standard Progression & Milestones
		'achtype_completion', # Completion (100%, collectables, all stages/missions)
		'achtype_grinding', # Grinding / Hyper-Completion (reach level 99, collect every drop, reach 1000 kills with every weapon, etc)
		'achtype_damageless_boss', # Damageless Boss Challenges
		'achtype_deathless_boss', # Deathless Boss Challenges
		'achtype_other_boss', # Other Boss Challenges (weapon restrictions, party restrictions, etc)
		'achtype_level_challenges', # Level Challenges (no powerups, don't press left, no jumping, etc)
		'achtype_easter_eggs', # Easter Eggs (highlighting one-off points of interest in a game, intended by the game developers)
		'achtype_dev_challenges', # Developer-Created Challenges (highlighting one-off points of interest in a game, NOT intended by the game developers)
		'achtype_score', # Score Challenges
		'achtype_speedrun', # Speedrun Challenges

		'other_enjoyed_achievements', # [open response]
		'milestone_breakdown', # +1 individual achievements, 0 no opinion, -1 grouped achievements

		# 0 = no, 1 = yes
		'set_expectation_all_endings', # completion of all possible routes/endings, where applicable
		'set_expectation_completion', # 100%, as defined by the game
		'set_expectation_full_collection', # further completion, as defined by the dev (collect all 1ups, collect all ammo packs, etc)
		'set_expectation_boss_stage_challenges', # per-boss and/or per-stage challenges, as defined by the dev
		'set_expectation_full_game_challenges', # full-game challenges, as defined by the dev

		'willing_multiple_playthroughs', # -2 very unwilling, 0 neutral, +2 very willing

		# +2 strongly agree, +1 agree, 0 neutral, -1 disagree, -2 strong disagree
		'opinion_have_skipped_difficult', # I have skipped achievements for being too difficult
		'opinion_have_skipped_by_type', # I have skipped achievements for being a type of achievement I don't like
		'opinion_skipped_set', # I have not played *an entire set* because it contained a small number of achievements I didn't want to complete
		'opinion_must_master', # I feel the need to master every set that I play, even if I don't care for some of the achievements
		'opinion_single_genre_series', # I mostly play games of a specific series or genre
	])
	for row in output:
		writer.writerow(row)

import requests
with open('01-favorite-sets.txt', 'w') as f:
	bycount = [(c, k) for k, c in favsets.items()]
	for count, setid in reversed(sorted(bycount)):
		import _credentials
		import time

		r = requests.get(f'https://retroachievements.org/API/API_GetGame.php?i={setid}&y={_credentials.webkey}')
		name = '<unknown>'
		if r.ok:
			data = r.json()
			name = f"{data['GameTitle']} ({data['ConsoleName']})"
		time.sleep(0.25)

		f.write(f"{count} {setid} {name}\n")