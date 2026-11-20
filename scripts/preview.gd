extends Node2D

const Art = preload("res://scripts/art.gd")
var cls = "guerrier"
var t = 0.0
var trim = Color(0.8, 0.82, 0.88)

func _process(delta):
	t += delta
	queue_redraw()

func _draw():
	Art.hero(self, cls, t, false, 0.4 * (0.5 + 0.5 * sin(t * 2.5)), trim)
