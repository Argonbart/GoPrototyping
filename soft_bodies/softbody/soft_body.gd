class_name SoftBody extends Node2D

@export var number_of_points: int = 10
@export var radius: float = 50.0

@export_range(0.0, 1.0) var CONSTRAINT_STIFFNESS: float = 0.5
@export var CONSTRAINT_SOLVER_STEPS: int = 10
@export var desired_area_multiplier: float = 1.0

var desired_area = 10000

var points: Array[SBPoint]
var constraints: Array[SBConstraint]


func _ready() -> void:
	setup(number_of_points, desired_area * desired_area_multiplier, 0.5, CONSTRAINT_STIFFNESS)


func setup(num_points: int, area: float, constraint_length: float, constraint_stiffness: float):
	clear()
	desired_area = area
	for i in range(num_points):
		var angle = 360.0 / num_points * i
		var angle_rad = deg_to_rad(angle)
		var spawn_pos = global_position + Vector2(cos(angle_rad), sin(angle_rad)).normalized() * radius
		var point = SBPoint.new(spawn_pos, 8.0)
		points.append(point)
	for i in range(points.size()):
		var p_a = points[i]
		var p_b = points[(i + 1) % points.size()]
		constraints.append(SBConstraint.new(p_a, p_b, constraint_length, constraint_stiffness))


func clear():
	constraints.clear()
	points.clear()


func _physics_process(_delta: float) -> void:

	# --- verlet integration ---
	for p in points:
		var temp_pos = p.position

		var velocity = (p.position - p.previous_position) * 0.99
		
		var next_pos = p.position + velocity

		# collision
		# ...

		p.position += velocity
		p.previous_position = temp_pos

		# gravity
		p.position += Vector2.DOWN

	# --- handle constraints and area constraint ---
	for i in range(CONSTRAINT_SOLVER_STEPS):
		accumulate_constraint_offsets()
		accumulate_area_offsets()

		for p in points:
			p.apply_displacement()

	for p in points:
		p.limit_to_bounds(get_viewport_rect().size * 0.5)


func accumulate_constraint_offsets():
	for c in constraints:
			var p1 := c.p1
			var p2 := c.p2

			var direction = (p2.position - p1.position).normalized()
			var midpoint = p1.position + (p2.position - p1.position) * 0.5

			var target_1 = midpoint - direction * c.desired_length * 0.5
			var target_2 = midpoint + direction * c.desired_length * 0.5

			var target_1_smoothed = lerp(p1.position, target_1, c.stiffness)
			var target_2_smoothed = lerp(p2.position, target_2, c.stiffness)

			var offset_1 = target_1_smoothed - p1.position
			var offset_2 = target_2_smoothed - p2.position

			p1.accumulate_displacement(offset_1)
			p2.accumulate_displacement(offset_2)


func accumulate_area_offsets():
	var desired_radius_2 = desired_area / PI
	var desired_radius = (sqrt(desired_radius_2))
	var circ = 2 * PI * desired_radius

	var area_accumulator = 0.0

	for i in range(points.size()):
		var next_id = (i + 1) % points.size()
		var p1 = points[i].position
		var p2 = points[next_id].position

		var width = p2.x - p1.x
		var height = (p1.y + p2.y) / 2
		area_accumulator += width * -height

	var factor = (desired_area - area_accumulator) / circ


	for id in range(points.size()):
		var next_id = (id + 1) % points.size()
		var prev_id = (id - 1 + points.size()) % points.size()	
		
		var pos_next = points[next_id].position
		var pos_prev = points[prev_id].position

		var dir = pos_next - pos_prev
		dir = dir.rotated(-PI * 0.5)

		dir = dir.normalized()
		var offset = dir * factor

		points[id].accumulate_displacement(offset)
