extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button1.button_up.connect($Black.action)
	$Button2.button_up.connect($Blue.action)
