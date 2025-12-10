class_name Pool
extends Object


var objects: Array[Object]

var create: Callable
var reset: Callable


func setup(_create: Callable, _reset: Callable, _num_initial_objects: int) -> void:
	self.create = _create
	self.reset = _reset
	
	objects = []
	for i in _num_initial_objects:
		objects.append(create.call())


func request():
	if objects.is_empty():
		return create.call()
	return objects.pop_front()


func refund(object: Object):
	if reset.get_argument_count() == 0:
		push_error("WROOONG")
	reset.call(object)
	objects.append(object)
