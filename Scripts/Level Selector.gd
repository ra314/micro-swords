extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control_1/Button.button_up.connect(func(): load_level(1))
	$Control_2/Button.button_up.connect(func(): load_level(2))
	$Control_3/Button.button_up.connect(func(): load_level(3))

func load_level(level_number: int):
	print(level_number)
