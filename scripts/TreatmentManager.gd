extends Node2D

# Sequence: Cream -> Gel -> Bandage
var sequence = ["cream", "gel", "bandage"]
var current_step_index = 0

@onready var instruction_label = $CanvasLayer/InstructionLabel
@onready var drop_zone = $DropZone
@onready var items_container = $ItemsContainer

func _ready():
	update_instruction()
	# Connect signals for all draggable items
	for item in items_container.get_children():
		if item.has_signal("item_dropped"):
			item.connect("item_dropped", _on_item_dropped.bind(item))

func update_instruction():
	if current_step_index >= sequence.size():
		instruction_label.text = "Treatment Complete! Well Done!"
		# Here you could show a 'Finish Level' button or effect
		return
		
	var next_item_name = sequence[current_step_index].capitalize()
	instruction_label.text = "Apply %s to the wound." % next_item_name

func _on_item_dropped(item_name: String, drop_pos: Vector2, item_node):
	# check if dropped inside DropZone
	# Simple distance check or Area2D overlap check could work. 
	# Since drop_zone is an Area2D, we can check if the point is inside.
	# But simpler: check distance to drop_zone center.
	var drops = drop_zone.get_overlapping_areas()
	# Because 'item_node' is an Area2D itself, if it overlaps DropZone, it's valid physically.
	
	var is_in_zone = false
	if drop_zone.overlaps_area(item_node):
		is_in_zone = true
	
	if is_in_zone:
		var needed_item = sequence[current_step_index]
		if item_node.name.to_lower() == needed_item:
			# Correct item
			print("Correct item applied: " + item_node.name)
			current_step_index += 1
			item_node.visible = false # Hide used item or play animation
			# Play sound effect here
			update_instruction()
		else:
			# Wrong item
			print("Wrong item! Needed: " + sequence[current_step_index])
			status_feedback("Wrong item! Order matters.")
			item_node.return_to_start()
	else:
		# Dropped in void
		item_node.return_to_start()

func status_feedback(text: String):
	# Temporarily show error message then revert
	var old_text = instruction_label.text
	instruction_label.text = text
	instruction_label.modulate = Color(1, 0, 0) # Red
	await get_tree().create_timer(1.5).timeout
	instruction_label.modulate = Color(1, 1, 1) # White
	update_instruction()
