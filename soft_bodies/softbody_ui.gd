extends Control


@export var body: SoftBody
@export var label_paused: Control

@export var button_pause: Button
@export var button_reset: Button

var currently_grabbed_point


func _ready() -> void:
	button_reset.pressed.connect(handle_reset_button_pressed)
	button_pause.pressed.connect(handle_pause_button_pressed)


func _input(event: InputEvent) -> void:
	# -- spawning objects --
	if event.is_action_pressed("1"):
		body.spawn_point(body.get_global_mouse_position())

	if event.is_action_pressed("2"):
		body.spawn_single_constraint(body.get_global_mouse_position())

	if event.is_action_pressed("3"):
		body.spawn_pentagon(body.get_global_mouse_position())

	if event.is_action_pressed("4"):
		body.spawn_pentagon_with_center(body.get_global_mouse_position())

	# -- handling state --
	if event.is_action_pressed("pause"):
		handle_pause_button_pressed()

	if event.is_action_pressed("reset"):
		handle_reset_button_pressed()


func _physics_process(_delta: float) -> void:
	label_paused.visible = true if body.is_paused else false

	# handle mouse dragging
	var mouse_pos: Vector2 = body.get_global_mouse_position()
	var mouse_just_pressed = Input.is_action_just_pressed("interact")
	var mouse_pressed = Input.is_action_pressed("interact")
	var interact_radius = 7.5

	for p in body.points:
		if mouse_pos.distance_to(p.position) < p.radius + interact_radius:
			p.is_highlit = true
			if mouse_just_pressed:
				currently_grabbed_point = p
				p.is_interacted_with = true
			break
		else:
			p.is_highlit = false

	if currently_grabbed_point:
		if not mouse_pressed:
			currently_grabbed_point.is_interacted_with = false
			currently_grabbed_point = null
		else:
			currently_grabbed_point.position = mouse_pos


func handle_pause_button_pressed():
	body.is_paused = !body.is_paused


func handle_reset_button_pressed():
	body.clear()
