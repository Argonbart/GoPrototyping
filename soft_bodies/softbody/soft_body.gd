class_name SoftBody extends Node2D

@export var number_of_points: int = 10
@export var radius: float = 50.0

@export_range(0.0, 1.0) var CONSTRAINT_STIFFNESS: float = 0.5
@export var CONSTRAINT_SOLVER_STEPS: int = 10
@export var desired_area_multiplier: float = 1.0

@export_range(0.0, 1.0) var slide_scale = 0.8

var desired_area = 10000

var points: Array[SBPoint]
var constraints: Array[SBConstraint]

var input_vector: Vector2 

func _ready() -> void:
	setup(number_of_points, desired_area * desired_area_multiplier, 0.5, CONSTRAINT_STIFFNESS)
	# setup_single_point()


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


func setup_single_point():
	clear()
	var spawn_pos = global_position
	var point = SBPoint.new(spawn_pos, 8.0)
	points.append(point)


func clear():
	constraints.clear()
	points.clear()


func _process(delta: float) -> void:
	input_vector = Input.get_vector("left", "right", "up", "down")
	print(input_vector)


func _physics_process(_delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	# --- verlet integration ---
	for p in points:
		var temp_pos = p.position

		var velocity = (p.position - p.previous_position) * 0.99
		
		var next_pos = p.position + velocity

		# collision
		var query = PhysicsRayQueryParameters2D.create(p.position, next_pos)
		var result := space_state.intersect_ray(query)
		if result: 
			# reflect velocity vector on the surface of the collision object using a projection on the normal
			var normal = result.normal 
			var intersection = result.position
			var v_remaining = next_pos - intersection
			# normal should already have unit length so v_proj_n = v * n * n
			# else v_proj_n would be (v * n) / (n * n) * n
			var v_proj_n = v_remaining * normal * normal
			var v_reflected = v_remaining - 2 * v_proj_n			

			p.position = intersection + v_reflected
			p.previous_position = intersection

		# no collision happening
		else:
			p.position += velocity
			p.previous_position = temp_pos

		# gravity
		p.position += Vector2.DOWN

		# input
		p.position += input_vector
	# --- handle constraints and area constraint ---
	for i in range(CONSTRAINT_SOLVER_STEPS):
		accumulate_constraint_offsets()
		if points.size() > 2: # temporary guard for single points
			accumulate_area_offsets()

		for p in points:
			p.apply_displacement()

	for p in points:
		p.limit_to_bounds(get_viewport_rect().size * 0.5)

		# limit to geometry and slide
	for p in points:
		var move_dir = (p.position - p.previous_position).normalized()
		var query = PhysicsRayQueryParameters2D.create(p.previous_position - move_dir, p.position)
		var result := space_state.intersect_ray(query)
		if result: 
			var n = result.normal
			var remaining = p.position - result.position
			var remaining_proj_n = remaining * n * n
			var slide_pos = p.position - remaining_proj_n 
			p.position = lerp(result.position, slide_pos, slide_scale)


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
