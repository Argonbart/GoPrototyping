extends Node


signal started_turn(turn)

var turn_counter: int = 0


func player_moved():
	turn_counter += 1
	started_turn.emit(turn_counter)
