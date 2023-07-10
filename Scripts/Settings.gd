extends Control

var root: Root3

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureButton.button_up.connect(load_level_selector)
	root = get_parent().get_parent()

func load_level_selector():
	var level_selector = load("res://Scenes/Level Selector.tscn").instantiate()
	root.put_in_container(level_selector)
