class_name ConstData
const DIR_TO_RELATIVE_SWORD_POS = {
	ENUMS.DIRECTION.RIGHT: Vector2(-88, 56), 
	ENUMS.DIRECTION.LEFT: Vector2(8, 56)}

const HELD_ITEM_TO_COLLISION_LAYER = {
	ENUMS.HELD_ITEM.NONE: ENUMS.COLLISION_LAYER.NONE,
	ENUMS.HELD_ITEM.SWORD_1: ENUMS.COLLISION_LAYER.SWORD_1,
	ENUMS.HELD_ITEM.SWORD_2: ENUMS.COLLISION_LAYER.SWORD_2}

const SWORDSMAN_TO_COLLISION_LAYER = {
	ENUMS.SWORDSMAN.BLACK: ENUMS.COLLISION_LAYER.BLACK,
	ENUMS.SWORDSMAN.BLUE: ENUMS.COLLISION_LAYER.BLUE}

const GRAVITY = 4300
const WIN_SCORE = 5

#Player: H17, W16
#Platform Ground: W58
#Floating Platform: W60
#Max Jump Height: 51 or 3 times player height
#Speed: 4 bodylengths per second
#Sword Speed: Top height for a 90 degree throw should be 5 body heights
