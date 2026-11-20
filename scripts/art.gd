extends RefCounted

static func ell(ci, c, rx, ry, col, rot = 0.0):
	ci.draw_set_transform(c, rot, Vector2(1.0, ry / rx))
	ci.draw_circle(Vector2.ZERO, rx, col)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func shadow(ci, c, rx, ry):
	ell(ci, c, rx, ry, Color(0, 0, 0, 0.10))
	ell(ci, c, rx * 0.78, ry * 0.78, Color(0, 0, 0, 0.12))
	ell(ci, c, rx * 0.55, ry * 0.55, Color(0, 0, 0, 0.14))

static func ball(ci, c, r, col):
	ci.draw_circle(c, r, col.darkened(0.32))
	ci.draw_circle(c + Vector2(-r * 0.06, -r * 0.1), r * 0.9, col)
	ci.draw_circle(c + Vector2(-r * 0.3, -r * 0.38), r * 0.34, col.lightened(0.4))

static func bar(ci, pos, w, h, frac, col):
	ci.draw_rect(Rect2(pos - Vector2(1, 1), Vector2(w + 2, h + 2)), Color(0, 0, 0, 0.6))
	ci.draw_rect(Rect2(pos, Vector2(w * clampf(frac, 0.0, 1.0), h)), col)

static func _eyes(ci, bob):
	ci.draw_circle(Vector2(6, -58 + bob), 2.2, Color(0.1, 0.1, 0.15))
	ci.draw_circle(Vector2(-1, -58 + bob), 2.2, Color(0.1, 0.1, 0.15))

static func _halfdisc(c, r):
	var pts = PackedVector2Array()
	for i in range(9):
		var a = PI + PI * i / 8.0
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	return pts

static func hero(ci, cls, t, moving, swing, trim):
	var bob = sin(t * 9.0) * (2.2 if moving else 1.0)
	var step = sin(t * 12.0) * 5.0 if moving else 0.0
	shadow(ci, Vector2(0, 2), 22.0, 8.0)
	var boots = Color(0.22, 0.17, 0.16)
	ell(ci, Vector2(-8, -7 + step * 0.4), 7.0, 9.0, boots)
	ell(ci, Vector2(8, -7 - step * 0.4), 7.0, 9.0, boots)
	match cls:
		"guerrier":
			_warrior(ci, bob, swing, trim)
		"archer":
			_archer(ci, bob, swing, trim)
		_:
			_mage(ci, bob, swing, trim)

static func _warrior(ci, bob, swing, trim):
	var red = Color(0.78, 0.2, 0.18)
	var steel = Color(0.7, 0.75, 0.82)
	var skin = Color(0.96, 0.8, 0.66)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-10, -44 + bob), Vector2(-28, -6), Vector2(-4, -4), Vector2(6, -44 + bob)]), red.darkened(0.3))
	ell(ci, Vector2(0, -28 + bob), 17.0, 21.0, steel.darkened(0.25))
	ell(ci, Vector2(-1, -30 + bob), 15.0, 18.5, steel)
	ell(ci, Vector2(-4, -36 + bob), 7.0, 9.0, Color(1, 1, 1, 0.18))
	ci.draw_rect(Rect2(-16, -20 + bob, 32, 5), trim)
	ball(ci, Vector2(-17, -41 + bob), 7.5, steel)
	ball(ci, Vector2(17, -41 + bob), 7.5, steel)
	ball(ci, Vector2(0, -58 + bob), 13.0, skin)
	ci.draw_colored_polygon(_halfdisc(Vector2(0, -60 + bob), 15.0), steel)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-3, -75 + bob), Vector2(14, -86 + bob), Vector2(8, -68 + bob)]), red)
	_eyes(ci, bob)
	ell(ci, Vector2(-21, -27 + bob), 10.0, 15.0, red.darkened(0.2))
	ell(ci, Vector2(-21, -27 + bob), 7.0, 11.0, red)
	ci.draw_circle(Vector2(-21, -27 + bob), 3.0, trim)
	var hand = Vector2(20, -28 + bob)
	var a2 = -1.3 + swing * 2.6
	var dv = Vector2(cos(a2), sin(a2))
	var pd = Vector2(-dv.y, dv.x)
	ci.draw_line(hand, hand + dv * 54.0, Color(0.9, 0.94, 1.0), 7.0, true)
	ci.draw_line(hand + pd, hand + dv * 54.0 + pd, Color(1, 1, 1, 0.7), 1.5, true)
	ci.draw_line(hand + dv * 8.0 - pd * 8.0, hand + dv * 8.0 + pd * 8.0, trim, 4.0, true)
	ball(ci, hand, 5.0, skin)

