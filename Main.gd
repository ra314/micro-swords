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

func get_other_sword(sword: ENUMS.HELD_ITEM) -> Sword:
	var swords = ENUMS.HELD_ITEM.values()
	swords.erase(ENUMS.HELD_ITEM.NONE)
	swords.erase(sword)
	assert(len(swords)==1)
	return swords[0]

func get_swordsman(man: ENUMS.SWORDSMAN) -> Swordsman:
	if man == ENUMS.SWORDSMAN.BLACK:
		return $Black
	if man == ENUMS.SWORDSMAN.BLUE:
		return $Blue
	assert(false)
	return null

func get_other_swordsman(man: ENUMS.SWORDSMAN) -> Swordsman:
	var swordsmen = ENUMS.SWORDSMAN.values()
	swordsmen.erase(man)
	assert(len(swordsmen)==1)
	return get_swordsman(swordsmen[0])

func get_holder(sword: ENUMS.HELD_ITEM) -> Swordsman:
	assert(sword != ENUMS.HELD_ITEM.NONE)
	if $Black.held_item == sword:
		return $Black
	if $Blue.held_item == sword:
		return $Blue
	assert(false)
	return null
