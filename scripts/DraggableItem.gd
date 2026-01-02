extends Area2D

signal item_dropped(item_name, position)

@onready var initial_position = position
var is_dragging = false
var item_name = ""
var tooltip_container: PanelContainer
var tooltip_label: Label

func setup(name: String, texture: Texture2D):
	item_name = name
	$Sprite2D.texture = texture
	if tooltip_label:
		tooltip_label.text = name

func _ready():
	# Ensure the inputs are pickable
	input_pickable = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Create Tooltip Container
	tooltip_container = PanelContainer.new()
	tooltip_container.visible = false
	tooltip_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_container.position = Vector2(-50, -50) # Approximate position above item
	
	# Create StyleBox for the background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7) # Semi-transparent black
	style.set_corner_radius_all(5)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	tooltip_container.add_theme_stylebox_override("panel", style)
	
	add_child(tooltip_container)
	
	# Create Tooltip Label inside container
	tooltip_label = Label.new()
	tooltip_label.text = item_name
	tooltip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip_label.add_theme_color_override("font_color", Color.WHITE)
	tooltip_container.add_child(tooltip_label)

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

func _on_mouse_entered():
	if not is_dragging:
		tooltip_container.visible = true

func _on_mouse_exited():
	tooltip_container.visible = false
