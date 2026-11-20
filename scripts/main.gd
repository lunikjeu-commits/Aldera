extends Node

const SplashS = preload("res://scripts/splash.gd")
const MenuS = preload("res://scripts/menu.gd")
const HubS = preload("res://scripts/hub.gd")
const WorldS = preload("res://scripts/world.gd")
var current = null

func _ready():
	show_splash()

func _swap(n):
	if current != null:
		current.queue_free()
	current = n
	add_child(n)

func show_splash():
	var n = SplashS.new()
	n.main = self
	_swap(n)

func show_menu():
	var n = MenuS.new()
	n.main = self
	_swap(n)

func show_hub():
	var n = HubS.new()
	n.main = self
	_swap(n)

func start_stage(stg):
	Game.current_stage = stg
	var w = WorldS.new()
	w.setup(self, stg)
	_swap(w)
