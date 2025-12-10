extends CharacterBody2D


@export var health_bar: ProgressBar

const SPEED = 300.0

var health: float = 100.0


func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()
	var collision = get_last_slide_collision()
	if collision:
		health -= 10.0
		health_bar.value = health
