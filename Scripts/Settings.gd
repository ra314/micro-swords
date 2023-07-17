extends Control

var root: Root3
var last_selected_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureButton.button_up.connect(load_level_selector)
	init_check_boxes()
	init_spin_boxes()
	$VBox/DOUBLE_JUMP.button_up.connect(func(): ConstData.DOUBLE_JUMP = !ConstData.DOUBLE_JUMP)
	$VBox/VARIABLE_JUMP_HEIGHT.button_up.connect(func(): ConstData.VARIABLE_JUMP_HEIGHT = !ConstData.VARIABLE_JUMP_HEIGHT)
	$VBox/SEPARATE_BUTTONS.button_up.connect(func(): ConstData.SEPARATE_BUTTONS = !ConstData.SEPARATE_BUTTONS)
	$Reset.button_up.connect(reset_to_default)
	root = get_parent().get_parent()

func reset_to_default():
	for child in $VBox.get_children():
		if child is HBoxContainer:
			var property_name = child.name
			var spinbox = child.get_node("Label2")
			spinbox.value = ConstData.DEFAULTS[property_name][2]
	ConstData.DOUBLE_JUMP = false
	ConstData.VARIABLE_JUMP_HEIGHT = false
	ConstData.SEPARATE_BUTTONS = false
	$VBox/VARIABLE_JUMP_HEIGHT.button_pressed = false
	$VBox/SEPARATE_BUTTONS.button_pressed = false
	$VBox/DOUBLE_JUMP.button_pressed = false

func init_check_boxes():
	$VBox/VARIABLE_JUMP_HEIGHT.button_pressed = ConstData.VARIABLE_JUMP_HEIGHT
	$VBox/DOUBLE_JUMP.button_pressed = ConstData.DOUBLE_JUMP
	$VBox/SEPARATE_BUTTONS.button_pressed = ConstData.SEPARATE_BUTTONS

func init_spin_boxes():
	for child in $VBox.get_children():
		if child is HBoxContainer:
			var property_name = child.name
			var spinbox: SpinBox
			spinbox = child.get_node("Label2")
			var extents = child.get_node("Label3")
			var max = ConstData.DEFAULTS[property_name][1]
			var min = ConstData.DEFAULTS[property_name][0]
			extents.text = "min: %d, max: %d" % [min, max]
			spinbox.min_value = min
			spinbox.max_value = max
			spinbox.step = ConstData.DEFAULTS[property_name][3]
			spinbox.value_changed.connect(update_constant.bind(property_name))
			match property_name:
				"GRAVITY":
					spinbox.value = ConstData.GRAVITY
				"WIN_SCORE":
					spinbox.value = ConstData.WIN_SCORE
				"THROW_SPEED":
					spinbox.value = ConstData.THROW_SPEED
				"SPEED":
					spinbox.value = ConstData.SPEED
				"MAX_JUMP_HEIGHT":
					spinbox.value = ConstData.MAX_JUMP_HEIGHT
				"MAX_ROT_RANGE_DEG":
					spinbox.value = ConstData.MAX_ROT_RANGE_DEG
				"ROT_SPEED":
					spinbox.value = ConstData.ROT_SPEED
				_:
					assert(false)

func update_constant(value, property_name) -> void:
	match property_name:
		"GRAVITY":
			ConstData.GRAVITY = value
		"WIN_SCORE":
			ConstData.WIN_SCORE = value
		"THROW_SPEED":
			ConstData.THROW_SPEED = value
		"SPEED":
			ConstData.SPEED = value
		"MAX_JUMP_HEIGHT":
			ConstData.MAX_JUMP_HEIGHT = value
		"MAX_ROT_RANGE_DEG":
			ConstData.MAX_ROT_RANGE_DEG = value
		"ROT_SPEED":
			ConstData.ROT_SPEED = value
		_:
			assert(false)

func load_level_selector():
	var level_selector = load("res://Scenes/Level Selector.tscn").instantiate()
	root.put_in_container(level_selector)
