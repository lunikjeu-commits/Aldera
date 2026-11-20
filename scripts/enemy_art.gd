extends RefCounted

const Art = preload("res://scripts/art.gd")

static func draw(ci, kind, t, moving, atk):
	match kind:
		"gobelin":
			_gobelin(ci, t, moving, atk)
		"taureau":
			_taureau(ci, t, moving, atk)
		"lion":
			_lion(ci, t, moving, atk)
		"geant":
			_geant(ci, t, moving, atk)
		"trex":
			_trex(ci, t, moving, atk)
		"dragon":
			_dragon(ci, t, moving, atk)

static func _gobelin(ci, t, moving, atk):
	var b = sin(t * 14.0) * (3.0 if moving else 1.0)
	var g = Color(0.46, 0.72, 0.3)
	Art.shadow(ci, Vector2(0, 2), 18.0, 6.0)
	Art.ell(ci, Vector2(-6, -5), 5.0, 7.0, g.darkened(0.3))
	Art.ell(ci, Vector2(6, -5), 5.0, 7.0, g.darkened(0.3))
	Art.ell(ci, Vector2(0, -20 + b), 13.0, 15.0, Color(0.5, 0.32, 0.2))
	var hand = Vector2(15, -20 + b)
	var a = -1.0 + atk * 2.0
	ci.draw_line(hand, hand + Vector2(cos(a), sin(a)) * 24.0, Color(0.85, 0.85, 0.9), 4.0, true)
	Art.ball(ci, hand, 5.0, g)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-8, -40 + b), Vector2(-29, -47 + b), Vector2(-10, -30 + b)]), g)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(8, -40 + b), Vector2(29, -47 + b), Vector2(10, -30 + b)]), g)
	Art.ball(ci, Vector2(0, -36 + b), 13.0, g)
	ci.draw_circle(Vector2(5, -38 + b), 3.4, Color(1, 0.95, 0.3))
	ci.draw_circle(Vector2(-4, -38 + b), 3.4, Color(1, 0.95, 0.3))
	ci.draw_circle(Vector2(6, -38 + b), 1.5, Color.BLACK)
	ci.draw_circle(Vector2(-3, -38 + b), 1.5, Color.BLACK)
	ci.draw_line(Vector2(-3, -30 + b), Vector2(7, -31 + b), Color(0.2, 0.1, 0.1), 2.0, true)

static func _legs4(ci, xs, y, b, col):
	for i in range(4):
		var sw = b if i % 2 == 0 else -b
		Art.ell(ci, Vector2(xs[i], y + sw), 6.0, 12.0, col)

static func _taureau(ci, t, moving, atk):
	var b = sin(t * 11.0) * (2.5 if moving else 0.6)
	var br = Color(0.52, 0.3, 0.2)
	Art.shadow(ci, Vector2(2, 2), 42.0, 11.0)
	_legs4(ci, [-26.0, -12.0, 16.0, 30.0], -9.0, b, br.darkened(0.45))
	ci.draw_line(Vector2(-38, -40), Vector2(-54, -22), br.darkened(0.3), 4.0, true)
	Art.ball(ci, Vector2(-55, -20), 5.0, Color(0.2, 0.12, 0.1))
	Art.ell(ci, Vector2(0, -36), 40.0, 25.0, br.darkened(0.3))
	Art.ell(ci, Vector2(-2, -39), 38.0, 23.0, br)
	Art.ell(ci, Vector2(-10, -48), 20.0, 8.0, Color(1, 1, 1, 0.12))
	Art.ball(ci, Vector2(24, -52), 15.0, br.darkened(0.15))
	var hy = -34.0 + atk * 8.0
	Art.ball(ci, Vector2(42, hy), 16.0, br.darkened(0.1))
	Art.ell(ci, Vector2(54, hy + 6), 10.0, 7.0, Color(0.85, 0.65, 0.55))
	ci.draw_circle(Vector2(58, hy + 6), 2.0, Color(0.2, 0.1, 0.1))
	var cream = Color(0.95, 0.92, 0.8)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(36, hy - 10), Vector2(28, hy - 34), Vector2(44, hy - 12)]), cream)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(46, hy - 12), Vector2(56, hy - 34), Vector2(52, hy - 8)]), cream)
	ci.draw_circle(Vector2(47, hy - 4), 3.0, Color(1.0, 0.25, 0.2) if atk > 0.0 else Color(0.1, 0.05, 0.05))

