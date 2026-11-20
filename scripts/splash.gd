extends Control

const TEXT = "LC STUDIO"
var main
var t = 0.0
var done = false

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta):
	t += delta
	queue_redraw()
	if t >= 2.15 and not done:
		done = true
		main.show_menu()

func _draw():
	var s = get_viewport_rect().size
	var top = Color(0.04, 0.07, 0.14)
	var bot = Color(0.10, 0.17, 0.30)
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(s.x, 0), s, Vector2(0, s.y)]), PackedColorArray([top, top, bot, bot]))
	var fade = 1.0 - clampf((t - 1.8) / 0.35, 0.0, 1.0)
	var p = clampf(t / 0.5, 0.0, 1.0)
	p = 1.0 - pow(1.0 - p, 3.0)
	var a = p * fade
	var sz = 130.0 * (0.85 + 0.15 * p)
	var c = Vector2(s.x / 2.0, s.y / 2.0 - 50.0)
	var rect = Rect2(c - Vector2(sz, sz) / 2.0, Vector2(sz, sz))
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.2, 0.36, a)
	sb.set_corner_radius_all(int(sz * 0.3))
	sb.border_color = Color(0.3, 0.5, 1.0, a)
	sb.set_border_width_all(3)
	draw_style_box(sb, rect)
	var o = rect.position
	var u = sz / 100.0
	var white = Color(1, 1, 1, a)
	var orange = Color(1.0, 0.62, 0.11, a)
	draw_polyline(PackedVector2Array([o + Vector2(30, 28) * u, o + Vector2(30, 70) * u, o + Vector2(54, 70) * u]), white, 8.0 * u, true)
	draw_circle(o + Vector2(30, 28) * u, 4.0 * u, white)
	draw_circle(o + Vector2(54, 70) * u, 4.0 * u, white)
	var cc = o + Vector2(62, 50) * u
	draw_arc(cc, 22.0 * u, 0.65, TAU - 0.65, 40, orange, 8.0 * u, true)
	draw_circle(cc + Vector2(cos(0.65), sin(0.65)) * 22.0 * u, 4.0 * u, orange)
	draw_circle(cc + Vector2(cos(-0.65), sin(-0.65)) * 22.0 * u, 4.0 * u, orange)
	var q = clampf((t - 0.5) / 0.8, 0.0, 1.0)
	var font = ThemeDB.fallback_font
	var fs = 34
	var sp = 14.0
	var total = 0.0
	for i in range(TEXT.length()):
		total += font.get_string_size(TEXT[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + sp
	total -= sp
	var x = c.x - total / 2.0
	var y = c.y + sz / 2.0 + 62.0
	for i in range(TEXT.length()):
		var al = clampf(q * TEXT.length() - i, 0.0, 1.0) * fade
		draw_string(font, Vector2(x, y), TEXT[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.92, 0.95, 1.0, al))
		x += font.get_string_size(TEXT[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + sp
