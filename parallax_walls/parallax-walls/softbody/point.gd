class_name SBPoint extends Object


var position: Vector2
var previous_position: Vector2

var radius: float

var displacement_accumulator: Vector2
var number_of_accumulations: int

var collision_normal: Vector2 = Vector2.ZERO


func _init(p: Vector2, r: float) -> void:
		position = p
		previous_position = p
		radius = r


func set_velocity(velocity: Vector2):
	previous_position = position - velocity


func accumulate_displacement(displacement: Vector2):
	displacement_accumulator += displacement
	number_of_accumulations += 1


func apply_displacement():
		if number_of_accumulations > 0:
			position += displacement_accumulator / float(number_of_accumulations)
		displacement_accumulator = Vector2.ZERO
		number_of_accumulations = 0


func limit_to_bounds(bounds: Vector2):
	if position.x + radius > bounds.x:
		position.x = bounds.x -radius
	if position.x - radius < -bounds.x:
		position.x = -bounds.x + radius
		
	if position.y + radius > bounds.y:
		position.y = bounds.y  -radius
	if position.y - radius < -bounds.y:
		position.y = -bounds.y + radius	
