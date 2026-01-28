class_name Map
extends TileMapLayer


@export var width: int
@export var height: int

@onready var a_star: AStar2D = AStar2D.new()

var map_dict: Dictionary[Vector2i, int]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var used_cells: Array[Vector2i] = self.get_used_cells()
	for i in used_cells.size():
		map_dict[used_cells[i]] = i
		a_star.add_point(i, self.map_to_local(used_cells[i]))
	for cell in map_dict:
		var walkable: int = self.get_cell_tile_data(cell).get_custom_data("Walkable")
		if walkable == -1:
			continue
		for neighbour in self.get_surrounding_cells(cell):
			if not map_dict.has(neighbour):
				continue
			var n_walkable: int = self.get_cell_tile_data(neighbour).get_custom_data("Walkable")
			if n_walkable == -1:
				continue
			var neighbour_id = map_dict[neighbour]
			a_star.connect_points(map_dict[cell], neighbour_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func get_map_path(from: Vector2i, to: Vector2i) -> PackedVector2Array:
	if not map_dict.has(from) or not map_dict.has(to):
		return []
	var from_id = map_dict[from]
	var to_id = map_dict[to]
	return a_star.get_point_path(from_id, to_id)