static func _archer(ci, bob, swing, trim):
	var gr = Color(0.2, 0.55, 0.3)
	var skin = Color(0.96, 0.8, 0.66)
	var brown = Color(0.45, 0.3, 0.16)
	ci.draw_line(Vector2(-10, -50 + bob), Vector2(-18, -18 + bob), brown, 9.0, true)
	for i in range(3):
		ci.draw_line(Vector2(-11 + i * 2, -50 + bob), Vector2(-9 + i * 3, -58 + bob), Color(0.9, 0.3, 0.3), 2.0, true)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-8, -44 + bob), Vector2(-24, -6), Vector2(-2, -5), Vector2(6, -44 + bob)]), gr.darkened(0.4))
	ell(ci, Vector2(0, -27 + bob), 15.0, 20.0, gr.darkened(0.25))
	ell(ci, Vector2(-1, -29 + bob), 13.5, 18.0, gr)
	ci.draw_rect(Rect2(-14, -19 + bob, 28, 5), brown)
	ci.draw_rect(Rect2(-3, -21 + bob, 6, 9), trim)
	ball(ci, Vector2(0, -58 + bob), 13.0, skin)
	ci.draw_colored_polygon(_halfdisc(Vector2(0, -58 + bob), 16.0), gr)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-12, -66 + bob), Vector2(-27, -58 + bob), Vector2(-12, -52 + bob)]), gr.darkened(0.15))
	_eyes(ci, bob + 2.0)
	var c = Vector2(6, -30 + bob)
	var p1 = c + Vector2(cos(-1.15), sin(-1.15)) * 26.0
	var p2 = c + Vector2(cos(1.15), sin(1.15)) * 26.0
	ci.draw_arc(c, 26.0, -1.15, 1.15, 14, brown.lightened(0.1), 4.0, true)
	var mid = c + Vector2(10.7 - 8.0 * (1.0 - swing), 0.0)
	ci.draw_line(p1, mid, Color(1, 1, 1, 0.8), 1.5, true)
	ci.draw_line(mid, p2, Color(1, 1, 1, 0.8), 1.5, true)
	ball(ci, mid, 4.5, skin)

static func _mage(ci, bob, swing, trim):
	var bl = Color(0.28, 0.35, 0.85)
	var skin = Color(0.96, 0.8, 0.66)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-20, -3), Vector2(20, -3), Vector2(11, -46 + bob), Vector2(-11, -46 + bob)]), bl.darkened(0.3))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-17, -4), Vector2(17, -4), Vector2(9, -46 + bob), Vector2(-9, -46 + bob)]), bl)
	ci.draw_rect(Rect2(-12, -22 + bob, 24, 5), trim)
	ball(ci, Vector2(-14, -34 + bob), 6.0, bl.lightened(0.1))
	ball(ci, Vector2(0, -58 + bob), 13.0, skin)
	_eyes(ci, bob)
	ell(ci, Vector2(0, -67 + bob), 22.0, 6.0, bl.darkened(0.35))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-14, -67 + bob), Vector2(14, -67 + bob), Vector2(3, -102 + bob)]), bl.darkened(0.15))
	ci.draw_circle(Vector2(0, -75 + bob), 3.0, trim)
	ci.draw_line(Vector2(20, -2), Vector2(25, -74 + bob), Color(0.5, 0.34, 0.2), 5.0, true)
	var o = Vector2(25, -80 + bob)
	var pr = 1.0 + swing * 0.6
	ci.draw_circle(o, 16.0 * pr, Color(0.5, 0.7, 1.0, 0.18))
	ci.draw_circle(o, 11.0 * pr, Color(0.5, 0.75, 1.0, 0.35))
	ci.draw_circle(o, 7.0 * pr, Color(0.85, 0.95, 1.0))
	ball(ci, Vector2(20, -30 + bob), 4.5, skin)
