extends Node2D
class_name Root

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

func get_holder(sword: ENUMS.HELD_ITEM) -> Swordsman:
	assert(sword != ENUMS.HELD_ITEM.NONE)
	if $Black.held_item == sword:
		return $Black
	if $Blue.held_item == sword:
		return $Blue
	assert(false)
	return null

func update_collision_between_grounded_swords_and_empty_swordsmen():
	for swordsman in get_swordsmen():
		for sword in get_swords():
			if sword.state == ENUMS.SWORD_STATE.GROUNDED:
				var enable_collision = swordsman.held_item == ENUMS.HELD_ITEM.NONE
				swordsman.set_collision_mask_value(sword.collision_layer(), enable_collision)

func debug_collision_print():
	print($Black.collision_mask)
	print($Blue.collision_mask)
	print($Sword1.collision_mask)
	print($Sword2.collision_mask)
	print($Black.held_item)
	print($Blue.held_item)
	print($Sword1.state)
	print($Sword2.state)
