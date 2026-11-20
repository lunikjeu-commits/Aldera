extends RefCounted

const CLASSES = {
	"guerrier": {"nom": "Guerrier", "hp": 140, "dmg": 12, "speed": 235.0, "range": 110.0, "cd": 0.6, "skill": "Tourbillon", "skill_cd": 6.0, "color": Color(0.85, 0.25, 0.22), "desc": "Corps à corps dévastateur, très résistant."},
	"archer": {"nom": "Archer", "hp": 100, "dmg": 9, "speed": 265.0, "range": 440.0, "cd": 0.5, "skill": "Volée", "skill_cd": 5.0, "color": Color(0.25, 0.7, 0.35), "desc": "Tire de loin, rapide et précis."},
	"mage": {"nom": "Mage", "hp": 85, "dmg": 11, "speed": 245.0, "range": 390.0, "cd": 0.75, "skill": "Nova", "skill_cd": 6.0, "color": Color(0.35, 0.45, 0.95), "desc": "Sorts à distance, explosion de zone."},
}

const ENEMIES = {
	"gobelin": {"nom": "Lutin", "hp": 28.0, "dmg": 6.0, "speed": 150.0, "r": 18.0, "h": 52.0, "xp": 6, "gold": 2, "range": 30.0},
	"taureau": {"nom": "Taureau", "hp": 70.0, "dmg": 12.0, "speed": 105.0, "r": 28.0, "h": 70.0, "xp": 12, "gold": 4, "range": 40.0},
	"lion": {"nom": "Lion", "hp": 55.0, "dmg": 10.0, "speed": 200.0, "r": 24.0, "h": 62.0, "xp": 11, "gold": 4, "range": 38.0},
	"geant": {"nom": "Géant", "hp": 170.0, "dmg": 20.0, "speed": 72.0, "r": 42.0, "h": 120.0, "xp": 26, "gold": 9, "range": 60.0},
	"trex": {"nom": "T-Rex", "hp": 210.0, "dmg": 26.0, "speed": 100.0, "r": 46.0, "h": 110.0, "xp": 32, "gold": 11, "range": 66.0},
	"dragon": {"nom": "Dragon", "hp": 150.0, "dmg": 14.0, "speed": 95.0, "r": 38.0, "h": 120.0, "xp": 34, "gold": 12, "range": 0.0},
}

const BOSSES = ["geant", "dragon", "trex", "taureau", "lion"]

const RARITY = [
	{"nom": "Commun", "mult": 1.0, "color": Color(0.8, 0.82, 0.85)},
	{"nom": "Rare", "mult": 1.5, "color": Color(0.35, 0.65, 1.0)},
	{"nom": "Épique", "mult": 2.2, "color": Color(0.75, 0.4, 1.0)},
	{"nom": "Légendaire", "mult": 3.2, "color": Color(1.0, 0.72, 0.2)},
]
const ADJ = ["rustique", "d'acier", "runique", "des Anciens"]
const WEAPONS = {"guerrier": ["Épée", "Hache", "Lame"], "archer": ["Arc", "Arc long", "Arc court"], "mage": ["Bâton", "Sceptre", "Grimoire"]}
const ARMORS = {"guerrier": ["Armure", "Cuirasse", "Plastron"], "archer": ["Tenue", "Cape", "Cotte de cuir"], "mage": ["Robe", "Manteau", "Tunique"]}
const SLOT_NAMES = {"arme": "Arme", "armure": "Tenue", "amulette": "Amulette"}
const STAT_INFO = {
	"sante": ["Santé", "+15 PV"],
	"force": ["Force", "+3 dégâts"],
	"endurance": ["Endurance", "+10 énergie"],
	"agilite": ["Agilité", "vitesse, critique"],
}

static func boss_kind(stage):
	return BOSSES[(int(stage / 3) - 1) % BOSSES.size()]

static func pick_kind(stage):
	var pool = ["gobelin", "gobelin", "gobelin", "taureau"]
	if stage >= 2:
		pool.append("lion")
	if stage >= 3:
		pool.append("geant")
	if stage >= 5:
		pool.append("trex")
	if stage >= 6:
		pool.append("dragon")
	return pool.pick_random()

static func roll_rarity(boss, stage):
	var r = randf() - stage * 0.01 - (0.35 if boss else 0.0)
	if r < 0.02:
		return 3
	if r < 0.10:
		return 2
	if r < 0.35:
		return 1
	return 0

static func make_item(slot, tier, rar, cls):
	var nm = "Amulette"
	if slot == "arme":
		nm = WEAPONS[cls].pick_random()
	elif slot == "armure":
		nm = ARMORS[cls].pick_random()
	return {"slot": slot, "name": nm + " " + ADJ[rar], "rar": rar, "tier": tier, "up": 0}

static func item_power(it):
	return int((4 + it["tier"] * 4) * RARITY[it["rar"]]["mult"] * (1.0 + 0.18 * it["up"]))

static func item_bonus(it):
	var p = item_power(it)
	var b = {"dmg": 0, "hp": 0, "armor": 0}
	match it["slot"]:
		"arme":
			b["dmg"] = p
		"armure":
			b["armor"] = p
			b["hp"] = p * 3
		"amulette":
			b["hp"] = p * 2
			b["dmg"] = int(p * 0.4)
	return b

static func bonus_text(it):
	var b = item_bonus(it)
	var parts = []
	if b["dmg"] > 0:
		parts.append("Dégâts +" + str(b["dmg"]))
	if b["hp"] > 0:
		parts.append("PV +" + str(b["hp"]))
	if b["armor"] > 0:
		parts.append("Armure +" + str(b["armor"]))
	return "  ".join(parts)
