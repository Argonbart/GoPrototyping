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

	for p in body.points:
		var color = Color.DARK_OLIVE_GREEN if p.is_highlit else Color.WEB_GRAY
		if p.is_interacted_with:
			color = Color.GREEN
		
		draw_circle(p.position, p.radius, color)

		if p.is_about_to_connect:
			color = Color.POWDER_BLUE
			draw_circle(p.position, p.radius + 2.5, color, false, 5.0, true)