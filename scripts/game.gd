extends Node

const Data = preload("res://scripts/data.gd")
const SAVE_PATH = "user://aldera_save.json"

var hero_class = "guerrier"
var level = 1
var xp = 0
var points = 0
var gold = 0
var stats = {"sante": 0, "force": 0, "endurance": 0, "agilite": 0}
var equipped = {"arme": null, "armure": null, "amulette": null}
var max_stage = 1
var current_stage = 1

func new_game(cls):
	hero_class = cls
	level = 1
	xp = 0
	points = 0
	gold = 0
	stats = {"sante": 0, "force": 0, "endurance": 0, "agilite": 0}
	equipped = {"arme": Data.make_item("arme", 1, 0, cls), "armure": Data.make_item("armure", 1, 0, cls), "amulette": null}
	max_stage = 1
	current_stage = 1
	save()

func bonus():
	var b = {"dmg": 0, "hp": 0, "armor": 0}
	for slot in equipped:
		var it = equipped[slot]
		if it != null:
			var ib = Data.item_bonus(it)
			for k in b:
				b[k] += ib[k]
	return b

func max_hp():
	return int(Data.CLASSES[hero_class]["hp"] + (level - 1) * 12 + stats["sante"] * 15 + bonus()["hp"])

func damage():
	return Data.CLASSES[hero_class]["dmg"] + (level - 1) * 2 + stats["force"] * 3 + bonus()["dmg"]

func armor():
	return bonus()["armor"]

func max_stamina():
	return 100 + stats["endurance"] * 10

func stamina_regen():
	return 18.0 + stats["endurance"] * 1.5

func move_speed():
	return Data.CLASSES[hero_class]["speed"] * (1.0 + stats["agilite"] * 0.012)

func attack_cd():
	return Data.CLASSES[hero_class]["cd"] / (1.0 + stats["agilite"] * 0.02)

func crit_chance():
	return 0.05 + stats["agilite"] * 0.008

func xp_needed():
	return int(40 + 35 * pow(level, 1.4))

func add_xp(n):
	xp += n
	var gained = 0
	while xp >= xp_needed():
		xp -= xp_needed()
		level += 1
		points += 3
		gained += 1
	return gained

func summary():
	return "PV " + str(max_hp()) + "  ·  Dégâts " + str(damage()) + "\nArmure " + str(armor()) + "  ·  Énergie " + str(max_stamina()) + "\nCritique " + str(int(crit_chance() * 100.0)) + " %"

func upgrade_cost(it):
	return int(20 * (it["up"] + 1) * (1.0 + it["tier"] * 0.5))

func upgrade(slot):
	var it = equipped[slot]
	if it == null or it["up"] >= 10:
		return false
	var c = upgrade_cost(it)
	if gold < c:
		return false
	gold -= c
	it["up"] += 1
	save()
	return true

func give_item(it):
	var slot = it["slot"]
	var cur = equipped[slot]
	if cur == null or Data.item_power(it) > Data.item_power(cur):
		equipped[slot] = it
		return "Équipé : " + it["name"]
	var v = Data.item_power(it) * 3
	gold += v
	return "Vendu " + it["name"] + " (+" + str(v) + " or)"

func has_save():
	return FileAccess.file_exists(SAVE_PATH)

func save():
	var d = {"cls": hero_class, "lvl": level, "xp": xp, "pts": points, "gold": gold, "stats": stats, "eq": equipped, "max": max_stage, "cur": current_stage}
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(var_to_str(d))

func load_game():
	if not has_save():
		return false
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var d = str_to_var(f.get_as_text())
	if typeof(d) != TYPE_DICTIONARY:
		return false
	hero_class = d.get("cls", "guerrier")
	level = d.get("lvl", 1)
	xp = d.get("xp", 0)
	points = d.get("pts", 0)
	gold = d.get("gold", 0)
	stats = d.get("stats", {"sante": 0, "force": 0, "endurance": 0, "agilite": 0})
	equipped = d.get("eq", {"arme": null, "armure": null, "amulette": null})
	max_stage = d.get("max", 1)
	current_stage = d.get("cur", 1)
	return true
