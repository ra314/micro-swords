extends CharacterBody2D
class_name Sword

# Top height for a 90 degree throw should be 5 body heights
const THROW_SPEED = 1700
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var state: ENUMS.SWORD_STATE
@export var sword_name: ENUMS.HELD_ITEM
@export var direction: ENUMS.DIRECTION
var hor_speed: float
var ROTATION_SPEED := 30.0
var root: Root
# This is set to true, when thrown
# Set to false after the first bounce, or after becoming grounded
# The intention is to prevent multiple bounces off the same wall
var can_switch_directions := false

func init(_direction: ENUMS.DIRECTION, _sword_name: ENUMS.HELD_ITEM, _state: ENUMS.SWORD_STATE):
	direction = _direction
	sword_name = _sword_name
	state = _state
	match sword_name:
		ENUMS.HELD_ITEM.SWORD_1:
			name = "Sword1"
		ENUMS.HELD_ITEM.SWORD_2:
			name = "Sword2"
		_:
			assert(false)
	return self

func _ready():
	root = get_parent()

func set_velocity_based_on_direction():
	if direction == ENUMS.DIRECTION.RIGHT:
		velocity.x = hor_speed
	else:
		velocity.x = -hor_speed

func _physics_process(delta):
	if state == ENUMS.SWORD_STATE.THROWN:
		rotation_degrees += ROTATION_SPEED
		# MOVE
		move_and_slide()
		
		if Utils.detect_collision("Platforms", self):
			become_grounded()
		else:
			# Handle switching directions
			if Utils.detect_collision("Walls", self) and can_switch_directions:
				if direction == ENUMS.DIRECTION.RIGHT:
					direction = ENUMS.DIRECTION.LEFT
				else:
					direction = ENUMS.DIRECTION.RIGHT
				can_switch_directions = false
			
			# Set velocity based on direction
			set_velocity_based_on_direction()
			velocity.y += ConstData.GRAVITY * delta
	
	elif state == ENUMS.SWORD_STATE.HELD:
		pass

func become_grounded():
	state = ENUMS.SWORD_STATE.GROUNDED
	velocity = Vector2(0,0)
	can_switch_directions = false

func action(_direction: ENUMS.DIRECTION, rot_deg: int):
	direction = _direction
	assert(state == ENUMS.SWORD_STATE.HELD)
	var new_y = sin(deg_to_rad(abs(rot_deg)))*THROW_SPEED
	hor_speed = abs(cos(deg_to_rad(abs(rot_deg)))*THROW_SPEED)
	velocity.y = -new_y
	set_velocity_based_on_direction()
	state = ENUMS.SWORD_STATE.THROWN
	can_switch_directions = true

func die():
	queue_free()
