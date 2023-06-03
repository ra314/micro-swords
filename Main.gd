extends Node2D
class_name Root
var score := {ENUMS.SWORDSMAN.BLACK: 0, ENUMS.SWORDSMAN.BLUE: 0}
const RESET_PAUSE_TIME = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button1.button_up.connect($Black.action)
	$Button2.button_up.connect($Blue.action)

func get_sword(item: ENUMS.HELD_ITEM) -> Sword: 
	if item == ENUMS.HELD_ITEM.SWORD_1:
		return $Sword1
	if item == ENUMS.HELD_ITEM.SWORD_2:
		return $Sword2
	assert(false)
	return null
func get_swords() -> Array:
	return [$Sword1, $Sword2]
func get_other_sword(item: ENUMS.HELD_ITEM) -> Sword:
	if item == ENUMS.HELD_ITEM.SWORD_1:
		return $Sword2
	if item == ENUMS.HELD_ITEM.SWORD_2:
		return $Sword1
	assert(false)
	return null

func get_swordsman(man: ENUMS.SWORDSMAN) -> Swordsman:
	if man == ENUMS.SWORDSMAN.BLACK:
		return $Black
	if man == ENUMS.SWORDSMAN.BLUE:
		return $Blue
	assert(false)
	return null
func get_swordsmen() -> Array:
	return [$Black, $Blue]
func get_other_swordsman(man: ENUMS.SWORDSMAN) -> Swordsman:
	if man == ENUMS.SWORDSMAN.BLACK:
		return $Blue
	if man == ENUMS.SWORDSMAN.BLUE:
		return $Black
	assert(false)
	return null
func get_other_swordsman_name(man: ENUMS.SWORDSMAN) -> ENUMS.SWORDSMAN:
	if man == ENUMS.SWORDSMAN.BLACK:
		return ENUMS.SWORDSMAN.BLUE
	if man == ENUMS.SWORDSMAN.BLUE:
		return ENUMS.SWORDSMAN.BLACK
	assert(false)
	return ENUMS.SWORDSMAN.BLUE

func collide(swordsman: Swordsman, sword: Sword, enable: bool):
	swordsman.set_collision_mask_value(sword.collision_layer(), enable)

func update_collision_between_swords_and_swordsmen():
	for swordsman in get_swordsmen():
		for sword in get_swords():
			match sword.state:
				# If a sword is being held, you should never be able to 
				# collide with it.
				ENUMS.SWORD_STATE.HELD:
					collide(swordsman, sword, false)
				ENUMS.SWORD_STATE.THROWN:
					# Don't collide with a sword you've thrown if it's mid air
					if swordsman.last_held_item == sword.sword_name:
						collide(swordsman, sword, false)
					# Only collide if you're not the one that threw the sword
					else:
						collide(swordsman, sword, true)
				ENUMS.SWORD_STATE.GROUNDED:
					if swordsman.held_item == ENUMS.HELD_ITEM.NONE:
						# If you're not holding anything, you need to collide
						# with grounded swords to be able to pick it up
						collide(swordsman, sword, true)
					elif swordsman.held_item in {ENUMS.HELD_ITEM.SWORD_1:1, ENUMS.HELD_ITEM.SWORD_2:1}:
						# If you're already holding a sword, then you can't
						# pick up a grounded sword
						collide(swordsman, sword, false)
					else:
						assert(false)
				_:
					assert(false)

func update_collision_between_grounded_swords_and_empty_swordsmen():
	for swordsman in get_swordsmen():
		for sword in get_swords():
			if sword.state == ENUMS.SWORD_STATE.GROUNDED:
				var enable_collision = swordsman.held_item == ENUMS.HELD_ITEM.NONE
				swordsman.set_collision_mask_value(sword.collision_layer(), enable_collision)

func died(man: ENUMS.SWORDSMAN):
	score[get_other_swordsman_name(man)] += 1
	update_ui()
	# If both players die within RESET_PAUSE_TIME,
	# we don't want reset to be called twice.
	if resetting: return
	get_tree().create_timer(RESET_PAUSE_TIME).timeout.connect(reset)
	resetting = true
func update_ui():
	$BlackScore.text = str(score[ENUMS.SWORDSMAN.BLACK])
	$BlueScore.text = str(score[ENUMS.SWORDSMAN.BLUE])
var resetting := false
func reset():
	if has_node("Black"):
		$Black.queue_free()
	if has_node("Blue"):
		$Blue.queue_free()
	if has_node("Sword1"):
		$Sword1.queue_free()
	if has_node("Sword2"):
		$Sword2.queue_free()
	var black = load("res://Swordsman.tscn").instantiate().init(ENUMS.DIRECTION.RIGHT, ENUMS.SWORDSMAN.BLACK, ENUMS.HELD_ITEM.SWORD_1)
	var blue = load("res://Swordsman.tscn").instantiate().init(ENUMS.DIRECTION.LEFT, ENUMS.SWORDSMAN.BLUE, ENUMS.HELD_ITEM.SWORD_2)
	var sword1 = load("res://Sword.tscn").instantiate().init(ENUMS.DIRECTION.RIGHT, ENUMS.HELD_ITEM.SWORD_1, ENUMS.SWORD_STATE.HELD)
	var sword2 = load("res://Sword.tscn").instantiate().init(ENUMS.DIRECTION.LEFT, ENUMS.HELD_ITEM.SWORD_2, ENUMS.SWORD_STATE.HELD)
	add_child(sword1)
	add_child(sword2)
	add_child(black)
	add_child(blue)
	resetting = false
