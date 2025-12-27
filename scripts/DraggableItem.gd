extends Area2D

signal item_dropped(item_name, position)

@onready var initial_position = position
var is_dragging = false
var item_name = ""

func setup(name: String, texture: Texture2D):
	item_name = name
	$Sprite2D.texture = texture

func _ready():
	# Ensure the inputs are pickable
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
			else:
				is_dragging = false
				emit_signal("item_dropped", item_name, global_position)
				# Snap back logic will be handled by Manager if drop is invalid,
				# but for visual smoothness we can tween back if not handled.
				
func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position()

func return_to_start():
	var tween = create_tween()
	tween.tween_property(self, "position", initial_position, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
