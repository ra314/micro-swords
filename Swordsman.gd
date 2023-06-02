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
var root: Root

func _ready():
	root = get_parent()

func update_held_sword_location(sword: Sword):
	sword.position = position-ConstData.DIR_TO_RELATIVE_SWORD_POS[direction]

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle switching directions
	if Utils.approx_equal(position.x, 0):
		direction = ENUMS.DIRECTION.RIGHT
		update_held_sword_location(root.get_sword(held_item))
	elif Utils.approx_equal(position.x, 1920-64):
		direction = ENUMS.DIRECTION.LEFT
		update_held_sword_location(root.get_sword(held_item))
	
	# Set velocity based on direction
	if direction == ENUMS.DIRECTION.RIGHT:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED
	
	# Sync sword velocity with swordsman velocity
	if held_item != ENUMS.HELD_ITEM.NONE:
		root.get_sword(held_item).velocity = velocity
	
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
				print("pickup")
				pickup_sword(sword)
		ENUMS.SWORD_STATE.THROWN:
			if last_held_item != sword.sword_name:
				print("die")
				die()
				sword.die()
		_:
			assert(false)

func die():
	queue_free()
	if held_item != ENUMS.HELD_ITEM.NONE:
		root.get_sword(held_item).die()

func pickup_sword(sword: Sword):
	held_item = sword.sword_name
	update_held_sword_location(sword)
	sword.state = ENUMS.SWORD_STATE.HELD
	sword.direction = direction
	# Dsiable collision
	sword.set_collision_mask_value(ENUMS.COLLISION_LAYER.FLOOR, false)
	sword.set_collision_mask_value(ENUMS.COLLISION_LAYER.SWORDSMAN, false)
	root.get_swordsman(ENUMS.SWORDSMAN.BLACK).set_collision_mask_value(sword.collision_layer(), false)
	root.get_swordsman(ENUMS.SWORDSMAN.BLUE).set_collision_mask_value(sword.collision_layer(), false)

func action():
	# JUMP
	if held_item == ENUMS.HELD_ITEM.NONE:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	# THROW
	else:
		var other_swordsman := root.get_other_swordsman(swordsman_name)
		var sword: Sword = root.get_sword(held_item)
		
		# Enable relevant collisions
		sword.set_collision_mask_value(ENUMS.COLLISION_LAYER.FLOOR, true)
		sword.set_collision_mask_value(ENUMS.COLLISION_LAYER.SWORDSMAN, true)
		other_swordsman.set_collision_mask_value(sword.collision_layer(), true)
		
		# Update held item
		last_held_item = held_item
		held_item = ENUMS.HELD_ITEM.NONE
		
		# Perform throw
		sword.action(direction)
