class_name Utils
static func approx_equal(x, y):
	return abs(y-x) < 0.1

static func disconnect_all(_signal: Signal) -> void:
	for connection in _signal.get_connections():
		var callable = connection["callable"]
		_signal.disconnect(callable)

static func select_random(array: Array):
	randomize()
	return array[randi_range(0, array.size()-1)]

static func detect_collision(collider_name: String, object: CharacterBody2D) -> bool:
	for i in object.get_slide_collision_count():
		var collider = object.get_slide_collision(i).get_collider()
		if collider.name.contains(collider_name):
			return true
	return false

static func calc_jump_velocity(gravity: float, max_jump_height: float) -> float:
	# Binary search
	var min := 0.0
	var max := 1000000.0
	var curr = max/2
	var height = calc_max_jump_height(gravity, curr)
	while abs(max_jump_height-height) > 0.1:
		if height > max_jump_height:
			max = curr
			curr = (curr+min)/2.0
		else:
			min = curr
			curr += (curr+max)/2.0
		height = calc_max_jump_height(gravity, curr)
	return curr
	

static func calc_max_jump_height(gravity: float, jump_velocity: float) -> float:
	var velocity := jump_velocity
	var position := 0.0
	var delta := 1.0/Engine.physics_ticks_per_second
	var decrement_per_tick = gravity * delta
	assert(velocity > decrement_per_tick)
	while velocity >= 0:
		position += velocity * delta
		velocity -= gravity * delta
	return position
