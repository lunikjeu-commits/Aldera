extends Node2D

const Art = preload("res://scripts/art.gd")
var stage = 1
var w = Vector2(2200, 1300)

func setup(stg, size_):
	stage = stg
	w = size_

func _draw():
	var biome = int((stage - 1) / 3) % 3
	var cols = [
		[Color(0.33, 0.58, 0.30), Color(0.21, 0.45, 0.26)],
		[Color(0.90, 0.78, 0.52), Color(0.78, 0.62, 0.38)],
		[Color(0.32, 0.26, 0.30), Color(0.19, 0.15, 0.19)],
	]
	var a = cols[biome][0]
	var b = cols[biome][1]
	draw_rect(Rect2(-900, -900, w.x + 1800, w.y + 1800), b.darkened(0.5))
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w.x, 0), w, Vector2(0, w.y)]), PackedColorArray([a.lightened(0.1), a, b, a]))
	var rng = RandomNumberGenerator.new()
	rng.seed = stage * 7919 + 13
	for i in range(36):
		var p = Vector2(rng.randf() * w.x, rng.randf() * w.y)
		var r = rng.randf_range(70.0, 220.0)
		var tint = Color(1, 1, 1, 0.04) if i % 2 == 0 else Color(0, 0, 0, 0.06)
		Art.ell(self, p, r, r * 0.55, tint)
	for i in range(170):
		_decor(biome, Vector2(rng.randf() * w.x, rng.randf() * w.y), rng)
	var vc = Color(0, 0, 0, 0.35)
	var vt = Color(0, 0, 0, 0.0)
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w.x, 0), Vector2(w.x, 160), Vector2(0, 160)]), PackedColorArray([vc, vc, vt, vt]))
	draw_polygon(PackedVector2Array([Vector2(0, w.y - 160), Vector2(w.x, w.y - 160), w, Vector2(0, w.y)]), PackedColorArray([vt, vt, vc, vc]))
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(160, 0), Vector2(160, w.y), Vector2(0, w.y)]), PackedColorArray([vc, vt, vt, vc]))
	draw_polygon(PackedVector2Array([Vector2(w.x - 160, 0), Vector2(w.x, 0), w, Vector2(w.x - 160, w.y)]), PackedColorArray([vt, vc, vc, vt]))
	var x = -60.0
	while x < w.x + 80.0:
		_tree(biome, Vector2(x, -30.0 + rng.randf() * 30.0), rng)
		_tree(biome, Vector2(x + 40.0, w.y + 30.0 + rng.randf() * 30.0), rng)
		x += 80.0
	var y = 40.0
	while y < w.y:
		_tree(biome, Vector2(-30.0 - rng.randf() * 30.0, y), rng)
		_tree(biome, Vector2(w.x + 30.0 + rng.randf() * 30.0, y), rng)
		y += 80.0

func _decor(biome, p, rng):
	var k = rng.randi() % 4
	match biome:
		0:
			if k == 0:
				var gc = Color(0.15, 0.4, 0.2, 0.8)
				draw_line(p, p + Vector2(-4, -12), gc, 2.0, true)
				draw_line(p, p + Vector2(0, -15), gc, 2.0, true)
				draw_line(p, p + Vector2(5, -11), gc, 2.0, true)
			elif k == 1:
				var fc = [Color(1, 0.9, 0.3), Color(1, 0.5, 0.6), Color(0.95, 0.95, 1)][rng.randi() % 3]
				draw_circle(p, 3.5, fc)
				draw_circle(p, 1.5, Color(0.9, 0.6, 0.1))
			elif k == 2:
				Art.ball(self, p, 6.0 + rng.randf() * 5.0, Color(0.55, 0.58, 0.6))
		1:
			if k <= 1:
				draw_arc(p, 30.0, PI * 1.1, PI * 1.9, 12, Color(0.7, 0.55, 0.32, 0.35), 3.0, true)
			elif k == 2:
				Art.ball(self, p, 5.0 + rng.randf() * 4.0, Color(0.62, 0.5, 0.38))
		2:
			if k == 0:
				draw_line(p, p + Vector2(rng.randf_range(-30.0, 30.0), rng.randf_range(-20.0, 20.0)), Color(1.0, 0.45, 0.1, 0.55), 3.0, true)
			elif k == 1:
				Art.ball(self, p, 6.0 + rng.randf() * 5.0, Color(0.25, 0.2, 0.23))

func _tree(biome, p, rng):
	var s = 0.8 + rng.randf() * 0.5
	Art.shadow(self, p + Vector2(0, 6), 30.0 * s, 9.0 * s)
	match biome:
		0:
			draw_rect(Rect2(p.x - 5.0 * s, p.y - 14.0 * s, 10.0 * s, 16.0 * s), Color(0.35, 0.22, 0.12))
			for i in range(3):
				var yy = p.y - (22.0 + i * 24.0) * s
				var wd = (38.0 - i * 9.0) * s
				draw_colored_polygon(PackedVector2Array([Vector2(p.x - wd, yy + 26.0 * s), Vector2(p.x + wd, yy + 26.0 * s), Vector2(p.x, yy - 18.0 * s)]), Color(0.12, 0.38 + i * 0.05, 0.2))
		1:
			var cg = Color(0.25, 0.55, 0.3)
			draw_line(p, p + Vector2(0, -60.0 * s), cg, 14.0 * s, true)
			draw_line(p + Vector2(0, -30.0 * s), p + Vector2(-18.0 * s, -30.0 * s), cg, 9.0 * s, true)
			draw_line(p + Vector2(-18.0 * s, -30.0 * s), p + Vector2(-18.0 * s, -48.0 * s), cg, 9.0 * s, true)
			draw_line(p + Vector2(0, -40.0 * s), p + Vector2(16.0 * s, -40.0 * s), cg, 9.0 * s, true)
		2:
			draw_colored_polygon(PackedVector2Array([Vector2(p.x - 26.0 * s, p.y), Vector2(p.x - 10.0 * s, p.y - 60.0 * s), Vector2(p.x + 4.0 * s, p.y - 30.0 * s), Vector2(p.x + 16.0 * s, p.y - 70.0 * s), Vector2(p.x + 28.0 * s, p.y)]), Color(0.14, 0.11, 0.14))
			draw_line(Vector2(p.x + 2.0 * s, p.y - 4.0 * s), Vector2(p.x + 4.0 * s, p.y - 30.0 * s), Color(1.0, 0.45, 0.1, 0.7), 3.0, true)
