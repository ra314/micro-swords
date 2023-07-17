extends Control

var root: Root3
var last_selected_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureButton.button_up.connect(load_level_selector)
	init_check_boxes()
	init_text()
	$VBox/DOUBLE_JUMP.button_up.connect(func(): ConstData.DOUBLE_JUMP = !ConstData.DOUBLE_JUMP)
	$VBox/VARIABLE_JUMP_HEIGHT.button_up.connect(func(): ConstData.VARIABLE_JUMP_HEIGHT = !ConstData.VARIABLE_JUMP_HEIGHT)
	$VBox/SEPARATE_BUTTONS.button_up.connect(func(): ConstData.SEPARATE_BUTTONS = !ConstData.SEPARATE_BUTTONS)
	root = get_parent().get_parent()

func init_check_boxes():
	$VBox/VARIABLE_JUMP_HEIGHT.button_pressed = ConstData.VARIABLE_JUMP_HEIGHT
	$VBox/DOUBLE_JUMP.button_pressed = ConstData.DOUBLE_JUMP
	$VBox/SEPARATE_BUTTONS.button_pressed = ConstData.SEPARATE_BUTTONS

func init_text():
	for child in $VBox.get_children():
		if child is HBoxContainer:
			var property_name = child.name
			var spinbox = child.get_node("Label2")
			var extents = child.get_node("Label3")
			spinbox.value = ConstData.DEFAULTS[property_name][2]
			var max = ConstData.DEFAULTS[property_name][1]
			var min = ConstData.DEFAULTS[property_name][0]
			extents.text = "min: %d, max: %d" % [min, max]
			spinbox.min_value = min
			spinbox.max_value = max
			spinbox.step = ConstData.DEFAULTS[property_name][3]

func load_level_selector():
	var level_selector = load("res://Scenes/Level Selector.tscn").instantiate()
	root.put_in_container(level_selector)
