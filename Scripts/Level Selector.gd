extends Node2D

var root: Root3

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control_1/Button.button_up.connect(func(): load_level(1))
	$Control_2/Button.button_up.connect(func(): load_level(2))
	$Control_3/Button.button_up.connect(func(): load_level(3))
	root = get_parent().get_parent()

func load_level(level_number: int):
	var level_path := "res://Scenes/Levels/Level_"+str(level_number)+".tscn"
	var level = load(level_path).instantiate()
	var ui = load("res://Scenes/Main.tscn").instantiate()
	ui.set_level(level)
	root.put_in_container(ui)
