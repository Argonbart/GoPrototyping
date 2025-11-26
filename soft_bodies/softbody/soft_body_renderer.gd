class_name SoftBodyRenderer extends Node2D


var body: SoftBody

var default_font: Font = ThemeDB.fallback_font


func _ready() -> void:	
	body = get_parent() as SoftBody
		

func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for c in body.constraints:
		var visual_maximal_length = 500.0 # used for color lerping
		var current_length = c.p1.position.distance_to(c.p1.position)
		var t = (current_length - c.desired_length) / visual_maximal_length
		var color = Color.DIM_GRAY.lerp(Color.RED, t)
		draw_line(c.p1.position -global_position, c.p2.position - global_position, color, 10)

	for p in body.points:
		var color = Color.DARK_OLIVE_GREEN 	
		draw_circle(p.position - global_position, p.radius, color)
