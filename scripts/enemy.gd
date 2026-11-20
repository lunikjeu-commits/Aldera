extends Node2D

const Data = preload("res://scripts/data.gd")
const EArt = preload("res://scripts/enemy_art.gd")
const Art = preload("res://scripts/art.gd")

var world
var kind = "gobelin"
var boss = false
var hp = 1.0
var max_hp = 1.0
var dmg = 1.0
var speed = 100.0
var radius = 20.0
var base_scale = 1.0
var t = 0.0
var cd = 1.0
var windup = 0.0
var windup_time = 0.35
var state = "chase"
var state_t = 0.0
var charge_dir = Vector2.RIGHT
var hit_done = false
var dir = Vector2.RIGHT
var moving = false
var flash = 0.0
var knock = Vector2.ZERO
var dead = false

func setup(w, k, stage, is_boss):
	world = w
	kind = k
	boss = is_boss
	var d = Data.ENEMIES[k]
	max_hp = d["hp"] * (1.0 + 0.22 * (stage - 1)) * (7.0 if boss else 1.0)
	hp = max_hp
	dmg = d["dmg"] * (1.0 + 0.15 * (stage - 1)) * (1.5 if boss else 1.0)
	speed = d["speed"] * (0.9 if boss else 1.0)
	base_scale = 1.7 if boss else 1.0
	radius = d["r"] * base_scale
	scale = Vector2(base_scale, base_scale)
	cd = randf_range(0.5, 1.5)
	windup_time = 0.45 if k == "dragon" else (0.5 if k in ["geant", "trex"] else 0.35)

func center():
	return position + Vector2(0, -radius * 0.9)

func _process(delta):
	if world == null or not world.running or dead:
		return
	t += delta
	cd -= delta
	flash = max(0.0, flash - delta)
	var hero = world.hero
	var to = hero.position - position
	var dist = to.length()
	if dist > 1.0:
		dir = to / dist
	var d = Data.ENEMIES[kind]
	moving = false
	match state:
		"chase":
			if kind == "dragon":
				_dragon_move(delta, dist)
			else:
				position += dir * speed * delta
				moving = true
				var reach = d["range"] * base_scale + radius * 0.6
				if dist < reach and cd <= 0.0:
					state = "windup"
					windup = windup_time
				elif kind == "taureau" and dist < 480.0 and dist > 180.0 and cd <= 0.0:
					state = "charge_prep"
					windup = 0.55
					charge_dir = dir
		"windup":
			windup -= delta
			if windup <= 0.0:
				if kind == "dragon":
					_shoot()
				else:
					_strike(d)
				state = "chase"
				cd = 0.9 if boss else 1.3
				if kind == "dragon":
					cd = 1.5 if boss else 2.4
		"charge_prep":
			windup -= delta
			if windup <= 0.0:
				state = "charge"
				state_t = 0.6
				hit_done = false
		"charge":
			state_t -= delta
			position += charge_dir * 620.0 * delta
			moving = true
			if not hit_done and position.distance_to(hero.position) < radius + 24.0:
				hero.hurt(dmg * 1.2, position)
				hit_done = true
			if state_t <= 0.0:
				state = "chase"
				cd = 2.5
	position += knock * delta
	knock = knock.move_toward(Vector2.ZERO, 700.0 * delta)
	for o in world.enemies:
		if o != self and is_instance_valid(o):
			var dd = position - o.position
			var l = dd.length()
			var mind = (radius + o.radius) * 0.8
			if l < mind and l > 0.01:
				position += dd / l * (mind - l) * 0.15
	position.x = clampf(position.x, 30.0, world.WORLD.x - 30.0)
	position.y = clampf(position.y, 50.0, world.WORLD.y - 50.0)
	if state == "windup" or state == "charge_prep":
		modulate = Color(1.5, 0.7, 0.7)
	elif flash > 0.0:
		modulate = Color(1.6, 0.9, 0.9)
	else:
		modulate = Color.WHITE
	scale = Vector2(base_scale * (1.0 if dir.x >= 0.0 else -1.0), base_scale)
	queue_redraw()

func _dragon_move(delta, dist):
	moving = true
	if dist > 330.0:
		position += dir * speed * delta
	elif dist < 230.0:
		position -= dir * speed * 0.7 * delta
	else:
		moving = false
	if cd <= 0.0 and dist < 560.0:
		state = "windup"
		windup = windup_time

func _shoot():
	var origin = position + Vector2(dir.x * 30.0 * base_scale, -radius * 1.8)
	var v = (world.hero.center() - origin).normalized()
	if boss:
		for i in range(-1, 2):
			world.spawn_proj(origin, v.rotated(i * 0.25) * 360.0, dmg, "fire", true)
	else:
		world.spawn_proj(origin, v * 360.0, dmg, "fire", true)

func _strike(d):
	var reach = d["range"] * base_scale + radius * 0.6 + 30.0
	if kind == "geant" or kind == "trex":
		world.fx.ring(position, reach, Color(0.85, 0.65, 0.4))
		world.shake = max(world.shake, 0.25)
	if position.distance_to(world.hero.position) < reach:
		world.hero.hurt(dmg, position)

func hit(amount, from_pos, crit = false):
	if dead:
		return
	hp -= amount
	flash = 0.12
	knock += (position - from_pos).normalized() * (40.0 if boss else 160.0)
	world.fx.text(center() + Vector2(0, -radius), str(int(amount)), Color(1.0, 0.9, 0.3) if crit else Color.WHITE, crit)
	if hp <= 0.0:
		dead = true
		world.enemy_killed(self)
		queue_free()

func _draw():
	var atk = 0.0
	if state == "windup" or state == "charge_prep":
		atk = clampf(1.0 - windup / windup_time, 0.0, 1.0)
	EArt.draw(self, kind, t, moving, atk)
	if hp < max_hp:
		var d = Data.ENEMIES[kind]
		var w = d["r"] * 2.4
		Art.bar(self, Vector2(-w / 2.0, -d["h"] - 16.0), w, 6.0, hp / max_hp, Color(0.9, 0.25, 0.25))
