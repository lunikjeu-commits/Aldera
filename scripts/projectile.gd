extends Node2D

var world
var vel = Vector2.ZERO
var dmg = 1.0
var kind = "arrow"
var hostile = false
var crit = false
var life = 1.0
var radius = 10.0
var aoe = 0.0
var homing = 0.0
var t = 0.0

func _ready():
	rotation = vel.angle()
	match kind:
		"arrow":
			life = 0.65
			radius = 12.0
		"orb":
			life = 1.8
			radius = 14.0
			homing = 5.0
			aoe = 100.0
		"fire":
			life = 3.0
			radius = 18.0

func _process(delta):
	if not world.running:
		return
	t += delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	if homing > 0.0:
		var tg = world.nearest_enemy(position, 320.0)
		if tg != null:
			var want = (tg.center() - position).normalized() * vel.length()
			vel = vel.lerp(want, clampf(homing * delta, 0.0, 1.0))
			rotation = vel.angle()
	position += vel * delta
	if hostile:
		if position.distance_to(world.hero.center()) < radius + 18.0:
			world.hero.hurt(dmg, position)
			queue_free()
		queue_redraw()
		return
	for e in world.enemies:
		if is_instance_valid(e) and not e.dead and position.distance_to(e.center()) < radius + e.radius * 0.8:
			_impact(e)
			return
	queue_redraw()

func _impact(e):
	var back = position - vel.normalized() * 10.0
	if aoe > 0.0:
		world.fx.ring(position, aoe, Color(0.5, 0.6, 1.0))
		for o in world.enemies_near(position, aoe):
			o.hit(dmg * (1.0 if o == e else 0.6), back, crit and o == e)
	else:
		e.hit(dmg, back, crit)
	queue_free()

func _draw():
	match kind:
		"arrow":
			draw_line(Vector2(-22, 0), Vector2(6, 0), Color(0.55, 0.38, 0.2), 3.0, true)
			draw_colored_polygon(PackedVector2Array([Vector2(6, -4), Vector2(17, 0), Vector2(6, 4)]), Color(0.85, 0.9, 1.0))
			draw_line(Vector2(-22, 0), Vector2(-28, -5), Color(0.9, 0.3, 0.3), 2.5, true)
			draw_line(Vector2(-22, 0), Vector2(-28, 5), Color(0.9, 0.3, 0.3), 2.5, true)
		"orb":
			var p = 1.0 + 0.15 * sin(t * 20.0)
			draw_circle(Vector2.ZERO, 22.0 * p, Color(0.5, 0.7, 1.0, 0.18))
			draw_circle(Vector2.ZERO, 15.0 * p, Color(0.5, 0.75, 1.0, 0.4))
			draw_circle(Vector2.ZERO, 8.0, Color(0.9, 0.97, 1.0))
		"fire":
			var f = 1.0 + 0.2 * sin(t * 25.0)
			draw_circle(Vector2.ZERO, 24.0 * f, Color(1.0, 0.4, 0.1, 0.25))
			draw_circle(Vector2.ZERO, 16.0 * f, Color(1.0, 0.55, 0.15, 0.7))
			draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.95, 0.5))
