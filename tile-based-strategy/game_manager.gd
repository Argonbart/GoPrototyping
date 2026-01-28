extends Node2D


@export var map: Map

@export_category("UI")
@export var entity_name: RichTextLabel
@export var entity_range: RichTextLabel

var active_entity: Entity


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in self.get_children():
		if child is Entity:
			child.selected.connect(_on_entity_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if not active_entity:
			return
		var click_position = get_global_mouse_position()
		var seleted_cell = map.local_to_map(click_position)
		active_entity.move_to_cell(seleted_cell)


func _on_entity_selected(entity: Entity):
	self.active_entity = entity
	entity_name.text = entity.entity_name
	entity_range.text = str(entity.entity_range)
