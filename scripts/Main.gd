extends Node2D

@onready var dialogue_ui = $CanvasLayer/UI
@onready var background = $Background
@onready var injured_person_area = $Areas/InjuredPerson
@onready var medkit_area = $Areas/Medkit

func _ready():
	# Initial State
	dialogue_ui.show_dialogue("Oh no! Someone is hurt in the park! I should help.")
	medkit_area.visible = false # Medkit might be hidden or just not interactable yet

func _on_injured_person_clicked():
	if not GameManager.has_examined_patient:
		GameManager.has_examined_patient = true
		dialogue_ui.show_dialogue("He has a severe burn on his hand. It looks painful. I need my First Aid Kit.")
		medkit_area.visible = true # Now we can see/click the bag
		medkit_area.monitoring = true

func _on_medkit_clicked():
	if GameManager.has_examined_patient:
		GameManager.is_bag_open = true
		dialogue_ui.show_dialogue("I opened the bag. What should I do?")
		# Show options with icons and feedback
		show_medkit_options()

func show_medkit_options():
	var options = [
		{
			"text": "Put butter on it",
			"id": "butter",
			# Using placeholders or generated assets if available. 
			"feedback": "No! Butter traps heat and bacteria. Never put butter on a burn."
		},
		{
			"text": "Cool with water & cover",
			"id": "cool_cover",
			"feedback": "" # Correct answer
		},
		{
			"text": "Shake his hand",
			"id": "shake",
			"feedback": "Ouch! You shouldn't shake a burned hand! You could cause more damage."
		}
	]
	dialogue_ui.show_options(options)

func _on_option_selected(option_id):
	if option_id == "cool_cover":
		dialogue_ui.show_dialogue("Correct! Cooling the burn stops the pain and preventing further damage.")
		# Transition to Treatment Scene
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/Treatment.tscn")
		
	elif option_id == "butter":
		dialogue_ui.show_feedback("No! Butter traps heat and bacteria. Never put butter on a burn.")
		
	elif option_id == "shake":
		dialogue_ui.show_feedback("Ouch! You shouldn't shake a burned hand! You could cause more damage.")

func _on_try_again():
	show_medkit_options()

# Input Event Handlers
func _on_injured_person_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_injured_person_clicked()

func _on_medkit_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_medkit_clicked()
