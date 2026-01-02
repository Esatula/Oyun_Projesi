extends Node2D

# Visual Progression Textures
@export var tex_cleaned: Texture2D
@export var tex_creamed: Texture2D
@export var tex_bandaged: Texture2D

@onready var injured_sprite = $InjuredPerson

# Sequence: Gel -> Cream -> Bandage
# Identifiers must match the 'id' (item name converted to lower case or specific ID)
var sequence = ["gel", "cream", "bandage"]
var current_step_index = 0

@onready var instruction_label = $CanvasLayer/InstructionLabel
@onready var drop_zone = $DropZone
@onready var items_container = $ItemsContainer

func _ready():
	# Initialize items with names if not already set (assuming setup() is called or properties set in inspector)
	# For this implementation key names are derived from node names or manually set.
	# We rely on node names being mapped or checked against sequence.
	update_instruction()
	# Connect signals for all draggable items
	for item in items_container.get_children():
		# Setup tooltips/names if they are just generic nodes
		if item.name.to_lower() == "gel":
			item.setup("Temizleme Jeli", item.get_node("Sprite2D").texture)
		elif item.name.to_lower() == "cream":
			item.setup("Yanık Kremi", item.get_node("Sprite2D").texture)
		elif item.name.to_lower() == "bandage":
			item.setup("Sargı Bezi", item.get_node("Sprite2D").texture)
			
		if item.has_signal("item_dropped"):
			item.connect("item_dropped", _on_item_dropped.bind(item))

func update_instruction():
	if current_step_index >= sequence.size():
		instruction_label.text = "Tedavi Tamamlandı!"
		instruction_label.modulate = Color(0, 1, 0) # Green
		# Here you could show a 'Finish Level' button or effect
		return
		
	var next_hint = ""
	var current_id = sequence[current_step_index]
	
	match current_id:
		"gel": next_hint = "Yaranın enfeksiyon kapmaması için önce temizlenmesi gerek."
		"cream": next_hint = "Yara temizlendi. Şimdi acıyı dindirmek ve iyileşmeyi hızlandırmak lazım."
		"bandage": next_hint = "Krem sürüldü. Şimdi dış etkenlerden korumak için kapatılması gerek."
	
	instruction_label.text = next_hint

func _on_item_dropped(item_name: String, drop_pos: Vector2, item_node):
	# check if dropped inside DropZone
	var is_in_zone = false
	if drop_zone.overlaps_area(item_node):
		is_in_zone = true
	
	if is_in_zone:
		# Check if correct item
		# We assume item_node.name is "Gel", "Cream", "Bandage" etc.
		var dropped_id = item_node.name.to_lower()
		var needed_id = sequence[current_step_index]
		
		if dropped_id == needed_id:
			# Correct item
			print("Correct item applied: " + item_node.name)
			current_step_index += 1
			item_node.visible = false # Hide used item
			
			# Audio Feedback
			match dropped_id:
				"gel": AudioManager.play_gel()
				"cream": AudioManager.play_cream()
				"bandage": AudioManager.play_bandage()
			
			# Visual Progression
			update_visuals(dropped_id)
			
			update_instruction()
		else:
			# Wrong item
			print("Wrong item! Needed: " + needed_id)
			# AudioManager.play_failure() # If we had one
			status_feedback("Yanlış! Önce diğer malzemeyi kullanmalısın.")
			item_node.return_to_start()
	else:
		# Dropped in void
		item_node.return_to_start()

func update_visuals(step_id: String):
	if injured_sprite == null: return
	
	match step_id:
		"gel":
			if tex_cleaned: injured_sprite.texture = tex_cleaned
		"cream":
			if tex_creamed: injured_sprite.texture = tex_creamed
		"bandage":
			if tex_bandaged: injured_sprite.texture = tex_bandaged

func status_feedback(text: String):
	# Temporarily show error message then revert
	var old_text = instruction_label.text
	instruction_label.text = text
	instruction_label.modulate = Color(1, 0, 0) # Red
	await get_tree().create_timer(2.0).timeout
	if current_step_index < sequence.size():
		instruction_label.modulate = Color(1, 1, 1) # White
		update_instruction()
