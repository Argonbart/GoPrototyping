extends Sprite2D


@onready var move_manager = $"../MoveManager"
@onready var player = $"../Player"

var dir: Vector2 = Vector2(1.0, 0.0)


func _ready():
	move_manager.started_turn.connect(test)


func test(turn: int):
	
	var vec_to_player: Vector2 = (player.position - position).normalized()
	if abs(vec_to_player.x) > abs(vec_to_player.y):
		dir = Vector2(vec_to_player.x, 0.0).normalized()
	else:
		dir = Vector2(0.0, vec_to_player.y).normalized()
	
	if turn % 2 == 0:
		position += dir * 16.0
