extends Control


@export var body: SoftBody
@export var label_paused: Control

@export var button_pause: Button
@export var button_reset: Button


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


func handle_pause_button_pressed():
	body.is_paused = !body.is_paused


func handle_reset_button_pressed():
	body.clear()
