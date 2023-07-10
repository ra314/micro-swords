extends Control
class_name NumPad

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/Label.button_up.connect(func(): number.emit(1))
	$VBoxContainer/HBoxContainer/Label2.button_up.connect(func(): number.emit(2))
	$VBoxContainer/HBoxContainer/Label3.button_up.connect(func(): number.emit(3))
	$VBoxContainer/HBoxContainer2/Label.button_up.connect(func(): number.emit(4))
	$VBoxContainer/HBoxContainer2/Label2.button_up.connect(func(): number.emit(5))
	$VBoxContainer/HBoxContainer2/Label3.button_up.connect(func(): number.emit(6))
	$VBoxContainer/HBoxContainer3/Label.button_up.connect(func(): number.emit(7))
	$VBoxContainer/HBoxContainer3/Label2.button_up.connect(func(): number.emit(8))
	$VBoxContainer/HBoxContainer3/Label3.button_up.connect(func(): number.emit(9))
	$VBoxContainer/HBoxContainer4/Label.button_up.connect(func(): number.emit(0))

signal number
