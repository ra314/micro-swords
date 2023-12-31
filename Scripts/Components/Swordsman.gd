extends CharacterBody2D
class_name Swordsman

var rot_deg := 0
var rotating_clockwise := true
var holding_jump := false
var action_name
# Time spent after jumping before being grounded.
var time_in_air := 0.0
@onready var JUMP_VELOCITY = Utils.calc_jump_velocity(ConstData.GRAVITY, ConstData.MAX_JUMP_HEIGHT, ConstData.VARIABLE_JUMP_HEIGHT, ConstData.REDUCED_GRAVITY_WHEN_HOLDING_JUMP, ConstData.MAX_JUMP_HOLD_TIME)

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var direction: ENUMS.DIRECTION
@export var held_item: ENUMS.HELD_ITEM
@export var swordsman_name: ENUMS.SWORDSMAN
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
			$Sprite2D.offset.x = -2
		ENUMS.SWORDSMAN.BLUE:
			name = "Blue"
			position = Vector2(1629-96, 864)
			$Sprite2D.texture = load("res://Assets/dinoCharactersVersion1.1/sheets/DinoSprites - tard.png")
		_:
			assert(false)
	action_name = name.to_upper()
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
	root.get_sword(held_item).last_holder = swordsman_name
	$AnimationPlayer.play("Walk")

func flip_rotation():
	rotating_clockwise = not rotating_clockwise

func rotate_arrow():
	if rotating_clockwise:
		rot_deg += ConstData.ROT_SPEED
	else:
		rot_deg -= ConstData.ROT_SPEED
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
					if rot_deg <= -ConstData.MAX_ROT_RANGE_DEG: flip_rotation()
				ENUMS.DIRECTION.LEFT:
					if rot_deg <= -180: flip_rotation()
				_:
					assert(false)
		_:
			assert(false)
	$Arrow.rotation_degrees = rot_deg

func update_held_sword_location(sword: Sword):
	var new_position = ConstData.DIR_TO_RELATIVE_SWORD_POS[direction]
	$Arrow.global_position = position+new_position
	sword.position = position+new_position

func update_character_x_scale():
	match direction:
		ENUMS.DIRECTION.RIGHT:
			$Sprite2D.flip_h = false
		ENUMS.DIRECTION.LEFT:
			$Sprite2D.flip_h = true
		_:
			assert(false)

func is_still_holding_jump(delta: float) -> bool:
	if not Input.is_action_pressed(action_name):
		# TODO configure separate button to also accept the ui button
		if not root.get_button(swordsman_name).is_pressed():
			return false
	if time_in_air > ConstData.MAX_JUMP_HOLD_TIME:
		return false
	if not ConstData.VARIABLE_JUMP_HEIGHT:
		return false
	return true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		time_in_air += delta
		holding_jump = is_still_holding_jump(delta)
		if holding_jump:
			velocity.y += ConstData.REDUCED_GRAVITY_WHEN_HOLDING_JUMP * delta
		else:
			velocity.y += ConstData.GRAVITY * delta
	else:
		time_in_air = 0
		holding_jump = false
	
	# Handle switching directions
	# Updating sword location
	# And flipping player sprite
	var flipped_direction := false
	if Utils.detect_collision("Walls", self):
		if direction == ENUMS.DIRECTION.RIGHT:
			direction = ENUMS.DIRECTION.LEFT
		else:
			direction = ENUMS.DIRECTION.RIGHT
		flipped_direction = true
	if flipped_direction:
		update_character_x_scale()
		if held_item != ENUMS.HELD_ITEM.NONE:
			update_held_sword_location(root.get_sword(held_item))
	
	# Set velocity based on direction
	if direction == ENUMS.DIRECTION.RIGHT:
		velocity.x = ConstData.SPEED
	else:
		velocity.x = -ConstData.SPEED
	
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
	
	if ConstData.SEPARATE_BUTTONS:
		if Input.is_action_just_pressed(action_name):
			jump()
		if Input.is_action_just_pressed(action_name+str(2)):
			throw()
	else:
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
				pickup_sword(sword)
		ENUMS.SWORD_STATE.THROWN:
			if swordsman_name != sword.last_holder:
				if sword.time_in_air > ConstData.SWORD_THROWN_INVULNERABILITY_TIME:
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
	sword.last_holder = swordsman_name
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
	# Update UI
	root.update_button_icon(held_item, swordsman_name)

func can_jump() -> bool:
	if is_on_floor():
		if ConstData.SEPARATE_BUTTONS:
			return true
		if held_item == ENUMS.HELD_ITEM.NONE:
			return true
	return false

func jump():
	velocity.y = -JUMP_VELOCITY
	holding_jump = true

func can_throw():
	return held_item != ENUMS.HELD_ITEM.NONE

func throw():
	var other_swordsman := root.get_other_swordsman(swordsman_name)
	var sword: Sword = root.get_sword(held_item)
	
	# Enable collision of sword with the ground
	sword.set_collision_mask_value(1, true)
	# Update held item
	held_item = ENUMS.HELD_ITEM.NONE
	
	# Perform throw
	sword.action(direction, rot_deg)
	$Arrow.visible = false
	
	# Update UI
	root.update_button_icon(held_item, swordsman_name)

func action():
	if can_throw():
		return throw()
	elif can_jump():
		return jump()
