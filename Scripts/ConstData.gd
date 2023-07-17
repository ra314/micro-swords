extends Node
const DIR_TO_RELATIVE_SWORD_POS = {
	ENUMS.DIRECTION.RIGHT: Vector2(82, 0), 
	ENUMS.DIRECTION.LEFT: Vector2(10, 0)}

const HELD_ITEM_TO_COLLISION_LAYER = {
	ENUMS.HELD_ITEM.NONE: ENUMS.COLLISION_LAYER.NONE,
	ENUMS.HELD_ITEM.SWORD_1: ENUMS.COLLISION_LAYER.SWORD_1,
	ENUMS.HELD_ITEM.SWORD_2: ENUMS.COLLISION_LAYER.SWORD_2}

const SWORDSMAN_TO_COLLISION_LAYER = {
	ENUMS.SWORDSMAN.BLACK: ENUMS.COLLISION_LAYER.BLACK,
	ENUMS.SWORDSMAN.BLUE: ENUMS.COLLISION_LAYER.BLUE}

# 2 frames at 60 fps
const SWORD_THROWN_INVULNERABILITY_TIME = 2/60

var GRAVITY := 4500
var WIN_SCORE := 5
# Top height for a 90 degree throw should be 5 body heights
var THROW_SPEED := 2000
# 4 bodylengths per second
# const SPEED := 64*4
var SPEED := 350
# Max jump height needs to be 3 times character height
var JUMP_VELOCITY := 1500
var MAX_ROT_RANGE_DEG := 120
var ROT_SPEED := 4

const DEFAULTS := {
	"GRAVITY": [1000, 10000, 4500, 500],
	"WIN_SCORE": [1, 20, 5, 1],
	"THROW_SPEED": [500, 5000, 2000, 100],
	"SPEED": [100, 1000, 350, 50],
	"JUMP_VELOCITY": [0, 10000, 1200, 100],
	"MAX_ROT_RANGE_DEG": [0, 180, 120, 5],
	"ROT_SPEED": [0, 50, 4, 1]}

var MAX_JUMP_HOLD_TIME := 0.3
var REDUCED_GRAVITY_WHEN_HOLDING_JUMP := 2250
var VARIABLE_JUMP_HEIGHT := false
var DOUBLE_JUMP := false
var SEPARATE_BUTTONS := false

#Player: H17, W16
#Platform Ground: W58
#Floating Platform: W60
#Max Jump Height: 51 or 3 times player height
#Speed: 4 bodylengths per second
#Sword Speed: Top height for a 90 degree throw should be 5 body heights
