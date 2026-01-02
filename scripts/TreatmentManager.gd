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
@onready var dialogue_ui = $CanvasLayer/UI

func _ready():
	# Initial Setup
	for child in items_container.get_children():
		if child.has_method("setup"):
			# Set up specific textures? Or just names?
			# Current DraggableItem setup might use sprite visible in editor
			child.initial_position = child.position
			child.item_name = child.name
			
			# Connect signal
			if !child.is_connected("item_dropped", _on_item_dropped):
				child.connect("item_dropped", _on_item_dropped.bind(child))
				
	update_instruction()
	
	# Initial Visual
	# injured_person.texture = tex_cleaned # Start dirty/burnt actually? 
	# User provided adam_jelli (cleaned), adam_kremli (creamed), adam_bandajli (bandaged).
	# Before any treatment, we probably want the base 'yarali_adam.png' which is set in editor.
	# So no change here.

func update_instruction():
	if current_step_index >= sequence.size():
		instruction_label.visible = false
		run_outro_sequence()
		return
		
	var next_hint = ""
	var current_id = sequence[current_step_index]
	
	match current_id:
		"gel": next_hint = "Adım 1: Temizleme. \nEnfeksiyonu önlemek için yara çevresindeki bakterileri yok etmeliyiz. Antiseptik solüsyon veya jel kullanmalıyız."
		"cream": next_hint = "Adım 2: İyileştirme. \nDeri dokusunun yenilenmesini hızlandırmak ve acıyı azaltmak için yanık kremi uygulamalıyız."
		"bandage": next_hint = "Adım 3: Koruma. \nYaranın dış etkenlerle temasını kesmek ve steril kalması için sargı bezi ile kapatmalıyız."
	
	instruction_label.text = next_hint

func run_outro_sequence():
	# Hide gameplay elements
	items_container.visible = false
	drop_zone.monitoring = false
	
	# Dialogue 1: Injured Person
	dialogue_ui.show_dialogue("Yaralı: \"Çok teşekkür ederim! Elimi kurtardın, acım dindi.\"")
	await dialogue_ui.dialogue_advanced
	AudioManager.play_click()
	
	# Dialogue 2: Doctor (Player)
	dialogue_ui.show_dialogue("Ben: \"Rica ederim. Ben sadece görevimi yaptım. Sakin olmanız önemliydi.\"")
	await dialogue_ui.dialogue_advanced
	AudioManager.play_click()
	
	# Dialogue 3: Injured Person
	dialogue_ui.show_dialogue("Yaralı: \"Sen gerçekten harika bir doktor olacaksın. Bu soğukkanlılığını hiç kaybetme.\"")
	await dialogue_ui.dialogue_advanced
	AudioManager.play_click()
	
	# Demo End
	dialogue_ui.show_dialogue("[DEMO SONU] Oynadığınız için teşekkürler!")
	await dialogue_ui.dialogue_advanced
	AudioManager.play_click()
	
	# Return to Menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

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
