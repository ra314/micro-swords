extends CharacterBody2D

const THROW_SPEED = 600.0
const THROW_ANGLE = 45 # Measured from the floor
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var state: ENUMS.SWORD_STATE
var direction: ENUMS.DIRECTION
var hor_speed: float

func approx_equal(x, y):
	return abs(y-x) < 0.1

func _physics_process(delta):
	if state == ENUMS.SWORD_STATE.THROWN:
		if is_on_floor():
			state = ENUMS.SWORD_STATE.GROUNDED
			velocity = Vector2(0,0)
		else:
			# Handle switching directions
			if approx_equal(position.x, 0):
				direction = ENUMS.DIRECTION.RIGHT
			elif approx_equal(position.x, 1920-64):
				direction = ENUMS.DIRECTION.LEFT
			
			# Set velocity based on direction
			if direction == ENUMS.DIRECTION.RIGHT:
				velocity.x = hor_speed
			else:
				velocity.x = -hor_speed
			velocity.y += gravity * delta
			move_and_slide()
	elif state == ENUMS.SWORD_STATE.HELD:
		position += (velocity*delta)

func action(_direction: ENUMS.DIRECTION):
	direction = _direction
	assert(state == ENUMS.SWORD_STATE.HELD)
	var new_y = sin(deg_to_rad(THROW_ANGLE))*THROW_SPEED
	var new_x = cos(deg_to_rad(THROW_ANGLE))*THROW_SPEED
	hor_speed = new_x+abs(velocity.x)
	velocity = Vector2(new_x+abs(velocity.x), -new_y)
	if direction == ENUMS.DIRECTION.LEFT:
		velocity.x *= -1
	state = ENUMS.SWORD_STATE.THROWN
