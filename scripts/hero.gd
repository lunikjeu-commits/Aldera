extends Node2D

const Data = preload("res://scripts/data.gd")
const Art = preload("res://scripts/art.gd")

var world
var hp = 100.0
var max_hp = 100.0
var stamina = 100.0
var max_stamina = 100.0
var cd = 0.0
var skill_cd = 0.0
var swing = 0.0
var t = 0.0
var facing = 1.0
var moving = false
var inv = 0.0
var dodge_t = 0.0
var dodge_dir = Vector2.RIGHT
var flash = 0.0
var trim = Color(0.8, 0.82, 0.88)

func _ready():
	refresh()
	hp = max_hp
	stamina = max_stamina
	var a = Game.equipped["armure"]
	if a != null:
		trim = Data.RARITY[a["rar"]]["color"]

func refresh():
	max_hp = float(Game.max_hp())
	max_stamina = float(Game.max_stamina())
	hp = min(hp, max_hp)

func center():
	return position + Vector2(0, -34)

func _process(delta):
	if not world.running:
		return
	t += delta
	cd -= delta
	skill_cd -= delta
	inv -= delta
	flash -= delta
	swing = max(0.0, swing - delta * 4.0)
	stamina = min(max_stamina, stamina + Game.stamina_regen() * delta)
	var mv = world.move
	moving = mv.length() > 0.05
	if dodge_t > 0.0:
		dodge_t -= delta
		position += dodge_dir * 640.0 * delta
	else:
		position += mv * Game.move_speed() * delta
		if world.dodge_req and stamina >= 25.0:
			stamina -= 25.0
			dodge_t = 0.22
			dodge_dir = mv.normalized() if moving else Vector2(facing, 0.0)
	world.dodge_req = false
	if absf(mv.x) > 0.1:
		facing = 1.0 if mv.x > 0.0 else -1.0
	position.x = clampf(position.x, 40.0, world.WORLD.x - 40.0)
	position.y = clampf(position.y, 60.0, world.WORLD.y - 60.0)
	_auto_attack()
	if world.skill_req:
		world.skill_req = false
		_use_skill()
	var al = 1.0
	if dodge_t > 0.0:
		al = 0.45
	elif inv > 0.0 and fmod(t * 20.0, 2.0) < 1.0:
		al = 0.55
	modulate = Color(1.6, 0.8, 0.8, al) if flash > 0.0 else Color(1, 1, 1, al)
	scale.x = facing
	queue_redraw()

func _roll(mult = 1.0):
	var crit = randf() < Game.crit_chance()
	var a = Game.damage() * mult * randf_range(0.9, 1.1)
	if crit:
		a *= 2.0
	return [a, crit]

func _auto_attack():
	if cd > 0.0 or dodge_t > 0.0:
		return
	var info = Data.CLASSES[Game.hero_class]
	var rng = info["range"]
	var target = world.nearest_enemy(center(), rng)
	if target == null:
		return
	cd = Game.attack_cd()
	swing = 1.0
	var dir = (target.center() - center()).normalized()
	facing = 1.0 if dir.x >= 0.0 else -1.0
	match Game.hero_class:
		"guerrier":
			world.fx.slash(center(), dir, rng, Color.WHITE)
			for e in world.enemies_near(center(), rng):
				var to = (e.center() - center()).normalized()
				if to.dot(dir) > 0.1:
					var r = _roll()
					e.hit(r[0], position, r[1])
		"archer":
			var r = _roll()
			world.spawn_proj(center(), dir * 950.0, r[0], "arrow", false, r[1])
		"mage":
			var r = _roll(1.1)
			world.spawn_proj(center(), dir * 620.0, r[0], "orb", false, r[1])

func _use_skill():
	var info = Data.CLASSES[Game.hero_class]
	if skill_cd > 0.0 or stamina < 35.0:
		return
	stamina -= 35.0
	skill_cd = info["skill_cd"]
	swing = 1.0
	var d = Game.damage()
	match Game.hero_class:
		"guerrier":
			world.fx.ring(center(), 170.0, Color(1.0, 0.5, 0.3))
			for e in world.enemies_near(center(), 170.0):
				e.hit(d * 2.2, position)
		"archer":
			var tg = world.nearest_enemy(center(), 700.0)
			var base = Vector2(facing, 0.0)
			if tg != null:
				base = (tg.center() - center()).normalized()
			for i in range(-3, 4):
				world.spawn_proj(center(), base.rotated(i * 0.16) * 950.0, d * 0.9, "arrow", false, false)
		"mage":
			world.fx.ring(center(), 240.0, Color(0.5, 0.6, 1.0))
			for e in world.enemies_near(center(), 240.0):
				e.hit(d * 2.0, position)
	world.shake = max(world.shake, 0.2)

func hurt(amount, from_pos):
	if inv > 0.0 or dodge_t > 0.0 or not world.running:
		return
	var a = max(1.0, amount * 100.0 / (100.0 + Game.armor() * 3.0))
	hp -= a
	inv = 0.45
	flash = 0.15
	world.fx.text(position + Vector2(0, -90), str(int(a)), Color(1.0, 0.35, 0.35), false)
	world.shake = 0.3
	if hp <= 0.0:
		world.hero_died()

func _draw():
	Art.hero(self, Game.hero_class, t, moving, swing, trim)
