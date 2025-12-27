extends Node

# Global state variables
var current_step: int = 0
var has_examined_patient: bool = false
var is_bag_open: bool = false

# Signals to notify other parts of the game
signal tool_selected(tool_name: String)
signal game_over(reason: String)
signal level_completed

func _ready():
	print("GameManager Initialized")

func reset_state():
	current_step = 0
	has_examined_patient = false
	is_bag_open = false

func check_victory_condition(selection: String):
	if selection == "wash_bandage":
		emit_signal("level_completed")
		return true
	else:
		return false
