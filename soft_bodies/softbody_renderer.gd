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
		var current_length = c.a.position.distance_to(c.b.position)
		var t = (current_length - c.target_length) / visual_maximal_length
		var color = Color.DIM_GRAY.lerp(Color.RED, t)
		draw_line(c.a.position, c.b.position, color, 10)

	for b in body.points:
		draw_circle(b.position, b.radius, Color.WEB_GRAY)