static func _lion(ci, t, moving, atk):
	var b = sin(t * 14.0) * (3.0 if moving else 0.8)
	var gold = Color(0.92, 0.7, 0.3)
	var mane = Color(0.55, 0.3, 0.14)
	Art.shadow(ci, Vector2(0, 2), 36.0, 9.0)
	_legs4(ci, [-22.0, -10.0, 14.0, 26.0], -8.0, b, gold.darkened(0.4))
	ci.draw_line(Vector2(-32, -34), Vector2(-50, -46 + b), gold.darkened(0.2), 4.0, true)
	Art.ball(ci, Vector2(-52, -48 + b), 6.0, mane)
	Art.ell(ci, Vector2(0, -32), 34.0, 19.0, gold.darkened(0.25))
	Art.ell(ci, Vector2(-2, -34), 32.0, 17.0, gold)
	Art.ball(ci, Vector2(30, -46), 25.0, mane)
	Art.ball(ci, Vector2(34, -44 + atk * 5.0), 17.0, gold.lightened(0.1))
	ci.draw_circle(Vector2(24, -64), 6.0, mane.lightened(0.2))
	ci.draw_circle(Vector2(42, -64), 6.0, mane.lightened(0.2))
	ci.draw_circle(Vector2(40, -48), 2.4, Color(0.15, 0.1, 0.05))
	ci.draw_circle(Vector2(30, -48), 2.4, Color(0.15, 0.1, 0.05))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(33, -42), Vector2(43, -42), Vector2(38, -36)]), Color(0.3, 0.15, 0.12))
	if atk > 0.0:
		ci.draw_colored_polygon(PackedVector2Array([Vector2(32, -33), Vector2(36, -26), Vector2(40, -33)]), Color.WHITE)

static func _geant(ci, t, moving, atk):
	var b = sin(t * 6.0) * (3.0 if moving else 1.0)
	var skin = Color(0.58, 0.64, 0.74)
	Art.shadow(ci, Vector2(0, 3), 40.0, 12.0)
	Art.ell(ci, Vector2(-14, -16 + b * 0.5), 13.0, 18.0, skin.darkened(0.3))
	Art.ell(ci, Vector2(14, -16 - b * 0.5), 13.0, 18.0, skin.darkened(0.3))
	Art.ell(ci, Vector2(0, -62 + b), 30.0, 38.0, skin.darkened(0.25))
	Art.ell(ci, Vector2(-2, -64 + b), 28.0, 35.0, skin)
	Art.ell(ci, Vector2(-8, -78 + b), 14.0, 12.0, Color(1, 1, 1, 0.12))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-28, -40 + b), Vector2(28, -40 + b), Vector2(22, -18), Vector2(-22, -18)]), Color(0.45, 0.3, 0.2))
	Art.ball(ci, Vector2(-32, -64 + b), 12.0, skin)
	Art.ball(ci, Vector2(6, -104 + b), 15.0, skin)
	ci.draw_line(Vector2(4, -111 + b), Vector2(16, -108 + b), Color(0.2, 0.15, 0.15), 3.0, true)
	ci.draw_circle(Vector2(12, -104 + b), 2.6, Color(0.9, 0.2, 0.2))
	var hand = Vector2(34, -62 + b)
	var a = -1.2 + atk * 2.5
	var dv = Vector2(cos(a), sin(a))
	ci.draw_line(hand, hand + dv * 70.0, Color(0.4, 0.27, 0.15), 11.0, true)
	Art.ball(ci, hand + dv * 70.0, 14.0, Color(0.45, 0.3, 0.18))
	Art.ball(ci, hand, 8.0, skin)

