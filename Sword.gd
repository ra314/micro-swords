extends CharacterBody2D
class_name Sword

# Top height for a 90 degree throw should be 5 body heights
const THROW_SPEED = 1700
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var state: ENUMS.SWORD_STATE
@export var sword_name: ENUMS.HELD_ITEM
var direction: ENUMS.DIRECTION
var hor_speed: float
var root: Root

func _ready():
	root = get_parent()

func collision_layer():
	return ConstData.HELD_ITEM_TO_COLLISION_LAYER[sword_name]

func _physics_process(delta):
	if state == ENUMS.SWORD_STATE.THROWN:
		# MOVE
		move_and_slide()
		detect_swordsman_collision()
		
		if is_on_floor():
			become_grounded()
		else:
			# Handle switching directions
			if Utils.approx_equal(position.x, 488):
				direction = ENUMS.DIRECTION.RIGHT
			elif Utils.approx_equal(position.x, 1920-16):
				direction = ENUMS.DIRECTION.LEFT
			
			# Set velocity based on direction
			if direction == ENUMS.DIRECTION.RIGHT:
				velocity.x = hor_speed
			else:
				velocity.x = -hor_speed
			velocity.y += ConstData.GRAVITY * delta
#			if velocity.y > 0:
#				print("hello")
	
	elif state == ENUMS.SWORD_STATE.HELD:
		pass

func detect_swordsman_collision():
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.name == "Black" or collider.name == "Blue":
			collider.respond_to_collision(self)

func become_grounded():
	state = ENUMS.SWORD_STATE.GROUNDED
	velocity = Vector2(0,0)
	# Swords shouldn't collide into swordsmen, it should be the other way around.
	# Since the sword is stationary after it is grounded. Only the swordsman will
	# be able to detect the collision.
	set_collision_mask_value(ENUMS.COLLISION_LAYER.BLACK, false)
	set_collision_mask_value(ENUMS.COLLISION_LAYER.BLUE, false)
	# Enable collision with swordsman to allow for pickup
	root.update_collision_between_swords_and_swordsmen()

func action(_direction: ENUMS.DIRECTION, rot_deg: int):
	direction = _direction
	assert(state == ENUMS.SWORD_STATE.HELD)
	var new_y = sin(deg_to_rad(rot_deg))*THROW_SPEED
	var new_x = cos(deg_to_rad(rot_deg))*THROW_SPEED
	hor_speed = new_x
	velocity = Vector2(new_x, -new_y)
	if direction == ENUMS.DIRECTION.LEFT:
		velocity.x *= -1
	state = ENUMS.SWORD_STATE.THROWN

func die():
	queue_free()
