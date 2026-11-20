extends Control

const UI = preload("res://scripts/ui_kit.gd")
const Data = preload("res://scripts/data.gd")
const Preview = preload("res://scripts/preview.gd")
var main
var t = 0.0

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modulate.a = 0.0
	_home()

func _process(delta):
	t += delta
	if modulate.a < 1.0:
		modulate.a = minf(1.0, modulate.a + delta / 0.35)
	queue_redraw()

func _draw():
	UI.backdrop(self, get_viewport_rect().size, t)

func _clear():
	for c in get_children():
		remove_child(c)
		c.queue_free()

func _center():
	var cc = CenterContainer.new()
	add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	cc.add_child(v)
	return v

func _home():
	_clear()
	var v = _center()
	v.add_child(UI.lbl("ALDÉRA", 84, Color(1.0, 0.8, 0.3), HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(UI.lbl("Légendes d'aventure", 26, Color(0.7, 0.8, 1.0), HORIZONTAL_ALIGNMENT_CENTER))
	var sp = Control.new()
	sp.custom_minimum_size = Vector2(0, 24)
	v.add_child(sp)
	if Game.has_save():
		var b = UI.btn("Continuer", Color(0.2, 0.55, 0.95), Vector2(340, 70), 28)
		b.pressed.connect(_continue)
		v.add_child(b)
	var nb = UI.btn("Nouvelle partie", Color(0.9, 0.5, 0.15), Vector2(340, 70), 28)
	nb.pressed.connect(_select)
	v.add_child(nb)
	v.add_child(UI.lbl("par lunikapp", 18, Color(1, 1, 1, 0.4), HORIZONTAL_ALIGNMENT_CENTER))

func _continue():
	if Game.load_game():
		main.show_hub()

func _select():
	_clear()
	var v = _center()
	v.add_theme_constant_override("separation", 10)
	v.add_child(UI.lbl("Choisis ta classe", 38, Color(1.0, 0.8, 0.3), HORIZONTAL_ALIGNMENT_CENTER))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	for cls in ["guerrier", "archer", "mage"]:
		row.add_child(_card(cls))
	v.add_child(row)
	var back = UI.btn("Retour", Color(0.35, 0.4, 0.5), Vector2(200, 52), 22)
	back.pressed.connect(_home)
	v.add_child(back)

func _card(cls):
	var d = Data.CLASSES[cls]
	var p = UI.panel()
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)
	var holder = Control.new()
	holder.custom_minimum_size = Vector2(270, 180)
	var pv = Preview.new()
	pv.cls = cls
	pv.position = Vector2(135, 172)
	pv.scale = Vector2(1.7, 1.7)
	holder.add_child(pv)
	v.add_child(holder)
	v.add_child(UI.lbl(d["nom"], 32, d["color"].lightened(0.2), HORIZONTAL_ALIGNMENT_CENTER))
	var desc = UI.lbl(d["desc"], 18, Color(0.8, 0.85, 0.95), HORIZONTAL_ALIGNMENT_CENTER)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(250, 50)
	v.add_child(desc)
	v.add_child(UI.lbl("PV " + str(d["hp"]) + "  ·  Dégâts " + str(d["dmg"]), 18, Color(1, 1, 1, 0.8), HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(UI.lbl("Compétence : " + d["skill"], 18, Color(1.0, 0.85, 0.4), HORIZONTAL_ALIGNMENT_CENTER))
	var b = UI.btn("Choisir", d["color"].darkened(0.1), Vector2(240, 54), 24)
	b.pressed.connect(_choose.bind(cls))
	v.add_child(b)
	return p

func _choose(cls):
	Game.new_game(cls)
	main.show_hub()
