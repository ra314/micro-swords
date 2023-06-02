extends CharacterBody2D
class_name Swordsman

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

const MAX_ROT_RANGE_DEG := 120
const ROT_SPEED := 3
var rot_deg := 0
var rotating_upwards := true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var direction: ENUMS.DIRECTION
@export var held_item: ENUMS.HELD_ITEM
@export var swordsman_name: ENUMS.SWORDSMAN
var last_held_item: ENUMS.HELD_ITEM
var root: Root

func _ready():
	root = get_parent()
	update_arrow_rotation()

func update_arrow_rotation():
	match direction:
		ENUMS.DIRECTION.RIGHT:
			$Arrow.rotation_degrees = -rot_deg
		ENUMS.DIRECTION.LEFT:
			$Arrow.rotation_degrees = -180+rot_deg
		_:
			assert(false)

func rotate_arrow():
	if rotating_upwards:
		rot_deg += ROT_SPEED
	else:
		rot_deg -= ROT_SPEED
	if rot_deg >= 120 or rot_deg <= 0:
		rotating_upwards = not rotating_upwards

func collision_layer():
	return ConstData.SWORDSMAN_TO_COLLISION_LAYER[swordsman_name]

func update_held_sword_location(sword: Sword):
	sword.position = position-ConstData.DIR_TO_RELATIVE_SWORD_POS[direction]

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle switching directions
	if Utils.approx_equal(position.x, 0):
		direction = ENUMS.DIRECTION.RIGHT
		if held_item != ENUMS.HELD_ITEM.NONE:
			update_held_sword_location(root.get_sword(held_item))
		update_arrow_rotation()
	elif Utils.approx_equal(position.x, 1920-64):
		direction = ENUMS.DIRECTION.LEFT
		if held_item != ENUMS.HELD_ITEM.NONE:
			update_held_sword_location(root.get_sword(held_item))
		update_arrow_rotation()
	
	# Set velocity based on direction
	if direction == ENUMS.DIRECTION.RIGHT:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED
	
	if held_item != ENUMS.HELD_ITEM.NONE:
		# Sync sword velocity with swordsman velocity
		root.get_sword(held_item).velocity = velocity
		# Rotate the arrow
		rotate_arrow()
		update_arrow_rotation()
	
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
	root.died(swordsman_name)

func pickup_sword(sword: Sword):
	held_item = sword.sword_name
	update_held_sword_location(sword)
	root.update_collision_between_grounded_swords_and_empty_swordsmen()
	sword.state = ENUMS.SWORD_STATE.HELD
	sword.direction = direction
	$Arrow.visible = true
	match direction:
		ENUMS.DIRECTION.RIGHT:
			$Arrow.rotation_degrees = 0
		ENUMS.DIRECTION.LEFT:
			$Arrow.rotation_degrees = -180
		_:
			assert(false)

func action():
	# JUMP
	if held_item == ENUMS.HELD_ITEM.NONE:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	# THROW
	else:
		var other_swordsman := root.get_other_swordsman(swordsman_name)
		var sword: Sword = root.get_sword(held_item)
		
		# Enable collision with other swordsman
		sword.set_collision_mask_value(other_swordsman.collision_layer(), true)
		# Enable pickup of grounded swords
		root.update_collision_between_grounded_swords_and_empty_swordsmen()
		# Update held item
		last_held_item = held_item
		held_item = ENUMS.HELD_ITEM.NONE
		
		# Perform throw
		sword.action(direction)
		$Arrow.visible = false
