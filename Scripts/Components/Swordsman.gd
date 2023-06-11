extends CharacterBody2D
class_name Swordsman

# 4 bodylengths per second
# const SPEED := 64*4
const SPEED := 350
# Max jump height needs to be 3 times character height
const JUMP_VELOCITY := -1500

const MAX_ROT_RANGE_DEG := 120
const ROT_SPEED := 4
var rot_deg := 0
var rotating_clockwise := true

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var direction: ENUMS.DIRECTION
@export var held_item: ENUMS.HELD_ITEM
@export var swordsman_name: ENUMS.SWORDSMAN
var last_held_item: ENUMS.HELD_ITEM
var root: Root

func init(_direction: ENUMS.DIRECTION, _swordsman_name: ENUMS.SWORDSMAN, _held_item: ENUMS.HELD_ITEM):
	direction = _direction
	held_item = _held_item
	swordsman_name = _swordsman_name
	match swordsman_name:
		ENUMS.SWORDSMAN.BLACK:
			name = "Black"
			position = Vector2(291, 864)
			$Sprite2D.texture = load("res://Assets/dinoCharactersVersion1.1/sheets/DinoSprites - mort.png")
		ENUMS.SWORDSMAN.BLUE:
			name = "Blue"
			position = Vector2(1629-96, 864)
			$Sprite2D.texture = load("res://Assets/dinoCharactersVersion1.1/sheets/DinoSprites - tard.png")
		_:
			assert(false)
	match direction:
		ENUMS.DIRECTION.RIGHT:
			rotating_clockwise = false
		ENUMS.DIRECTION.LEFT:
			rot_deg = -180
		_:
			assert(false)
	update_character_x_scale()
	return self

#var debug_orig_y
func _ready():
	root = get_parent()
	scale = Vector2(1.5, 1.5)
	update_held_sword_location(root.get_sword(held_item))
	$AnimationPlayer.play("Walk")
#	debug_orig_y = position.y

func flip_rotation():
	rotating_clockwise = not rotating_clockwise

func rotate_arrow():
	if rotating_clockwise:
		rot_deg += ROT_SPEED
	else:
		rot_deg -= ROT_SPEED
	match rotating_clockwise:
		true:
			match direction:
				ENUMS.DIRECTION.RIGHT:
					if rot_deg >= 0: flip_rotation()
				ENUMS.DIRECTION.LEFT:
					if rot_deg >= -60: flip_rotation()
				_:
					assert(false)
		false:
			match direction:
				ENUMS.DIRECTION.RIGHT:
					if rot_deg <= -120: flip_rotation()
				ENUMS.DIRECTION.LEFT:
					if rot_deg <= -180: flip_rotation()
				_:
					assert(false)
		_:
			assert(false)
	$Arrow.rotation_degrees = rot_deg

func update_held_sword_location(sword: Sword):
	sword.position = position-ConstData.DIR_TO_RELATIVE_SWORD_POS[direction]

func update_character_x_scale():
	match direction:
		ENUMS.DIRECTION.RIGHT:
			$Sprite2D.scale.x = abs($Sprite2D.scale.x)
		ENUMS.DIRECTION.LEFT:
			$Sprite2D.scale.x = abs($Sprite2D.scale.x) * -1
		_:
			assert(false)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += ConstData.GRAVITY * delta
	
	# Handle switching directions
	# Updating sword location
	# And flipping player sprite
	var flipped_direction := false
	if Utils.approx_equal(position.x, 256):
		direction = ENUMS.DIRECTION.RIGHT
		flipped_direction = true
	elif Utils.approx_equal(position.x, 1568):
		direction = ENUMS.DIRECTION.LEFT
		flipped_direction = true
	if flipped_direction:
		update_character_x_scale()
		if held_item != ENUMS.HELD_ITEM.NONE:
			update_held_sword_location(root.get_sword(held_item))
	
	# Set velocity based on direction
	if direction == ENUMS.DIRECTION.RIGHT:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED
	
	if held_item != ENUMS.HELD_ITEM.NONE:
		# Sync sword velocity with swordsman velocity
		update_held_sword_location(root.get_sword(held_item))
		# Rotate the arrow
		rotate_arrow()
	
	# MOVE
	var prev_position = position
	var prev_velocity = velocity
	move_and_slide()
	detect_and_respond_to_sword_collision()
	
	# Use is_action_pressed when no held item, to allow for bunny hopping
	var action_name = ENUMS.SWORDSMAN.keys()[swordsman_name]
	if Input.is_action_just_pressed(action_name):
		action()

func detect_and_respond_to_sword_collision() -> bool:
	var detected := false
	for area in $Area2D.get_overlapping_areas():
		if area.get_parent().name.contains("Sword"):
			respond_to_collision(area.get_parent())
			detected = true
	return detected

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

var dead := false
func die():
	# Used to prevent multiple calls to the die function
	if dead: return
	queue_free()
	if held_item != ENUMS.HELD_ITEM.NONE:
		root.get_sword(held_item).die()
	root.died(swordsman_name)
	dead = true

func pickup_sword(sword: Sword):
	held_item = sword.sword_name
	update_held_sword_location(sword)
	sword.state = ENUMS.SWORD_STATE.HELD
	sword.rotation_degrees = 0
	# Prevent any collisions
	sword.set_collision_mask_value(1, false)
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
		
		# Enable collision of sword with the ground
		sword.set_collision_mask_value(1, true)
		# Update held item
		last_held_item = held_item
		held_item = ENUMS.HELD_ITEM.NONE
		
		# Perform throw
		sword.action(direction, rot_deg)
		$Arrow.visible = false
