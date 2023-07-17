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

static func calc_jump_velocity(gravity: float, max_jump_height: float, variable_jump_height_allowed: bool, reduced_gravity: float, reduced_gravity_duration: float) -> float:
	# Binary search
	var min := 0.0
	var max := 1000000.0
	var curr = max/2
	var height = calc_max_jump_height(gravity, curr, variable_jump_height_allowed, reduced_gravity, reduced_gravity_duration)
	while abs(max_jump_height-height) > 0.1:
		if height > max_jump_height:
			max = curr
			curr = (curr+min)/2.0
		else:
			min = curr
			curr += (curr+max)/2.0
		height = calc_max_jump_height(gravity, curr, variable_jump_height_allowed, reduced_gravity, reduced_gravity_duration)
	return curr

static func calc_max_jump_height(gravity: float, jump_velocity: float, variable_jump_height_allowed: bool, reduced_gravity: float, reduced_gravity_duration: float) -> float:
	# Validation
	if variable_jump_height_allowed:
		assert(reduced_gravity >= 0)
		assert(reduced_gravity_duration > 0)
		assert(reduced_gravity < gravity)
	var delta := 1.0/Engine.physics_ticks_per_second
	var decrement_per_tick = gravity * delta
	assert(jump_velocity > decrement_per_tick)
	
	# Logic
	var velocity := jump_velocity
	var position := 0.0
	var time_in_air := 0.0
	while velocity >= 0:
		position += velocity * delta
		if variable_jump_height_allowed and time_in_air < reduced_gravity_duration:
			velocity -= reduced_gravity * delta
		else:
			velocity -= gravity * delta
		time_in_air += delta
	return position
