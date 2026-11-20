extends Control

const UI = preload("res://scripts/ui_kit.gd")
const Data = preload("res://scripts/data.gd")
const Preview = preload("res://scripts/preview.gd")
var main
var t = 0.0
var sel = 1

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sel = clampi(Game.current_stage, 1, Game.max_stage)
	_build()

func _process(delta):
	t += delta
	queue_redraw()

func _draw():
	UI.backdrop(self, get_viewport_rect().size, t)

func _build():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var margin = MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)
	root.add_child(_header())
	var cols = HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 14)
	root.add_child(cols)
	cols.add_child(_hero_panel())
	cols.add_child(_stats_panel())
	cols.add_child(_gear_panel())
	root.add_child(_footer())

func _header():
	var h = HBoxContainer.new()
	h.add_theme_constant_override("separation", 20)
	var title = UI.lbl("Camp de base", 34, Color(1.0, 0.8, 0.3))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(title)
	h.add_child(UI.lbl("Or : " + str(Game.gold), 26, Color(1.0, 0.85, 0.3)))
	var m = UI.btn("Menu", Color(0.35, 0.4, 0.5), Vector2(120, 46), 20)
	m.pressed.connect(main.show_menu)
	h.add_child(m)
	return h

func _hero_panel():
	var p = UI.panel()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	var holder = Control.new()
	holder.custom_minimum_size = Vector2(300, 230)
	var pv = Preview.new()
	pv.cls = Game.hero_class
	var a = Game.equipped["armure"]
	if a != null:
		pv.trim = Data.RARITY[a["rar"]]["color"]
	pv.position = Vector2(150, 215)
	pv.scale = Vector2(2.0, 2.0)
	holder.add_child(pv)
	v.add_child(holder)
	var d = Data.CLASSES[Game.hero_class]
	v.add_child(UI.lbl(d["nom"] + "  ·  Niveau " + str(Game.level), 28, d["color"].lightened(0.25), HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(UI.progress(Game.xp_needed(), Game.xp, Color(0.4, 0.6, 1.0), 14))
	v.add_child(UI.lbl("XP " + str(Game.xp) + " / " + str(Game.xp_needed()), 16, Color(1, 1, 1, 0.7), HORIZONTAL_ALIGNMENT_CENTER))
	return p

func _stats_panel():
	var p = UI.panel()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	v.add_child(UI.lbl("Capacités", 30, Color(1.0, 0.8, 0.3)))
	var pc = Color(0.5, 1.0, 0.6) if Game.points > 0 else Color(1, 1, 1, 0.6)
	v.add_child(UI.lbl("Points à répartir : " + str(Game.points), 22, pc))
	for k in ["sante", "force", "endurance", "agilite"]:
		v.add_child(_stat_row(k))
	v.add_child(UI.lbl(Game.summary(), 18, Color(0.8, 0.88, 1.0)))
	return p

func _stat_row(k):
	var info = Data.STAT_INFO[k]
	var row = HBoxContainer.new()
	var l = UI.lbl(info[0] + " " + str(Game.stats[k]) + "  (" + info[1] + ")", 20)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(l)
	var b = UI.btn("+", Color(0.2, 0.6, 0.4), Vector2(62, 50), 28)
	b.disabled = Game.points <= 0
	b.pressed.connect(_add_point.bind(k))
	row.add_child(b)
	return row

func _add_point(k):
	Game.stats[k] += 1
	Game.points -= 1
	Game.save()
	_build()

func _gear_panel():
	var p = UI.panel()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	v.add_child(UI.lbl("Équipement", 30, Color(1.0, 0.8, 0.3)))
	for slot in ["arme", "armure", "amulette"]:
		var it = Game.equipped[slot]
		var row = VBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		row.add_child(UI.lbl(Data.SLOT_NAMES[slot], 16, Color(1, 1, 1, 0.55)))
		if it == null:
			row.add_child(UI.lbl("— vide (butin des monstres)", 18, Color(1, 1, 1, 0.5)))
		else:
			var up = " +" + str(it["up"]) if it["up"] > 0 else ""
			row.add_child(UI.lbl(it["name"] + up, 22, Data.RARITY[it["rar"]]["color"]))
			row.add_child(UI.lbl(Data.bonus_text(it), 17, Color(0.8, 0.9, 1.0)))
			var cost = Game.upgrade_cost(it)
			var b = UI.btn("Améliorer · " + str(cost) + " or" if it["up"] < 10 else "Niveau max", Color(0.2, 0.6, 0.4), Vector2(0, 44), 20)
			b.disabled = it["up"] >= 10 or Game.gold < cost
			b.pressed.connect(_upgrade.bind(slot))
			row.add_child(b)
		v.add_child(row)
	return p

func _upgrade(slot):
	Game.upgrade(slot)
	_build()

func _footer():
	var h = HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	var prev = UI.btn("<", Color(0.3, 0.38, 0.55), Vector2(70, 64), 30)
	prev.disabled = sel <= 1
	prev.pressed.connect(_stage.bind(-1))
	h.add_child(prev)
	var boss = sel % 3 == 0
	var l = UI.lbl("Niveau " + str(sel) + ("  ·  BOSS" if boss else ""), 30, Color(1.0, 0.45, 0.4) if boss else Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	l.custom_minimum_size = Vector2(280, 0)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(l)
	var nxt = UI.btn(">", Color(0.3, 0.38, 0.55), Vector2(70, 64), 30)
	nxt.disabled = sel >= Game.max_stage
	nxt.pressed.connect(_stage.bind(1))
	h.add_child(nxt)
	var sp = Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(sp)
	var play = UI.btn("JOUER", Color(0.9, 0.5, 0.15), Vector2(300, 66), 32)
	play.pressed.connect(_play)
	h.add_child(play)
	return h

func _stage(d):
	sel = clampi(sel + d, 1, Game.max_stage)
	_build()

func _play():
	main.start_stage(sel)
