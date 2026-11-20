extends Control

const UI = preload("res://scripts/ui_kit.gd")
const Data = preload("res://scripts/data.gd")
const JOY_R = 90.0

var world
var joy_index = -1
var joy_origin = Vector2.ZERO
var joy_pos = Vector2.ZERO
var overlay = null

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _layout():
	var s = get_viewport_rect().size
	return {"skill": Vector2(s.x - 120, s.y - 130), "dodge": Vector2(s.x - 270, s.y - 80), "pause": Vector2(s.x - 50, 50)}

func _input(event):
	if world == null or overlay != null:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_press(event.index, event.position)
		elif event.index == joy_index:
			joy_index = -1
	elif event is InputEventScreenDrag:
		if event.index == joy_index:
			var v = event.position - joy_origin
			if v.length() > JOY_R:
				v = v.normalized() * JOY_R
			joy_pos = joy_origin + v

func _press(idx, pos):
	var L = _layout()
	if pos.distance_to(L["pause"]) < 40.0:
		show_pause()
		return
	if pos.distance_to(L["skill"]) < 72.0:
		world.skill_req = true
		return
	if pos.distance_to(L["dodge"]) < 58.0:
		world.dodge_req = true
		return
	if joy_index == -1 and pos.x < get_viewport_rect().size.x * 0.6:
		joy_index = idx
		joy_origin = pos
		joy_pos = pos

func _process(_delta):
	if world == null:
		return
	var mv = Vector2.ZERO
	if joy_index != -1:
		var v = (joy_pos - joy_origin) / JOY_R
		if v.length() > 0.12:
			mv = v
	else:
		mv = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	world.move = mv
	queue_redraw()

func _txt(s, pos, size, col, centered):
	var font = ThemeDB.fallback_font
	var p = pos
	if centered:
		p.x -= font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / 2.0
	draw_string(font, p + Vector2(1.5, 1.5), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0, 0, 0, 0.6))
	draw_string(font, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

func _rbar(r, frac, col):
	var rad = int(r.size.y / 2.0)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.5)
	bg.set_corner_radius_all(rad)
	draw_style_box(bg, r)
	if frac > 0.01:
		var fg = StyleBoxFlat.new()
		fg.bg_color = col
		fg.set_corner_radius_all(rad)
		draw_style_box(fg, Rect2(r.position, Vector2(maxf(r.size.y, r.size.x * clampf(frac, 0.0, 1.0)), r.size.y)))

func _pie(c, r, frac, col):
	var pts = PackedVector2Array([c])
	for i in range(29):
		var a = -PI / 2.0 + TAU * frac * i / 28.0
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, col)

func _button(c, r, col, label, cdf, ok):
	draw_circle(c, r + 5.0, Color(0, 0, 0, 0.35))
	draw_circle(c, r, col.darkened(0.2) if ok else Color(0.25, 0.27, 0.32))
	draw_circle(c, r * 0.82, col if ok else Color(0.32, 0.34, 0.4))
	draw_arc(c, r, 0.0, TAU, 40, Color(1, 1, 1, 0.5), 3.0, true)
	if cdf > 0.0:
		_pie(c, r, clampf(cdf, 0.0, 1.0), Color(0, 0, 0, 0.55))
	_txt(label, c + Vector2(0, 7), 20, Color.WHITE, true)

