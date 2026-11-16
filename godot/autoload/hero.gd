extends Node
## The persistent hero (the JS global `H`) and the three save slots.
## Saves are JSON in user://slot_N.json. On Windows user:// is
## %APPDATA%\Godot\app_userdata\Deepdelve\.
##
## Stage 3 of the porting plan fills this out from the JS State section
## (newHero, migrateHero, ensureSkills). For now it holds the basics.

const SAVE_VERSION := 1

var slot := 0
var h: Dictionary = {}


func new_hero(hero_name: String = "Delver") -> Dictionary:
	var skills := {}
	for k: String in Data.table("SKILLS").keys():
		skills[k] = {"lv": 5, "xp": 0}
	for k: String in Data.table("CRAFT_SK"):
		skills[k] = {"lv": 5, "xp": 0}
	var hp: int = int(Data.BAL.get("hp0", 26))
	return {
		"v": SAVE_VERSION,
		"name": hero_name,
		"lvl": 1, "xp": 0,
		"hp": hp, "mhp": hp,
		"bank": 0, "deaths": 0, "best": 0,
		"sk": skills, "perks": [],
		"weapon": {"kind": "w", "wt": "sword", "base": "Rusty Shortsword",
			"n": "Rusty Shortsword", "d": [1, 4], "t": 0, "plus": 0, "aff": [], "rar": 0},
		"armor": null, "shield": null,
		"potions": 0, "bag": [], "stash": [], "mats": {},
	}


func slot_path(i: int) -> String:
	return "user://slot_%d.json" % i


func has_slot(i: int) -> bool:
	return FileAccess.file_exists(slot_path(i))


func start_new(i: int) -> void:
	slot = i
	h = new_hero()
	save()


func load_slot(i: int) -> bool:
	if not has_slot(i):
		return false
	var f := FileAccess.open(slot_path(i), FileAccess.READ)
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Save slot %d is unreadable" % i)
		return false
	slot = i
	h = migrate(parsed)
	return true


func save() -> void:
	var f := FileAccess.open(slot_path(slot), FileAccess.WRITE)
	f.store_string(JSON.stringify(h, "\t"))


## Port of migrateHero: give old saves defaults for any field added later.
func migrate(old: Dictionary) -> Dictionary:
	var fresh := new_hero(old.get("name", "Delver"))
	for k: String in fresh.keys():
		if not old.has(k):
			old[k] = fresh[k]
	for k: String in fresh["sk"].keys():
		if not old["sk"].has(k):
			old["sk"][k] = {"lv": 5, "xp": 0}
	old["v"] = SAVE_VERSION
	return old


## Port of train(): skills rise by use, 5..100, with a perk every 25 levels.
signal skill_up(skill: String, level: int)

func train(skill: String, amount: float) -> void:
	var s: Dictionary = h["sk"][skill]
	if s["lv"] >= 100:
		return
	s["xp"] += amount
	var need := Data.skill_need(int(s["lv"]))
	while s["xp"] >= need and s["lv"] < 100:
		s["xp"] -= need
		s["lv"] += 1
		need = Data.skill_need(int(s["lv"]))
		skill_up.emit(skill, int(s["lv"]))