static func _trex(ci, t, moving, atk):
	var b = sin(t * 8.0) * (3.0 if moving else 1.0)
	var g = Color(0.36, 0.62, 0.46)
	Art.shadow(ci, Vector2(0, 3), 50.0, 12.0)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-16, -60), Vector2(-86, -34 + b), Vector2(-14, -34)]), g.darkened(0.25))
	Art.ell(ci, Vector2(-10, -24 + b * 0.4), 14.0, 24.0, g.darkened(0.35))
	Art.ell(ci, Vector2(14, -24 - b * 0.4), 14.0, 24.0, g.darkened(0.2))
	Art.ell(ci, Vector2(-2, -6), 18.0, 6.0, g.darkened(0.45))
	Art.ell(ci, Vector2(22, -4), 16.0, 6.0, g.darkened(0.45))
	Art.ell(ci, Vector2(2, -62 + b), 34.0, 30.0, g.darkened(0.25), -0.35)
	Art.ell(ci, Vector2(0, -64 + b), 32.0, 28.0, g, -0.35)
	Art.ell(ci, Vector2(8, -52 + b), 20.0, 16.0, g.lightened(0.35), -0.35)
	for i in range(4):
		var sx = -22.0 + i * 12.0
		var sy = -82.0 + b + absf(i - 1.5) * 4.0
		ci.draw_colored_polygon(PackedVector2Array([Vector2(sx - 5, sy), Vector2(sx, sy - 12), Vector2(sx + 5, sy)]), g.darkened(0.45))
	ci.draw_line(Vector2(22, -58 + b), Vector2(36, -48 + b), g.darkened(0.3), 5.0, true)
	Art.ell(ci, Vector2(38, -92 + b), 28.0, 17.0, g.darkened(0.1), -0.15)
	Art.ell(ci, Vector2(40, -78 + b + atk * 12.0), 24.0, 8.0, g.darkened(0.3), 0.15)
	for i in range(4):
		var tx = 28.0 + i * 8.0
		ci.draw_colored_polygon(PackedVector2Array([Vector2(tx, -84 + b), Vector2(tx + 6, -84 + b), Vector2(tx + 3, -77 + b + atk * 6.0)]), Color.WHITE)
	ci.draw_circle(Vector2(46, -98 + b), 4.0, Color(1.0, 0.85, 0.2))
	ci.draw_circle(Vector2(47, -98 + b), 1.8, Color.BLACK)

static func _dragon(ci, t, moving, atk):
	var hv = -28.0 + sin(t * 3.0) * 5.0
	var pu = Color(0.55, 0.25, 0.65)
	var wy = sin(t * 9.0) * 16.0
	Art.shadow(ci, Vector2(0, 4), 36.0, 10.0)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-6, hv - 56), Vector2(-40, hv - 100 - wy), Vector2(-76, hv - 62 - wy * 0.5), Vector2(-34, hv - 50)]), pu.darkened(0.35))
	ci.draw_polyline(PackedVector2Array([Vector2(-18, hv - 30), Vector2(-44, hv - 18), Vector2(-66, hv - 30), Vector2(-84, hv - 22)]), pu.darkened(0.2), 9.0, true)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-84, hv - 30), Vector2(-100, hv - 22), Vector2(-84, hv - 14)]), Color(0.9, 0.5, 0.2))
	Art.ell(ci, Vector2(0, hv - 40), 26.0, 21.0, pu.darkened(0.25))
	Art.ell(ci, Vector2(-1, hv - 42), 24.0, 19.0, pu)
	Art.ell(ci, Vector2(4, hv - 34), 15.0, 12.0, Color(0.95, 0.75, 0.45))
	ci.draw_line(Vector2(14, hv - 54), Vector2(30, hv - 76), pu, 12.0, true)
	Art.ball(ci, Vector2(34, hv - 80), 14.0, pu.lightened(0.05))
	Art.ell(ci, Vector2(46, hv - 76), 11.0, 7.0, pu.lightened(0.15))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(26, hv - 90), Vector2(20, hv - 108), Vector2(34, hv - 92)]), Color(0.95, 0.9, 0.75))
	ci.draw_circle(Vector2(38, hv - 84), 3.0, Color(1.0, 0.85, 0.2))
	if atk > 0.0:
		ci.draw_circle(Vector2(58, hv - 76), 10.0 + atk * 14.0, Color(1.0, 0.5, 0.1, 0.35))
		ci.draw_circle(Vector2(58, hv - 76), 6.0 + atk * 8.0, Color(1.0, 0.85, 0.3, 0.7))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(4, hv - 56), Vector2(38, hv - 104 - wy), Vector2(74, hv - 64 - wy * 0.5), Vector2(34, hv - 50)]), pu.lightened(0.2))
	ci.draw_line(Vector2(4, hv - 56), Vector2(38, hv - 104 - wy), pu.darkened(0.3), 3.0, true)
