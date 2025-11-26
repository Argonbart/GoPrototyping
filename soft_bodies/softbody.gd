class_name SoftBody extends Node2D


class Point:
	var position: Vector2
	var p_position: Vector2
	
	var radius: float

	var displacement_accumulator: Vector2
	var number_of_accumulations: int


	func set_velocity(vel: Vector2):
		p_position = position - vel
		

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
	
	func _init(p: Vector2, r: float) -> void:
		position = p
		p_position = p
		radius = r

 
class Constraint:
	var a: Point
	var b: Point	
	var target_length: float
	var strength: float

	func _init(_a: Point, _b: Point, _l: float, _s: float = 1) -> void:
		a = _a
		b = _b
		target_length = _l
		strength = _s

@export var CONSTRAINT_SOLVER_STEPS: int = 10
@export var CONSTRAINT_STRENGTH: float = 0.2

var points: Array[Point]
var constraints: Array[Constraint]
var is_paused: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var x = randf_range(-50.0, 50.0)
		var y = randf_range(-50, 0)
		for p in points:
			p.set_velocity(Vector2(x, y))


func _ready() -> void:
	spawn_single_constraint()

func clear():
	constraints.clear()
	points.clear()

func spawn_point(pos: Vector2):
	points.append(Point.new(pos, 20))

	
func spawn_single_constraint(pos: Vector2 = Vector2.ZERO):
	var points_to_add = [
	Vector2(-50, -50),      
	Vector2(50, 0),     
	]

	var idx = points.size()
	
	for p in points_to_add:
		points.append(Point.new(pos + p, 20))

	constraints.append(Constraint.new(points[idx], points[idx + 1], 100, 0.2))


func spawn_pentagon_with_center(pos: Vector2 = Vector2.ZERO):
	var points_to_add = [
	Vector2(0, -50),      # obere Spitze
	Vector2(47, -15),     # rechts-oben
	Vector2(29, 40),      # rechts-unten
	Vector2(-29, 40),     # links-unten
	Vector2(-47, -15),    # links-oben
	]
	
	var idx = points.size()

	for p in points_to_add:
		points.append(Point.new(pos + p, 20))

	points.append(Point.new(pos + Vector2.ZERO, 20))

	constraints.append(Constraint.new(points[idx], points[idx + 1], 100.0, CONSTRAINT_STRENGTH))
	constraints.append(Constraint.new(points[idx + 1], points[idx + 2], 100.0, CONSTRAINT_STRENGTH))
	constraints.append(Constraint.new(points[idx + 2], points[idx + 3], 100.0, CONSTRAINT_STRENGTH))
	constraints.append(Constraint.new(points[idx + 3], points[idx + 4], 100.0, CONSTRAINT_STRENGTH))
	constraints.append(Constraint.new(points[idx + 4], points[idx], 100.0, CONSTRAINT_STRENGTH))

	for i in range(5):
		constraints.append(Constraint.new(points[idx + i], points[idx + 5], 100, CONSTRAINT_STRENGTH))


func spawn_pentagon(pos: Vector2 = Vector2.ZERO):
	var points_to_add = [
	Vector2(0, -50),      # obere Spitze
	Vector2(47, -15),     # rechts-oben
	Vector2(29, 40),      # rechts-unten
	Vector2(-29, 40),     # links-unten
	Vector2(-47, -15),    # links-oben
	]
	
	var idx = points.size()

	for p in points_to_add:
		points.append(Point.new(pos + p, 20))

	constraints.append(Constraint.new(points[idx], points[idx + 1], 100.0, CONSTRAINT_STRENGTH))
	constraints.append(Constraint.new(points[idx + 1], points[idx + 2], 100.0, CONSTRAINT_STRENGTH))
	constraints.append(Constraint.new(points[idx + 2], points[idx + 3], 100.0, CONSTRAINT_STRENGTH))
	constraints.append(Constraint.new(points[idx + 3], points[idx + 4], 100.0, CONSTRAINT_STRENGTH))
	constraints.append(Constraint.new(points[idx + 4], points[idx], 100.0, CONSTRAINT_STRENGTH))
	

func _physics_process(_delta: float) -> void:
	if is_paused:
		return

	var bounds = get_viewport_rect().size * 0.5
	
	for p in points:
		var temp_position = p.position
		
		var vel = (p.position - p.p_position) * 0.99
		
		var next_pos = p.position + vel
		if abs(next_pos.x) + p.radius > bounds.x:
			vel.x *= -1
		if abs(next_pos.y) + p.radius > bounds.y:
			vel.y *= -1
		
		p.position += vel
		
		p.p_position = temp_position
		
		# gravity
		p.position += Vector2.DOWN
		
	# handle constraints
	for i in range(CONSTRAINT_SOLVER_STEPS):
		for c in constraints:
			var point_a = c.a
			var point_b = c.b
		
			#if point_a.position.distance_to(point_b.position) < c.target_length:
			#	continue

			var direction = (point_b.position - point_a.position).normalized()
			var midpoint = point_a.position + (point_b.position - point_a.position) * 0.5
		
			var target_a = midpoint - direction * c.target_length * 0.5
			var target_b = midpoint + direction * c.target_length * 0.5 

			var smoothed_target_a = lerp(point_a.position, target_a, c.strength)
			var smoothed_target_b = lerp(point_b.position, target_b, c.strength)

			var offset_a = smoothed_target_a - point_a.position
			var offset_b = smoothed_target_b - point_b.position

			point_a.accumulate_displacement(offset_a)
			point_b.accumulate_displacement(offset_b)

		# applying position accumulations
		for p in points:
			p.apply_displacement()

	# limit points to viewport
	for p in points:		
		p.limit_to_bounds(bounds)
		
