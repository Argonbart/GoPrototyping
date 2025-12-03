extends Node2D

@export var top_offset = 0.2
@export var count: int = 8 
@export var canvas: CanvasLayer
@export var color_1: Color
@export var color_2: Color

@export var curve: Curve

func _ready() -> void:
	randomize()
	var wall_cells := generate_maze(50, 50) # 10x8 Zellen (logische Zellen)
	print("Anzahl Wände: ", wall_cells.size())
	# Beispiel: Wände in ein TileMap2D setzen
	for pos in wall_cells:
		(canvas.get_child(0) as TileMapLayer).set_cell(pos, 0, Vector2i.ZERO)  # layer, coords, tile_id


	for i in range(count):
		var dupe = canvas.duplicate(true) as CanvasLayer
		add_child(dupe)
		var scale_factor = (i) * top_offset / count
		dupe.follow_viewport_enabled = true
		dupe.follow_viewport_scale = 1 + scale_factor

		var child = dupe.get_child(0) as Node2D
		var t = i / float(count)
		t = curve.sample(t)
		child.modulate = lerp(color_1, color_2, t)

	canvas.queue_free()


func generate_maze(cell_width: int, cell_height: int) -> Array[Vector2i]:
	# "Logische" Zellengröße -> tatsächliches Tile-Gitter:
	# Jede Zelle = 1 Tile, Wände dazwischen = 1 Tile, plus Rand
	# => (cell_width * 2 + 1) x (cell_height * 2 + 1)
	var maze_width  : int = cell_width * 2 + 1
	var maze_height : int = cell_height * 2 + 1

	# grid[y][x] = 1 -> Wand, 0 -> Weg
	var grid: Array = []
	for y in range(maze_height):
		var row: Array = []
		for x in range(maze_width):
			row.append(1) # alles erstmal Wand
		grid.append(row)

	# Besuchte Zellen (für logische Zellen, NICHT Tiles)
	var visited: Array = []
	for y in range(cell_height):
		var row_v: Array = []
		for x in range(cell_width):
			row_v.append(false)
		visited.append(row_v)

	var dirs := [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	# Startzelle
	var start_cell := Vector2i(0, 0)
	var stack: Array[Vector2i] = []
	stack.append(start_cell)
	visited[start_cell.y][start_cell.x] = true

	# Start-Tile ist Weg
	grid[start_cell.y * 2 + 1][start_cell.x * 2 + 1] = 0

	# DFS / Recursive Backtracker
	while stack.size() > 0:
		var current: Vector2i = stack.back()

		# Nachbarn sammeln, die noch nicht besucht sind
		var neighbors: Array[Vector2i] = []
		for d in dirs:
			var nx: int = current.x + d.x
			var ny: int = current.y + d.y
			if nx >= 0 and nx < cell_width and ny >= 0 and ny < cell_height:
				if not visited[ny][nx]:
					neighbors.append(Vector2i(nx, ny))

		if neighbors.size() == 0:
			# Sackgasse -> backtrack
			stack.pop_back()
			continue

		# zufälligen Nachbarn wählen
		var next: Vector2i = neighbors[randi() % neighbors.size()]
		visited[next.y][next.x] = true
		stack.append(next)

		# Tile-Koordinaten der aktuellen und nächsten Zelle
		var cx: int = current.x * 2 + 1
		var cy: int = current.y * 2 + 1
		var nx_t: int = next.x * 2 + 1
		var ny_t: int = next.y * 2 + 1

		# beide Zellen sind Weg
		grid[cy][cx] = 0
		grid[ny_t][nx_t] = 0

		# Wand dazwischen durchbrechen
		var wx: int = (cx + nx_t) / 2
		var wy: int = (cy + ny_t) / 2
		grid[wy][wx] = 0

	# Am Ende alle Wände als Vector2i einsammeln
	var walls: Array[Vector2i] = []
	for y in range(maze_height):
		for x in range(maze_width):
			if grid[y][x] == 1:
				walls.append(Vector2i(x, y))

	return walls