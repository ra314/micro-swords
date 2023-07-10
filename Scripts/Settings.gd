extends Control

var root: Root3
var last_selected_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureButton.button_up.connect(load_level_selector)
	init_text()
	init_buttons()
	$VBox/double_jump.button_up.connect(func(): ConstData.DOUBLE_JUMP = !ConstData.DOUBLE_JUMP)
	$VBox/variable_jump_height.button_up.connect(func(): ConstData.VARIABLE_JUMP_HEIGHT = !ConstData.VARIABLE_JUMP_HEIGHT)
	$VBox/separate_buttons.button_up.connect(func(): ConstData.SEPARATE_BUTTONS = !ConstData.SEPARATE_BUTTONS)
	root = get_parent().get_parent()

func init_text():
	for child in $VBox.get_children():
		if child is HBoxContainer:
			var property_name = child.name
			var value = child.get_node("Label2")
			var extents = child.get_node("Label3")
			value.text = str(ConstData.DEFAULTS[property_name][2])
			var max = ConstData.DEFAULTS[property_name][1]
			var min = ConstData.DEFAULTS[property_name][0]
			extents.text = "min: %d, max: %d" % [min, max]

func init_buttons():
	for child in $VBox.get_children():
		if child is HBoxContainer:
			var button: Button
			button.button_up.connect(func(): last_selected_button = button)

func load_level_selector():
	var level_selector = load("res://Scenes/Level Selector.tscn").instantiate()
	root.put_in_container(level_selector)
