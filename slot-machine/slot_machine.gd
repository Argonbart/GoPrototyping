extends Node3D


@export var wheels: Array[Node3D]

var is_spinning: bool = false
var num_symbols: float = 16.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spin()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		spin()


func spin() -> void:
	if is_spinning:
		return
	is_spinning = true
	var counter: float = 0
	for w in wheels:
		counter += .3
		var tween = create_tween()
		tween.tween_property(w, "rotation_degrees:z", 360 / num_symbols * float(randi_range(int(num_symbols), int(num_symbols) * 3)), .5 + counter).as_relative()
	var _timer = get_tree().create_timer(1.4).timeout.connect(check_win)

func check_win():
	is_spinning = false
	if fmod(wheels[0].rotation_degrees.z, 360.0) == fmod(wheels[1].rotation_degrees.z, 360.0) and fmod(wheels[1].rotation_degrees.z, 360.0) == fmod(wheels[2].rotation_degrees.z, 360.0):
		print("WON!")
