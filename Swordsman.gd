extends CharacterBody2D
class_name Swordsman

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var direction: ENUMS.DIRECTION
@export var held_item: ENUMS.HELD_ITEM
@export var swordsman_name: ENUMS.SWORDSMAN
var last_held_item: ENUMS.HELD_ITEM

func approx_equal(x, y):
	return abs(y-x) < 0.1

func get_sword(item: ENUMS.HELD_ITEM):
	if item == ENUMS.HELD_ITEM.SWORD_1:
		return $"../Sword1"
	if item == ENUMS.HELD_ITEM.SWORD_2:
		return $"../Sword2"
	assert(false)

func get_swordsman(man: ENUMS.SWORDSMAN):
	if man == ENUMS.SWORDSMAN.BLACK:
		return $"../Black"
	if man == ENUMS.SWORDSMAN.BLUE:
		return $"../Blue"
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
	detect_sword_collision()

func detect_sword_collision():
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.name.contains("Sword"):
			respond_to_collision(collider)

func respond_to_collision(sword: Sword):
	match sword.state:
		ENUMS.SWORD_STATE.HELD:
			pass
		ENUMS.SWORD_STATE.GROUNDED:
			if held_item == ENUMS.HELD_ITEM.NONE:
				pickup_sword(sword)
		ENUMS.SWORD_STATE.THROWN:
			if last_held_item != sword.sword_name:
				die()
				sword.die()
		_:
			assert(false)

func die():
	queue_free()
	if held_item != ENUMS.HELD_ITEM.NONE:
		get_sword(held_item).die()

func pickup_sword(sword: Sword):
	print("pickup")

func change_collision_with_sword(sword: Sword, enable: bool):
	sword.set_collision_mask_value(ENUMS.COLLISION_LAYER.FLOOR, enable)
	sword.set_collision_mask_value(ENUMS.COLLISION_LAYER.SWORDSMAN, enable)
	match sword.sword_name:
		ENUMS.HELD_ITEM.SWORD_1:
			set_collision_mask_value(ENUMS.COLLISION_LAYER.SWORD_1, enable)
		ENUMS.HELD_ITEM.SWORD_2:
			set_collision_mask_value(ENUMS.COLLISION_LAYER.SWORD_2, enable)
		_:
			assert(false)

func action():
	if held_item == ENUMS.HELD_ITEM.NONE:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	else:
		# Enable collisions with the floor and the player
		var sword: Sword = get_sword(held_item)
		get_swordsman(ENUMS.SWORDSMAN.BLACK).change_collision_with_sword(sword, true)
		get_swordsman(ENUMS.SWORDSMAN.BLUE).change_collision_with_sword(sword, true)
		sword.action(direction)
		last_held_item = held_item
		held_item = ENUMS.HELD_ITEM.NONE
