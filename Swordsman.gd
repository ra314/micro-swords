extends CharacterBody2D
class_name Swordsman

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var direction: ENUMS.DIRECTION
@export var held_item: ENUMS.HELD_ITEM
var last_held_item: ENUMS.HELD_ITEM

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
	respond_to_collision()

func respond_to_collision():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider_name: String = collision.get_collider().name
		if collider_name.contains("Sword"):
			var sword: Sword = collision.get_collider()
			print("Collided with: ", collider_name)

func change_collision_with_sword(sword: Sword, enable: bool):
	sword.set_collision_mask_value(ENUMS.COLLISION_LAYER.FLOOR, enable)
	sword.set_collision_mask_value(ENUMS.COLLISION_LAYER.SWORDSMAN, enable)
	set_collision_mask_value(ENUMS.COLLISION_LAYER.SWORD, enable)

func action():
	if held_item == ENUMS.HELD_ITEM.NONE:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	else:
		# Enable collisions with the floor and the player
		var sword: Sword = get_sword(held_item)
		change_collision_with_sword(sword, true)
		sword.action(direction)
		last_held_item = held_item
		held_item = ENUMS.HELD_ITEM.NONE
