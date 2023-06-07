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
