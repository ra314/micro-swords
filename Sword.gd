extends CharacterBody2D
class_name Sword

const THROW_SPEED = 600.0
const THROW_ANGLE = 45 # Measured from the floor
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var state: ENUMS.SWORD_STATE
@export var sword_name: ENUMS.HELD_ITEM
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
			
			# MOVE
			move_and_slide()
			detect_swordsman_collision()
	
	elif state == ENUMS.SWORD_STATE.HELD:
		position += (velocity*delta)

func detect_swordsman_collision():
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.name == "Black" or collider.name == "Blue":
			collider.respond_to_collision(self)

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
	# Enable collision with the ground
	set_collision_mask_value(ENUMS.COLLISION_LAYER.FLOOR, true)

func die():
	queue_free()