func _draw():
	if world == null or world.hero == null:
		return
	var s = get_viewport_rect().size
	var hero = world.hero
	var info = Data.CLASSES[Game.hero_class]
	_txt("Niv. " + str(Game.level), Vector2(28, 38), 20, Color(1.0, 0.85, 0.4), false)
	_rbar(Rect2(24, 44, 330, 24), hero.hp / hero.max_hp, Color(0.9, 0.25, 0.3))
	_txt(str(int(hero.hp)) + " / " + str(int(hero.max_hp)), Vector2(189, 62), 16, Color.WHITE, true)
	_rbar(Rect2(24, 74, 260, 14), hero.stamina / hero.max_stamina, Color(0.95, 0.78, 0.25))
	_rbar(Rect2(24, 94, 260, 9), float(Game.xp) / float(Game.xp_needed()), Color(0.4, 0.62, 1.0))
	_txt("Niveau " + str(world.stage), Vector2(s.x / 2.0, 36), 26, Color.WHITE, true)
	_txt("Ennemis : " + str(world.to_spawn + world.enemies.size()), Vector2(s.x / 2.0, 62), 18, Color(1, 1, 1, 0.75), true)
	var bo = world.boss_ref
	if bo != null and is_instance_valid(bo) and not bo.dead:
		_txt(Data.ENEMIES[bo.kind]["nom"].to_upper(), Vector2(s.x / 2.0, 90), 18, Color(1.0, 0.5, 0.45), true)
		_rbar(Rect2(s.x / 2.0 - 230.0, 98, 460, 16), bo.hp / bo.max_hp, Color(0.85, 0.2, 0.25))
	draw_circle(Vector2(s.x - 190, 48), 11.0, Color(1.0, 0.8, 0.2))
	draw_circle(Vector2(s.x - 190, 48), 6.0, Color(1.0, 0.92, 0.5))
	_txt(str(Game.gold), Vector2(s.x - 172, 57), 22, Color(1.0, 0.9, 0.5), false)
	var L = _layout()
	draw_circle(L["pause"], 30.0, Color(0, 0, 0, 0.4))
	draw_rect(Rect2(s.x - 58, 38, 6, 24), Color(1, 1, 1, 0.8))
	draw_rect(Rect2(s.x - 46, 38, 6, 24), Color(1, 1, 1, 0.8))
	if joy_index != -1:
		draw_circle(joy_origin, JOY_R, Color(1, 1, 1, 0.10))
		draw_arc(joy_origin, JOY_R, 0.0, TAU, 40, Color(1, 1, 1, 0.35), 3.0, true)
		draw_circle(joy_pos, 38.0, Color(1, 1, 1, 0.35))
	else:
		draw_arc(Vector2(150, s.y - 130), JOY_R, 0.0, TAU, 40, Color(1, 1, 1, 0.12), 3.0, true)
	_button(L["skill"], 62.0, info["color"], info["skill"], hero.skill_cd / info["skill_cd"], hero.stamina >= 35.0)
	_button(L["dodge"], 48.0, Color(0.4, 0.5, 0.7), "Esquive", 0.0, hero.stamina >= 25.0)

func _overlay(title, tcol):
	joy_index = -1
	world.move = Vector2.ZERO
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cc = CenterContainer.new()
	dim.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var p = UI.panel()
	cc.add_child(p)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	v.add_child(UI.lbl(title, 48, tcol, HORIZONTAL_ALIGNMENT_CENTER))
	overlay = dim
	return v

func show_pause():
	if overlay != null or world.over:
		return
	world.running = false
	var v = _overlay("Pause", Color.WHITE)
	var b1 = UI.btn("Reprendre", Color(0.2, 0.6, 0.4), Vector2(320, 62), 26)
	b1.pressed.connect(_resume)
	v.add_child(b1)
	var b2 = UI.btn("Quitter le niveau", Color(0.6, 0.3, 0.3), Vector2(320, 62), 26)
	b2.pressed.connect(world.quit_to_hub)
	v.add_child(b2)

func _resume():
	if overlay != null:
		overlay.queue_free()
		overlay = null
	world.running = true

func show_result(win):
	var v = _overlay("VICTOIRE !" if win else "DÉFAITE", Color(0.4, 1.0, 0.5) if win else Color(1.0, 0.4, 0.4))
	v.add_child(UI.lbl("Ennemis vaincus : " + str(world.killed), 24, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(UI.lbl("XP gagnée : " + str(world.xp_gain) + "     Or gagné : " + str(world.gold_gain), 24, Color(1.0, 0.9, 0.5), HORIZONTAL_ALIGNMENT_CENTER))
	if world.levels_gained > 0:
		v.add_child(UI.lbl("Niveaux gagnés : +" + str(world.levels_gained) + "  (points à dépenser !)", 22, Color(0.5, 1.0, 0.6), HORIZONTAL_ALIGNMENT_CENTER))
	for i in range(mini(world.loot.size(), 5)):
		v.add_child(UI.lbl(world.loot[i], 20, Color(1.0, 0.85, 0.4), HORIZONTAL_ALIGNMENT_CENTER))
	var nb = UI.btn("Niveau suivant" if win else "Réessayer", Color(0.9, 0.5, 0.15), Vector2(320, 62), 26)
	nb.pressed.connect(world.main.start_stage.bind(world.stage + 1 if win else world.stage))
	v.add_child(nb)
	var hb = UI.btn("Camp de base", Color(0.3, 0.4, 0.6), Vector2(320, 56), 24)
	hb.pressed.connect(world.main.show_hub)
	v.add_child(hb)
