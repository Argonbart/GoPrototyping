extends Sprite2D


@onready var move_manager = $"../MoveManager"

var is_moving: bool = false
var dir: Vector2 = Vector2.ZERO


func _process(_delta):
	
	dir = Input.get_vector("left", "right", "up", "down")
	
	if dir.is_zero_approx():
		is_moving = false
	
	if abs(dir.x + dir.y) != 1.0:
		return
	
	if not is_moving:
		is_moving = true
		position += dir * 16.0
		move_manager.player_moved()
