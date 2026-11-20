extends Node2D

var items = []

func text(pos, s, col, big = false):
	items.append({"k": "t", "p": pos, "s": s, "c": col, "life": 0.9, "max": 0.9, "big": big})

func ring(pos, r, col):
	items.append({"k": "r", "p": pos, "r": r, "c": col, "life": 0.4, "max": 0.4})

func slash(pos, dir, r, col):
	items.append({"k": "s", "p": pos, "a": dir.angle(), "r": r, "c": col, "life": 0.18, "max": 0.18})

func puff(pos, col):
	items.append({"k": "b", "p": pos, "c": col, "life": 0.5, "max": 0.5})

func _process(delta):
	for it in items:
		it["life"] -= delta
	items = items.filter(func(i): return i["life"] > 0.0)
	queue_redraw()

func _draw():
	var font = ThemeDB.fallback_font
	for it in items:
		var f = it["life"] / it["max"]
		var c = it["c"]
		match it["k"]:
			"t":
				var sz = 34 if it["big"] else 24
				var w = font.get_string_size(it["s"], HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x
				var p = it["p"] + Vector2(-w / 2.0, -50.0 * (1.0 - f))
				draw_string(font, p + Vector2(2, 2), it["s"], HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(0, 0, 0, f * 0.7))
				draw_string(font, p, it["s"], HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(c.r, c.g, c.b, min(1.0, f * 2.0)))
			"r":
				var rr = it["r"] * (1.0 - f)
				draw_circle(it["p"], rr, Color(c.r, c.g, c.b, 0.12 * f))
				draw_arc(it["p"], rr, 0.0, TAU, 40, Color(c.r, c.g, c.b, f), 6.0 * f + 2.0, true)
			"s":
				draw_arc(it["p"], it["r"] * 0.85, it["a"] - 0.9, it["a"] + 0.9, 18, Color(1, 1, 1, f), 12.0 * f + 2.0, true)
			"b":
				for i in range(8):
					var a = i * TAU / 8.0
					draw_circle(it["p"] + Vector2(cos(a), sin(a)) * 50.0 * (1.0 - f), 6.0 * f + 1.0, Color(c.r, c.g, c.b, f))
