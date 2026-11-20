extends Node2D

const Data = preload("res://scripts/data.gd")
const HeroS = preload("res://scripts/hero.gd")
const EnemyS = preload("res://scripts/enemy.gd")
const ProjS = preload("res://scripts/projectile.gd")
const HudS = preload("res://scripts/hud.gd")
const GroundS = preload("res://scripts/ground.gd")
const FxS = preload("res://scripts/fx.gd")
const WORLD = Vector2(2200, 1300)

var main
var stage = 1
var running = false
var over = false
var hero
var cam
var fx
var hud
var enemies = []
var move = Vector2.ZERO
var skill_req = false
var dodge_req = false
var to_spawn = 0
var spawn_timer = 1.0
var boss_ref = null
var killed = 0
var xp_gain = 0
var gold_gain = 0
var levels_gained = 0
var loot = []
var shake = 0.0

func setup(m, stg):
	main = m
	stage = stg

func _ready():
	y_sort_enabled = true
	var g = GroundS.new()
	g.setup(stage, WORLD)
	g.z_index = -10
	add_child(g)
	hero = HeroS.new()
	hero.world = self
	hero.position = WORLD / 2.0
	add_child(hero)
	cam = Camera2D.new()
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(WORLD.x)
	cam.limit_bottom = int(WORLD.y)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 9.0
	add_child(cam)
	cam.position = hero.position
	cam.make_current()
	fx = FxS.new()
	fx.z_index = 100
	add_child(fx)
	var layer = CanvasLayer.new()
	add_child(layer)
	hud = HudS.new()
	hud.world = self
	layer.add_child(hud)
	if stage % 3 == 0:
		to_spawn = 6 + stage * 2
		boss_ref = spawn_enemy(Data.boss_kind(stage), true)
		fx.text(hero.position + Vector2(0, -130), "BOSS : " + Data.ENEMIES[boss_ref.kind]["nom"], Color(1.0, 0.4, 0.35), true)
	else:
		to_spawn = 10 + stage * 3
	running = true

func _process(delta):
	cam.position = hero.position + Vector2(0, -30)
	if shake > 0.0:
		shake = max(0.0, shake - delta)
		cam.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 24.0
	else:
		cam.offset = Vector2.ZERO
	if not running:
		return
	spawn_timer -= delta
	var max_alive = 7 + mini(stage, 6)
	if to_spawn > 0 and enemies.size() < max_alive and spawn_timer <= 0.0:
		spawn_timer = max(0.5, 1.6 - stage * 0.08)
		spawn_enemy(Data.pick_kind(stage), false)
		to_spawn -= 1

func spawn_enemy(kind, is_boss):
	var e = EnemyS.new()
	var ang = randf() * TAU
	var dist = 800.0 if is_boss else 650.0 + randf() * 300.0
	var p = hero.position + Vector2(cos(ang), sin(ang)) * dist
	p.x = clampf(p.x, 60.0, WORLD.x - 60.0)
	p.y = clampf(p.y, 60.0, WORLD.y - 60.0)
	if p.distance_to(hero.position) < 400.0:
		p = WORLD - p
	e.position = p
	e.setup(self, kind, stage, is_boss)
	add_child(e)
	enemies.append(e)
	return e

func spawn_proj(pos, vel, dmg, kind, hostile = false, crit = false):
	var p = ProjS.new()
	p.world = self
	p.position = pos
	p.vel = vel
	p.dmg = dmg
	p.kind = kind
	p.hostile = hostile
	p.crit = crit
	add_child(p)
	return p

func nearest_enemy(from, rng):
	var best = null
	var bd = rng
	for e in enemies:
		if is_instance_valid(e) and not e.dead:
			var d = from.distance_to(e.center()) - e.radius
			if d < bd:
				bd = d
				best = e
	return best

func enemies_near(c, r):
	var out = []
	for e in enemies:
		if is_instance_valid(e) and not e.dead and c.distance_to(e.center()) < r + e.radius:
			out.append(e)
	return out

func enemy_killed(e):
	enemies.erase(e)
	killed += 1
	var d = Data.ENEMIES[e.kind]
	var mult = 5 if e.boss else 1
	var xp = int(d["xp"] * (1.0 + 0.15 * (stage - 1)) * mult)
	var gd = int(d["gold"] * (1.0 + 0.2 * (stage - 1)) * mult)
	xp_gain += xp
	gold_gain += gd
	Game.gold += gd
	var lv = Game.add_xp(xp)
	if lv > 0:
		levels_gained += lv
		hero.refresh()
		hero.hp = hero.max_hp
		hero.stamina = hero.max_stamina
		fx.text(hero.position + Vector2(0, -115), "NIVEAU " + str(Game.level) + " !", Color(1.0, 0.85, 0.2), true)
	fx.puff(e.center(), Color(1.0, 0.9, 0.6))
	if randf() < 0.12 + 0.03 * stage or e.boss:
		_drop(e.boss)
	if to_spawn == 0 and enemies.is_empty():
		end_stage(true)

func _drop(is_boss):
	var slot = ["arme", "armure", "amulette"].pick_random()
	var rar = Data.roll_rarity(is_boss, stage)
	var tier = 1 + int(floor((stage - 1) / 2.0))
	var it = Data.make_item(slot, tier, rar, Game.hero_class)
	var msg = Game.give_item(it)
	loot.append(msg)
	fx.text(hero.position + Vector2(0, -150), msg, Data.RARITY[rar]["color"], false)

func hero_died():
	end_stage(false)

func end_stage(win):
	if over:
		return
	over = true
	running = false
	if win:
		var bonus = 20 * stage + (60 * stage if stage % 3 == 0 else 0)
		Game.gold += bonus
		gold_gain += bonus
		if stage >= Game.max_stage:
			Game.max_stage = stage + 1
		Game.current_stage = mini(stage + 1, Game.max_stage)
	Game.save()
	hud.show_result(win)

func quit_to_hub():
	Game.save()
	main.show_hub()
