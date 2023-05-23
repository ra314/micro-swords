extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var direction: ENUMS.DIRECTION
@export var held_item: ENUMS.HELD_ITEM

func approx_equal(x, y):
	return abs(y-x) < 0.1

func get_sword(item: ENUMS.HELD_ITEM):
	if item == ENUMS.HELD_ITEM.SWORD_1:
		return $"../Sword1"
	if item == ENUMS.HELD_ITEM.SWORD_2:
		return $"../Sword2"
	assert(false)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle switching directions
	if approx_equal(position.x, 0):
		direction = ENUMS.DIRECTION.RIGHT
	elif approx_equal(position.x, 1920-64):
		direction = ENUMS.DIRECTION.LEFT
	
	# Set velocity based on direction
	if direction == ENUMS.DIRECTION.RIGHT:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED
	
	# Sync sword velocity with swordsman velocity
	if held_item != ENUMS.HELD_ITEM.NONE:
		get_sword(held_item).velocity = velocity
	
	# MOVE
	move_and_slide()

func action():
	if held_item == ENUMS.HELD_ITEM.NONE:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	else:
		get_sword(held_item).action(direction)
		held_item = ENUMS.HELD_ITEM.NONE
