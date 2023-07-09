extends Node
class_name Root3

# Called when the node enters the scene tree for the first time.
func _ready():
	var level_selector = load("res://Scenes/Level Selector.tscn").instantiate()
	$Container.add_child(level_selector)

func put_in_container(node):
	clear_container()
	$Container.add_child(node)

func clear_container():
	for child in $Container.get_children():
		$Container.remove_child(child)
		child.queue_free()
