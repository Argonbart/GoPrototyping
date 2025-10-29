extends Node


@onready var player: Sprite2D = $"../Player"
@onready var todog: Sprite2D = $"../todoG"
@onready var james: Sprite2D = $"../JaMeS"
@onready var move_manager = $"../MoveManager"
@onready var game_over_label = $"../GameOverLabel"
@onready var win_label = $"../WinLabel"


func _ready():
	move_manager.started_turn.connect(check_for_end)


func check_for_end(_turn: int):
	if player.position.is_equal_approx(todog.position):
		game_over_label.show()
	if player.position.is_equal_approx(james.position):
		win_label.show()
