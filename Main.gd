extends Node2D
class_name Root
var score := {ENUMS.SWORDSMAN.BLACK: 0, ENUMS.SWORDSMAN.BLUE: 0}

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

func update_collision_between_grounded_swords_and_empty_swordsmen():
	for swordsman in get_swordsmen():
		for sword in get_swords():
			if sword.state == ENUMS.SWORD_STATE.GROUNDED:
				var enable_collision = swordsman.held_item == ENUMS.HELD_ITEM.NONE
				swordsman.set_collision_mask_value(sword.collision_layer(), enable_collision)
func died(man: ENUMS.SWORDSMAN):
	score[get_other_swordsman(man).swordsman_name] += 1
	update_ui()
func update_ui():
	$BlackScore.text = str(score[ENUMS.SWORDSMAN.BLACK])
	$BlueScore.text = str(score[ENUMS.SWORDSMAN.BLUE])
