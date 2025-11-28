class_name SoftBody extends Node2D

@export var number_of_points: int = 10
@export var radius: float = 50.0

@export_range(0.0, 1.0) var CONSTRAINT_STIFFNESS: float = 0.5
@export var CONSTRAINT_SOLVER_STEPS: int = 10
@export var desired_area_multiplier: float = 1.0

@export_range(0.0, 1.0) var slide_scale = 0.8
@export var move_speed: float = 5.0
@export var gravity_scale: float = 1.0

var desired_area: float

var points: Array[SBPoint]
var constraints: Array[SBConstraint]

var input_axis: float
var intends_jump: bool

# debug
var collisions_this_frame: Array[Dictionary]

func _ready() -> void:
	setup(number_of_points, radius, 0.5, CONSTRAINT_STIFFNESS)
	#setup_single_point()


func setup(num_points: int, _radius: float, constraint_length: float, constraint_stiffness: float):
	clear()
	desired_area = _radius * _radius * PI
	var circ = 2 * _radius * PI
	var segment_length = circ / num_points
	for i in range(num_points):
		var angle = 360.0 / num_points * i
		var angle_rad = deg_to_rad(angle)
		var spawn_pos = global_position + Vector2(cos(angle_rad), sin(angle_rad)).normalized() * radius
		var point = SBPoint.new(spawn_pos, 8.0)
		points.append(point)
	for i in range(points.size()):
		var p_a = points[i]
		var p_b = points[(i + 1) % points.size()]
		constraints.append(SBConstraint.new(p_a, p_b, segment_length, constraint_stiffness))


func setup_single_point():
	clear()
	var spawn_pos = global_position
	var point = SBPoint.new(spawn_pos, 8.0)
	points.append(point)


func clear():
	constraints.clear()
	points.clear()


func _process(_delta: float) -> void:
	queue_redraw()
	input_axis = Input.get_axis("left", "right")
	intends_jump = Input.is_action_pressed("jump")


func _physics_process(_delta: float) -> void:
	collisions_this_frame.clear()

	for p in points:
		var temp_pos = p.position

		var velocity = (p.position - p.previous_position) * 0.99

		p.position += velocity
		p.previous_position = temp_pos

		# gravity
		p.accumulate_displacement(Vector2.DOWN * gravity_scale)

		# input
		p.accumulate_displacement(Vector2(input_axis,0) * move_speed)
		if intends_jump: 
			desired_area_multiplier = 5
		else:
			desired_area_multiplier = lerp(desired_area_multiplier, 1.0, 0.01)				

	# --- handle constraints and area constraint ---
	for i in range(CONSTRAINT_SOLVER_STEPS):
		accumulate_constraint_offsets()
		if points.size() > 2: # temporary guard for single points
			accumulate_area_offsets()

		for p in points:
			p.apply_displacement()
			clip_to_geometry(p)


func move_and_slide(p: SBPoint):
	var space_state = get_world_2d().direct_space_state
	
	var move_dir = (p.position - p.previous_position).normalized()
	var query = PhysicsRayQueryParameters2D.create(p.previous_position - move_dir, p.position)
	var result := space_state.intersect_ray(query)

	if result: 
		var n = result.normal.normalized()
		var remaining = p.position - result.position
		var remaining_proj_n = remaining.dot(n) * n
		var slide_pos = p.position - remaining_proj_n
		p.position = lerp(result.position, slide_pos, slide_scale)
		collisions_this_frame.append(result)


func clip_to_geometry(p: SBPoint):
	var space_state = get_world_2d().direct_space_state

	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = p.position
	var results: Array[Dictionary] = space_state.intersect_point(point_query, 8)

	if results.size() == 0:
		return

	var intersected_colliders: Array[RID]

	for r in results:
		intersected_colliders.append(r.rid)

	var total_push: Vector2 = Vector2.ZERO
	var combined_normal: Vector2 = Vector2.ZERO


	var vel = p.position - p.previous_position
	var move_dir = vel.normalized()

	for c in intersected_colliders:
		# get all other intersected colliders for exclude 
		var others = intersected_colliders.filter(func(x): return x != c)
		var ray_query = PhysicsRayQueryParameters2D.new()
		ray_query.from = p.previous_position - move_dir
		ray_query.to = p.position
		ray_query.exclude = others

		var hit = space_state.intersect_ray(ray_query)
		if hit:
			var normal = hit.normal
			var intersection = hit.position
			var depth = ((p.position - intersection).dot(normal))

			if abs(depth) > 0.0:
				total_push += normal * depth
				combined_normal += normal

			collisions_this_frame.append(hit)

	p.position = p.position - total_push

	# sliding
	if combined_normal.length() > 0.0001:
		combined_normal = combined_normal.normalized()

		# tangent = velocity without normal component
		var normal_component = combined_normal * vel.dot(combined_normal)
		var tangent_component = vel - normal_component

		p.position -= tangent_component * (1 - slide_scale)

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

	var factor = (desired_area * desired_area_multiplier - area_accumulator) / circ

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


func _draw() -> void:
	for c in collisions_this_frame:
		var pos = c.position - global_position
		var size = Vector2(5, 5)
		var rect = Rect2(pos - size * 0.5, size)
		draw_rect(rect, Color.RED)

		var normal_target_pos = pos + c.normal * 15
		draw_line(pos, normal_target_pos, Color.YELLOW, 2)