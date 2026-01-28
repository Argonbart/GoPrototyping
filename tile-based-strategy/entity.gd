class_name Entity
extends Node2D


signal selected(entity: Entity)


@export_category("Components")
@export var map: Map

@export_category("Parameters")
@export var entity_name: String
@export var entity_range: int = 4
@export var tween_duration: float = 0.2

var map_position: Vector2i

var is_moving: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_position = map.local_to_map(self.position)
	self.position = map.map_to_local(map_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var click_mouse_position = get_global_mouse_position()
		var click_map_position = map.local_to_map(click_mouse_position)
		if click_map_position == self.map_position:
			selected.emit(self)


func move_to_cell(new_map_position: Vector2i):
	var path: PackedVector2Array = map.get_map_path(map_position, new_map_position)
	if path.size() > 0:
		path.remove_at(0)
	if path.size() > self.entity_range:
		return
	print(path)
	is_moving = true
	for point in path:
		await _move_to_position(point)
		map_position = map.local_to_map(self.position)
	is_moving = false


func _move_to_position(new_position: Vector2) -> Signal:
	var tween = create_tween()
	tween.tween_property(self, "position", new_position, tween_duration)
	return tween.finished
