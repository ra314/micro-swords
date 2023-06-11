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
		
		if detect_platform_collision():
			print("becoming grounded")
			become_grounded()
		else:
			# Handle switching directions
			if Utils.approx_equal(position.x, 291):
				direction = ENUMS.DIRECTION.RIGHT
			elif Utils.approx_equal(position.x, 1629-16):
				direction = ENUMS.DIRECTION.LEFT
			
			# Set velocity based on direction
			set_velocity_based_on_direction()
			velocity.y += ConstData.GRAVITY * delta
	
	elif state == ENUMS.SWORD_STATE.HELD:
		pass

func detect_platform_collision() -> bool:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		print(collider.name)
		if collider.name.contains("Platforms"):
			return true
	return false

func become_grounded():
	state = ENUMS.SWORD_STATE.GROUNDED
	velocity = Vector2(0,0)

func action(_direction: ENUMS.DIRECTION, rot_deg: int):
	direction = _direction
	assert(state == ENUMS.SWORD_STATE.HELD)
	var new_y = sin(deg_to_rad(abs(rot_deg)))*THROW_SPEED
	hor_speed = abs(cos(deg_to_rad(abs(rot_deg)))*THROW_SPEED)
	velocity.y = -new_y
	set_velocity_based_on_direction()
	state = ENUMS.SWORD_STATE.THROWN

func die():
	queue_free()
