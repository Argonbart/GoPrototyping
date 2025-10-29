shader_type canvas_item;

void vertex() {
	VERTEX = VERTEX * mat2(vec2(1.0, 0.0), vec2(0.0, -1.0));
}

void fragment() {
	COLOR = COLOR * vec4(1.0, 0.0, 0.0, 1.0);
}
