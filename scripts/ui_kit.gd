extends RefCounted

static func lbl(text, size = 22, col = Color.WHITE, align = HORIZONTAL_ALIGNMENT_LEFT):
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	return l

static func box(col = Color(0.09, 0.13, 0.2, 0.96), radius = 22):
	var sb = StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.3, 0.42, 0.65, 0.55)
	sb.set_content_margin_all(16)
	sb.shadow_size = 10
	sb.shadow_color = Color(0, 0, 0, 0.35)
	return sb

static func panel(col = Color(0.09, 0.13, 0.2, 0.96)):
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(col))
	return p

static func btn(text, col, min_size = Vector2(240, 60), fs = 24):
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size", fs)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.4))
	for st in ["normal", "hover", "pressed", "disabled"]:
		var sb = StyleBoxFlat.new()
		sb.bg_color = col
		if st == "pressed":
			sb.bg_color = col.darkened(0.25)
		if st == "disabled":
			sb.bg_color = Color(0.25, 0.28, 0.34)
		sb.set_corner_radius_all(16)
		sb.border_width_bottom = 4
		sb.border_color = sb.bg_color.darkened(0.4)
		sb.set_content_margin_all(10)
		b.add_theme_stylebox_override(st, sb)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return b

static func progress(maxv, val, col, h = 14):
	var pb = ProgressBar.new()
	pb.max_value = maxv
	pb.value = val
	pb.show_percentage = false
	pb.custom_minimum_size = Vector2(0, h)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.45)
	bg.set_corner_radius_all(int(h / 2))
	var fg = StyleBoxFlat.new()
	fg.bg_color = col
	fg.set_corner_radius_all(int(h / 2))
	pb.add_theme_stylebox_override("background", bg)
	pb.add_theme_stylebox_override("fill", fg)
	return pb

static func backdrop(ci, s, t):
	var top = Color(0.04, 0.07, 0.14)
	var bot = Color(0.11, 0.18, 0.32)
	ci.draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(s.x, 0), s, Vector2(0, s.y)]), PackedColorArray([top, top, bot, bot]))
	for i in range(28):
		var x = fmod(i * 97.0 + t * (6.0 + i % 5), s.x)
		var y = absf(fmod(i * 53.0 + 20.0 * sin(t * 0.5 + i), s.y))
		ci.draw_circle(Vector2(x, y), 1.5 + i % 3, Color(1.0, 0.9, 0.6, 0.12 + 0.08 * sin(t + i)))
